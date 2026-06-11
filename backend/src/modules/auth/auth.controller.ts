import { Body, Controller, Headers, Ip, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';

import { CurrentUser } from './decorators/current-user.decorator';
import {
  ForgotPasswordDto,
  LoginDto,
  LogoutDto,
  RefreshDto,
  RegisterDto,
  ResetPasswordDto,
  SendEmailOtpDto,
  SocialLoginDto,
  VerifyEmailDto,
} from './dto/auth.dto';
import { User } from './entities/user.entity';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { AuthService } from './auth.service';

@ApiTags('Auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  @Throttle({ default: { limit: 5, ttl: 60_000 } })
  register(
    @Body() dto: RegisterDto,
    @Ip() ip: string,
    @Headers('user-agent') userAgent?: string,
  ) {
    return this.authService.register(dto, ip, userAgent);
  }

  @Post('login')
  @Throttle({ default: { limit: 8, ttl: 60_000 } })
  login(
    @Body() dto: LoginDto,
    @Ip() ip: string,
    @Headers('user-agent') userAgent?: string,
  ) {
    return this.authService.login(dto, ip, userAgent);
  }

  @Post('refresh')
  @Throttle({ default: { limit: 12, ttl: 60_000 } })
  refresh(@Body() dto: RefreshDto) {
    return this.authService.refresh(dto);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Post('logout')
  logout(@CurrentUser() user: User, @Body() dto: LogoutDto) {
    return this.authService.logout(user.id, dto.refreshToken);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Post('logout-all')
  logoutAll(@CurrentUser() user: User) {
    return this.authService.logoutAll(user.id);
  }

  @Post('forgot-password')
  @Throttle({ default: { limit: 5, ttl: 60_000 } })
  forgotPassword(@Body() dto: ForgotPasswordDto) {
    return this.authService.forgotPassword(dto);
  }

  @Post('reset-password')
  @Throttle({ default: { limit: 5, ttl: 60_000 } })
  resetPassword(@Body() dto: ResetPasswordDto) {
    return this.authService.resetPassword(dto);
  }

  @Post('email-otp/send')
  @Throttle({ default: { limit: 5, ttl: 60_000 } })
  sendEmailOtp(@Body() dto: SendEmailOtpDto) {
    return this.authService.sendEmailOtp(dto);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Post('verify-email/send')
  @Throttle({ default: { limit: 3, ttl: 60_000 } })
  sendVerificationEmail(@CurrentUser() user: User) {
    return this.authService.sendVerificationEmail(user.id);
  }

  @Post('verify-email')
  @Throttle({ default: { limit: 8, ttl: 60_000 } })
  verifyEmail(@Body() dto: VerifyEmailDto) {
    return this.authService.verifyEmail(dto);
  }

  @Post('google')
  @Throttle({ default: { limit: 8, ttl: 60_000 } })
  google(
    @Body() dto: SocialLoginDto,
    @Ip() ip: string,
    @Headers('user-agent') userAgent?: string,
  ) {
    return this.authService.loginWithGoogle(dto, ip, userAgent);
  }

  @Post('apple')
  @Throttle({ default: { limit: 8, ttl: 60_000 } })
  apple(
    @Body() dto: SocialLoginDto,
    @Ip() ip: string,
    @Headers('user-agent') userAgent?: string,
  ) {
    return this.authService.loginWithApple(dto, ip, userAgent);
  }
}
