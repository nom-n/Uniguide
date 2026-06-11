import { MigrationInterface, QueryRunner } from 'typeorm';

export class AuthHardening1714180000001 implements MigrationInterface {
  name = 'AuthHardening1714180000001';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      ALTER TABLE "users"
        ADD COLUMN "email_verification_token_hash" character varying,
        ADD COLUMN "email_verification_token_digest" character varying,
        ADD COLUMN "email_verification_expires_at" TIMESTAMP WITH TIME ZONE,
        ADD COLUMN "password_reset_token_hash" character varying,
        ADD COLUMN "password_reset_token_digest" character varying,
        ADD COLUMN "password_reset_expires_at" TIMESTAMP WITH TIME ZONE,
        ADD COLUMN "failed_login_attempts" integer NOT NULL DEFAULT 0,
        ADD COLUMN "locked_until" TIMESTAMP WITH TIME ZONE;
    `);
    await queryRunner.query(
      `CREATE INDEX "IDX_users_email_verification_token_digest" ON "users" ("email_verification_token_digest");`,
    );
    await queryRunner.query(
      `CREATE INDEX "IDX_users_password_reset_token_digest" ON "users" ("password_reset_token_digest");`,
    );
    await queryRunner.query(
      `CREATE UNIQUE INDEX "UQ_device_tokens_fcm_token" ON "device_tokens" ("fcm_token");`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP INDEX "public"."UQ_device_tokens_fcm_token";`);
    await queryRunner.query(
      `DROP INDEX "public"."IDX_users_password_reset_token_digest";`,
    );
    await queryRunner.query(
      `DROP INDEX "public"."IDX_users_email_verification_token_digest";`,
    );
    await queryRunner.query(`
      ALTER TABLE "users"
        DROP COLUMN "locked_until",
        DROP COLUMN "failed_login_attempts",
        DROP COLUMN "password_reset_expires_at",
        DROP COLUMN "password_reset_token_digest",
        DROP COLUMN "password_reset_token_hash",
        DROP COLUMN "email_verification_expires_at",
        DROP COLUMN "email_verification_token_digest",
        DROP COLUMN "email_verification_token_hash";
    `);
  }
}
