import { LoginRequest, LoginResponse, RegisterRequest } from '../models/ApiModels'
import { HttpClient } from './HttpClient'
import { AccessConfig } from '../config/AccessConfig'
import { SessionStore } from './SessionStore'

/**
 * 认证服务。登录/注册成功后 await SessionStore.saveSession（preferences+flush）。
 * body.tenantId 必填（NetworkKit Map header 不可靠时的兜底）。
 */
export class AuthService {
  static lastError: string = ''

  private static resolveTenantId(): string {
    return AppStorage.get<string>('tenantId') ?? ''
  }

  static async login(username: string, password: string): Promise<boolean> {
    AuthService.lastError = ''
    const body = new LoginRequest()
    body.username = username
    body.password = password
    body.tenantId = AuthService.resolveTenantId()
    const res = await HttpClient.post<LoginResponse>('/auth/login', body)
    if (res.code === 0 && res.data !== undefined && res.data.accessToken.length > 0) {
      await SessionStore.saveSession(res.data.accessToken, username)
      return true
    }
    AuthService.lastError = res.message.length > 0 ? res.message : '登录失败，请检查账号密码'
    return false
  }

  static async register(req: RegisterRequest): Promise<boolean> {
    AuthService.lastError = ''
    req.tenantId = AuthService.resolveTenantId()
    const res = await HttpClient.post<LoginResponse>('/auth/register', req)
    if (res.code === 0 && res.data !== undefined && res.data.accessToken.length > 0) {
      await SessionStore.saveSession(res.data.accessToken, req.username)
      return true
    }
    AuthService.lastError = res.message.length > 0 ? res.message : '注册失败，请检查信息或换一个账号'
    return false
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
