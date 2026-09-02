/**
 * 筑科材料验收 Design Tokens — 建筑蓝 + 深石墨，浅灰白底。
 */
export type ColorMode = 'light' | 'dark' | 'system'

export class ThemeColors {
  brandPrimary: string = '#1E5A8A'
  brandPrimaryPressed: string = '#174A72'
  brandPrimaryContainer: string = '#E4EEF5'
  brandOnPrimary: string = '#FFFFFF'
  brandDeep: string = '#1A1F26'
  brandAccent: string = '#3D7AB5'
  surfacePage: string = '#F4F5F7'
  surfaceSubtle: string = '#EBEEF2'
  surfaceCard: string = '#FFFFFF'
  surfaceGlass: string = 'rgba(255,255,255,0.78)'
  surfaceInverse: string = '#1A1F26'
  textPrimary: string = '#1A1F26'
  textSecondary: string = '#3A4450'
  textTertiary: string = '#3A4450'
  textOnInverse: string = '#F4F5F7'
  strokeHairline: string = 'rgba(26,31,38,0.08)'
  strokeStrong: string = 'rgba(26,31,38,0.14)'
  success: string = '#4A7C59'
  successContainer: string = '#E6F0E8'
  warning: string = '#C4843A'
  warningContainer: string = '#F6ECDD'
  danger: string = '#A84848'
  dangerContainer: string = '#F4E4E4'
  info: string = '#1E5A8A'
  overlayScrim: string = 'rgba(26,31,38,0.44)'
  chart1: string = '#1E5A8A'
  chart2: string = '#4A7C59'
  chart3: string = '#C4843A'
  chart4: string = '#3D7AB5'
  chart5: string = '#5B6573'
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
  section: number = 28
  cardPadding: number = 16
  listItemY: number = 12
  inline: number = 8
  textStack: number = 2
}

export class ThemeRadius {
  xs: number = 4
  sm: number = 8
  md: number = 16
  lg: number = 16
  xl: number = 20
  sheet: number = 24
  pill: number = 999
  card: number = 16
}

export class ThemeTypeScale {
  displayL: number = 48
  displayM: number = 40
  displayS: number = 36
  titleL: number = 28
  titleM: number = 22
  titleS: number = 20
  subtitleL: number = 18
  subtitleM: number = 16
  subtitleS: number = 14
  bodyL: number = 16
  bodyM: number = 14
  bodyS: number = 13
  captionL: number = 13
  captionM: number = 12
  display: number = 36
  title1: number = 28
  title2: number = 22
  title3: number = 20
  body: number = 16
  callout: number = 16
  subhead: number = 14
  footnote: number = 13
  caption: number = 13
  overline: number = 12
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
    c.brandPrimary = '#1F6AAD'
    c.brandPrimaryPressed = '#3D86C4'
    c.brandPrimaryContainer = '#16324A'
    c.brandOnPrimary = '#FFFFFF'
    c.brandDeep = '#0E1218'
    c.brandAccent = '#8EC4F0'
    c.surfacePage = '#0E1218'
    c.surfaceSubtle = '#3A4A5C'
    c.surfaceCard = '#1A222C'
    c.surfaceGlass = 'rgba(26,34,44,0.88)'
    c.surfaceInverse = '#F2F4F7'
    c.textPrimary = '#F5F7FA'
    c.textSecondary = '#D5DCE6'
    c.textTertiary = '#D5DCE6'
    c.textOnInverse = '#1A1F26'
    c.strokeHairline = 'rgba(245,247,250,0.18)'
    c.strokeStrong = 'rgba(245,247,250,0.28)'
    c.success = '#B6E0BE'
    c.successContainer = '#1A3A24'
    c.warning = '#F0D4A0'
    c.warningContainer = '#3D2C12'
    c.danger = '#F0B4B4'
    c.dangerContainer = '#3A1C1C'
    c.info = '#8EC4F0'
    c.overlayScrim = 'rgba(0,0,0,0.62)'
    c.chart1 = '#4A9BE0'
    c.chart2 = '#B6E0BE'
    c.chart3 = '#F0D4A0'
    c.chart4 = '#8EC4F0'
    c.chart5 = '#D5DCE6'
    return c
  }

  static shadowSm(): string {
    return Theme.isDark() ? '0 1vp 2vp rgba(0,0,0,0.28)' : '0 1vp 2vp rgba(26,31,38,0.04)'
  }

  static shadowMd(): string {
    return Theme.isDark() ? '0 4vp 16vp rgba(0,0,0,0.32)' : '0 2vp 10vp rgba(26,31,38,0.05)'
  }

  static chipFg(on: boolean): string {
    if (on) {
      return '#FFFFFF'
    }
    return Theme.isDark() ? '#F5F7FA' : '#1A1F26'
  }

  static chipBg(on: boolean): string {
    if (on) {
      return Theme.isDark() ? '#1565A8' : '#174A72'
    }
    return Theme.isDark() ? '#3A4A5C' : '#D5DDE6'
  }
}
