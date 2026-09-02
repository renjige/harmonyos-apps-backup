import { Module } from '@nestjs/common';
import { BizController } from './biz.controller';

@Module({ controllers: [BizController] })
export class BizModule {}
