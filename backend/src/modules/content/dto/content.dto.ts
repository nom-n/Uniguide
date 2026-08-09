import { ApiProperty } from '@nestjs/swagger';
import {
  IsArray,
  IsBoolean,
  IsDateString,
  IsIn,
  IsInt,
  IsOptional,
  IsString,
  MaxLength,
  Min,
} from 'class-validator';
import { Type } from 'class-transformer';

const categories = [
  'preArrival',
  'afterArrival',
  'banking',
  'housing',
  'universityLife',
  'transport',
  'studentTips',
  'maps',
] as const;

export class ContentLocaleQueryDto {
  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  locale?: string;
}

export class UpsertGuideArticleDto {
  @ApiProperty()
  @IsString()
  locale!: string;

  @ApiProperty({ enum: categories })
  @IsIn(categories)
  category!: string;

  @ApiProperty()
  @Type(() => Number)
  @IsInt()
  iconCodePoint!: number;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  iconFontFamily?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  iconFontPackage?: string;

  @ApiProperty()
  @IsString()
  title!: string;

  @ApiProperty()
  @IsString()
  summary!: string;

  @ApiProperty({ isArray: true, required: false })
  @IsOptional()
  @IsArray()
  tags?: string[];

  @ApiProperty({ isArray: true, required: false })
  @IsOptional()
  @IsArray()
  steps?: unknown[];

  @ApiProperty({ required: false })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;

  @ApiProperty({ required: false })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  sortOrder?: number;
}

export class UpsertTaskTemplateDto {
  @ApiProperty()
  @IsString()
  locale!: string;

  @ApiProperty({ enum: categories })
  @IsIn(categories)
  category!: string;

  @ApiProperty()
  @IsString()
  title!: string;

  @ApiProperty()
  @IsString()
  description!: string;

  @ApiProperty()
  @Type(() => Number)
  @IsInt()
  priority!: number;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;

  @ApiProperty({ required: false })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  sortOrder?: number;
}

export class UpsertImportantPlaceDto {
  @ApiProperty()
  @IsString()
  locale!: string;

  @ApiProperty()
  @IsString()
  name!: string;

  @ApiProperty()
  @IsString()
  type!: string;

  @ApiProperty()
  @IsString()
  city!: string;

  @ApiProperty()
  @IsString()
  description!: string;

  @ApiProperty()
  @IsString()
  url!: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;

  @ApiProperty({ required: false })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  sortOrder?: number;
}

export class UpsertNotificationCampaignDto {
  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  locale?: string;

  @ApiProperty()
  @IsString()
  @MaxLength(140)
  title!: string;

  @ApiProperty()
  @IsString()
  @MaxLength(240)
  body!: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  audience?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  status?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsDateString()
  sendAt?: string;
}
