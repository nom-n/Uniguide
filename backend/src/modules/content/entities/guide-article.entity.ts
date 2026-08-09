import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity({ name: 'guide_articles' })
export class GuideArticleEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Index()
  @Column({ type: 'varchar' })
  locale!: string;

  @Index()
  @Column({ type: 'varchar' })
  category!: string;

  @Column({ name: 'icon_code_point', type: 'integer' })
  iconCodePoint!: number;

  @Column({ name: 'icon_font_family', type: 'varchar', nullable: true })
  iconFontFamily!: string | null;

  @Column({ name: 'icon_font_package', type: 'varchar', nullable: true })
  iconFontPackage!: string | null;

  @Column({ type: 'varchar' })
  title!: string;

  @Column({ type: 'varchar' })
  summary!: string;

  @Column({ type: 'jsonb', default: () => "'[]'::jsonb" })
  tags!: string[];

  @Column({ type: 'jsonb', default: () => "'[]'::jsonb" })
  steps!: unknown[];

  @Column({ name: 'is_active', type: 'boolean', default: true })
  isActive!: boolean;

  @Column({ name: 'sort_order', type: 'integer', default: 0 })
  sortOrder!: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt!: Date;
}
