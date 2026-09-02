/**
 * AppSpec.access 运行时视图。由 EntryAbility 写入 AppStorage，Index / 业务门禁读取。
 * 禁止独立隐私首屏；协议勾选在登录页。禁止写死 Privacy → Login → Main。
 */
export type AccessMode = 'login_required' | 'open_optional' | 'register_optional'
export type PrivacyRefusePolicy = 'exit' | 'browse_basic'

export class AccessConfig {
  static mode(): AccessMode {
    const v = AppStorage.get<string>('accessMode')
    if (v === 'open_optional' || v === 'register_optional' || v === 'login_required') {
      return v
    }
    return 'login_required'
  }

  static allowRegister(): boolean {
    // 工厂强制：全产品支持注册
    return true
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

  /** EntryAbility 注入；交付时与 AppSpec.access 对齐 */
  static applyDefaults(mode: AccessMode): void {
    AppStorage.setOrCreate('accessMode', mode)
    AppStorage.setOrCreate('accessAllowRegister', true)
    if (mode === 'login_required') {
      AppStorage.setOrCreate('accessGuestBrowse', false)
      AppStorage.setOrCreate('accessGuestWrite', false)
      AppStorage.setOrCreate('accessOnPrivacyRefuse', 'exit')
      AppStorage.setOrCreate('accessGateActions', 'create,submit,ai_chat')
    } else if (mode === 'open_optional') {
      AppStorage.setOrCreate('accessGuestBrowse', true)
      AppStorage.setOrCreate('accessGuestWrite', false)
      AppStorage.setOrCreate('accessOnPrivacyRefuse', 'browse_basic')
      AppStorage.setOrCreate('accessGateActions', 'create,submit,ai_chat,sync')
    } else {
      AppStorage.setOrCreate('accessGuestBrowse', true)
      AppStorage.setOrCreate('accessGuestWrite', false)
      AppStorage.setOrCreate('accessOnPrivacyRefuse', 'browse_basic')
      AppStorage.setOrCreate('accessGateActions', 'create,submit,ai_chat,sync')
    }
  }
}
