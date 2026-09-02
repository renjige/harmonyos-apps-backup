import { Injectable } from '@nestjs/common';

export type RegisterInput = {
  username: string;
  password: string;
  realName: string;
  phone: string;
  inviteCode?: string;
};

type RegisteredUser = {
  username: string;
  password: string;
  realName: string;
  phone: string;
  inviteCode: string;
};

@Injectable()
export class AuthService {
  private registered: RegisteredUser[] = [];

  private demoAccounts(): Array<{ username: string; password: string }> {
    const list: Array<{ username: string; password: string }> = [];
    const envUser = process.env.DEMO_USERNAME ?? '';
    const envPass = process.env.DEMO_PASSWORD ?? '';
    if (envUser.length > 0 && envPass.length > 0) {
      list.push({ username: envUser, password: envPass });
    }
    for (const row of this.registered) {
      list.push({ username: row.username, password: row.password });
    }
    return list;
  }

  private isValidPhone(phone: string): boolean {
    return /^1\d{10}$/.test(phone);
  }

  async login(username: string, password: string) {
    if (!username || !password) {
      return null;
    }
    const accounts = this.demoAccounts();
    if (accounts.length === 0) {
      return {
        accessToken: `jwt_placeholder_${Date.now()}`,
        user: { id: '00000000-0000-0000-0000-000000000001', username },
      };
    }
    const matched = accounts.some(
      (item) => item.username === username && item.password === password,
    );
    if (!matched) {
      return null;
    }
    return {
      accessToken: `jwt_demo_${Date.now()}`,
      user: { id: '00000000-0000-0000-0000-000000000001', username },
    };
  }

  async register(input: RegisterInput) {
    const username = (input.username ?? '').trim();
    const password = input.password ?? '';
    const realName = (input.realName ?? '').trim();
    const phone = (input.phone ?? '').trim();
    const inviteCode = (input.inviteCode ?? '').trim();
    if (!username || username.length < 3 || !password || password.length < 6) {
      return null;
    }
    if (!realName || !this.isValidPhone(phone)) {
      return null;
    }
    const exists = this.demoAccounts().some((item) => item.username === username);
    if (exists) {
      return null;
    }
    this.registered.push({ username, password, realName, phone, inviteCode });
    return {
      accessToken: `jwt_reg_${Date.now()}`,
      user: {
        id: `reg_${Date.now()}`,
        username,
        realName,
        phone,
        inviteCode: inviteCode.length > 0 ? inviteCode : undefined,
      },
    };
  }
}
