import { Body, Controller, Get, Post, Query } from '@nestjs/common';
import { ok } from '../../common/api-response';

/** Industry resources under /biz/* — construction uses inspections. */
@Controller('biz')
export class BizController {
  private items = [
    { id: '33333333-3333-3333-3333-333333333333', title: '基坑支护日常巡查', status: 'submitted' },
    { id: '44444444-4444-4444-4444-444444444444', title: '外脚手架连墙件复核', status: 'rectifying' },
  ];

  @Get('inspections')
  list(@Query('page') page = '1', @Query('pageSize') pageSize = '20') {
    return ok({ list: this.items, page: Number(page), pageSize: Number(pageSize), total: this.items.length });
  }

  @Post('inspections')
  create(@Body() body: { title?: string; status?: string }) {
    const row = {
      id: cryptoRandom(),
      title: body.title || '新建巡检',
      status: body.status || 'draft',
    };
    this.items = [row, ...this.items];
    return ok(row);
  }
}

function cryptoRandom(): string {
  return '55555555-5555-5555-5555-' + Date.now().toString().slice(-12);
}
