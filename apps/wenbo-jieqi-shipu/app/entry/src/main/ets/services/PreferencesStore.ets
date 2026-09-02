import { SessionStore } from './SessionStore'

const KEY_VEG = 'prefVegetarianOnly'
const KEY_LIGHT = 'prefLightTaste'

/** 饮食偏好（本地 Preferences，非栏目种子） */
export class PreferencesStore {
  static vegetarianOnly(): boolean {
    return AppStorage.get<boolean>(KEY_VEG) === true
  }

  static lightTaste(): boolean {
    return AppStorage.get<boolean>(KEY_LIGHT) === true
  }

  static async setVegetarianOnly(value: boolean): Promise<void> {
    AppStorage.setOrCreate(KEY_VEG, value)
    await SessionStore.saveBool(KEY_VEG, value)
  }

  static async setLightTaste(value: boolean): Promise<void> {
    AppStorage.setOrCreate(KEY_LIGHT, value)
    await SessionStore.saveBool(KEY_LIGHT, value)
  }
}
