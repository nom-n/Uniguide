import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { ConfigService } from '@nestjs/config';
import helmet from 'helmet';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import type { NextFunction, Request, Response } from 'express';

import { AppModule } from './app.module';

async function bootstrap(): Promise<void> {
  const app = await NestFactory.create(AppModule);
  const config = app.get(ConfigService);
  const corsOrigin = config.get<string | string[]>('app.corsOrigin') ?? '*';
  const env = config.get<string>('app.env');

  app.use(helmet());
  if (env === 'production') {
    app.getHttpAdapter().getInstance().set('trust proxy', 1);
    app.use((req: Request, res: Response, next: NextFunction) => {
      if (req.secure || req.headers['x-forwarded-proto'] === 'https') {
        next();
        return;
      }
      res.status(403).json({ message: 'HTTPS is required.' });
    });
  }
  app.enableCors({
    origin: corsOrigin,
    credentials: corsOrigin !== '*',
  });
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: true,
    }),
  );

  const swaggerConfig = new DocumentBuilder()
    .setTitle('UniGuide API')
    .setDescription('Manual auth backend')
    .setVersion('1.0.0')
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, swaggerConfig);
  SwaggerModule.setup('docs', app, document);

  const port = config.get<number>('app.port') ?? 3000;
  await app.listen(port);
}

bootstrap();
