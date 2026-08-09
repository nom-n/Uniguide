import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class AdminKeyGuard implements CanActivate {
  constructor(private readonly configService: ConfigService) {}

  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest<{ headers: Record<string, string | undefined> }>();
    const expected = this.configService.get<string>('admin.apiKey') ?? '';
    if (!expected) return false;
    const provided = request.headers['x-admin-key'];
    return typeof provided === 'string' && provided === expected;
  }
}
