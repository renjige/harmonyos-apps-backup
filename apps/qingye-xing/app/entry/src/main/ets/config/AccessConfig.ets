/**
 * AppSpec.access — 清野札：纯本地，无登录注册。
 */
export type AccessMode = 'login_required' | 'open_optional' | 'register_optional'
export type PrivacyRefusePolicy = 'exit' | 'browse_basic'

export class AccessConfig {
  static mode(): AccessMode {
    return 'open_optional'
  }

  static allowRegister(): boolean {
    return false
  }

  static guestBrowse(): boolean {
    return true
  }

  static guestWrite(): boolean {
    return true
  }

  static onPrivacyRefuse(): PrivacyRefusePolicy {
    return 'exit'
  }

  static isGateAction(action: string): boolean {
    return false
  }

  static applyLocalDefaults(): void {
    AppStorage.setOrCreate('accessMode', 'open_optional')
    AppStorage.setOrCreate('accessAllowRegister', false)
    AppStorage.setOrCreate('accessGuestBrowse', true)
    AppStorage.setOrCreate('accessGuestWrite', true)
    AppStorage.setOrCreate('accessOnPrivacyRefuse', 'exit')
    AppStorage.setOrCreate('accessGateActions', '')
  }

  static applyDefaults(mode: AccessMode): void {
    AccessConfig.applyLocalDefaults()
  }
}
