import { Controller, Get, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';

import { CurrentUser } from './decorators/current-user.decorator';
import { User } from './entities/user.entity';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { AuthService } from './auth.service';

@ApiTags('User')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller()
export class MeController {
  constructor(private readonly authService: AuthService) {}

  @Get('me')
  me(@CurrentUser() user: User) {
    return this.authService.me(user.id);
  }
}
