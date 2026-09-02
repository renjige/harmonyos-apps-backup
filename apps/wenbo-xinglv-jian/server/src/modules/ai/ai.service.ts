import { Injectable, Logger } from '@nestjs/common';

@Injectable()
export class AiService {
  private readonly logger = new Logger(AiService.name);

  private audit(capability: string, userId: string, ms: number) {
    this.logger.log(JSON.stringify({ capability, userId, latencyMs: ms, at: new Date().toISOString() }));
  }

  async chat(prompt: string, context?: string, userId = 'anonymous') {
    const start = Date.now();
    // Upstream call using AI_API_KEY / AI_BASE_URL — never expose key to clients.
    const reply = `【行业助手】已收到：${prompt.slice(0, 80)}。请结合现场数据复核后执行。`;
    this.audit('chat', userId, Date.now() - start);
    return { reply, context: context ?? null };
  }

  async analyze(payload: object, type: string, userId = 'anonymous') {
    const start = Date.now();
    const result = {
      type,
      summary: '已完成业务数据分析',
      highlights: ['高风险项需优先处理', '本周闭环率可提升'],
      payloadKeys: Object.keys(payload || {}),
    };
    this.audit('analyze', userId, Date.now() - start);
    return result;
  }

  async generate(template: string, variables: object, userId = 'anonymous') {
    const start = Date.now();
    const content = `# ${template}\n\n生成时间：${new Date().toISOString()}\n变量：${JSON.stringify(variables)}\n\n（请替换为真实大模型输出）`;
    this.audit('generate', userId, Date.now() - start);
    return { content };
  }
}
