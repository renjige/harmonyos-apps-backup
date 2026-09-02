import { ArchiveStore } from './ArchiveStore'
import { LifeStore } from './LifeStore'
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
    await ArchiveStore.clearAll()
    await LifeStore.clearAll()
    return true
  }

  static async deleteAccount(): Promise<boolean> {
    await ArchiveStore.clearAll()
    await LifeStore.clearAll()
    await SessionStore.clearSession()
    return true
  }
}
