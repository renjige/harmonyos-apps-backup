import { Body, Controller, Post } from '@nestjs/common';
import { AuthService } from './auth.service';
import { ErrorCode, fail, ok } from '../../common/api-response';

@Controller('auth')
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  @Post('login')
  async login(@Body() body: { username?: string; password?: string }) {
    const result = await this.auth.login(body.username ?? '', body.password ?? '');
    if (!result) {
      return fail(ErrorCode.UNAUTHORIZED, '账号或密码错误');
    }
    return ok(result);
  }

  @Post('register')
  async register(
    @Body()
    body: {
      username?: string;
      password?: string;
      realName?: string;
      phone?: string;
      inviteCode?: string;
    },
  ) {
    const result = await this.auth.register({
      username: body.username ?? '',
      password: body.password ?? '',
      realName: body.realName ?? '',
      phone: body.phone ?? '',
      inviteCode: body.inviteCode ?? '',
    });
    if (!result) {
      return fail(ErrorCode.BAD_REQUEST, '注册失败，请检查姓名、手机号或账号是否已存在');
    }
    return ok(result);
  }
}
