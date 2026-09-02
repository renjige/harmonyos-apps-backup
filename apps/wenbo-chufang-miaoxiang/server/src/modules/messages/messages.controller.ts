import { Controller, Get } from '@nestjs/common';
import { ok } from '../../common/api-response';

@Controller('messages')
export class MessagesController {
  @Get()
  list() {
    return ok({
      list: [
        { title: '今日厨房灵感', body: '试试番茄鸡蛋焖面，十几分钟就能完成。', type: 'kitchen', read: false },
        { title: '清单提醒', body: '做饭前可以先确认厨房清单。', type: 'list', read: true },
      ],
    });
  }
}
