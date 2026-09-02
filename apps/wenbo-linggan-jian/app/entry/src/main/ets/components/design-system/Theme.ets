/**
 * HCDS Theme — ArkTS strict-mode compatible token accessors.
 * Source of truth: knowledge/design-system/tokens.json
 */

export type ColorMode = 'light' | 'dark' | 'system'

export class ThemeColors {
  brandPrimary: string = '#18233A'
  brandPrimaryPressed: string = '#10182A'
  brandPrimaryContainer: string = '#E8E2D4'
  brandOnPrimary: string = '#F7F3EA'
  brandDeep: string = '#18233A'
  brandAccent: string = '#D9AE62'
  surfacePage: string = '#F7F3EA'
  surfaceSubtle: string = '#EEE8DC'
  surfaceCard: string = '#FFFDF8'
  surfaceGlass: string = 'rgba(255,253,248,0.86)'
  surfaceInverse: string = '#18233A'
  textPrimary: string = '#293044'
  textSecondary: string = '#5C6373'
  textTertiary: string = '#858B99'
  textOnInverse: string = '#F7F3EA'
  strokeHairline: string = '#E8E2D4'
  strokeStrong: string = '#D9D1C2'
  success: string = '#5B7A68'
  successContainer: string = '#E4EEE8'
  warning: string = '#D9AE62'
  warningContainer: string = '#F6ECD6'
  danger: string = '#A85A52'
  dangerContainer: string = '#F4E4E1'
  info: string = '#858B99'
  overlayScrim: string = 'rgba(24,35,58,0.40)'
  chart1: string = '#18233A'
  chart2: string = '#D9AE62'
  chart3: string = '#5B7A68'
  chart4: string = '#8A7A62'
  chart5: string = '#858B99'
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
  pageX: number = 20
  pageY: number = 16
  section: number = 32
  cardPadding: number = 20
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
  card: number = 20
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
  title1: number = 28
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
  tabMax: number = 4
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

  static applyFontLevel(level: number): void {
    const compact = level <= 0
    const large = level >= 2
    Theme.type.title1 = compact ? 24 : (large ? 32 : 28)
    Theme.type.title2 = compact ? 22 : (large ? 26 : 24)
    Theme.type.title3 = compact ? 18 : (large ? 22 : 20)
    Theme.type.body = compact ? 15 : (large ? 18 : 16)
    Theme.type.callout = Theme.type.body
    Theme.type.subhead = compact ? 13 : (large ? 16 : 14)
    Theme.type.footnote = compact ? 12 : (large ? 14 : 13)
    Theme.type.caption = compact ? 11 : (large ? 13 : 12)
    AppStorage.setOrCreate('fontLevel', level)
  }

  static lightColors(): ThemeColors {
    return new ThemeColors()
  }

  static darkColors(): ThemeColors {
    const c = new ThemeColors()
    c.brandPrimary = '#E5B86B'
    c.brandPrimaryPressed = '#D9AE62'
    c.brandPrimaryContainer = '#2A3348'
    c.brandOnPrimary = '#18233A'
    c.brandDeep = '#10182A'
    c.brandAccent = '#E5B86B'
    c.surfacePage = '#121826'
    c.surfaceSubtle = '#1A2233'
    c.surfaceCard = '#1E2738'
    c.surfaceGlass = 'rgba(30,39,56,0.86)'
    c.surfaceInverse = '#F7F3EA'
    c.textPrimary = '#F4EFE4'
    c.textSecondary = '#B7B3A8'
    c.textTertiary = '#8A877C'
    c.textOnInverse = '#18233A'
    c.strokeHairline = 'rgba(244,239,228,0.10)'
    c.strokeStrong = 'rgba(244,239,228,0.18)'
    c.success = '#8FBF9A'
    c.successContainer = '#243028'
    c.warning = '#E0B56E'
    c.warningContainer = '#3A2F1C'
    c.danger = '#E08A86'
    c.dangerContainer = '#3A2422'
    c.info = '#B7B3A8'
    c.overlayScrim = 'rgba(0,0,0,0.56)'
    c.chart1 = '#E5B86B'
    c.chart2 = '#8FBF9A'
    c.chart3 = '#F4EFE4'
    c.chart4 = '#8A7A62'
    c.chart5 = '#B7B3A8'
    return c
  }

  static shadowSm(): string {
    return Theme.isDark() ? '0 1vp 2vp rgba(0,0,0,0.25)' : '0 1vp 2vp rgba(10,37,64,0.04)'
  }

  static shadowMd(): string {
    return Theme.isDark() ? '0 4vp 16vp rgba(0,0,0,0.35)' : '0 4vp 16vp rgba(10,37,64,0.06)'
  }
}
