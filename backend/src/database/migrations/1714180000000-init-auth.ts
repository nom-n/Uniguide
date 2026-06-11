import { MigrationInterface, QueryRunner } from 'typeorm';

export class InitAuth1714180000000 implements MigrationInterface {
  name = 'InitAuth1714180000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`CREATE EXTENSION IF NOT EXISTS "pgcrypto";`);
    await queryRunner.query(`
      CREATE TABLE "users" (
        "id" uuid NOT NULL DEFAULT gen_random_uuid(),
        "email" character varying NOT NULL,
        "password_hash" character varying NOT NULL,
        "is_verified" boolean NOT NULL DEFAULT false,
        "display_name" character varying,
        "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT "UQ_users_email" UNIQUE ("email"),
        CONSTRAINT "PK_users_id" PRIMARY KEY ("id")
      );
    `);

    await queryRunner.query(`
      CREATE TABLE "sessions" (
        "id" uuid NOT NULL DEFAULT gen_random_uuid(),
        "user_id" uuid NOT NULL,
        "refresh_token_hash" character varying NOT NULL,
        "device_info" character varying,
        "ip" character varying,
        "expires_at" TIMESTAMP WITH TIME ZONE NOT NULL,
        "revoked_at" TIMESTAMP WITH TIME ZONE,
        "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT "PK_sessions_id" PRIMARY KEY ("id"),
        CONSTRAINT "FK_sessions_user" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE
      );
    `);
    await queryRunner.query(`CREATE INDEX "IDX_sessions_user_id" ON "sessions" ("user_id");`);
    await queryRunner.query(`CREATE INDEX "IDX_sessions_expires_at" ON "sessions" ("expires_at");`);

    await queryRunner.query(`
      CREATE TABLE "device_tokens" (
        "id" uuid NOT NULL DEFAULT gen_random_uuid(),
        "user_id" uuid NOT NULL,
        "fcm_token" character varying NOT NULL,
        "platform" character varying NOT NULL,
        "last_seen_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        CONSTRAINT "PK_device_tokens_id" PRIMARY KEY ("id"),
        CONSTRAINT "FK_device_tokens_user" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE
      );
    `);
    await queryRunner.query(`CREATE INDEX "IDX_device_tokens_user_id" ON "device_tokens" ("user_id");`);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP INDEX "public"."IDX_device_tokens_user_id";`);
    await queryRunner.query(`DROP TABLE "device_tokens";`);
    await queryRunner.query(`DROP INDEX "public"."IDX_sessions_expires_at";`);
    await queryRunner.query(`DROP INDEX "public"."IDX_sessions_user_id";`);
    await queryRunner.query(`DROP TABLE "sessions";`);
    await queryRunner.query(`DROP TABLE "users";`);
  }
}
