import { Controller, Get, Query } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';

import { ContentLocaleQueryDto } from './dto/content.dto';
import { ContentService } from './content.service';

@ApiTags('Content')
@Controller('content')
export class ContentController {
  constructor(private readonly contentService: ContentService) {}

  @Get('snapshot')
  snapshot(@Query() query: ContentLocaleQueryDto) {
    return this.contentService.snapshot(query.locale);
  }
}
