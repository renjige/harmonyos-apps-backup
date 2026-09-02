import { Controller, Get } from '@nestjs/common';
import { ok } from '../../common/api-response';

@Controller('messages')
export class MessagesController {
  @Get()
  list() {
    return ok({
      list: [
        { title: '行前清单提示', body: '建议出发前再次核对证件与常用设备。', type: 'system', read: false },
        { title: '入住事项提示', body: '可在提醒页记录入住时间与重要备注。', type: 'system', read: true },
      ],
    });
  }
}
