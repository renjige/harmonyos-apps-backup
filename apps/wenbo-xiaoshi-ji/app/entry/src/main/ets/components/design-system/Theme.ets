/**
 * HCDS Theme — ArkTS strict-mode compatible token accessors.
 * Source of truth: knowledge/design-system/tokens.json
 */

export type ColorMode = 'light' | 'dark' | 'system'

export class ThemeColors {
  brandPrimary: string = '#C44A22'
  brandPrimaryPressed: string = '#A33B1C'
  brandPrimaryContainer: string = '#F3D5C6'
  brandOnPrimary: string = '#FFFFFF'
  brandDeep: string = '#9A3A18'
  brandAccent: string = '#0F766E'
  surfacePage: string = '#FAF8F5'
  surfaceSubtle: string = '#F0EBE4'
  surfaceCard: string = '#FFFFFF'
  surfaceGlass: string = 'rgba(255,255,255,0.80)'
  surfaceInverse: string = '#2D2D2D'
  textPrimary: string = '#2D2D2D'
  textSecondary: string = '#5C5C5C'
  textTertiary: string = '#6B6B70'
  textOnInverse: string = '#F8FAFC'
  strokeHairline: string = 'rgba(15,23,42,0.06)'
  strokeStrong: string = 'rgba(15,23,42,0.12)'
  success: string = '#0F766E'
  successContainer: string = '#CCFBF1'
  warning: string = '#B45309'
  warningContainer: string = '#FEF3C7'
  danger: string = '#BE123C'
  dangerContainer: string = '#FFE4E6'
  info: string = '#0369A1'
  overlayScrim: string = 'rgba(10,37,64,0.40)'
  chart1: string = '#0B6BCB'
  chart2: string = '#0F766E'
  chart3: string = '#B45309'
  chart4: string = '#6366F1'
  chart5: string = '#64748B'
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
    const c = new ThemeColors()
    c.brandPrimary = '#C44A22'
    c.brandPrimaryPressed = '#A33B1C'
    c.brandPrimaryContainer = '#F3D5C6'
    c.brandDeep = '#9A3A18'
    c.brandAccent = '#0F766E'
    c.surfacePage = '#FAF8F5'
    c.surfaceSubtle = '#EDE6DC'
    c.surfaceCard = '#FFFFFF'
    c.textPrimary = '#1F1F1F'
    c.textSecondary = '#3D3D3D'
    c.textTertiary = '#4A4844'
    c.danger = '#BE123C'
    c.chart1 = '#C44A22'
    c.chart2 = '#0F766E'
    c.chart3 = '#9A5A2A'
    c.chart4 = '#3D6A80'
    c.chart5 = '#5C534C'
    return c
  }

  static darkColors(): ThemeColors {
    const c = new ThemeColors()
    c.brandPrimary = '#FF8A5B'
    c.brandPrimaryPressed = '#FFA07A'
    c.brandPrimaryContainer = '#5A3220'
    c.brandOnPrimary = '#FFFFFF'
    c.brandDeep = '#C44A22'
    c.brandAccent = '#7EE0D8'
    c.surfacePage = '#1C1916'
    c.surfaceSubtle = '#2A2622'
    c.surfaceCard = '#312C28'
    c.surfaceGlass = 'rgba(49,44,40,0.78)'
    c.surfaceInverse = '#FAF8F5'
    c.textPrimary = '#F5F1EC'
    c.textSecondary = '#D0CBC4'
    c.textTertiary = '#A8A29A'
    c.textOnInverse = '#2D2D2D'
    c.strokeHairline = 'rgba(245,241,236,0.08)'
    c.strokeStrong = 'rgba(245,241,236,0.16)'
    c.success = '#7EE0D8'
    c.successContainer = '#1E3A38'
    c.warning = '#E8A87C'
    c.warningContainer = '#3D2A18'
    c.danger = '#F08080'
    c.dangerContainer = '#3D2020'
    c.info = '#7EC8E0'
    c.overlayScrim = 'rgba(0,0,0,0.56)'
    c.chart1 = '#FF8A5B'
    c.chart2 = '#7EE0D8'
    c.chart3 = '#E8A87C'
    c.chart4 = '#7AA3B8'
    c.chart5 = '#C4B8A8'
    return c
  }

  static shadowSm(): string {
    return Theme.isDark() ? '0 1vp 2vp rgba(0,0,0,0.25)' : '0 1vp 2vp rgba(10,37,64,0.04)'
  }

  static shadowMd(): string {
    return Theme.isDark() ? '0 4vp 16vp rgba(0,0,0,0.35)' : '0 4vp 16vp rgba(10,37,64,0.06)'
  }
}
