/**
 * AppSpec.access 运行时视图。茶香档案为纯本地工具：无登录墙，协议勾选在首次 Overlay。
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
    const mode = AccessConfig.mode()
    if (mode === 'open_optional' || mode === 'register_optional') {
      return true
    }
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
    const raw = AppStorage.get<string>('accessGateActions') ?? ''
    if (raw.length === 0) {
      return action.length > 0
    }
    const parts = raw.split(',')
    for (let p of parts) {
      if (p.trim() === action) {
        return true
      }
    }
    return false
  }

  static applyLocalArchiveDefaults(): void {
    AppStorage.setOrCreate('accessMode', 'open_optional')
    AppStorage.setOrCreate('accessAllowRegister', false)
    AppStorage.setOrCreate('accessGuestBrowse', true)
    AppStorage.setOrCreate('accessGuestWrite', true)
    AppStorage.setOrCreate('accessOnPrivacyRefuse', 'exit')
    AppStorage.setOrCreate('accessGateActions', '')
  }

  /** EntryAbility 注入；交付时与 AppSpec.access 对齐 */
  static applyDefaults(mode: AccessMode): void {
    AccessConfig.applyLocalArchiveDefaults()
  }
}
