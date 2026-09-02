/**
 * HCDS Theme — ArkTS strict-mode compatible token accessors.
 * Source of truth: knowledge/design-system/tokens.json
 */

export type ColorMode = 'light' | 'dark' | 'system'

export class ThemeColors {
  brandPrimary: string = '#1A1A2E'
  brandPrimaryPressed: string = '#12121F'
  brandPrimaryContainer: string = '#EFE6C8'
  brandOnPrimary: string = '#F5F0E8'
  brandDeep: string = '#1A1A2E'
  brandAccent: string = '#C9A84C'
  surfacePage: string = '#F5F0E8'
  surfaceSubtle: string = '#EBE4D6'
  surfaceCard: string = '#FDFBF7'
  surfaceGlass: string = 'rgba(253,251,247,0.86)'
  surfaceInverse: string = '#1A1A2E'
  textPrimary: string = '#2C2C2C'
  textSecondary: string = '#5A5A5A'
  textTertiary: string = '#5A5A5A'
  textOnInverse: string = '#F5F0E8'
  strokeHairline: string = 'rgba(26,26,46,0.08)'
  strokeStrong: string = 'rgba(201,168,76,0.45)'
  success: string = '#2F6B4F'
  successContainer: string = '#E4F0E8'
  warning: string = '#C9A84C'
  warningContainer: string = '#F4E8C4'
  danger: string = '#C0392B'
  dangerContainer: string = '#F8E4E1'
  info: string = '#1A1A2E'
  overlayScrim: string = 'rgba(26,26,46,0.48)'
  chart1: string = '#1A1A2E'
  chart2: string = '#C9A84C'
  chart3: string = '#C0392B'
  chart4: string = '#5A5A5A'
  chart5: string = '#8A7A55'
}

export class ThemeSpace {
  s0: number = 0
  s1: number = 4
  s2: number = 8
  s3: number = 12
  s4: number = 16
  s5: number = 20
  s6: number = 24
  s7: number = 32
  s8: number = 40
  s9: number = 48
  s10: number = 64
  pageX: number = 16
  pageY: number = 16
  section: number = 32
  cardPadding: number = 16
  listItemY: number = 12
  inline: number = 8
  textStack: number = 2
}

export class ThemeRadius {
  // Official: https://developer.huawei.com/consumer/cn/doc/design-guides/corner-radius-parameter-0000002556468705
  xs: number = 4
  sm: number = 8
  md: number = 16
  lg: number = 20
  xl: number = 24
  sheet: number = 32
  pill: number = 999
}

export class ThemeTypeScale {
  // Official HarmonyOS phone tokens (vp)
  // https://developer.huawei.com/consumer/cn/doc/design-guides/typography-0000002622688363
  displayL: number = 56
  displayM: number = 48
  displayS: number = 38
  titleL: number = 30
  titleM: number = 24
  titleS: number = 20
  subtitleL: number = 18
  subtitleM: number = 16
  subtitleS: number = 14
  bodyL: number = 16
  bodyM: number = 14
  bodyS: number = 12
  captionL: number = 12
  captionM: number = 10

  // HCDS aliases → official phone scale
  display: number = 38
  title1: number = 30
  title2: number = 24
  title3: number = 20
  body: number = 16
  callout: number = 16
  subhead: number = 14
  footnote: number = 12
  caption: number = 12
  overline: number = 10
}

export class ThemeMotion {
  instant: number = 80
  fast: number = 150
  normal: number = 240
  slow: number = 320
  emphasis: number = 420
  staggerMs: number = 45
}

export class ThemeIconSize {
  sm: number = 16
  md: number = 20
  lg: number = 24
  xl: number = 28
  minTouch: number = 44
}

export class ThemeNav {
  tabHeight: number = 56
  tabMax: number = 5
}

export class Theme {
  static readonly space: ThemeSpace = new ThemeSpace()
  static readonly radius: ThemeRadius = new ThemeRadius()
  static readonly type: ThemeTypeScale = new ThemeTypeScale()
  static readonly motion: ThemeMotion = new ThemeMotion()
  static readonly icon: ThemeIconSize = new ThemeIconSize()
  static readonly nav: ThemeNav = new ThemeNav()

  private static mode: ColorMode = 'system'
  private static forcedDark: boolean = false

  static setColorMode(mode: ColorMode): void {
    Theme.mode = mode
    AppStorage.setOrCreate('colorMode', mode)
    AppStorage.setOrCreate('darkModeOn', mode === 'dark')
    const epoch = (AppStorage.get<number>('themeEpoch') ?? 0) + 1
    AppStorage.setOrCreate('themeEpoch', epoch)
  }

  static setForcedDark(dark: boolean): void {
    Theme.forcedDark = dark
  }

  static isDark(): boolean {
    if (Theme.mode === 'dark') {
      return true
    }
    if (Theme.mode === 'light') {
      return false
    }
    return Theme.forcedDark
  }

  static colors(): ThemeColors {
    if (Theme.isDark()) {
      return Theme.darkColors()
    }
    return Theme.lightColors()
  }

  static applyBrandPrimary(hex: string): void {
    AppStorage.setOrCreate('brandPrimary', hex)
  }

  static lightColors(): ThemeColors {
    return new ThemeColors()
  }

  static darkColors(): ThemeColors {
    const c = new ThemeColors()
    c.brandPrimary = '#C9A84C'
    c.brandPrimaryPressed = '#B8943A'
    c.brandPrimaryContainer = '#3A3420'
    c.brandOnPrimary = '#1A1A2E'
    c.brandDeep = '#1A1A2E'
    c.brandAccent = '#C9A84C'
    c.surfacePage = '#1A1A2E'
    c.surfaceSubtle = '#222236'
    c.surfaceCard = '#2A2A3E'
    c.surfaceGlass = 'rgba(42,42,62,0.86)'
    c.surfaceInverse = '#F5F0E8'
    c.textPrimary = '#F5F0E8'
    c.textSecondary = '#E4DCC8'
    c.textTertiary = '#C9BEA6'
    c.textOnInverse = '#1A1A2E'
    c.strokeHairline = 'rgba(245,240,232,0.10)'
    c.strokeStrong = 'rgba(201,168,76,0.55)'
    c.success = '#7DCEA0'
    c.successContainer = '#1E3A2C'
    c.warning = '#C9A84C'
    c.warningContainer = '#3A3420'
    c.danger = '#E07468'
    c.dangerContainer = '#3F1C1A'
    c.info = '#C9A84C'
    c.overlayScrim = 'rgba(0,0,0,0.56)'
    c.chart1 = '#C9A84C'
    c.chart2 = '#E4DCC8'
    c.chart3 = '#E07468'
    c.chart4 = '#7DCEA0'
    c.chart5 = '#C9BEA6'
    return c
  }

  static shadowSm(): string {
    return Theme.isDark() ? '0 1vp 2vp rgba(0,0,0,0.25)' : '0 1vp 2vp rgba(10,37,64,0.04)'
  }

  static shadowMd(): string {
    return Theme.isDark() ? '0 4vp 16vp rgba(0,0,0,0.35)' : '0 4vp 16vp rgba(10,37,64,0.06)'
  }
}
