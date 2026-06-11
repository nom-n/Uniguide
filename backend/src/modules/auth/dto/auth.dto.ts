import { ApiProperty } from '@nestjs/swagger';
import {
  IsEmail,
  IsNotEmpty,
  IsOptional,
  IsString,
  Matches,
  IsInt,
  Max,
  MinLength,
  Min,
} from 'class-validator';
import { Type } from 'class-transformer';

export class RegisterDto {
  @ApiProperty()
  @IsEmail()
  email!: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  firstName!: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  lastName!: string;

  @ApiProperty()
  @IsString()
  @MinLength(8)
  password!: string;

  @ApiProperty({ example: '🙂' })
  @IsString()
  @IsNotEmpty()
  profileEmoji!: string;

  @ApiProperty({ example: 'male' })
  @IsString()
  @IsNotEmpty()
  gender!: string;

  @ApiProperty({ example: 2001 })
  @Type(() => Number)
  @IsInt()
  @Min(1920)
  @Max(2026)
  birthYear!: number;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  registrationTicket!: string;
}

export class LoginDto {
  @ApiProperty()
  @IsEmail()
  email!: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  password!: string;
}

export class RefreshDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  refreshToken!: string;
}

export class ForgotPasswordDto {
  @ApiProperty()
  @IsEmail()
  email!: string;
}

export class ResetPasswordDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  token!: string;

  @ApiProperty()
  @IsString()
  @MinLength(8)
  newPassword!: string;
}

export class VerifyEmailDto {
  @ApiProperty()
  @IsEmail()
  email!: string;

  @ApiProperty({ example: '123456' })
  @IsString()
  @IsNotEmpty()
  @Matches(/^\d{6}$/)
  code!: string;
}

export class SendEmailOtpDto {
  @ApiProperty()
  @IsEmail()
  email!: string;
}

export class SocialLoginDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  idToken!: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  firstName?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  lastName?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  profileEmoji?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  gender?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1920)
  @Max(2026)
  birthYear?: number;
}

export class LogoutDto {
  @ApiProperty()
  @IsOptional()
  @IsString()
  refreshToken?: string;
}

export class UpsertFcmTokenDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  fcmToken!: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  platform!: string;
}
