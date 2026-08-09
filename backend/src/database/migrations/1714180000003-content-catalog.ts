import { readFileSync, existsSync } from 'fs';
import { join } from 'path';
import { MigrationInterface, QueryRunner } from 'typeorm';

type SeedPayload = {
  guides: Array<Record<string, unknown>>;
  tasks: Array<Record<string, unknown>>;
  places: Array<Record<string, unknown>>;
};

export class ContentCatalog1714180000003 implements MigrationInterface {
  name = 'ContentCatalog1714180000003';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`CREATE EXTENSION IF NOT EXISTS "pgcrypto";`);

    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS "guide_articles" (
        "id" uuid NOT NULL DEFAULT gen_random_uuid(),
        "locale" character varying NOT NULL,
        "category" character varying NOT NULL,
        "icon_code_point" integer NOT NULL,
        "icon_font_family" character varying,
        "icon_font_package" character varying,
        "title" character varying NOT NULL,
        "summary" character varying NOT NULL,
        "tags" jsonb NOT NULL DEFAULT '[]'::jsonb,
        "steps" jsonb NOT NULL DEFAULT '[]'::jsonb,
        "is_active" boolean NOT NULL DEFAULT true,
        "sort_order" integer NOT NULL DEFAULT 0,
        "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT "PK_guide_articles_id" PRIMARY KEY ("id")
      );
    `);
    await queryRunner.query(`CREATE INDEX IF NOT EXISTS "IDX_guide_articles_locale" ON "guide_articles" ("locale");`);
    await queryRunner.query(`CREATE INDEX IF NOT EXISTS "IDX_guide_articles_category" ON "guide_articles" ("category");`);

    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS "task_templates" (
        "id" uuid NOT NULL DEFAULT gen_random_uuid(),
        "locale" character varying NOT NULL,
        "category" character varying NOT NULL,
        "title" character varying NOT NULL,
        "description" character varying NOT NULL,
        "priority" integer NOT NULL,
        "is_active" boolean NOT NULL DEFAULT true,
        "sort_order" integer NOT NULL DEFAULT 0,
        "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT "PK_task_templates_id" PRIMARY KEY ("id")
      );
    `);
    await queryRunner.query(`CREATE INDEX IF NOT EXISTS "IDX_task_templates_locale" ON "task_templates" ("locale");`);
    await queryRunner.query(`CREATE INDEX IF NOT EXISTS "IDX_task_templates_category" ON "task_templates" ("category");`);

    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS "important_places" (
        "id" uuid NOT NULL DEFAULT gen_random_uuid(),
        "locale" character varying NOT NULL,
        "name" character varying NOT NULL,
        "type" character varying NOT NULL,
        "city" character varying NOT NULL,
        "description" character varying NOT NULL,
        "url" character varying NOT NULL,
        "is_active" boolean NOT NULL DEFAULT true,
        "sort_order" integer NOT NULL DEFAULT 0,
        "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT "PK_important_places_id" PRIMARY KEY ("id")
      );
    `);
    await queryRunner.query(`CREATE INDEX IF NOT EXISTS "IDX_important_places_locale" ON "important_places" ("locale");`);

    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS "notification_campaigns" (
        "id" uuid NOT NULL DEFAULT gen_random_uuid(),
        "locale" character varying,
        "title" character varying NOT NULL,
        "body" character varying NOT NULL,
        "audience" character varying NOT NULL DEFAULT 'all',
        "status" character varying NOT NULL DEFAULT 'draft',
        "send_at" TIMESTAMP WITH TIME ZONE,
        "sent_at" TIMESTAMP WITH TIME ZONE,
        "metadata" jsonb NOT NULL DEFAULT '{}'::jsonb,
        "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT "PK_notification_campaigns_id" PRIMARY KEY ("id")
      );
    `);
    await queryRunner.query(`CREATE INDEX IF NOT EXISTS "IDX_notification_campaigns_locale" ON "notification_campaigns" ("locale");`);
    await queryRunner.query(`CREATE INDEX IF NOT EXISTS "IDX_notification_campaigns_status" ON "notification_campaigns" ("status");`);

    const seedPath = join(process.cwd(), 'src', 'database', 'seed', 'content-seed.json');
    if (!existsSync(seedPath)) {
      return;
    }

    const rawSeed = readFileSync(seedPath, 'utf8').trim();
    if (!rawSeed) {
      return;
    }

    const seed = JSON.parse(rawSeed) as SeedPayload;
    for (const guide of seed.guides) {
      await queryRunner.manager.insert('guide_articles', guide);
    }
    for (const task of seed.tasks) {
      await queryRunner.manager.insert('task_templates', task);
    }
    for (const place of seed.places) {
      await queryRunner.manager.insert('important_places', place);
    }
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE IF EXISTS "notification_campaigns";`);
    await queryRunner.query(`DROP TABLE IF EXISTS "important_places";`);
    await queryRunner.query(`DROP TABLE IF EXISTS "task_templates";`);
    await queryRunner.query(`DROP TABLE IF EXISTS "guide_articles";`);
  }
}
