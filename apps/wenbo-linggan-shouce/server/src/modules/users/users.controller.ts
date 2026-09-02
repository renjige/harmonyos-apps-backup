import { Controller, Get } from '@nestjs/common';
import { ok } from '../../common/api-response';

@Controller('users')
export class UsersController {
  @Get('me')
  me() {
    return ok({ id: '00000000-0000-0000-0000-000000000001', name: '审核演示账号', role: 'manager' });
  }
}
