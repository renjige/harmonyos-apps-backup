/**
 * HCDS Theme — ArkTS strict-mode compatible token accessors.
 * Source of truth: knowledge/design-system/tokens.json
 */

export type ColorMode = 'light' | 'dark' | 'system'

export class ThemeColors {
  brandPrimary: string = '#5E3F4F'
  brandPrimaryPressed: string = '#4A3240'
  brandPrimaryContainer: string = '#E8DDE4'
  brandOnPrimary: string = '#FFFCF7'
  brandDeep: string = '#3F2C36'
  brandAccent: string = '#C4A574'
  surfacePage: string = '#F6F1E8'
  surfaceSubtle: string = '#EEE6DA'
  surfaceCard: string = '#FFFCF7'
  surfaceGlass: string = 'rgba(255,252,247,0.86)'
  surfaceInverse: string = '#3F2C36'
  textPrimary: string = '#2C2926'
  textSecondary: string = '#6A645C'
  textTertiary: string = '#8A837A'
  textOnInverse: string = '#F7F3EC'
  strokeHairline: string = 'rgba(94,63,79,0.08)'
  strokeStrong: string = 'rgba(94,63,79,0.16)'
  success: string = '#5C6B5A'
  successContainer: string = '#E4EAE3'
  warning: string = '#8A6A3C'
  warningContainer: string = '#F3E8D4'
  danger: string = '#8A4A52'
  dangerContainer: string = '#F3E4E6'
  info: string = '#5E3F4F'
  overlayScrim: string = 'rgba(63,44,54,0.40)'
  chart1: string = '#5E3F4F'
  chart2: string = '#C4A574'
  chart3: string = '#6B7A6A'
  chart4: string = '#8B6B7A'
  chart5: string = '#8A837A'
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
  cardPadding: number = 16
  listItemY: number = 12
  inline: number = 8
  textStack: number = 2
}

export class ThemeRadius {
  // Official: https://developer.huawei.com/consumer/cn/doc/design-guides/corner-radius-parameter-0000002556468705
  xs: number = 8
  sm: number = 12
  md: number = 16
  lg: number = 20
  xl: number = 22
  sheet: number = 28
  pill: number = 999
  tag: number = 14
  card: number = 22
  button: number = 18
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
    c.brandPrimary = '#C9B4BE'
    c.brandPrimaryPressed = '#D8C6CE'
    c.brandPrimaryContainer = '#3A2C34'
    c.brandOnPrimary = '#1C1618'
    c.brandDeep = '#1C1618'
    c.brandAccent = '#C4A574'
    c.surfacePage = '#1C1816'
    c.surfaceSubtle = '#26211E'
    c.surfaceCard = '#2A2421'
    c.surfaceGlass = 'rgba(42,36,33,0.78)'
    c.surfaceInverse = '#F6F1E8'
    c.textPrimary = '#F4EEE6'
    c.textSecondary = '#C2B8AE'
    c.textTertiary = '#9A9188'
    c.textOnInverse = '#2C2926'
    c.strokeHairline = 'rgba(244,238,230,0.08)'
    c.strokeStrong = 'rgba(244,238,230,0.16)'
    c.success = '#A8B8A6'
    c.successContainer = '#2A3329'
    c.warning = '#D4B48A'
    c.warningContainer = '#3A2E1C'
    c.danger = '#D4A0A6'
    c.dangerContainer = '#3A2428'
    c.info = '#C9B4BE'
    c.overlayScrim = 'rgba(0,0,0,0.56)'
    c.chart1 = '#C9B4BE'
    c.chart2 = '#C4A574'
    c.chart3 = '#A8B8A6'
    c.chart4 = '#B8A0AC'
    c.chart5 = '#9A9188'
    return c
  }

  static shadowSm(): string {
    return Theme.isDark() ? '0 1vp 2vp rgba(0,0,0,0.25)' : '0 1vp 2vp rgba(94,63,79,0.04)'
  }

  static shadowMd(): string {
    return Theme.isDark() ? '0 4vp 16vp rgba(0,0,0,0.35)' : '0 4vp 12vp rgba(94,63,79,0.06)'
  }
}
