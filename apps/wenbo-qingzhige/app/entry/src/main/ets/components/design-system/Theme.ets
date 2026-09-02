/**
 * HCDS Theme — 轻知阁：深青蓝 × 暖米白 × 金杏色
 */

export type ColorMode = 'light' | 'dark' | 'system'

export class ThemeColors {
  brandPrimary: string = '#1B4A5C'
  brandPrimaryPressed: string = '#163C4B'
  brandPrimaryContainer: string = '#E4EEF1'
  brandOnPrimary: string = '#FFFFFF'
  brandDeep: string = '#122A36'
  brandAccent: string = '#D4A574'
  surfacePage: string = '#F6F1EA'
  surfaceSubtle: string = '#EFE8DC'
  surfaceCard: string = '#FFFFFF'
  surfaceGlass: string = 'rgba(255,255,255,0.82)'
  surfaceInverse: string = '#122A36'
  textPrimary: string = '#1E2A30'
  textSecondary: string = '#5C6A72'
  textTertiary: string = '#6E7C84'
  textOnInverse: string = '#F6F1EA'
  strokeHairline: string = '#E8E2D6'
  strokeStrong: string = '#D9D2C4'
  success: string = '#1B4A5C'
  successContainer: string = '#E4EEF1'
  warning: string = '#B45309'
  warningContainer: string = '#F8ECD8'
  danger: string = '#C46A6A'
  dangerContainer: string = '#F8E4E2'
  info: string = '#3D6A7A'
  overlayScrim: string = 'rgba(18,42,54,0.40)'
  chart1: string = '#1B4A5C'
  chart2: string = '#3D6A7A'
  chart3: string = '#D4A574'
  chart4: string = '#C4B4A8'
  chart5: string = '#6E7C84'
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
    c.brandPrimary = '#8FB8C6'
    c.brandPrimaryPressed = '#A3C6D2'
    c.brandPrimaryContainer = '#1E3340'
    c.brandOnPrimary = '#122A36'
    c.brandDeep = '#0C1C24'
    c.brandAccent = '#D4A574'
    c.surfacePage = '#121C22'
    c.surfaceSubtle = '#1A262D'
    c.surfaceCard = '#223038'
    c.surfaceGlass = 'rgba(34,48,56,0.82)'
    c.surfaceInverse = '#F6F1EA'
    c.textPrimary = '#F4EFE6'
    c.textSecondary = '#B7C2C8'
    c.textTertiary = '#8A969C'
    c.textOnInverse = '#122A36'
    c.strokeHairline = 'rgba(246,241,234,0.08)'
    c.strokeStrong = 'rgba(246,241,234,0.16)'
    c.success = '#8FB8C6'
    c.successContainer = '#1E3340'
    c.warning = '#D4A574'
    c.warningContainer = '#3D2A0A'
    c.danger = '#E08A8A'
    c.dangerContainer = '#3F1520'
    c.info = '#8FB8C6'
    c.overlayScrim = 'rgba(0,0,0,0.56)'
    c.chart1 = '#8FB8C6'
    c.chart2 = '#1B4A5C'
    c.chart3 = '#D4A574'
    c.chart4 = '#C4B4A8'
    c.chart5 = '#B7C2C8'
    return c
  }

  static shadowSm(): string {
    return Theme.isDark() ? '0 1vp 2vp rgba(0,0,0,0.25)' : '0 1vp 2vp rgba(18,42,54,0.04)'
  }

  static shadowMd(): string {
    return Theme.isDark() ? '0 4vp 16vp rgba(0,0,0,0.35)' : '0 4vp 16vp rgba(18,42,54,0.06)'
  }
}
