/**
 * AppSpec.access 运行时视图。格物集为纯本地应用，无登录注册。
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
      return false
    }
    const parts = raw.split(',')
    for (let p of parts) {
      if (p.trim() === action) {
        return true
      }
    }
    return false
  }

  /** EntryAbility 注入；localOnly=true 时关闭注册、开放游客读写、无门禁动作 */
  static applyDefaults(mode: AccessMode, allowRegister: boolean = true): void {
    AppStorage.setOrCreate('accessMode', mode)
    AppStorage.setOrCreate('accessAllowRegister', allowRegister)
    if (!allowRegister) {
      AppStorage.setOrCreate('accessGuestBrowse', true)
      AppStorage.setOrCreate('accessGuestWrite', true)
      AppStorage.setOrCreate('accessOnPrivacyRefuse', 'browse_basic')
      AppStorage.setOrCreate('accessGateActions', '')
      return
    }
    if (mode === 'login_required') {
      AppStorage.setOrCreate('accessGuestBrowse', false)
      AppStorage.setOrCreate('accessGuestWrite', false)
      AppStorage.setOrCreate('accessOnPrivacyRefuse', 'exit')
      AppStorage.setOrCreate('accessGateActions', 'create,submit')
    } else if (mode === 'open_optional') {
      AppStorage.setOrCreate('accessGuestBrowse', true)
      AppStorage.setOrCreate('accessGuestWrite', false)
      AppStorage.setOrCreate('accessOnPrivacyRefuse', 'browse_basic')
      AppStorage.setOrCreate('accessGateActions', 'create,submit,sync')
    } else {
      AppStorage.setOrCreate('accessGuestBrowse', true)
      AppStorage.setOrCreate('accessGuestWrite', false)
      AppStorage.setOrCreate('accessOnPrivacyRefuse', 'browse_basic')
      AppStorage.setOrCreate('accessGateActions', 'create,submit,sync')
    }
  }
}
