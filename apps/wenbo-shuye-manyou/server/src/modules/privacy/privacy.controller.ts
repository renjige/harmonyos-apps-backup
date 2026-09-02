import { Body, Controller, Delete, Post } from '@nestjs/common';
import { ok } from '../../common/api-response';

@Controller('privacy')
export class PrivacyController {
  @Post('delete-data')
  deleteData(@Body() body: { userId?: string }) {
    return ok({ deleted: true, userId: body.userId ?? null });
  }

  @Delete('account')
  deleteAccount(@Body() body: { userId?: string }) {
    return ok({ closed: true, userId: body.userId ?? null });
  }
}
