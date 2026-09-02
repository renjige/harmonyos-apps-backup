import { Configuration, ConfigurationConstant, common } from '@kit.AbilityKit'
import { ColorMode, Theme } from '../components/design-system/Theme'
import { ShoppingNotifyService } from './ShoppingNotifyService'

/** 深色模式统一切换 — 持久化 appearance + themeEpoch 触发全 App 实时刷新 */
export class ThemeAppearance {
  private static host: common.UIAbilityContext | null = null

  static init(context: common.UIAbilityContext): void {
    ThemeAppearance.host = context
  }

  static normalize(mode: string): ColorMode {
    if (mode === 'dark' || mode === 'light') {
      return mode
    }
    return 'system'
  }

  static apply(mode: string, hostContext?: common.UIAbilityContext): void {
    const ctx = hostContext !== undefined ? hostContext : ThemeAppearance.resolveContext()
    const normalized = ThemeAppearance.normalize(mode)
    AppStorage.setOrCreate('appearance', normalized)
    if (normalized === 'system') {
      ThemeAppearance.syncSystemDark(ctx)
    } else {
      Theme.setForcedDark(normalized === 'dark')
    }
    Theme.setColorMode(normalized)
    ThemeAppearance.applyAppColorMode(normalized, ctx)
    ThemeAppearance.bumpEpoch()
  }

  static applyStored(hostContext?: common.UIAbilityContext): void {
    const stored = AppStorage.get<string>('appearance')
    const mode = stored !== undefined && stored.length > 0 ? stored : 'system'
    ThemeAppearance.apply(mode, hostContext)
  }

  static onSystemConfiguration(config: Configuration): void {
    const mode = AppStorage.get<string>('appearance') ?? 'system'
    if (mode !== 'system') {
      return
    }
    Theme.setForcedDark(config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK)
    ThemeAppearance.bumpEpoch()
  }

  static bumpEpoch(): void {
    const rev = (AppStorage.get<number>('themeEpoch') ?? 0) + 1
    AppStorage.setOrCreate('themeEpoch', rev)
  }

  private static resolveContext(): common.UIAbilityContext | undefined {
    if (ThemeAppearance.host !== null) {
      return ThemeAppearance.host
    }
    return ShoppingNotifyService.hostContext()
  }

  private static syncSystemDark(hostContext?: common.UIAbilityContext): void {
    try {
      if (hostContext !== undefined) {
        Theme.setForcedDark(hostContext.config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK)
        return
      }
    } catch {
    }
    Theme.setForcedDark(false)
  }

  private static applyAppColorMode(mode: ColorMode, hostContext?: common.UIAbilityContext): void {
    if (hostContext === undefined) {
      return
    }
    try {
      const appCtx = hostContext.getApplicationContext()
      if (mode === 'dark') {
        appCtx.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK)
        return
      }
      if (mode === 'light') {
        appCtx.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT)
        return
      }
      appCtx.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET)
      ThemeAppearance.syncSystemDark(hostContext)
    } catch {
    }
  }
}
