import 'dotenv/config';
import 'reflect-metadata';
import { DataSource } from 'typeorm';

import { DeviceToken } from '../modules/auth/entities/device-token.entity';
import { Session } from '../modules/auth/entities/session.entity';
import { User } from '../modules/auth/entities/user.entity';
import { GuideArticleEntity } from '../modules/content/entities/guide-article.entity';
import { ImportantPlaceEntity } from '../modules/content/entities/important-place.entity';
import { NotificationCampaignEntity } from '../modules/content/entities/notification-campaign.entity';
import { TaskTemplateEntity } from '../modules/content/entities/task-template.entity';

export default new DataSource({
  type: 'postgres',
  url: process.env.DATABASE_URL,
  entities: [
    User,
    Session,
    DeviceToken,
    GuideArticleEntity,
    TaskTemplateEntity,
    ImportantPlaceEntity,
    NotificationCampaignEntity,
  ],
  migrations: ['src/database/migrations/*.ts'],
  synchronize: false,
});
