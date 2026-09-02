import { SilanStore } from './SilanStore'
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

  static async deleteData(): Promise<boolean> {
    await SilanStore.clearAll()
    return true
  }

  static async deleteAccount(): Promise<boolean> {
    await SilanStore.clearAll()
    await SessionStore.clearSession()
    return true
  }
}
