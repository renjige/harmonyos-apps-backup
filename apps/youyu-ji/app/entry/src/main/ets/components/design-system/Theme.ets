/**
 * 悠隅纪 Theme — 暖杏窗隅 · 米白纸面
 */

export type ColorMode = 'light' | 'dark' | 'system'

export class ThemeColors {
  brandPrimary: string = '#D4A574'
  brandPrimaryPressed: string = '#C49463'
  brandPrimaryContainer: string = '#F3E6D4'
  brandOnPrimary: string = '#3D2B1F'
  brandDeep: string = '#3D2B1F'
  brandAccent: string = '#E8D4B8'
  surfacePage: string = '#F9F6F0'
  surfaceSubtle: string = '#F1EBE3'
  surfaceCard: string = '#FFFFFF'
  surfaceGlass: string = 'rgba(255,255,255,0.86)'
  surfaceInverse: string = '#3D2B1F'
  textPrimary: string = '#2C2C2C'
  textSecondary: string = '#6B645C'
  textTertiary: string = '#7A726A'
  textOnInverse: string = '#F9F6F0'
  strokeHairline: string = 'rgba(61,43,31,0.08)'
  strokeStrong: string = 'rgba(61,43,31,0.16)'
  success: string = '#5C6B5A'
  successContainer: string = '#E4EAE3'
  warning: string = '#8A6A3C'
  warningContainer: string = '#F3E8D4'
  danger: string = '#8A4A52'
  dangerContainer: string = '#F3E4E6'
  info: string = '#D4A574'
  overlayScrim: string = 'rgba(61,43,31,0.40)'
  chart1: string = '#D4A574'
  chart2: string = '#3D2B1F'
  chart3: string = '#6B7A6A'
  chart4: string = '#C4A090'
  chart5: string = '#7A726A'
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
  xs: number = 8
  sm: number = 12
  md: number = 16
  lg: number = 20
  xl: number = 22
  sheet: number = 28
  pill: number = 999
  tag: number = 14
  card: number = 16
  button: number = 18
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
  bodyM: number = 15
  bodyS: number = 12
  captionL: number = 12
  captionM: number = 10
  display: number = 38
  title1: number = 30
  title2: number = 24
  title3: number = 20
  body: number = 15
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
    c.brandPrimary = '#E0C09A'
    c.brandPrimaryPressed = '#E8D4B8'
    c.brandPrimaryContainer = '#3A322C'
    c.brandOnPrimary = '#1C1C1E'
    c.brandDeep = '#1C1C1E'
    c.brandAccent = '#E8D4B8'
    c.surfacePage = '#1C1C1E'
    c.surfaceSubtle = '#242426'
    c.surfaceCard = '#2C2C2E'
    c.surfaceGlass = 'rgba(44,44,46,0.82)'
    c.surfaceInverse = '#F9F6F0'
    c.textPrimary = '#F5F5F5'
    c.textSecondary = '#D4CDC4'
    c.textTertiary = '#A89F94'
    c.textOnInverse = '#2C2C2C'
    c.strokeHairline = 'rgba(245,245,245,0.08)'
    c.strokeStrong = 'rgba(245,245,245,0.16)'
    c.success = '#A8B8A6'
    c.successContainer = '#2A3329'
    c.warning = '#D4B48A'
    c.warningContainer = '#3A2E1C'
    c.danger = '#D4A0A6'
    c.dangerContainer = '#3A2428'
    c.info = '#E0C09A'
    c.overlayScrim = 'rgba(0,0,0,0.56)'
    c.chart1 = '#E0C09A'
    c.chart2 = '#F5F5F5'
    c.chart3 = '#A8B8A6'
    c.chart4 = '#C4A090'
    c.chart5 = '#A89F94'
    return c
  }

  static shadowSm(): string {
    return Theme.isDark() ? '0 1vp 2vp rgba(0,0,0,0.25)' : '0 1vp 2vp rgba(61,43,31,0.06)'
  }

  static shadowMd(): string {
    return Theme.isDark() ? '0 4vp 16vp rgba(0,0,0,0.35)' : '0 4vp 12vp rgba(61,43,31,0.08)'
  }
}
