import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  OneToMany,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

import { DeviceToken } from './device-token.entity';
import { Session } from './session.entity';

@Entity({ name: 'users' })
export class User {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ unique: true })
  email!: string;

  @Column({ name: 'password_hash', type: 'varchar', nullable: true })
  passwordHash!: string | null;

  @Column({ name: 'is_verified', default: false })
  isVerified!: boolean;

  @Column({ name: 'display_name', type: 'varchar', nullable: true })
  displayName!: string | null;

  @Column({ name: 'first_name', type: 'varchar', nullable: true })
  firstName!: string | null;

  @Column({ name: 'last_name', type: 'varchar', nullable: true })
  lastName!: string | null;

  @Column({ name: 'profile_emoji', type: 'varchar', nullable: true })
  profileEmoji!: string | null;

  @Column({ type: 'varchar', nullable: true })
  gender!: string | null;

  @Column({ name: 'birth_year', type: 'integer', nullable: true })
  birthYear!: number | null;

  @Column({ name: 'auth_provider', type: 'varchar', default: 'email' })
  authProvider!: string;

  @Column({ name: 'provider_subject', type: 'varchar', nullable: true })
  providerSubject!: string | null;

  @Column({ name: 'email_verification_token_hash', type: 'varchar', nullable: true })
  emailVerificationTokenHash!: string | null;

  @Index()
  @Column({ name: 'email_verification_token_digest', type: 'varchar', nullable: true })
  emailVerificationTokenDigest!: string | null;

  @Column({ name: 'email_verification_expires_at', type: 'timestamptz', nullable: true })
  emailVerificationExpiresAt!: Date | null;

  @Column({ name: 'password_reset_token_hash', type: 'varchar', nullable: true })
  passwordResetTokenHash!: string | null;

  @Index()
  @Column({ name: 'password_reset_token_digest', type: 'varchar', nullable: true })
  passwordResetTokenDigest!: string | null;

  @Column({ name: 'password_reset_expires_at', type: 'timestamptz', nullable: true })
  passwordResetExpiresAt!: Date | null;

  @Column({ name: 'registration_ticket_hash', type: 'varchar', nullable: true })
  registrationTicketHash!: string | null;

  @Index()
  @Column({ name: 'registration_ticket_digest', type: 'varchar', nullable: true })
  registrationTicketDigest!: string | null;

  @Column({ name: 'registration_ticket_expires_at', type: 'timestamptz', nullable: true })
  registrationTicketExpiresAt!: Date | null;

  @Column({ name: 'failed_login_attempts', default: 0 })
  failedLoginAttempts!: number;

  @Column({ name: 'locked_until', type: 'timestamptz', nullable: true })
  lockedUntil!: Date | null;

  @CreateDateColumn({ name: 'created_at' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt!: Date;

  @OneToMany(() => Session, (session) => session.user)
  sessions!: Session[];

  @OneToMany(() => DeviceToken, (token) => token.user)
  deviceTokens!: DeviceToken[];
}
