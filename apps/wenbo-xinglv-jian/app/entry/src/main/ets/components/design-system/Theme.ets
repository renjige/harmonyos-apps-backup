/**
 * 行旅笺 Theme — 纸上的旅途：暖杏灰 + 琥珀金 + 米白留白
 */

export type ColorMode = 'light' | 'dark' | 'system'

export class ThemeColors {
  brandPrimary: string = '#B8A088'
  brandPrimaryPressed: string = '#A08870'
  brandPrimaryContainer: string = '#EDE4D8'
  brandOnPrimary: string = '#FFFFFF'
  brandDeep: string = '#2C2C2C'
  brandAccent: string = '#C49B6C'
  surfacePage: string = '#F8F5F0'
  surfaceSubtle: string = '#F0EBE3'
  surfaceCard: string = '#FFFFFF'
  surfaceGlass: string = 'rgba(255,255,255,0.82)'
  surfaceInverse: string = '#2C2C2C'
  textPrimary: string = '#2C2C2C'
  textSecondary: string = '#6B6B6B'
  textTertiary: string = '#8A8A8A'
  textOnInverse: string = '#F8F5F0'
  strokeHairline: string = '#E8E2D9'
  strokeStrong: string = '#D4C5A9'
  success: string = '#7A9E7E'
  successContainer: string = '#E8F0E9'
  warning: string = '#C49B6C'
  warningContainer: string = '#F5EBDF'
  danger: string = '#C46A6A'
  dangerContainer: string = '#F8E4E2'
  info: string = '#B8A088'
  overlayScrim: string = 'rgba(44,44,44,0.45)'
  chart1: string = '#B8A088'
  chart2: string = '#C49B6C'
  chart3: string = '#8A8A8A'
  chart4: string = '#D4C5A9'
  chart5: string = '#6B6B6B'
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
  listItemY: number = 14
  inline: number = 8
  textStack: number = 4
}

export class ThemeRadius {
  xs: number = 4
  sm: number = 10
  md: number = 16
  lg: number = 20
  xl: number = 24
  sheet: number = 28
  pill: number = 999
  card: number = 16
}

export class ThemeTypeScale {
  displayL: number = 32
  displayM: number = 30
  displayS: number = 28
  titleL: number = 26
  titleM: number = 22
  titleS: number = 20
  subtitleL: number = 18
  subtitleM: number = 16
  subtitleS: number = 15
  bodyL: number = 16
  bodyM: number = 15
  bodyS: number = 13
  captionL: number = 13
  captionM: number = 12
  display: number = 32
  title1: number = 30
  title2: number = 24
  title3: number = 20
  body: number = 16
  callout: number = 16
  subhead: number = 14
  footnote: number = 13
  caption: number = 12
  overline: number = 11
  time: number = 18
}

export class ThemeMotion {
  instant: number = 80
  fast: number = 160
  normal: number = 240
  slow: number = 320
  emphasis: number = 380
  staggerMs: number = 40
}

export class ThemeIconSize {
  sm: number = 16
  md: number = 20
  lg: number = 24
  xl: number = 28
  minTouch: number = 48
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

  static applyDark(on: boolean): void {
    Theme.mode = on ? 'dark' : 'light'
  }

  static palette(dark: boolean): ThemeColors {
    Theme.applyDark(dark)
    return Theme.colors()
  }

  static heroScrimTop(dark: boolean): string {
    return dark ? 'rgba(26,26,26,0.55)' : 'rgba(44,44,44,0.15)'
  }

  static heroScrimBottom(dark: boolean): string {
    return dark ? 'rgba(26,26,26,1)' : 'rgba(44,44,44,0.72)'
  }

  static setForcedDark(dark: boolean): void {
    Theme.forcedDark = dark
  }

  static setFontLevel(level: number): void {
    let k = 1
    if (level <= 0) {
      k = 0.92
    } else if (level >= 2) {
      k = 1.12
    }
    Theme.type.displayL = Math.round(32 * k)
    Theme.type.displayM = Math.round(30 * k)
    Theme.type.displayS = Math.round(28 * k)
    Theme.type.titleL = Math.round(26 * k)
    Theme.type.titleM = Math.round(22 * k)
    Theme.type.titleS = Math.round(20 * k)
    Theme.type.subtitleL = Math.round(18 * k)
    Theme.type.subtitleM = Math.round(16 * k)
    Theme.type.bodyL = Math.round(16 * k)
    Theme.type.bodyM = Math.round(15 * k)
    Theme.type.bodyS = Math.round(13 * k)
    Theme.type.display = Theme.type.displayS
    Theme.type.title1 = Theme.type.displayM
    Theme.type.title2 = Theme.type.titleM
    Theme.type.title3 = Theme.type.titleS
    Theme.type.body = Theme.type.bodyL
    Theme.type.callout = Theme.type.bodyL
    Theme.type.subhead = Math.round(14 * k)
    Theme.type.footnote = Math.round(13 * k)
    Theme.type.caption = Math.round(12 * k)
    Theme.type.time = Math.round(18 * k)
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

  static lightColors(): ThemeColors {
    return new ThemeColors()
  }

  static darkColors(): ThemeColors {
    const c = new ThemeColors()
    c.brandPrimary = '#C4AE96'
    c.brandPrimaryPressed = '#D4BEA6'
    c.brandPrimaryContainer = '#3A3530'
    c.brandOnPrimary = '#1A1A1A'
    c.brandDeep = '#1A1A1A'
    c.brandAccent = '#D4AF7A'
    c.surfacePage = '#1A1A1A'
    c.surfaceSubtle = '#242424'
    c.surfaceCard = '#2C2C2C'
    c.surfaceGlass = 'rgba(44,44,44,0.88)'
    c.surfaceInverse = '#F8F5F0'
    c.textPrimary = '#E8E8E8'
    c.textSecondary = '#B8B8B8'
    c.textTertiary = '#9A9A9A'
    c.textOnInverse = '#2C2C2C'
    c.strokeHairline = 'rgba(232,232,232,0.08)'
    c.strokeStrong = 'rgba(232,232,232,0.16)'
    c.success = '#8AB890'
    c.successContainer = '#2A3A2C'
    c.warning = '#D4AF7A'
    c.warningContainer = '#3A3020'
    c.danger = '#E08A8A'
    c.dangerContainer = '#3F1520'
    c.info = '#C4AE96'
    c.overlayScrim = 'rgba(0,0,0,0.56)'
    c.chart1 = '#C4AE96'
    c.chart2 = '#D4AF7A'
    c.chart3 = '#9A9A9A'
    return c
  }

  static shadowSm(): string {
    return Theme.isDark() ? '0 1vp 2vp rgba(0,0,0,0.25)' : '0 1vp 3vp rgba(44,44,44,0.06)'
  }

  static shadowMd(): string {
    return Theme.isDark() ? '0 4vp 16vp rgba(0,0,0,0.35)' : '0 6vp 20vp rgba(44,44,44,0.08)'
  }
}
