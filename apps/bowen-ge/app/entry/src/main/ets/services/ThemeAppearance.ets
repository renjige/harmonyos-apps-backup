import { Configuration, ConfigurationConstant, common } from '@kit.AbilityKit'
import { ColorMode, Theme } from '../components/design-system/Theme'

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
    Theme.setColorMode(normalized)
    if (normalized === 'system') {
      ThemeAppearance.syncSystemDark(hostContext)
    } else {
      Theme.setForcedDark(normalized === 'dark')
    }
    ThemeAppearance.applyAppColorMode(normalized, hostContext)
    ThemeAppearance.bumpEpoch()
  }

  static applyStored(hostContext?: common.UIAbilityContext): void {
    const stored = AppStorage.get<string>('colorMode')
    const mode = stored !== undefined && stored.length > 0 ? stored : 'system'
    ThemeAppearance.apply(mode, hostContext)
  }

  static toggle(hostContext?: common.UIAbilityContext): boolean {
    const nextDark = !Theme.isDark()
    ThemeAppearance.apply(nextDark ? 'dark' : 'light', hostContext)
    return nextDark
  }

  static onSystemConfiguration(config: Configuration): void {
    const mode = AppStorage.get<string>('colorMode') ?? 'system'
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
