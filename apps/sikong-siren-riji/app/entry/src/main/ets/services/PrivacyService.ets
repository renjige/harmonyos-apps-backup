import { SessionStore } from './SessionStore'
import { DiaryStore } from './DiaryStore'

const KEY_PRIVACY = 'privacyAccepted'

/** 纯本地 App：不调用网络接口 */
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
    const all = await DiaryStore.loadAll()
    for (const it of all) {
      await DiaryStore.deleteEntry(it.id)
    }
    return true
  }

  static async deleteAccount(): Promise<boolean> {
    await PrivacyService.deleteData()
    await SessionStore.clearSession()
    return true
  }
}
