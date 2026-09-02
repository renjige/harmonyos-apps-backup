/**
 * HCDS Theme — ArkTS strict-mode compatible token accessors.
 * Source of truth: knowledge/design-system/tokens.json
 */

export type ColorMode = 'light' | 'dark' | 'system'

export class ThemeColors {
  brandPrimary: string = '#FF8C42'
  brandPrimaryPressed: string = '#E07028'
  brandPrimaryContainer: string = '#FFE4D2'
  brandOnPrimary: string = '#FFFFFF'
  brandDeep: string = '#5C2E12'
  brandAccent: string = '#2F6FB3'
  surfacePage: string = '#FFF8F0'
  surfaceSubtle: string = '#F3E6D8'
  surfaceCard: string = '#FFFFFF'
  surfaceGlass: string = 'rgba(255,255,255,0.78)'
  surfaceInverse: string = '#5C2E12'
  textPrimary: string = '#2A241C'
  textSecondary: string = '#5C5348'
  textTertiary: string = '#6B6258'
  textOnInverse: string = '#FFF8F0'
  strokeHairline: string = 'rgba(92,46,18,0.08)'
  strokeStrong: string = 'rgba(92,46,18,0.16)'
  success: string = '#3D8A42'
  successContainer: string = '#E3F4E4'
  warning: string = '#B45309'
  warningContainer: string = '#FEF3C7'
  danger: string = '#BE123C'
  dangerContainer: string = '#FFE4E6'
  info: string = '#2F6FB3'
  overlayScrim: string = 'rgba(42,36,28,0.48)'
  chart1: string = '#FF8C42'
  chart2: string = '#2F6FB3'
  chart3: string = '#3D8A42'
  chart4: string = '#C45A18'
  chart5: string = '#5C5348'
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
  card: number = 16
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
    c.brandPrimary = '#FFA05C'
    c.brandPrimaryPressed = '#FF8C42'
    c.brandPrimaryContainer = '#4A2E1C'
    c.brandOnPrimary = '#2A1810'
    c.brandDeep = '#1A1A2E'
    c.brandAccent = '#7EB3F0'
    c.surfacePage = '#1A1A2E'
    c.surfaceSubtle = '#24243A'
    c.surfaceCard = '#2D2D44'
    c.surfaceGlass = 'rgba(45,45,68,0.78)'
    c.surfaceInverse = '#F5F0E8'
    c.textPrimary = '#F5F0E8'
    c.textSecondary = '#C9C2B8'
    c.textTertiary = '#B4ADA3'
    c.textOnInverse = '#1A1A2E'
    c.strokeHairline = 'rgba(245,240,232,0.10)'
    c.strokeStrong = 'rgba(245,240,232,0.18)'
    c.success = '#7BC67E'
    c.successContainer = '#1E3A22'
    c.warning = '#FBBF24'
    c.warningContainer = '#3D2A0A'
    c.danger = '#FB7185'
    c.dangerContainer = '#3F1520'
    c.info = '#7EB3F0'
    c.overlayScrim = 'rgba(0,0,0,0.56)'
    c.chart1 = '#FFA05C'
    c.chart2 = '#7EB3F0'
    c.chart3 = '#7BC67E'
    c.chart4 = '#FBBF24'
    c.chart5 = '#C9C2B8'
    return c
  }

  static shadowSm(): string {
    return Theme.isDark() ? '0 1vp 2vp rgba(0,0,0,0.28)' : '0 1vp 2vp rgba(92,46,18,0.06)'
  }

  static shadowMd(): string {
    return Theme.isDark() ? '0 4vp 16vp rgba(0,0,0,0.38)' : '0 4vp 16vp rgba(92,46,18,0.10)'
  }
}
