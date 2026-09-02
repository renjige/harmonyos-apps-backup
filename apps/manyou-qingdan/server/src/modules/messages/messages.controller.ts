import { Controller, Get } from '@nestjs/common';
import { ok } from '../../common/api-response';

@Controller('messages')
export class MessagesController {
  @Get()
  list() {
    return ok({
      list: [
        { title: '整改临期提醒', body: '请尽快闭环高风险项', type: 'inspection', read: false },
        { title: '周报已生成', body: '可通过 AI 助手查看', type: 'ai', read: true },
      ],
    });
  }
}
