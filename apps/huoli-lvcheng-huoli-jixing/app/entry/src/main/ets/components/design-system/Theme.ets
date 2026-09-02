/**
 * HCDS Theme — ArkTS strict-mode compatible token accessors.
 * Source of truth: knowledge/design-system/tokens.json
 */

export type ColorMode = 'light' | 'dark' | 'system'

export class ThemeColors {
  brandPrimary: string = '#0B6BCB'
  brandPrimaryPressed: string = '#0958A8'
  brandPrimaryContainer: string = '#D7E9F8'
  brandOnPrimary: string = '#FFFFFF'
  brandDeep: string = '#0A2540'
  brandAccent: string = '#3D8BDB'
  surfacePage: string = '#F2F4F7'
  surfaceSubtle: string = '#E8ECF1'
  surfaceCard: string = '#FFFFFF'
  surfaceGlass: string = 'rgba(255,255,255,0.72)'
  surfaceInverse: string = '#0A2540'
  textPrimary: string = '#0F172A'
  textSecondary: string = '#475569'
  textTertiary: string = '#64748B'
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
    c.brandPrimary = '#FF6B35'
    c.brandPrimaryPressed = '#E55A28'
    c.brandPrimaryContainer = '#FFE8DF'
    c.brandDeep = '#1A2A3A'
    c.brandAccent = '#F7DC6F'
    c.surfacePage = '#F8F6F3'
    c.surfaceSubtle = '#EDE9E4'
    c.surfaceCard = '#FFFFFF'
    c.textPrimary = '#1A2A3A'
    c.textSecondary = '#4A5568'
    c.textTertiary = '#6B7280'
    c.success = '#2ECC71'
    c.successContainer = '#D5F5E3'
    c.chart1 = '#FF6B35'
    c.chart2 = '#2ECC71'
    c.chart3 = '#F7DC6F'
    c.chart4 = '#1A2A3A'
    c.chart5 = '#FFB088'
    c.overlayScrim = 'rgba(26,42,58,0.40)'
    return c
  }

  static darkColors(): ThemeColors {
    const c = new ThemeColors()
    c.brandPrimary = '#FF8A5C'
    c.brandPrimaryPressed = '#FF9F76'
    c.brandPrimaryContainer = '#3D2A22'
    c.brandOnPrimary = '#1A1210'
    c.brandDeep = '#0F1419'
    c.brandAccent = '#F7DC6F'
    c.surfacePage = '#121820'
    c.surfaceSubtle = '#1A2430'
    c.surfaceCard = '#1E2A38'
    c.surfaceGlass = 'rgba(30,42,56,0.72)'
    c.surfaceInverse = '#F8F6F3'
    c.textPrimary = '#F5F3EE'
    c.textSecondary = '#C8C4BC'
    c.textTertiary = '#9A9690'
    c.textOnInverse = '#1A2A3A'
    c.strokeHairline = 'rgba(245,243,238,0.08)'
    c.strokeStrong = 'rgba(245,243,238,0.16)'
    c.success = '#2ECC71'
    c.successContainer = '#1A3D2A'
    c.warning = '#F7DC6F'
    c.warningContainer = '#3D3520'
    c.danger = '#FF6B6B'
    c.dangerContainer = '#3D2020'
    c.info = '#5DADE2'
    c.overlayScrim = 'rgba(0,0,0,0.56)'
    c.chart1 = '#FF8A5C'
    c.chart2 = '#2ECC71'
    c.chart3 = '#F7DC6F'
    c.chart4 = '#8BAFC3'
    c.chart5 = '#FFB088'
    return c
  }

  static shadowSm(): string {
    return Theme.isDark() ? '0 1vp 2vp rgba(0,0,0,0.25)' : '0 1vp 2vp rgba(10,37,64,0.04)'
  }

  static shadowMd(): string {
    return Theme.isDark() ? '0 4vp 16vp rgba(0,0,0,0.35)' : '0 4vp 16vp rgba(10,37,64,0.06)'
  }
}
