/**
 * HCDS Theme — ArkTS strict-mode compatible token accessors.
 * Source of truth: knowledge/design-system/tokens.json
 */

export type ColorMode = 'light' | 'dark' | 'system'

export class ThemeColors {
  brandPrimary: string = '#16A34A'
  brandPrimaryPressed: string = '#15803D'
  brandPrimaryContainer: string = '#DCFCE7'
  brandOnPrimary: string = '#FAFAF5'
  brandDeep: string = '#15803D'
  brandAccent: string = '#FB923C'
  surfacePage: string = '#FAFAF5'
  surfaceSubtle: string = '#F0F4EA'
  surfaceCard: string = '#FFFFFF'
  surfaceGlass: string = 'rgba(255,255,255,0.92)'
  surfaceInverse: string = '#15803D'
  textPrimary: string = '#1A1A1A'
  textSecondary: string = '#4B5563'
  textTertiary: string = '#6B7280'
  textOnInverse: string = '#FAFAF5'
  strokeHairline: string = 'rgba(21,128,61,0.08)'
  strokeStrong: string = 'rgba(21,128,61,0.16)'
  success: string = '#16A34A'
  successContainer: string = '#DCFCE7'
  warning: string = '#D97706'
  warningContainer: string = '#FEF3C7'
  danger: string = '#BE123C'
  dangerContainer: string = '#FFE4E6'
  info: string = '#16A34A'
  overlayScrim: string = 'rgba(21,128,61,0.46)'
  chart1: string = '#16A34A'
  chart2: string = '#FB923C'
  chart3: string = '#6B7280'
  chart4: string = '#86EFAC'
  chart5: string = '#FDBA74'
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
  card: number = 12
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
    c.brandPrimary = '#9FBF8E'
    c.brandPrimaryPressed = '#B7D0A8'
    c.brandPrimaryContainer = '#24352B'
    c.brandOnPrimary = '#121A12'
    c.brandDeep = '#101810'
    c.brandAccent = '#E8A06A'
    c.surfacePage = '#121916'
    c.surfaceSubtle = '#1A221C'
    c.surfaceCard = '#1E2622'
    c.surfaceGlass = 'rgba(30,38,34,0.82)'
    c.surfaceInverse = '#F5F0E8'
    c.textPrimary = '#F3EFE7'
    c.textSecondary = '#CBD5E1'
    c.textTertiary = '#94A3B8'
    c.textOnInverse = '#0F172A'
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
    c.chart1 = '#5BA3E0'
    c.chart2 = '#2DD4BF'
    c.chart3 = '#FBBF24'
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
