/**
 * HCDS Theme — ArkTS strict-mode compatible token accessors.
 * Source of truth: knowledge/design-system/tokens.json
 */

export type ColorMode = 'light' | 'dark' | 'system'

export class ThemeColors {
  brandPrimary: string = '#F5A623'
  brandPrimaryPressed: string = '#D4891A'
  brandPrimaryContainer: string = '#FFF0D6'
  brandOnPrimary: string = '#FFFFFF'
  brandDeep: string = '#2C2C2C'
  brandAccent: string = '#FF8A7A'
  surfacePage: string = '#FFF8F0'
  surfaceSubtle: string = '#FFF0E0'
  surfaceCard: string = '#FFFFFF'
  surfaceGlass: string = 'rgba(255,255,255,0.88)'
  surfaceInverse: string = '#2C2C2C'
  textPrimary: string = '#2C2C2C'
  textSecondary: string = '#5A4A3A'
  textTertiary: string = '#7A6A5A'
  textOnInverse: string = '#FFF8F0'
  strokeHairline: string = 'rgba(44,44,44,0.08)'
  strokeStrong: string = 'rgba(44,44,44,0.14)'
  success: string = '#D4891A'
  successContainer: string = '#FFF0D6'
  warning: string = '#B45309'
  warningContainer: string = '#FEF3C7'
  danger: string = '#BE123C'
  dangerContainer: string = '#FFE4E6'
  info: string = '#D4891A'
  overlayScrim: string = 'rgba(44,44,44,0.42)'
  chart1: string = '#F5A623'
  chart2: string = '#FF8A7A'
  chart3: string = '#B45309'
  chart4: string = '#6366F1'
  chart5: string = '#7A6A5A'
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
  card: number = 20
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
    const stored = AppStorage.get<boolean>('darkMode')
    if (stored === true) {
      return true
    }
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
    c.brandPrimary = '#FFB84D'
    c.brandPrimaryPressed = '#F5A623'
    c.brandPrimaryContainer = '#3D3020'
    c.brandOnPrimary = '#1A1408'
    c.brandDeep = '#1A1612'
    c.brandAccent = '#FF9A8A'
    c.surfacePage = '#1A1612'
    c.surfaceSubtle = '#252018'
    c.surfaceCard = '#2C2620'
    c.surfaceGlass = 'rgba(44,38,32,0.78)'
    c.surfaceInverse = '#FFF8F0'
    c.textPrimary = '#FFF5E8'
    c.textSecondary = '#E8D8C8'
    c.textTertiary = '#C8B8A8'
    c.textOnInverse = '#2C2C2C'
    c.strokeHairline = 'rgba(255,245,232,0.10)'
    c.strokeStrong = 'rgba(255,245,232,0.18)'
    c.success = '#FFB84D'
    c.successContainer = '#3D3020'
    c.warning = '#FBBF24'
    c.warningContainer = '#3D2A0A'
    c.danger = '#FB7185'
    c.dangerContainer = '#3F1520'
    c.info = '#FFB84D'
    c.overlayScrim = 'rgba(0,0,0,0.56)'
    c.chart1 = '#FFB84D'
    c.chart2 = '#FF9A8A'
    c.chart3 = '#FBBF24'
    c.chart4 = '#A5B4FC'
    c.chart5 = '#C8B8A8'
    return c
  }

  static shadowSm(): string {
    return Theme.isDark() ? '0 1vp 2vp rgba(0,0,0,0.25)' : '0 1vp 2vp rgba(10,37,64,0.04)'
  }

  static shadowMd(): string {
    return Theme.isDark() ? '0 4vp 16vp rgba(0,0,0,0.35)' : '0 4vp 16vp rgba(10,37,64,0.06)'
  }
}
