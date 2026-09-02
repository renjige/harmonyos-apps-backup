/**
 * HCDS Theme — 书页漫游：暖棕 × 米白 × 砖红强调 × 深绿
 */

export type ColorMode = 'light' | 'dark' | 'system'

export class ThemeColors {
  brandPrimary: string = '#8B6B4D'
  brandPrimaryPressed: string = '#735839'
  brandPrimaryContainer: string = '#EDE4D6'
  brandOnPrimary: string = '#FFFFFF'
  brandDeep: string = '#2D4A3E'
  brandAccent: string = '#C0392B'
  surfacePage: string = '#F0E9DC'
  surfaceSubtle: string = '#E8DFD0'
  surfaceCard: string = '#FFFCF7'
  surfaceGlass: string = 'rgba(255,252,247,0.82)'
  surfaceInverse: string = '#2D4A3E'
  textPrimary: string = '#2A241C'
  textSecondary: string = '#5C5348'
  textTertiary: string = '#756B5E'
  textOnInverse: string = '#F4EFE6'
  strokeHairline: string = '#E0D5C4'
  strokeStrong: string = '#CFC2AE'
  success: string = '#2D4A3E'
  successContainer: string = '#D8E4DE'
  warning: string = '#B45309'
  warningContainer: string = '#F8ECD8'
  danger: string = '#C0392B'
  dangerContainer: string = '#F5DCD8'
  info: string = '#5C7A6A'
  overlayScrim: string = 'rgba(45,74,62,0.40)'
  chart1: string = '#8B6B4D'
  chart2: string = '#2D4A3E'
  chart3: string = '#C0392B'
  chart4: string = '#B8A48E'
  chart5: string = '#756B5E'
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
  cardPadding: number = 16
  listItemY: number = 12
  inline: number = 8
  textStack: number = 2
}

export class ThemeRadius {
  xs: number = 4
  sm: number = 8
  md: number = 16
  lg: number = 18
  xl: number = 24
  sheet: number = 28
  pill: number = 999
  card: number = 16
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
  tabMax: number = 4
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
    c.brandPrimary = '#B8956F'
    c.brandPrimaryPressed = '#C9A680'
    c.brandPrimaryContainer = '#3D3428'
    c.brandOnPrimary = '#1A1510'
    c.brandDeep = '#1E3329'
    c.brandAccent = '#E05A4D'
    c.surfacePage = '#1A1814'
    c.surfaceSubtle = '#242018'
    c.surfaceCard = '#2A2620'
    c.surfaceGlass = 'rgba(42,38,32,0.82)'
    c.surfaceInverse = '#F4EFE6'
    c.textPrimary = '#F4EFE6'
    c.textSecondary = '#C9BFB0'
    c.textTertiary = '#A89E90'
    c.textOnInverse = '#2A241C'
    c.strokeHairline = 'rgba(244,239,230,0.08)'
    c.strokeStrong = 'rgba(244,239,230,0.16)'
    c.success = '#6A9A82'
    c.successContainer = '#1E3329'
    c.warning = '#D4A574'
    c.warningContainer = '#3D2A0A'
    c.danger = '#E05A4D'
    c.dangerContainer = '#3F1520'
    c.info = '#8FA896'
    c.overlayScrim = 'rgba(0,0,0,0.56)'
    c.chart1 = '#B8956F'
    c.chart2 = '#6A9A82'
    c.chart3 = '#E05A4D'
    c.chart4 = '#C9BFB0'
    c.chart5 = '#A89E90'
    return c
  }

  static shadowSm(): string {
    return Theme.isDark() ? '0 1vp 2vp rgba(0,0,0,0.25)' : '0 1vp 2vp rgba(45,74,62,0.04)'
  }

  static shadowMd(): string {
    return Theme.isDark() ? '0 4vp 16vp rgba(0,0,0,0.35)' : '0 4vp 16vp rgba(45,74,62,0.06)'
  }
}
