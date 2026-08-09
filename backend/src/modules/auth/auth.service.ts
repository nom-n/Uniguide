import {
  BadRequestException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { JwtService } from '@nestjs/jwt';
import * as argon2 from 'argon2';
import { createHash, randomBytes, randomInt } from 'crypto';
import { IsNull, Repository } from 'typeorm';
import type { StringValue } from 'ms';
import { OAuth2Client } from 'google-auth-library';
import * as appleSignin from 'apple-signin-auth';

import { DeviceToken } from './entities/device-token.entity';
import { Session } from './entities/session.entity';
import { User } from './entities/user.entity';
import {
  ForgotPasswordDto,
  LoginDto,
  RefreshDto,
  RegisterDto,
  ResetPasswordDto,
  SendEmailOtpDto,
  SocialLoginDto,
  UpdateProfileDto,
  UpsertFcmTokenDto,
  VerifyEmailDto,
} from './dto/auth.dto';
import { JwtPayload } from './interfaces/jwt-payload.interface';
import { EmailService } from '../mail/email.service';

const MAX_FAILED_LOGIN_ATTEMPTS = 5;
const LOCK_MINUTES = 15;
const EMAIL_VERIFICATION_TTL_MINUTES = 10;
const REGISTRATION_TICKET_TTL_MINUTES = 20;
const PASSWORD_RESET_TTL_MINUTES = 30;

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User) private readonly usersRepo: Repository<User>,
    @InjectRepository(Session) private readonly sessionsRepo: Repository<Session>,
    @InjectRepository(DeviceToken)
    private readonly deviceTokensRepo: Repository<DeviceToken>,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
    private readonly emailService: EmailService,
  ) {}

  async register(dto: RegisterDto, ip?: string, userAgent?: string) {
    const email = dto.email.toLowerCase();
    const existing = await this.usersRepo.findOne({
      where: { email },
    });
    if (
      !existing ||
      !existing.isVerified ||
      !existing.registrationTicketHash ||
      !existing.registrationTicketExpiresAt ||
      existing.registrationTicketExpiresAt.getTime() < Date.now()
    ) {
      throw new BadRequestException('Invalid credentials.');
    }
    const isTicketValid = await argon2.verify(
      existing.registrationTicketHash,
      dto.registrationTicket,
    );
    if (
      !isTicketValid ||
      existing.registrationTicketDigest !==
        this.digestToken(dto.registrationTicket)
    ) {
      throw new BadRequestException('Invalid credentials.');
    }
    if (existing.passwordHash) {
      throw new BadRequestException('Invalid credentials.');
    }

    existing.passwordHash = await argon2.hash(dto.password);
    existing.firstName = dto.firstName.trim();
    existing.lastName = dto.lastName.trim();
    existing.displayName = `${existing.firstName} ${existing.lastName}`.trim();
    existing.profileEmoji = dto.profileEmoji;
    existing.gender = dto.gender;
    existing.birthYear = dto.birthYear;
    existing.authProvider = 'email';
    existing.registrationTicketHash = null;
    existing.registrationTicketDigest = null;
    existing.registrationTicketExpiresAt = null;
    const user = await this.usersRepo.save(existing);
    return this.issueSession(user, ip, userAgent);
  }

  async login(dto: LoginDto, ip?: string, userAgent?: string) {
    const user = await this.usersRepo.findOne({
      where: { email: dto.email.toLowerCase() },
    });
    if (!user) {
      throw new UnauthorizedException('Invalid credentials.');
    }
    if (user.lockedUntil && user.lockedUntil.getTime() > Date.now()) {
      throw new UnauthorizedException('Invalid credentials.');
    }
    if (!user.passwordHash) {
      throw new UnauthorizedException('Invalid credentials.');
    }
    const isValid = await argon2.verify(user.passwordHash, dto.password);
    if (!isValid) {
      await this.recordFailedLogin(user);
      throw new UnauthorizedException('Invalid credentials.');
    }
    if (user.failedLoginAttempts > 0 || user.lockedUntil) {
      user.failedLoginAttempts = 0;
      user.lockedUntil = null;
      await this.usersRepo.save(user);
    }
    return this.issueSession(user, ip, userAgent);
  }

  async refresh(dto: RefreshDto) {
    const payload = await this.verifyRefreshToken(dto.refreshToken);
    const session = await this.sessionsRepo.findOne({
      where: {
        id: payload.sessionId,
        userId: payload.sub,
      },
      relations: ['user'],
    });
    if (!session) {
      throw new UnauthorizedException('Invalid refresh token.');
    }
    const isTokenValid = await argon2.verify(
      session.refreshTokenHash,
      dto.refreshToken,
    );
    if (!isTokenValid) {
      await this.revokeAllSessions(payload.sub);
      throw new UnauthorizedException('Refresh token reuse detected.');
    }
    if (session.revokedAt) {
      await this.revokeAllSessions(payload.sub);
      throw new UnauthorizedException('Refresh token reuse detected.');
    }
    if (session.expiresAt.getTime() < Date.now()) {
      session.revokedAt = new Date();
      await this.sessionsRepo.save(session);
      throw new UnauthorizedException('Refresh token expired.');
    }

    session.revokedAt = new Date();
    await this.sessionsRepo.save(session);
    return this.issueSession(
      session.user,
      session.ip ?? undefined,
      session.deviceInfo ?? undefined,
    );
  }

  async logout(userId: string, refreshToken?: string) {
    if (!refreshToken) return { success: true };
    const payload = await this.verifyRefreshToken(refreshToken);
    if (payload.sub !== userId || !payload.sessionId) {
      return { success: true };
    }
    await this.sessionsRepo.update(
      { id: payload.sessionId, userId, revokedAt: IsNull() },
      { revokedAt: new Date() },
    );
    return { success: true };
  }

  async logoutAll(userId: string) {
    await this.revokeAllSessions(userId);
    return { success: true };
  }

  async me(userId: string) {
    const user = await this.usersRepo.findOne({ where: { id: userId } });
    if (!user) {
      throw new UnauthorizedException('User not found.');
    }
    return { user: this.toSafeUser(user) };
  }

  async updateProfile(userId: string, dto: UpdateProfileDto) {
    const user = await this.usersRepo.findOne({ where: { id: userId } });
    if (!user) {
      throw new UnauthorizedException('User not found.');
    }

    if (dto.firstName !== undefined) {
      user.firstName = dto.firstName.trim() || null;
    }
    if (dto.lastName !== undefined) {
      user.lastName = dto.lastName.trim() || null;
    }
    if (dto.displayName !== undefined) {
      user.displayName = dto.displayName.trim() || null;
    }
    if (dto.profileEmoji !== undefined) {
      user.profileEmoji = dto.profileEmoji.trim() || null;
    }
    if (dto.gender !== undefined) {
      user.gender = dto.gender.trim() || null;
    }
    if (dto.birthYear !== undefined) {
      user.birthYear = dto.birthYear;
    }

    if (dto.displayName === undefined) {
      const fullName = [user.firstName, user.lastName]
        .filter((part): part is string => Boolean(part))
        .join(' ')
        .trim();
      user.displayName = fullName || user.displayName || user.email.split('@')[0];
    }

    const saved = await this.usersRepo.save(user);
    return { user: this.toSafeUser(saved) };
  }

  async sendVerificationEmail(userId: string) {
    const user = await this.usersRepo.findOne({ where: { id: userId } });
    if (!user || user.isVerified) {
      return { message: 'If verification is needed, instructions are sent.' };
    }
    const code = await this.createEmailVerificationOtp(user);
    await this.emailService.sendVerificationCode(user.email, code);
    return {
      message: 'If verification is needed, instructions are sent.',
      ...this.devToken('devEmailVerificationCode', code),
    };
  }

  async sendEmailOtp(dto: SendEmailOtpDto) {
    const email = dto.email.toLowerCase();
    let user = await this.usersRepo.findOne({ where: { email } });
    if (user?.passwordHash) {
      return { message: 'If verification is needed, instructions are sent.' };
    }
    if (!user) {
      user = await this.usersRepo.save(
        this.usersRepo.create({
          email,
          passwordHash: null,
          isVerified: false,
          authProvider: 'email',
        }),
      );
    }
    const code = await this.createEmailVerificationOtp(user);
    await this.emailService.sendVerificationCode(user.email, code);
    return {
      message: 'If verification is needed, instructions are sent.',
      ...this.devToken('devEmailVerificationCode', code),
    };
  }

  async verifyEmail(dto: VerifyEmailDto) {
    const email = dto.email.toLowerCase();
    const code = this.normalizeOtp(dto.code);
    if (code.length !== 6) {
      throw new BadRequestException('Invalid or expired verification code.');
    }
    const user = await this.usersRepo.findOne({ where: { email } });
    if (
      !user ||
      !user.emailVerificationTokenHash ||
      user.emailVerificationTokenDigest !==
        this.digestToken(`${email}:${code}`) ||
      !user.emailVerificationExpiresAt ||
      user.emailVerificationExpiresAt.getTime() < Date.now()
    ) {
      throw new BadRequestException('Invalid or expired verification code.');
    }
    const isValid = await argon2.verify(
      user.emailVerificationTokenHash,
      code,
    );
    if (!isValid) {
      throw new BadRequestException('Invalid or expired verification code.');
    }
    user.isVerified = true;
    user.emailVerificationTokenHash = null;
    user.emailVerificationTokenDigest = null;
    user.emailVerificationExpiresAt = null;
    const registrationTicket = await this.createRegistrationTicket(user);
    await this.usersRepo.save(user);
    return { success: true, registrationTicket };
  }

  async loginWithGoogle(dto: SocialLoginDto, ip?: string, userAgent?: string) {
    const clientId = this.configService.get<string>('oauth.googleClientId');
    if (!clientId) {
      throw new BadRequestException('Google sign-in is not configured.');
    }
    const client = new OAuth2Client(clientId);
    const ticket = await client.verifyIdToken({
      idToken: dto.idToken,
      audience: clientId,
    });
    const payload = ticket.getPayload();
    if (!payload?.email || !payload.sub) {
      throw new UnauthorizedException('Invalid Google token.');
    }
    const user = await this.upsertSocialUser({
      email: payload.email,
      provider: 'google',
      subject: payload.sub,
      firstName: dto.firstName ?? payload.given_name,
      lastName: dto.lastName ?? payload.family_name,
      profileEmoji: dto.profileEmoji,
      gender: dto.gender,
      birthYear: dto.birthYear,
    });
    return this.issueSession(user, ip, userAgent);
  }

  async loginWithApple(dto: SocialLoginDto, ip?: string, userAgent?: string) {
    const clientId = this.configService.get<string>('oauth.appleClientId');
    if (!clientId) {
      throw new BadRequestException('Apple sign-in is not configured.');
    }
    const payload = await appleSignin.verifyIdToken(dto.idToken, {
      audience: clientId,
      ignoreExpiration: false,
    });
    if (!payload?.email || !payload.sub) {
      throw new UnauthorizedException('Invalid Apple token.');
    }
    const user = await this.upsertSocialUser({
      email: payload.email,
      provider: 'apple',
      subject: payload.sub,
      firstName: dto.firstName,
      lastName: dto.lastName,
      profileEmoji: dto.profileEmoji,
      gender: dto.gender,
      birthYear: dto.birthYear,
    });
    return this.issueSession(user, ip, userAgent);
  }

  async forgotPassword(dto: ForgotPasswordDto) {
    const user = await this.usersRepo.findOne({
      where: { email: dto.email.toLowerCase() },
    });
    const token = user ? await this.createPasswordResetToken(user) : null;
    return {
      message: 'If account exists, reset instructions are sent.',
      ...this.devToken('devResetToken', token),
    };
  }

  async resetPassword(dto: ResetPasswordDto) {
    const user = await this.findUserByTokenDigest(
      dto.token,
      'passwordResetTokenDigest',
    );
    if (
      !user ||
      !user.passwordResetTokenHash ||
      !user.passwordResetExpiresAt ||
      user.passwordResetExpiresAt.getTime() < Date.now()
    ) {
      throw new BadRequestException('Invalid or expired reset token.');
    }
    const isValid = await argon2.verify(user.passwordResetTokenHash, dto.token);
    if (!isValid) {
      throw new BadRequestException('Invalid or expired reset token.');
    }
    user.passwordHash = await argon2.hash(dto.newPassword);
    user.passwordResetTokenHash = null;
    user.passwordResetTokenDigest = null;
    user.passwordResetExpiresAt = null;
    user.failedLoginAttempts = 0;
    user.lockedUntil = null;
    await this.usersRepo.save(user);
    await this.revokeAllSessions(user.id);
    return { message: 'Password reset completed if token is valid.' };
  }

  async upsertDeviceToken(userId: string, dto: UpsertFcmTokenDto) {
    const existing = await this.deviceTokensRepo.findOne({
      where: { fcmToken: dto.fcmToken },
    });
    if (existing) {
      existing.lastSeenAt = new Date();
      existing.userId = userId;
      existing.platform = dto.platform;
      await this.deviceTokensRepo.save(existing);
      return { success: true };
    }
    await this.deviceTokensRepo.save(
      this.deviceTokensRepo.create({
        userId,
        fcmToken: dto.fcmToken,
        platform: dto.platform,
      }),
    );
    return { success: true };
  }

  private async issueSession(user: User, ip?: string, userAgent?: string) {
    const sessionExpiry = new Date();
    const refreshTtlDays =
      this.configService.get<number>('auth.refreshTtlDays') ?? 14;
    sessionExpiry.setDate(sessionExpiry.getDate() + refreshTtlDays);

    const session = await this.sessionsRepo.save(
      this.sessionsRepo.create({
        userId: user.id,
        ip: ip ?? null,
        deviceInfo: userAgent ?? null,
        refreshTokenHash: 'pending',
        expiresAt: sessionExpiry,
      }),
    );

    const payload: JwtPayload = {
      sub: user.id,
      email: user.email,
      sessionId: session.id,
    };

    const accessToken = await this.jwtService.signAsync(payload, {
      secret: this.configService.get<string>('auth.accessSecret'),
      expiresIn: (this.configService.get<string>('auth.accessTtl') ??
        '15m') as StringValue,
    });
    const refreshToken = await this.jwtService.signAsync(payload, {
      secret: this.configService.get<string>('auth.refreshSecret'),
      expiresIn: `${refreshTtlDays}d` as StringValue,
    });

    session.refreshTokenHash = await argon2.hash(refreshToken);
    await this.sessionsRepo.save(session);

    return {
      accessToken,
      refreshToken,
      user: this.toSafeUser(user),
    };
  }

  private async verifyRefreshToken(refreshToken: string): Promise<JwtPayload> {
    try {
      return await this.jwtService.verifyAsync<JwtPayload>(refreshToken, {
        secret: this.configService.get<string>('auth.refreshSecret'),
      });
    } catch {
      throw new UnauthorizedException('Invalid refresh token.');
    }
  }

  private async recordFailedLogin(user: User) {
    user.failedLoginAttempts += 1;
    if (user.failedLoginAttempts >= MAX_FAILED_LOGIN_ATTEMPTS) {
      const lockedUntil = new Date();
      lockedUntil.setMinutes(lockedUntil.getMinutes() + LOCK_MINUTES);
      user.lockedUntil = lockedUntil;
    }
    await this.usersRepo.save(user);
  }

  private async revokeAllSessions(userId: string) {
    await this.sessionsRepo
      .createQueryBuilder()
      .update(Session)
      .set({ revokedAt: new Date() })
      .where('user_id = :userId', { userId })
      .andWhere('revoked_at IS NULL')
      .execute();
  }

  private async upsertSocialUser(input: {
    email: string;
    provider: 'google' | 'apple';
    subject: string;
    firstName?: string;
    lastName?: string;
    profileEmoji?: string;
    gender?: string;
    birthYear?: number;
  }): Promise<User> {
    const email = input.email.toLowerCase();
    let user = await this.usersRepo.findOne({
      where: { authProvider: input.provider, providerSubject: input.subject },
    });
    user ??= await this.usersRepo.findOne({ where: { email } });

    const firstName = input.firstName?.trim() || user?.firstName || null;
    const lastName = input.lastName?.trim() || user?.lastName || null;

    if (!user) {
      user = this.usersRepo.create({
        email,
        passwordHash: null,
        isVerified: true,
      });
    }

    user.email = email;
    user.isVerified = true;
    user.authProvider = input.provider;
    user.providerSubject = input.subject;
    user.firstName = firstName;
    user.lastName = lastName;
    const fullName = [firstName, lastName]
      .filter((part): part is string => Boolean(part))
      .join(' ');
    user.displayName = fullName || user.displayName || email.split('@')[0];
    user.profileEmoji = input.profileEmoji ?? user.profileEmoji ?? '🙂';
    user.gender = input.gender ?? user.gender;
    user.birthYear = input.birthYear ?? user.birthYear;
    return this.usersRepo.save(user);
  }

  private async createEmailVerificationOtp(user: User): Promise<string> {
    const code = this.generateOtpCode();
    user.emailVerificationTokenHash = await argon2.hash(code);
    user.emailVerificationTokenDigest = this.digestToken(
      `${user.email}:${code}`,
    );
    user.emailVerificationExpiresAt = this.minutesFromNow(
      EMAIL_VERIFICATION_TTL_MINUTES,
    );
    await this.usersRepo.save(user);
    return code;
  }

  private async createRegistrationTicket(user: User): Promise<string> {
    const ticket = this.generateOpaqueToken();
    user.registrationTicketHash = await argon2.hash(ticket);
    user.registrationTicketDigest = this.digestToken(ticket);
    user.registrationTicketExpiresAt = this.minutesFromNow(
      REGISTRATION_TICKET_TTL_MINUTES,
    );
    return ticket;
  }

  private async createPasswordResetToken(user: User): Promise<string> {
    const token = this.generateOpaqueToken();
    user.passwordResetTokenHash = await argon2.hash(token);
    user.passwordResetTokenDigest = this.digestToken(token);
    user.passwordResetExpiresAt = this.minutesFromNow(PASSWORD_RESET_TTL_MINUTES);
    await this.usersRepo.save(user);
    return token;
  }

  private async findUserByTokenDigest(
    token: string,
    digestColumn: 'emailVerificationTokenDigest' | 'passwordResetTokenDigest',
  ) {
    return this.usersRepo.findOne({
      where: { [digestColumn]: this.digestToken(token) },
    });
  }

  private generateOpaqueToken(): string {
    return randomBytes(32).toString('base64url');
  }

  private generateOtpCode(): string {
    return randomInt(0, 1_000_000).toString().padStart(6, '0');
  }

  private normalizeOtp(code: string): string {
    return code.replace(/\D/g, '');
  }

  private digestToken(token: string): string {
    return createHash('sha256').update(token).digest('hex');
  }

  private minutesFromNow(minutes: number): Date {
    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + minutes);
    return expiresAt;
  }

  private devToken(key: string, token: string | null) {
    const env = this.configService.get<string>('app.env');
    if (!token || env === 'production') return {};
    return { [key]: token };
  }

  private toSafeUser(user: User) {
    return {
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      firstName: user.firstName,
      lastName: user.lastName,
      profileEmoji: user.profileEmoji,
      gender: user.gender,
      birthYear: user.birthYear,
      authProvider: user.authProvider,
      isVerified: user.isVerified,
    };
  }
}
