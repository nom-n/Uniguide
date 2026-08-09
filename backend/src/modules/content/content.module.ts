import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';

import { AdminKeyGuard } from './admin-key.guard';
import { AdminContentController } from './admin-content.controller';
import { ContentController } from './content.controller';
import { ContentService } from './content.service';
import { GuideArticleEntity } from './entities/guide-article.entity';
import { ImportantPlaceEntity } from './entities/important-place.entity';
import { NotificationCampaignEntity } from './entities/notification-campaign.entity';
import { TaskTemplateEntity } from './entities/task-template.entity';

@Module({
  imports: [
    ConfigModule,
    TypeOrmModule.forFeature([
      GuideArticleEntity,
      TaskTemplateEntity,
      ImportantPlaceEntity,
      NotificationCampaignEntity,
    ]),
  ],
  controllers: [ContentController, AdminContentController],
  providers: [ContentService, AdminKeyGuard],
  exports: [ContentService],
})
export class ContentModule {}
