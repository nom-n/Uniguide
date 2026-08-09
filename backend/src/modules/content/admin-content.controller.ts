import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiHeader, ApiTags } from '@nestjs/swagger';

import { AdminKeyGuard } from './admin-key.guard';
import {
  ContentLocaleQueryDto,
  UpsertGuideArticleDto,
  UpsertImportantPlaceDto,
  UpsertNotificationCampaignDto,
  UpsertTaskTemplateDto,
} from './dto/content.dto';
import { ContentService } from './content.service';

@ApiTags('Admin Content')
@ApiHeader({ name: 'x-admin-key', required: true })
@UseGuards(AdminKeyGuard)
@Controller('admin')
export class AdminContentController {
  constructor(private readonly contentService: ContentService) {}

  @Get('guides')
  listGuides(@Query() query: ContentLocaleQueryDto) {
    return this.contentService.listGuides(query.locale);
  }

  @Post('guides')
  createGuide(@Body() dto: UpsertGuideArticleDto) {
    return this.contentService.createGuide(dto);
  }

  @Patch('guides/:id')
  updateGuide(@Param('id') id: string, @Body() dto: Partial<UpsertGuideArticleDto>) {
    return this.contentService.updateGuide(id, dto);
  }

  @Delete('guides/:id')
  deleteGuide(@Param('id') id: string) {
    return this.contentService.deleteGuide(id);
  }

  @Get('tasks')
  listTasks(@Query() query: ContentLocaleQueryDto) {
    return this.contentService.listTasks(query.locale);
  }

  @Post('tasks')
  createTask(@Body() dto: UpsertTaskTemplateDto) {
    return this.contentService.createTask(dto);
  }

  @Patch('tasks/:id')
  updateTask(@Param('id') id: string, @Body() dto: Partial<UpsertTaskTemplateDto>) {
    return this.contentService.updateTask(id, dto);
  }

  @Delete('tasks/:id')
  deleteTask(@Param('id') id: string) {
    return this.contentService.deleteTask(id);
  }

  @Get('places')
  listPlaces(@Query() query: ContentLocaleQueryDto) {
    return this.contentService.listPlaces(query.locale);
  }

  @Post('places')
  createPlace(@Body() dto: UpsertImportantPlaceDto) {
    return this.contentService.createPlace(dto);
  }

  @Patch('places/:id')
  updatePlace(@Param('id') id: string, @Body() dto: Partial<UpsertImportantPlaceDto>) {
    return this.contentService.updatePlace(id, dto);
  }

  @Delete('places/:id')
  deletePlace(@Param('id') id: string) {
    return this.contentService.deletePlace(id);
  }

  @Get('notifications')
  listCampaigns() {
    return this.contentService.listCampaigns();
  }

  @Post('notifications')
  createCampaign(@Body() dto: UpsertNotificationCampaignDto) {
    return this.contentService.createCampaign(dto);
  }

  @Patch('notifications/:id')
  updateCampaign(@Param('id') id: string, @Body() dto: Partial<UpsertNotificationCampaignDto>) {
    return this.contentService.updateCampaign(id, dto);
  }

  @Post('notifications/:id/send')
  sendCampaign(@Param('id') id: string) {
    return this.contentService.sendCampaign(id);
  }

  @Delete('notifications/:id')
  deleteCampaign(@Param('id') id: string) {
    return this.contentService.deleteCampaign(id);
  }
}
