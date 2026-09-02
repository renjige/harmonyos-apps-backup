/**
 * HCDS Theme — ArkTS strict-mode compatible token accessors.
 * Source of truth: knowledge/design-system/tokens.json
 * 云水间 palette: 青黛 · 墨绿 · 米白
 */

export type ColorMode = 'light' | 'dark' | 'system'

export class ThemeColors {
  brandPrimary: string = '#3D5A5C'
  brandPrimaryPressed: string = '#2F484A'
  brandPrimaryContainer: string = '#E8F0F0'
  brandOnPrimary: string = '#FFFFFF'
  brandDeep: string = '#2C4A3E'
  brandAccent: string = '#A8C5C8'
  surfacePage: string = '#F7F5F0'
  surfaceSubtle: string = '#EDEAE3'
  surfaceCard: string = '#FFFFFF'
  surfaceGlass: string = 'rgba(255,255,255,0.72)'
  surfaceInverse: string = '#1A2E28'
  textPrimary: string = '#1A2E28'
  textSecondary: string = '#4A5F5A'
  textTertiary: string = '#6B8078'
  textOnInverse: string = '#F7F5F0'
  strokeHairline: string = 'rgba(44,74,62,0.08)'
  strokeStrong: string = 'rgba(44,74,62,0.14)'
  success: string = '#2D6A4F'
  successContainer: string = '#D8F3DC'
  warning: string = '#B8860B'
  warningContainer: string = '#FEF9E7'
  danger: string = '#9B2335'
  dangerContainer: string = '#FFE4E6'
  info: string = '#3D5A5C'
  overlayScrim: string = 'rgba(44,74,62,0.40)'
  chart1: string = '#3D5A5C'
  chart2: string = '#2C4A3E'
  chart3: string = '#52B788'
  chart4: string = '#A8C5C8'
  chart5: string = '#6B8078'
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

  static applyDark(dark: boolean): void {
    Theme.setColorMode(dark ? 'dark' : 'light')
    Theme.setForcedDark(dark)
    AppStorage.setOrCreate('yunThemeTick', Date.now())
  }

  static lightColors(): ThemeColors {
    return new ThemeColors()
  }

  static darkColors(): ThemeColors {
    const c = new ThemeColors()
    c.brandPrimary = '#A8C5C8'
    c.brandPrimaryPressed = '#8FB0B4'
    c.brandPrimaryContainer = '#2A4038'
    c.brandOnPrimary = '#1A2E28'
    c.brandDeep = '#C5DDD8'
    c.brandAccent = '#6B9A9E'
    c.surfacePage = '#1A2E28'
    c.surfaceSubtle = '#243832'
    c.surfaceCard = '#2C4A3E'
    c.surfaceGlass = 'rgba(44,74,62,0.88)'
    c.surfaceInverse = '#F7F5F0'
    c.textPrimary = '#F7F5F0'
    c.textSecondary = '#C5DDD8'
    c.textTertiary = '#A8C5C8'
    c.textOnInverse = '#1A2E28'
    c.strokeHairline = 'rgba(247,245,240,0.12)'
    c.strokeStrong = 'rgba(247,245,240,0.22)'
    c.success = '#74C69D'
    c.successContainer = '#1B4332'
    c.warning = '#F4D03F'
    c.warningContainer = '#3D3420'
    c.danger = '#FF8A9A'
    c.dangerContainer = '#4A2030'
    c.info = '#A8C5C8'
    c.overlayScrim = 'rgba(10,20,16,0.55)'
    c.chart1 = '#A8C5C8'
    c.chart2 = '#74C69D'
    c.chart3 = '#52B788'
    c.chart4 = '#3D5A5C'
    c.chart5 = '#C5DDD8'
    return c
  }

  static shadowSm(): string {
    return Theme.isDark() ? '0 1vp 2vp rgba(0,0,0,0.25)' : '0 1vp 2vp rgba(44,74,62,0.06)'
  }

  static shadowMd(): string {
    return Theme.isDark() ? '0 4vp 16vp rgba(0,0,0,0.35)' : '0 4vp 16vp rgba(44,74,62,0.08)'
  }
}
