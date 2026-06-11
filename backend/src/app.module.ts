import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { ThrottlerModule } from '@nestjs/throttler';
import { TypeOrmModule } from '@nestjs/typeorm';

import configuration from './configuration';
import { AuthModule } from './modules/auth/auth.module';
import { DeviceToken } from './modules/auth/entities/device-token.entity';
import { Session } from './modules/auth/entities/session.entity';
import { User } from './modules/auth/entities/user.entity';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [configuration],
    }),
    ThrottlerModule.forRoot([
      {
        ttl: 60_000,
        limit: 20,
      },
    ]),
    TypeOrmModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        type: 'postgres' as const,
        url: config.get<string>('database.url'),
        autoLoadEntities: true,
        synchronize: false,
        entities: [User, Session, DeviceToken],
      }),
    }),
    AuthModule,
  ],
})
export class AppModule {}
