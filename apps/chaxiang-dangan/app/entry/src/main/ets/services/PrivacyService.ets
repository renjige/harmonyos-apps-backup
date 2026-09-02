import { SessionStore } from './SessionStore'

const KEY_PRIVACY = 'privacyAccepted'

export class PrivacyService {
  static isAccepted(): boolean {
    return AppStorage.get<boolean>(KEY_PRIVACY) === true
  }

  static accept(): void {
    AppStorage.setOrCreate(KEY_PRIVACY, true)
  }

  static async acceptAndPersist(): Promise<void> {
    PrivacyService.accept()
    await SessionStore.savePrivacyAccepted(true)
  }

  static async revoke(): Promise<void> {
    AppStorage.setOrCreate(KEY_PRIVACY, false)
    await SessionStore.savePrivacyAccepted(false)
  }

  /** 本机工具不提供批量清库入口；保留方法以免编译引用失败 */
  static async deleteData(): Promise<boolean> {
    return true
  }

  static async deleteAccount(): Promise<boolean> {
    await SessionStore.clearSession()
    return true
  }
}
