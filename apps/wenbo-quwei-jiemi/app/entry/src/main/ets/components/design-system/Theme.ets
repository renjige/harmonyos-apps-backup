/**
 * HCDS Theme — ArkTS strict-mode compatible token accessors.
 * Brand: primary #007AFF · accent #FF6B35 · success #34C759
 */

export type ColorMode = 'light' | 'dark' | 'system'

export class ThemeColors {
  brandPrimary: string = '#007AFF'
  brandPrimaryPressed: string = '#0066DD'
  brandPrimaryContainer: string = '#E5F2FF'
  brandOnPrimary: string = '#FFFFFF'
  brandDeep: string = '#003D80'
  brandAccent: string = '#FF6B35'
  surfacePage: string = '#F7F9FC'
  surfaceSubtle: string = '#EEF2F8'
  surfaceCard: string = '#FFFFFF'
  surfaceGlass: string = 'rgba(255,255,255,0.78)'
  surfaceInverse: string = '#003D80'
  textPrimary: string = '#1E2A3A'
  textSecondary: string = '#4A5B73'
  textTertiary: string = '#6B7C93'
  textOnInverse: string = '#F8FAFC'
  strokeHairline: string = 'rgba(30,42,58,0.06)'
  strokeStrong: string = 'rgba(30,42,58,0.12)'
  success: string = '#34C759'
  successContainer: string = '#DDFBE6'
  warning: string = '#FF9500'
  warningContainer: string = '#FFF4E5'
  danger: string = '#FF3B30'
  dangerContainer: string = '#FFE8E6'
  info: string = '#007AFF'
  overlayScrim: string = 'rgba(30,42,58,0.40)'
  chart1: string = '#007AFF'
  chart2: string = '#34C759'
  chart3: string = '#FF6B35'
  chart4: string = '#5AC8FA'
  chart5: string = '#6B7C93'
  mint: string = '#34C759'
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
  card: number = 24
}

export class ThemeTypeScale {
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
    c.brandPrimary = '#409CFF'
    c.brandPrimaryPressed = '#66B0FF'
    c.brandPrimaryContainer = '#0A2847'
    c.brandOnPrimary = '#041018'
    c.brandDeep = '#051A33'
    c.brandAccent = '#FF8A5C'
    c.surfacePage = '#0E1524'
    c.surfaceSubtle = '#162033'
    c.surfaceCard = '#17243A'
    c.surfaceGlass = 'rgba(23,36,58,0.76)'
    c.surfaceInverse = '#E8EEF7'
    c.textPrimary = '#F1F5F9'
    c.textSecondary = '#A8B6C8'
    c.textTertiary = '#7B8CA3'
    c.textOnInverse = '#1E2A3A'
    c.strokeHairline = 'rgba(248,250,252,0.08)'
    c.strokeStrong = 'rgba(248,250,252,0.16)'
    c.success = '#4CD964'
    c.successContainer = '#123822'
    c.warning = '#FF9F0A'
    c.warningContainer = '#3D2A0A'
    c.danger = '#FF6961'
    c.dangerContainer = '#3F1520'
    c.info = '#409CFF'
    c.overlayScrim = 'rgba(0,0,0,0.56)'
    c.chart1 = '#409CFF'
    c.chart2 = '#4CD964'
    c.chart3 = '#FF8A5C'
    c.chart4 = '#64D2FF'
    c.chart5 = '#94A3B8'
    c.mint = '#4CD964'
    return c
  }

  static shadowSm(): string {
    return Theme.isDark() ? '0 1vp 2vp rgba(0,0,0,0.25)' : '0 1vp 2vp rgba(10,37,64,0.04)'
  }

  static shadowMd(): string {
    return Theme.isDark() ? '0 4vp 16vp rgba(0,0,0,0.35)' : '0 4vp 16vp rgba(10,37,64,0.06)'
  }
}
