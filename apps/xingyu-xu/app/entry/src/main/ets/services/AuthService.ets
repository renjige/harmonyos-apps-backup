import { RegisterRequest } from '../models/ApiModels'
import { AccessConfig } from '../config/AccessConfig'
import { SessionStore } from './SessionStore'
import { LocalAuthStore } from './LocalAuthStore'

export class AuthService {
  static lastError: string = ''

  static async login(username: string, password: string): Promise<boolean> {
    AuthService.lastError = ''
    const ok = await LocalAuthStore.verify(username, password)
    if (ok) {
      await SessionStore.saveSession(`local_${Date.now()}`, username)
      return true
    }
    AuthService.lastError = '登录失败，请检查账号密码'
    return false
  }

  static async register(req: RegisterRequest): Promise<boolean> {
    AuthService.lastError = ''
    const err = await LocalAuthStore.register(req.username, req.password, req.realName, req.phone)
    if (err.length > 0) {
      AuthService.lastError = err
      return false
    }
    await SessionStore.saveSession(`local_${Date.now()}`, req.username)
    return true
  }

  static async logout(): Promise<void> {
    await SessionStore.clearSession()
  }

  static isLoggedIn(): boolean {
    const t = AppStorage.get<string>('accessToken')
    return !!t && t.length > 0
  }

  static isGuest(): boolean {
    return !AuthService.isLoggedIn()
  }

  static requireAuth(action: string): boolean {
    if (AuthService.isLoggedIn()) {
      return true
    }
    if (AccessConfig.guestWrite() && !AccessConfig.isGateAction(action)) {
      return true
    }
    if (!AccessConfig.isGateAction(action) && AccessConfig.guestBrowse()) {
      return true
    }
    if (AccessConfig.isGateAction(action)) {
      return false
    }
    return AccessConfig.guestBrowse()
  }

  static currentUsername(): string {
    const u = AppStorage.get<string>('currentUsername')
    return u && u.length > 0 ? u : '未登录'
  }
}
