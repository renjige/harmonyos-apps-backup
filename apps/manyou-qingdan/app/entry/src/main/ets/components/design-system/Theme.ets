/**
 * HCDS Theme — ArkTS strict-mode compatible token accessors.
 * Source of truth: knowledge/design-system/tokens.json
 */

export type ColorMode = 'light' | 'dark' | 'system'

export class ThemeColors {
  brandPrimary: string = '#0EA5E9'
  brandPrimaryPressed: string = '#0284C7'
  brandPrimaryContainer: string = '#E0F2FE'
  brandOnPrimary: string = '#FFFFFF'
  brandDeep: string = '#0C4A6E'
  brandAccent: string = '#34D399'
  surfacePage: string = '#F8FAFC'
  surfaceSubtle: string = '#F1F5F9'
  surfaceCard: string = '#FFFFFF'
  surfaceGlass: string = 'rgba(255,255,255,0.82)'
  surfaceInverse: string = '#0C4A6E'
  textPrimary: string = '#0F172A'
  textSecondary: string = '#475569'
  textTertiary: string = '#64748B'
  textOnInverse: string = '#F8FAFC'
  strokeHairline: string = 'rgba(12,74,110,0.08)'
  strokeStrong: string = 'rgba(12,74,110,0.16)'
  success: string = '#34D399'
  successContainer: string = '#D1FAE5'
  warning: string = '#F97316'
  warningContainer: string = '#FFEDD5'
  danger: string = '#BE123C'
  dangerContainer: string = '#FFE4E6'
  info: string = '#0EA5E9'
  overlayScrim: string = 'rgba(12,74,110,0.42)'
  chart1: string = '#0EA5E9'
  chart2: string = '#34D399'
  chart3: string = '#F97316'
  chart4: string = '#0C4A6E'
  chart5: string = '#94A3B8'
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
    c.brandPrimary = '#38BDF8'
    c.brandPrimaryPressed = '#7DD3FC'
    c.brandPrimaryContainer = '#0C4A6E'
    c.brandOnPrimary = '#0C4A6E'
    c.brandDeep = '#082F49'
    c.brandAccent = '#6EE7B7'
    c.surfacePage = '#0F172A'
    c.surfaceSubtle = '#1E293B'
    c.surfaceCard = '#1E293B'
    c.surfaceGlass = 'rgba(30,41,59,0.78)'
    c.surfaceInverse = '#F8FAFC'
    c.textPrimary = '#F8FAFC'
    c.textSecondary = '#CBD5E1'
    c.textTertiary = '#94A3B8'
    c.textOnInverse = '#0F172A'
    c.strokeHairline = 'rgba(248,250,252,0.10)'
    c.strokeStrong = 'rgba(248,250,252,0.18)'
    c.success = '#6EE7B7'
    c.successContainer = '#064E3B'
    c.warning = '#FB923C'
    c.warningContainer = '#431407'
    c.danger = '#FB7185'
    c.dangerContainer = '#3F1520'
    c.info = '#38BDF8'
    c.overlayScrim = 'rgba(0,0,0,0.56)'
    c.chart1 = '#38BDF8'
    c.chart2 = '#6EE7B7'
    c.chart3 = '#FB923C'
    c.chart4 = '#F8FAFC'
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
