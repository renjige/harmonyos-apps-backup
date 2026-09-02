import { Body, Controller, Post } from '@nestjs/common';
import { AiService } from './ai.service';
import { ok } from '../../common/api-response';

@Controller('ai')
export class AiController {
  constructor(private readonly ai: AiService) {}

  @Post('chat')
  async chat(@Body() body: { prompt?: string; context?: string }) {
    return ok(await this.ai.chat(body.prompt ?? '', body.context));
  }

  @Post('analyze')
  async analyze(@Body() body: { payload?: object; type?: string }) {
    return ok(await this.ai.analyze(body.payload ?? {}, body.type ?? 'default'));
  }

  @Post('generate')
  async generate(@Body() body: { template?: string; variables?: object }) {
    return ok(await this.ai.generate(body.template ?? 'report', body.variables ?? {}));
  }
}
