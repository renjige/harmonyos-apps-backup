import { Configuration, ConfigurationConstant, common } from '@kit.AbilityKit'
import { ColorMode, Theme } from '../components/design-system/Theme'
import { AppContextService } from './AppContextService'

/** 深色模式统一切换 — 持久化 + themeEpoch 触发全 App 实时刷新 */
export class ThemeAppearance {
  static normalize(mode: string): ColorMode {
    if (mode === 'dark' || mode === 'light') {
      return mode
    }
    return 'system'
  }

  static apply(mode: string, hostContext?: common.UIAbilityContext): void {
    const normalized = ThemeAppearance.normalize(mode)
    const ctx = hostContext !== undefined ? hostContext : ThemeAppearance.resolveContext()
    Theme.setColorMode(normalized)
    if (normalized === 'system') {
      ThemeAppearance.syncSystemDark(ctx)
    } else {
      Theme.setForcedDark(normalized === 'dark')
    }
    ThemeAppearance.applyAppColorMode(normalized, ctx)
    ThemeAppearance.bumpEpoch()
  }

  static applyStored(hostContext?: common.UIAbilityContext): void {
    const stored = AppStorage.get<string>('colorMode')
    const mode = stored !== undefined && stored.length > 0 ? stored : 'system'
    ThemeAppearance.apply(mode, hostContext)
  }

  static onSystemConfiguration(config: Configuration): void {
    const dark = config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK
    AppStorage.setOrCreate('systemColorDark', dark)
    const mode = AppStorage.get<string>('colorMode') ?? 'system'
    if (mode !== 'system') {
      return
    }
    Theme.setForcedDark(dark)
    ThemeAppearance.bumpEpoch()
  }

  static bumpEpoch(): void {
    const rev = (AppStorage.get<number>('themeEpoch') ?? 0) + 1
    AppStorage.setOrCreate('themeEpoch', rev)
  }

  private static resolveContext(): common.UIAbilityContext | undefined {
    const ctx = AppContextService.getContext()
    return ctx !== null ? ctx : undefined
  }

  private static syncSystemDark(hostContext?: common.UIAbilityContext): void {
    try {
      if (hostContext !== undefined) {
        const dark = hostContext.config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK
        AppStorage.setOrCreate('systemColorDark', dark)
        Theme.setForcedDark(dark)
        return
      }
    } catch {
    }
    const stored = AppStorage.get<boolean>('systemColorDark')
    Theme.setForcedDark(stored === true)
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
