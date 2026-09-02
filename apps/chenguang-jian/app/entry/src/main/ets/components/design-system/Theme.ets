/**
 * 晨光笺 Theme — 米白纸张 + 暖金晨光 + 深灰正文。
 */

export type ColorMode = 'light' | 'dark' | 'system'

export class ThemeColors {
  brandPrimary: string = '#A67C52'
  brandPrimaryPressed: string = '#8E6844'
  brandPrimaryContainer: string = '#F3E6D4'
  brandOnPrimary: string = '#FFFFFF'
  brandDeep: string = '#3D3228'
  brandAccent: string = '#D4A574'
  surfacePage: string = '#F5F0E8'
  surfaceSubtle: string = '#EDE6DA'
  surfaceCard: string = '#FFFBF5'
  surfaceGlass: string = 'rgba(255,251,245,0.86)'
  surfaceInverse: string = '#3D3D3D'
  textPrimary: string = '#3D3D3D'
  textSecondary: string = '#6B635C'
  textTertiary: string = '#7A726B'
  textOnInverse: string = '#F5F0E8'
  strokeHairline: string = '#E6DCCE'
  strokeStrong: string = '#D8CCBA'
  success: string = '#6E9A78'
  successContainer: string = '#E4F0E6'
  warning: string = '#C4924A'
  warningContainer: string = '#F6EBD8'
  danger: string = '#B56A5C'
  dangerContainer: string = '#F6E4DF'
  info: string = '#6B635C'
  overlayScrim: string = 'rgba(61,50,40,0.42)'
  chart1: string = '#A67C52'
  chart2: string = '#6E9A78'
  chart3: string = '#D4A574'
  chart4: string = '#C4B4A8'
  chart5: string = '#6B635C'
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
  pageX: number = 24
  pageY: number = 16
  section: number = 32
  cardPadding: number = 20
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
  displayL: number = 56
  displayM: number = 48
  displayS: number = 38
  titleL: number = 30
  titleM: number = 28
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
  title1: number = 28
  title2: number = 24
  title3: number = 20
  body: number = 16
  callout: number = 16
  subhead: number = 14
  footnote: number = 13
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
  tabMax: number = 3
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

  static applyFontLevel(level: number): void {
    const compact = level <= 0
    const large = level >= 2
    Theme.type.title1 = compact ? 24 : (large ? 32 : 28)
    Theme.type.title2 = compact ? 22 : (large ? 26 : 24)
    Theme.type.title3 = compact ? 18 : (large ? 22 : 20)
    Theme.type.body = compact ? 15 : (large ? 18 : 16)
    Theme.type.callout = Theme.type.body
    Theme.type.subhead = compact ? 13 : (large ? 16 : 14)
    Theme.type.footnote = compact ? 12 : (large ? 14 : 13)
    Theme.type.caption = compact ? 11 : (large ? 13 : 12)
    AppStorage.setOrCreate('fontLevel', level)
  }

  static lightColors(): ThemeColors {
    return new ThemeColors()
  }

  static darkColors(): ThemeColors {
    const c = new ThemeColors()
    c.brandPrimary = '#D4A574'
    c.brandPrimaryPressed = '#E0B68A'
    c.brandPrimaryContainer = '#3A3026'
    c.brandOnPrimary = '#1C1916'
    c.brandDeep = '#1C1916'
    c.brandAccent = '#E0B68A'
    c.surfacePage = '#1C1916'
    c.surfaceSubtle = '#241F1B'
    c.surfaceCard = '#2A2622'
    c.surfaceGlass = 'rgba(42,38,34,0.86)'
    c.surfaceInverse = '#F5F0E8'
    c.textPrimary = '#F5F0E8'
    c.textSecondary = '#D4C8B8'
    c.textTertiary = '#A89888'
    c.textOnInverse = '#3D3D3D'
    c.strokeHairline = 'rgba(245,240,232,0.12)'
    c.strokeStrong = 'rgba(245,240,232,0.20)'
    c.success = '#8FBF9A'
    c.successContainer = '#243028'
    c.warning = '#E0B56E'
    c.warningContainer = '#3A2F1C'
    c.danger = '#E08A86'
    c.dangerContainer = '#3A2422'
    c.info = '#D4C8B8'
    c.overlayScrim = 'rgba(0,0,0,0.56)'
    c.chart1 = '#D4A574'
    c.chart2 = '#8FBF9A'
    c.chart3 = '#E0B56E'
    c.chart4 = '#C4B4A8'
    c.chart5 = '#D4C8B8'
    return c
  }
}
