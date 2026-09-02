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
  /** 浅色底卡片/标签文字（禁止 brandAccent 作小字前景） */
  labelOnContainer: string = '#1A2332'
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
    const c = new ThemeColors()
    c.brandPrimary = '#1A2332'
    c.brandPrimaryPressed = '#121820'
    c.brandPrimaryContainer = '#E8E0D4'
    c.brandOnPrimary = '#FFFFFF'
    c.brandDeep = '#1A2332'
    c.brandAccent = '#B8894A'
    c.labelOnContainer = '#1A2332'
    c.surfacePage = '#F7F5F0'
    c.surfaceSubtle = '#EFEBE3'
    c.surfaceCard = '#FFFFFF'
    c.surfaceGlass = 'rgba(255,255,255,0.78)'
    c.surfaceInverse = '#1A2332'
    c.textPrimary = '#1A2332'
    c.textSecondary = '#3D4F63'
    c.textTertiary = '#4A5C6E'
    c.textOnInverse = '#F7F5F0'
    c.strokeHairline = 'rgba(26,35,50,0.08)'
    c.strokeStrong = 'rgba(61,90,128,0.22)'
    c.overlayScrim = 'rgba(26,35,50,0.48)'
    c.chart1 = '#1A2332'
    c.chart2 = '#3D5A80'
    c.chart3 = '#D4A56A'
    return c
  }

  static darkColors(): ThemeColors {
    const c = new ThemeColors()
    c.brandPrimary = '#D4A56A'
    c.brandPrimaryPressed = '#E0B882'
    c.brandPrimaryContainer = '#2A241C'
    c.brandOnPrimary = '#1A2332'
    c.brandDeep = '#0D1117'
    c.brandAccent = '#D4A56A'
    c.labelOnContainer = '#F8FAFC'
    c.surfacePage = '#0D1117'
    c.surfaceSubtle = '#12171E'
    c.surfaceCard = '#161B22'
    c.surfaceGlass = 'rgba(22,27,34,0.78)'
    c.surfaceInverse = '#F7F5F0'
    c.textPrimary = '#F8FAFC'
    c.textSecondary = '#CBD5E1'
    c.textTertiary = '#94A3B8'
    c.textOnInverse = '#1A2332'
    c.strokeHairline = 'rgba(248,250,252,0.08)'
    c.strokeStrong = 'rgba(248,250,252,0.16)'
    c.success = '#2DD4BF'
    c.successContainer = '#0F3D38'
    c.warning = '#FBBF24'
    c.warningContainer = '#3D2A0A'
    c.danger = '#FB7185'
    c.dangerContainer = '#3F1520'
    c.info = '#38BDF8'
    c.overlayScrim = 'rgba(0,0,0,0.56)'
    c.chart1 = '#D4A56A'
    c.chart2 = '#8BA3C7'
    c.chart3 = '#F8FAFC'
    c.chart4 = '#A5B4FC'
    c.chart5 = '#94A3B8'
    return c
  }

  static shadowSm(): string {
    return Theme.isDark() ? '0 1vp 2vp rgba(0,0,0,0.25)' : '0 1vp 2vp rgba(10,37,64,0.04)'
  }

  static shadowMd(): string {
    return Theme.isDark() ? '0 4vp 16vp rgba(0,0,0,0.35)' : '0 4vp 16vp rgba(10,37,64,0.06)'
  }
}
