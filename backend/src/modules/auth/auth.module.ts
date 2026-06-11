import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { TypeOrmModule } from '@nestjs/typeorm';

import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { DevicesController } from './devices.controller';
import { DeviceToken } from './entities/device-token.entity';
import { Session } from './entities/session.entity';
import { User } from './entities/user.entity';
import { JwtStrategy } from './strategies/jwt.strategy';
import { MeController } from './me.controller';
import { EmailService } from '../mail/email.service';

@Module({
  imports: [
    ConfigModule,
    PassportModule.register({ defaultStrategy: 'jwt' }),
    JwtModule.registerAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        secret: config.get<string>('auth.accessSecret'),
      }),
    }),
    TypeOrmModule.forFeature([User, Session, DeviceToken]),
  ],
  controllers: [AuthController, MeController, DevicesController],
  providers: [AuthService, JwtStrategy, EmailService],
  exports: [AuthService],
})
export class AuthModule {}
