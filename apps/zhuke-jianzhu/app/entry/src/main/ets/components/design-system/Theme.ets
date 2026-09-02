/**
 * 筑科建筑 — premium-business 设计令牌
 * 主色 #1677FF · 工程灰 #344054 · 背景 #F7F8FA
 */

export type ColorMode = 'light' | 'dark' | 'system'

export class ThemeColors {
  brandPrimary: string = '#1677FF'
  brandPrimaryPressed: string = '#0958D9'
  brandPrimaryContainer: string = '#E6F4FF'
  brandOnPrimary: string = '#FFFFFF'
  brandDeep: string = '#344054'
  brandAccent: string = '#4096FF'
  surfacePage: string = '#F7F8FA'
  surfaceSubtle: string = '#EFF1F5'
  surfaceCard: string = '#FFFFFF'
  surfaceGlass: string = 'rgba(255,255,255,0.88)'
  surfaceInverse: string = '#344054'
  textPrimary: string = '#101828'
  textSecondary: string = '#344054'
  textTertiary: string = '#667085'
  textOnInverse: string = '#F9FAFB'
  strokeHairline: string = 'rgba(16,24,40,0.06)'
  strokeStrong: string = 'rgba(16,24,40,0.12)'
  success: string = '#12B76A'
  successContainer: string = '#ECFDF3'
  warning: string = '#F79009'
  warningContainer: string = '#FFFAEB'
  danger: string = '#F04438'
  dangerContainer: string = '#FEF3F2'
  info: string = '#1677FF'
  overlayScrim: string = 'rgba(52,64,84,0.45)'
  chart1: string = '#1677FF'
  chart2: string = '#12B76A'
  chart3: string = '#F79009'
  chart4: string = '#6941C6'
  chart5: string = '#667085'
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
  pageY: number = 16
  section: number = 32
  cardPadding: number = 20
  listItemY: number = 12
  inline: number = 8
  textStack: number = 4
}

export class ThemeRadius {
  xs: number = 4
  sm: number = 8
  md: number = 12
  lg: number = 16
  xl: number = 20
  card: number = 16
  sheet: number = 24
  pill: number = 999
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
  title1: number = 28
  title2: number = 22
  title3: number = 18
  body: number = 16
  callout: number = 16
  subhead: number = 14
  footnote: number = 12
  caption: number = 12
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
}

export class ThemeShadow {
  radius: number = 24
  color: string = 'rgba(16,24,40,0.06)'
  offsetX: number = 0
  offsetY: number = 4
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
    c.brandPrimary = '#4096FF'
    c.brandPrimaryPressed = '#69B1FF'
    c.brandPrimaryContainer = '#111A2C'
    c.brandOnPrimary = '#041018'
    c.brandDeep = '#1D2939'
    c.brandAccent = '#69B1FF'
    c.surfacePage = '#0C111D'
    c.surfaceSubtle = '#161B26'
    c.surfaceCard = '#1D2433'
    c.surfaceGlass = 'rgba(29,36,51,0.88)'
    c.surfaceInverse = '#F2F4F7'
    c.textPrimary = '#F9FAFB'
    c.textSecondary = '#98A2B3'
    c.textTertiary = '#667085'
    c.textOnInverse = '#101828'
    c.strokeHairline = 'rgba(249,250,251,0.08)'
    c.strokeStrong = 'rgba(249,250,251,0.14)'
    c.success = '#32D583'
    c.successContainer = '#053321'
    c.warning = '#FDB022'
    c.warningContainer = '#4A1F04'
    c.danger = '#F97066'
    c.dangerContainer = '#55160C'
    c.info = '#4096FF'
    c.overlayScrim = 'rgba(0,0,0,0.56)'
    c.chart1 = '#4096FF'
    c.chart2 = '#32D583'
    c.chart3 = '#FDB022'
    c.chart4 = '#B692F6'
    c.chart5 = '#98A2B3'
    return c
  }

  static cardShadow(): ThemeShadow {
    const s = new ThemeShadow()
    s.radius = Theme.isDark() ? 20 : 24
    s.color = Theme.isDark() ? 'rgba(0,0,0,0.35)' : 'rgba(16,24,40,0.06)'
    s.offsetX = 0
    s.offsetY = Theme.isDark() ? 6 : 4
    return s
  }
}
