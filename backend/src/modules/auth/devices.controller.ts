import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';

import { CurrentUser } from './decorators/current-user.decorator';
import { UpsertFcmTokenDto } from './dto/auth.dto';
import { User } from './entities/user.entity';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { AuthService } from './auth.service';

@ApiTags('Devices')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('devices')
export class DevicesController {
  constructor(private readonly authService: AuthService) {}

  @Post('fcm-token')
  saveFcmToken(@CurrentUser() user: User, @Body() dto: UpsertFcmTokenDto) {
    return this.authService.upsertDeviceToken(user.id, dto);
  }
}
