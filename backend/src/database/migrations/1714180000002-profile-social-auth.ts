import { MigrationInterface, QueryRunner } from 'typeorm';

export class ProfileSocialAuth1714180000002 implements MigrationInterface {
  name = 'ProfileSocialAuth1714180000002';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      ALTER TABLE "users"
        ALTER COLUMN "password_hash" DROP NOT NULL,
        ADD COLUMN "first_name" character varying,
        ADD COLUMN "last_name" character varying,
        ADD COLUMN "profile_emoji" character varying,
        ADD COLUMN "gender" character varying,
        ADD COLUMN "birth_year" integer,
        ADD COLUMN "auth_provider" character varying NOT NULL DEFAULT 'email',
        ADD COLUMN "provider_subject" character varying,
        ADD COLUMN "registration_ticket_hash" character varying,
        ADD COLUMN "registration_ticket_digest" character varying,
        ADD COLUMN "registration_ticket_expires_at" TIMESTAMP WITH TIME ZONE;
    `);
    await queryRunner.query(
      `CREATE INDEX "IDX_users_registration_ticket_digest" ON "users" ("registration_ticket_digest");`,
    );
    await queryRunner.query(
      `CREATE INDEX "IDX_users_provider_subject" ON "users" ("auth_provider", "provider_subject");`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP INDEX "public"."IDX_users_provider_subject";`);
    await queryRunner.query(
      `DROP INDEX "public"."IDX_users_registration_ticket_digest";`,
    );
    await queryRunner.query(`
      ALTER TABLE "users"
        DROP COLUMN "registration_ticket_expires_at",
        DROP COLUMN "registration_ticket_digest",
        DROP COLUMN "registration_ticket_hash",
        DROP COLUMN "provider_subject",
        DROP COLUMN "auth_provider",
        DROP COLUMN "birth_year",
        DROP COLUMN "gender",
        DROP COLUMN "profile_emoji",
        DROP COLUMN "last_name",
        DROP COLUMN "first_name",
        ALTER COLUMN "password_hash" SET NOT NULL;
    `);
  }
}
