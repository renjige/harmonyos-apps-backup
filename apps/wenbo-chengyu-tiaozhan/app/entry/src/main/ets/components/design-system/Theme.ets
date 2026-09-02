/**
 * HCDS Theme — ArkTS strict-mode compatible token accessors.
 * Source of truth: knowledge/design-system/tokens.json
 */

export type ColorMode = 'light' | 'dark' | 'system'

export class ThemeColors {
  brandPrimary: string = '#C41A1A'
  brandPrimaryPressed: string = '#9E1414'
  brandPrimaryContainer: string = '#F8E6E4'
  brandOnPrimary: string = '#FFFFFF'
  brandDeep: string = '#1A1A1A'
  brandAccent: string = '#B8860B'
  surfacePage: string = '#F8F5F0'
  surfaceSubtle: string = '#EFE8DC'
  surfaceCard: string = '#FFFBF6'
  surfaceGlass: string = 'rgba(255,251,246,0.82)'
  surfaceInverse: string = '#1C1A18'
  textPrimary: string = '#1A1A1A'
  textSecondary: string = '#5C5348'
  textTertiary: string = '#6B6258'
  textOnInverse: string = '#F5F0E8'
  strokeHairline: string = 'rgba(26,26,26,0.08)'
  strokeStrong: string = 'rgba(26,26,26,0.16)'
  success: string = '#1F7A4D'
  successContainer: string = '#D8F0E4'
  warning: string = '#B8860B'
  warningContainer: string = '#F8EBC8'
  danger: string = '#C41A1A'
  dangerContainer: string = '#F8E6E4'
  info: string = '#C41A1A'
  overlayScrim: string = 'rgba(28,26,24,0.46)'
  chart1: string = '#C41A1A'
  chart2: string = '#B8860B'
  chart3: string = '#5C5348'
  chart4: string = '#1A1A1A'
  chart5: string = '#8A7A68'
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
  card: number = 24
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
    c.brandPrimary = '#E84A4A'
    c.brandPrimaryPressed = '#FF6B6B'
    c.brandPrimaryContainer = '#3A1A1A'
    c.brandOnPrimary = '#1A1A1A'
    c.brandDeep = '#F5F0E8'
    c.brandAccent = '#E8C86A'
    c.surfacePage = '#1C1A18'
    c.surfaceSubtle = '#2A2622'
    c.surfaceCard = '#26221E'
    c.surfaceGlass = 'rgba(38,34,30,0.82)'
    c.surfaceInverse = '#F5F0E8'
    c.textPrimary = '#F0E8DC'
    c.textSecondary = '#C9BDB0'
    c.textTertiary = '#A89A8C'
    c.textOnInverse = '#1A1A1A'
    c.strokeHairline = 'rgba(245,240,232,0.10)'
    c.strokeStrong = 'rgba(245,240,232,0.18)'
    c.success = '#5DCAA0'
    c.successContainer = '#143326'
    c.warning = '#E8C86A'
    c.warningContainer = '#3D2E0A'
    c.danger = '#E84A4A'
    c.dangerContainer = '#3A1A1A'
    c.info = '#E84A4A'
    c.overlayScrim = 'rgba(0,0,0,0.58)'
    c.chart1 = '#E84A4A'
    c.chart2 = '#E8C86A'
    c.chart3 = '#C9BDB0'
    c.chart4 = '#F0E8DC'
    c.chart5 = '#A89A8C'
    return c
  }

  static shadowSm(): string {
    return Theme.isDark() ? '0 1vp 2vp rgba(0,0,0,0.25)' : '0 1vp 2vp rgba(10,37,64,0.04)'
  }

  static shadowMd(): string {
    return Theme.isDark() ? '0 4vp 16vp rgba(0,0,0,0.35)' : '0 4vp 16vp rgba(10,37,64,0.06)'
  }
}
