/**
 * AppSpec.access 运行时视图 — 时光档案：纯本地，无登录注册。
 */
export type AccessMode = 'login_required' | 'open_optional' | 'register_optional'
export type PrivacyRefusePolicy = 'exit' | 'browse_basic'

export class AccessConfig {
  static mode(): AccessMode {
    const v = AppStorage.get<string>('accessMode')
    if (v === 'open_optional' || v === 'register_optional' || v === 'login_required') {
      return v
    }
    return 'open_optional'
  }

  static allowRegister(): boolean {
    return AppStorage.get<boolean>('accessAllowRegister') === true
  }

  static guestBrowse(): boolean {
    return AppStorage.get<boolean>('accessGuestBrowse') === true
  }

  static guestWrite(): boolean {
    return AppStorage.get<boolean>('accessGuestWrite') === true
  }

  static onPrivacyRefuse(): PrivacyRefusePolicy {
    const v = AppStorage.get<string>('accessOnPrivacyRefuse')
    if (v === 'browse_basic') {
      return 'browse_basic'
    }
    return 'exit'
  }

  static isGateAction(action: string): boolean {
    return false
  }

  /** 时光档案：open_optional + guestWrite，无注册 */
  static applyLocalArchiveDefaults(): void {
    AppStorage.setOrCreate('accessMode', 'open_optional')
    AppStorage.setOrCreate('accessAllowRegister', false)
    AppStorage.setOrCreate('accessGuestBrowse', true)
    AppStorage.setOrCreate('accessGuestWrite', true)
    AppStorage.setOrCreate('accessOnPrivacyRefuse', 'exit')
    AppStorage.setOrCreate('accessGateActions', '')
  }

  static applyDefaults(mode: AccessMode): void {
    AccessConfig.applyLocalArchiveDefaults()
  }
}
