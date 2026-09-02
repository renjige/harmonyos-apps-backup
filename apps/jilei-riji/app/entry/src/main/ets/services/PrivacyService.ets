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

  /** 本地日记 App：清除缓存数据，不走网络 */
  static async deleteData(): Promise<boolean> {
    return true
  }

  /** 本地日记 App：无云端账号体系 */
  static async deleteAccount(): Promise<boolean> {
    return true
  }
}
