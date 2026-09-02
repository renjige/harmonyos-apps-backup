import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.setGlobalPrefix('api/v1');
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));
  app.enableCors({ origin: true });
  const port = process.env.PORT || 3000;
  await app.listen(port);
  // Prefer HTTPS terminator (nginx/caddy) in production; app assumes TLS at edge.
  console.log(`API listening on :${port}/api/v1`);
}

bootstrap();
