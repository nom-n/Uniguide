import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, IsNull, Repository } from 'typeorm';

import { GuideArticleEntity } from './entities/guide-article.entity';
import { ImportantPlaceEntity } from './entities/important-place.entity';
import { NotificationCampaignEntity } from './entities/notification-campaign.entity';
import { TaskTemplateEntity } from './entities/task-template.entity';
import {
  UpsertGuideArticleDto,
  UpsertImportantPlaceDto,
  UpsertNotificationCampaignDto,
  UpsertTaskTemplateDto,
} from './dto/content.dto';

@Injectable()
export class ContentService {
  constructor(
    @InjectRepository(GuideArticleEntity)
    private readonly guidesRepo: Repository<GuideArticleEntity>,
    @InjectRepository(TaskTemplateEntity)
    private readonly tasksRepo: Repository<TaskTemplateEntity>,
    @InjectRepository(ImportantPlaceEntity)
    private readonly placesRepo: Repository<ImportantPlaceEntity>,
    @InjectRepository(NotificationCampaignEntity)
    private readonly campaignsRepo: Repository<NotificationCampaignEntity>,
  ) {}

  async snapshot(locale?: string) {
    const locales = locale ? [locale] : await this.getLocales();
    const [guides, tasks, places, campaigns] = await Promise.all([
      this.guidesRepo.find({
        where: { locale: In(locales), isActive: true },
        order: { sortOrder: 'ASC', createdAt: 'ASC' },
      }),
      this.tasksRepo.find({
        where: { locale: In(locales), isActive: true },
        order: { sortOrder: 'ASC', createdAt: 'ASC' },
      }),
      this.placesRepo.find({
        where: { locale: In(locales), isActive: true },
        order: { sortOrder: 'ASC', createdAt: 'ASC' },
      }),
      this.campaignsRepo.find({
        where: [{ locale: In(locales) }, { locale: IsNull() }],
        order: { createdAt: 'DESC' },
      }),
    ]);

    return {
      locales,
      guides: guides.map((item) => this.toGuide(item)),
      tasks: tasks.map((item) => this.toTask(item)),
      places: places.map((item) => this.toPlace(item)),
      campaigns: campaigns.map((item) => this.toCampaign(item)),
    };
  }

  async listGuides(locale?: string) {
    return this.guidesRepo.find({
      where: locale ? { locale } : undefined,
      order: { sortOrder: 'ASC', createdAt: 'ASC' },
    });
  }

  async createGuide(dto: UpsertGuideArticleDto) {
    const item = this.guidesRepo.create({
      ...dto,
      iconFontFamily: dto.iconFontFamily ?? null,
      iconFontPackage: dto.iconFontPackage ?? null,
      tags: dto.tags ?? [],
      steps: dto.steps ?? [],
      isActive: dto.isActive ?? true,
      sortOrder: dto.sortOrder ?? 0,
    });
    return this.guidesRepo.save(item);
  }

  async updateGuide(id: string, dto: Partial<UpsertGuideArticleDto>) {
    const item = await this.guidesRepo.findOne({ where: { id } });
    if (!item) throw new NotFoundException('Guide not found.');
    Object.assign(item, {
      ...dto,
      iconFontFamily: dto.iconFontFamily ?? item.iconFontFamily,
      iconFontPackage: dto.iconFontPackage ?? item.iconFontPackage,
      tags: dto.tags ?? item.tags,
      steps: dto.steps ?? item.steps,
      isActive: dto.isActive ?? item.isActive,
      sortOrder: dto.sortOrder ?? item.sortOrder,
    });
    return this.guidesRepo.save(item);
  }

  async deleteGuide(id: string) {
    const result = await this.guidesRepo.delete(id);
    if (!result.affected) throw new NotFoundException('Guide not found.');
    return { success: true };
  }

  async listTasks(locale?: string) {
    return this.tasksRepo.find({
      where: locale ? { locale } : undefined,
      order: { sortOrder: 'ASC', createdAt: 'ASC' },
    });
  }

  async createTask(dto: UpsertTaskTemplateDto) {
    const item = this.tasksRepo.create({
      ...dto,
      isActive: dto.isActive ?? true,
      sortOrder: dto.sortOrder ?? 0,
    });
    return this.tasksRepo.save(item);
  }

