/**
 * 避暑游记 Theme — 清凉蓝玻璃风，深浅模式高对比。
 */

export type ColorMode = 'light' | 'dark' | 'system'

export class ThemeColors {
  brandPrimary: string = '#4A90D9'
  brandPrimaryPressed: string = '#357ABD'
  brandPrimaryContainer: string = '#D6E9F8'
  brandOnPrimary: string = '#FFFFFF'
  brandDeep: string = '#1B4F72'
  brandAccent: string = '#2E8B57'
  surfacePage: string = '#E8F4FD'
  surfaceSubtle: string = '#D7EAF8'
  surfaceCard: string = 'rgba(255,255,255,0.88)'
  surfaceGlass: string = 'rgba(255,255,255,0.72)'
  surfaceInverse: string = '#1B4F72'
  textPrimary: string = '#0F172A'
  textSecondary: string = '#475569'
  textTertiary: string = '#64748B'
  textOnInverse: string = '#F8FAFC'
  strokeHairline: string = 'rgba(27,79,114,0.10)'
  strokeStrong: string = 'rgba(27,79,114,0.18)'
  success: string = '#2E8B57'
  successContainer: string = '#D8F0E4'
  warning: string = '#B45309'
  warningContainer: string = '#F8E6D4'
  danger: string = '#BE123C'
  dangerContainer: string = '#FFE4E6'
  info: string = '#4A90D9'
  overlayScrim: string = 'rgba(15,23,42,0.46)'
  chart1: string = '#4A90D9'
  chart2: string = '#2E8B57'
  chart3: string = '#1B4F72'
  chart4: string = '#7EB6E8'
  chart5: string = '#F5A623'
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
  pageY: number = 20
  section: number = 28
  cardPadding: number = 16
  listItemY: number = 12
  inline: number = 8
  textStack: number = 2
}

export class ThemeRadius {
  xs: number = 10
  sm: number = 14
  md: number = 20
  lg: number = 24
  xl: number = 28
  sheet: number = 32
  pill: number = 999
  card: number = 24
}

export class ThemeTypeScale {
  displayL: number = 56
  displayM: number = 48
  displayS: number = 38
  titleL: number = 32
  titleM: number = 26
  titleS: number = 20
  subtitleL: number = 18
  subtitleM: number = 16
  subtitleS: number = 14
  bodyL: number = 16
  bodyM: number = 15
  bodyS: number = 13
  captionL: number = 13
  captionM: number = 11
  display: number = 32
  title1: number = 32
  title2: number = 26
  title3: number = 20
  body: number = 16
  callout: number = 16
  subhead: number = 14
  footnote: number = 13
  caption: number = 13
  overline: number = 11
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
  lift: number = 28
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
    c.brandPrimary = '#7EB6E8'
    c.brandPrimaryPressed = '#A8D0F2'
    c.brandPrimaryContainer = '#1E3A54'
    c.brandOnPrimary = '#0B1220'
    c.brandDeep = '#0B1220'
    c.brandAccent = '#5FBF8A'
    c.surfacePage = '#0B1220'
    c.surfaceSubtle = '#132033'
    c.surfaceCard = 'rgba(24,38,56,0.88)'
    c.surfaceGlass = 'rgba(24,38,56,0.72)'
    c.surfaceInverse = '#E8F4FD'
    c.textPrimary = '#F1F5F9'
    c.textSecondary = '#CBD5E1'
    c.textTertiary = '#94A3B8'
    c.textOnInverse = '#0F172A'
    c.strokeHairline = 'rgba(232,244,253,0.10)'
    c.strokeStrong = 'rgba(232,244,253,0.18)'
    c.success = '#5FBF8A'
    c.successContainer = '#163024'
    c.warning = '#FBBF24'
    c.warningContainer = '#3D2A0A'
    c.danger = '#FB7185'
    c.dangerContainer = '#3F1520'
    c.info = '#7EB6E8'
    c.overlayScrim = 'rgba(0,0,0,0.56)'
    c.chart1 = '#7EB6E8'
    c.chart2 = '#5FBF8A'
    c.chart3 = '#F1F5F9'
    c.chart4 = '#4A90D9'
    c.chart5 = '#F5A623'
    return c
  }

  static shadowSm(): string {
    return Theme.isDark() ? '0 1vp 2vp rgba(0,0,0,0.25)' : '0 1vp 2vp rgba(27,79,114,0.06)'
  }

  static shadowMd(): string {
    return Theme.isDark() ? '0 4vp 16vp rgba(0,0,0,0.35)' : '0 8vp 24vp rgba(27,79,114,0.10)'
  }
}
