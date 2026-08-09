import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity({ name: 'notification_campaigns' })
export class NotificationCampaignEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Index()
  @Column({ type: 'varchar', nullable: true })
  locale!: string | null;

  @Column({ type: 'varchar' })
  title!: string;

  @Column({ type: 'varchar' })
  body!: string;

  @Column({ type: 'varchar', default: 'all' })
  audience!: string;

  @Index()
  @Column({ type: 'varchar', default: 'draft' })
  status!: string;

  @Column({ name: 'send_at', type: 'timestamptz', nullable: true })
  sendAt!: Date | null;

  @Column({ name: 'sent_at', type: 'timestamptz', nullable: true })
  sentAt!: Date | null;

  @Column({ type: 'jsonb', default: () => "'{}'::jsonb" })
  metadata!: Record<string, unknown>;

  @CreateDateColumn({ name: 'created_at' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt!: Date;
}
