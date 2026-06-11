import 'dotenv/config';
import 'reflect-metadata';
import { DataSource } from 'typeorm';

import { DeviceToken } from '../modules/auth/entities/device-token.entity';
import { Session } from '../modules/auth/entities/session.entity';
import { User } from '../modules/auth/entities/user.entity';

export default new DataSource({
  type: 'postgres',
  url: process.env.DATABASE_URL,
  entities: [User, Session, DeviceToken],
  migrations: ['src/database/migrations/*.ts'],
  synchronize: false,
});
