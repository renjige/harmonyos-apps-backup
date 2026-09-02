import { EmptyPayload } from '../models/ApiModels'
import { HttpClient } from './HttpClient'
import { SessionStore } from './SessionStore'

const KEY_PRIVACY = 'privacyAccepted'

export class PrivacyService {
  static isAccepted(): boolean {
    return AppStorage.get<boolean>(KEY_PRIVACY) === true
  }

  static accept(): void {
    AppStorage.setOrCreate(KEY_PRIVACY, true)
  }

  /** 登录/注册勾选同意后持久化 */
  static async acceptAndPersist(): Promise<void> {
    PrivacyService.accept()
    await SessionStore.savePrivacyAccepted(true)
  }

  static async revoke(): Promise<void> {
    AppStorage.setOrCreate(KEY_PRIVACY, false)
    await SessionStore.savePrivacyAccepted(false)
  }

  static async deleteData(): Promise<boolean> {
    return true
  }

  /** 本地随笔不上传；注销走平台 API */
  static async deleteAccount(): Promise<boolean> {
    const res = await HttpClient.delete<EmptyPayload>('/privacy/account', new EmptyPayload())
    return res.code === 0
  }
}