  async updateTask(id: string, dto: Partial<UpsertTaskTemplateDto>) {
    const item = await this.tasksRepo.findOne({ where: { id } });
    if (!item) throw new NotFoundException('Task not found.');
    Object.assign(item, {
      ...dto,
      isActive: dto.isActive ?? item.isActive,
      sortOrder: dto.sortOrder ?? item.sortOrder,
    });
    return this.tasksRepo.save(item);
  }

  async deleteTask(id: string) {
    const result = await this.tasksRepo.delete(id);
    if (!result.affected) throw new NotFoundException('Task not found.');
    return { success: true };
  }

  async listPlaces(locale?: string) {
    return this.placesRepo.find({
      where: locale ? { locale } : undefined,
      order: { sortOrder: 'ASC', createdAt: 'ASC' },
    });
  }

  async createPlace(dto: UpsertImportantPlaceDto) {
    const item = this.placesRepo.create({
      ...dto,
      isActive: dto.isActive ?? true,
      sortOrder: dto.sortOrder ?? 0,
    });
    return this.placesRepo.save(item);
  }

  async updatePlace(id: string, dto: Partial<UpsertImportantPlaceDto>) {
    const item = await this.placesRepo.findOne({ where: { id } });
    if (!item) throw new NotFoundException('Place not found.');
    Object.assign(item, {
      ...dto,
      isActive: dto.isActive ?? item.isActive,
      sortOrder: dto.sortOrder ?? item.sortOrder,
    });
    return this.placesRepo.save(item);
  }

  async deletePlace(id: string) {
    const result = await this.placesRepo.delete(id);
    if (!result.affected) throw new NotFoundException('Place not found.');
    return { success: true };
  }

  async listCampaigns() {
    return this.campaignsRepo.find({ order: { createdAt: 'DESC' } });
  }

  async createCampaign(dto: UpsertNotificationCampaignDto) {
    const item = this.campaignsRepo.create({
      locale: dto.locale ?? null,
      title: dto.title,
      body: dto.body,
      audience: dto.audience ?? 'all',
      status: dto.status ?? 'draft',
      sendAt: dto.sendAt ? new Date(dto.sendAt) : null,
      sentAt: null,
      metadata: {},
    });
    return this.campaignsRepo.save(item);
  }

  async updateCampaign(id: string, dto: Partial<UpsertNotificationCampaignDto>) {
    const item = await this.campaignsRepo.findOne({ where: { id } });
    if (!item) throw new NotFoundException('Campaign not found.');
    Object.assign(item, {
      locale: dto.locale === undefined ? item.locale : dto.locale,
      title: dto.title ?? item.title,
      body: dto.body ?? item.body,
      audience: dto.audience ?? item.audience,
      status: dto.status ?? item.status,
      sendAt: dto.sendAt ? new Date(dto.sendAt) : item.sendAt,
    });
    return this.campaignsRepo.save(item);
  }

  async sendCampaign(id: string) {
    const item = await this.campaignsRepo.findOne({ where: { id } });
    if (!item) throw new NotFoundException('Campaign not found.');
    item.status = 'sent';
    item.sentAt = new Date();
    return this.campaignsRepo.save(item);
  }

  async deleteCampaign(id: string) {
    const result = await this.campaignsRepo.delete(id);
    if (!result.affected) throw new NotFoundException('Campaign not found.');
    return { success: true };
  }

  private async getLocales() {
    const locales = new Set<string>();
    const [guides, tasks, places] = await Promise.all([
      this.guidesRepo.find({ select: ['locale'] }),
      this.tasksRepo.find({ select: ['locale'] }),
      this.placesRepo.find({ select: ['locale'] }),
    ]);
    guides.forEach((item) => locales.add(item.locale));
    tasks.forEach((item) => locales.add(item.locale));
    places.forEach((item) => locales.add(item.locale));
    return [...locales];
  }

  private toGuide(item: GuideArticleEntity) {
    return {
      ...item,
      steps: item.steps,
      tags: item.tags,
    };
  }

  private toTask(item: TaskTemplateEntity) {
    return item;
  }

  private toPlace(item: ImportantPlaceEntity) {
    return item;
  }

  private toCampaign(item: NotificationCampaignEntity) {
    return item;
  }
}
