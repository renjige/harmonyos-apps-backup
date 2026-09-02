/**
 * 星座物候 Theme — 月光纸 + 星空蓝 + 自然绿
 */

export type ColorMode = 'light' | 'dark' | 'system'
export type FontScaleId = 'small' | 'medium' | 'large'

export class ThemeColors {
  brandPrimary: string = '#43587C'
  brandPrimaryPressed: string = '#354866'
  brandPrimaryContainer: string = '#E8EEF4'
  brandOnPrimary: string = '#F7F8FA'
  brandDeep: string = '#101827'
  brandAccent: string = '#7FA58F'
  moonlight: string = '#DCE3EC'
  surfacePage: string = '#F7F8FA'
  surfaceSubtle: string = '#EEF1F5'
  surfaceCard: string = '#FFFFFF'
  surfaceGlass: string = 'rgba(255,255,255,0.88)'
  surfaceInverse: string = '#101827'
  textPrimary: string = '#1B2430'
  textSecondary: string = '#788395'
  textTertiary: string = '#8B97A8'
  textOnInverse: string = '#DCE3EC'
  strokeHairline: string = 'rgba(27,36,48,0.06)'
  strokeStrong: string = 'rgba(27,36,48,0.12)'
  success: string = '#7FA58F'
  successContainer: string = '#E7F0EA'
  warning: string = '#B45309'
  warningContainer: string = '#F8E6D4'
  danger: string = '#BE123C'
  dangerContainer: string = '#FFE4E6'
  info: string = '#43587C'
  overlayScrim: string = 'rgba(16,24,39,0.46)'
  chart1: string = '#43587C'
  chart2: string = '#7FA58F'
  chart3: string = '#DCE3EC'
  chart4: string = '#788395'
  chart5: string = '#1B2430'
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
  pageX: number = 22
  pageY: number = 20
  section: number = 28
  cardPadding: number = 20
  listItemY: number = 12
  inline: number = 8
  textStack: number = 4
}

export class ThemeRadius {
  xs: number = 8
  sm: number = 12
  md: number = 20
  lg: number = 22
  xl: number = 24
  sheet: number = 28
  pill: number = 999
  card: number = 22
}

export class ThemeTypeScale {
  displayL: number = 40
  displayM: number = 34
  displayS: number = 30
  titleL: number = 32
  titleM: number = 28
  titleS: number = 22
  subtitleL: number = 18
  subtitleM: number = 16
  subtitleS: number = 14
  bodyL: number = 16
  bodyM: number = 15
  bodyS: number = 13
  captionL: number = 13
  captionM: number = 12
  display: number = 32
  title1: number = 30
  title2: number = 22
  title3: number = 20
  body: number = 16
  callout: number = 15
  subhead: number = 14
  footnote: number = 13
  caption: number = 12
  overline: number = 12
}

export class ThemeMotion {
  instant: number = 80
  fast: number = 180
  normal: number = 280
  slow: number = 420
  emphasis: number = 560
  staggerMs: number = 40
}

export class ThemeIconSize {
  sm: number = 16
  md: number = 20
  lg: number = 24
  xl: number = 28
  minTouch: number = 44
}

export class ThemeNav {
  tabHeight: number = 58
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

  static fontScale(): number {
    const v = AppStorage.get<string>('fontScale') ?? 'medium'
    if (v === 'small') {
      return 0.92
    }
    if (v === 'large') {
      return 1.12
    }
    return 1
  }

  static scaled(size: number): number {
    return Math.round(size * Theme.fontScale())
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
    c.brandPrimary = '#9BB0C9'
    c.brandPrimaryPressed = '#DCE3EC'
    c.brandPrimaryContainer = '#1C2A3D'
    c.brandOnPrimary = '#101827'
    c.brandDeep = '#0B1018'
    c.brandAccent = '#8FB59C'
    c.moonlight = '#DCE3EC'
    c.surfacePage = '#101827'
    c.surfaceSubtle = '#161F2E'
    c.surfaceCard = '#182033'
    c.surfaceGlass = 'rgba(24,32,51,0.88)'
    c.surfaceInverse = '#DCE3EC'
    c.textPrimary = '#E8EDF3'
    c.textSecondary = '#9AA6B5'
    c.textTertiary = '#7C8796'
    c.textOnInverse = '#101827'
    c.strokeHairline = 'rgba(220,227,236,0.08)'
    c.strokeStrong = 'rgba(220,227,236,0.16)'
    c.success = '#8FB59C'
    c.successContainer = '#1C2E26'
    c.warning = '#FBBF24'
    c.warningContainer = '#3D2A0A'
    c.danger = '#FB7185'
    c.dangerContainer = '#3F1520'
    c.info = '#9BB0C9'
    c.overlayScrim = 'rgba(0,0,0,0.56)'
    c.chart1 = '#9BB0C9'
    c.chart2 = '#8FB59C'
    c.chart3 = '#DCE3EC'
    c.chart4 = '#7C8796'
    c.chart5 = '#E8EDF3'
    return c
  }
}
