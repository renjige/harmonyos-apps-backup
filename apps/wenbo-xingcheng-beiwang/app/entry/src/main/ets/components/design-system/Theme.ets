/**
 * 行程备忘 Theme — 深墨蓝文字 + 清透蓝品牌 + 暖白留白
 */

export type ColorMode = 'light' | 'dark' | 'system'

export class ThemeColors {
  brandPrimary: string = '#4C7ED4'
  brandPrimaryPressed: string = '#3B6BC0'
  brandPrimaryContainer: string = '#E8EFFA'
  brandOnPrimary: string = '#FFFFFF'
  brandDeep: string = '#1B2744'
  brandAccent: string = '#4C7ED4'
  surfacePage: string = '#F6F5F2'
  surfaceSubtle: string = '#EEECE7'
  surfaceCard: string = '#FFFFFF'
  surfaceGlass: string = 'rgba(255,255,255,0.88)'
  surfaceInverse: string = '#1B2744'
  textPrimary: string = '#1B2744'
  textSecondary: string = '#5C6578'
  textTertiary: string = '#8A93A3'
  textOnInverse: string = '#F6F5F2'
  strokeHairline: string = '#E6E4DE'
  strokeStrong: string = '#D4D1C9'
  success: string = '#4C7ED4'
  successContainer: string = '#E8EFFA'
  warning: string = '#B45309'
  warningContainer: string = '#F8ECD8'
  danger: string = '#C46A6A'
  dangerContainer: string = '#F8E4E2'
  info: string = '#4C7ED4'
  overlayScrim: string = 'rgba(27,39,68,0.40)'
  chart1: string = '#4C7ED4'
  chart2: string = '#1B2744'
  chart3: string = '#8A93A3'
  chart4: string = '#C9CED8'
  chart5: string = '#5C6578'
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
  cardPadding: number = 18
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
  card: number = 18
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

  static applyDark(on: boolean): void {
    Theme.mode = on ? 'dark' : 'light'
  }

  static palette(dark: boolean): ThemeColors {
    Theme.applyDark(dark)
    return Theme.colors()
  }

  static heroScrimTop(dark: boolean): string {
    return dark ? 'rgba(18,26,44,0.62)' : 'rgba(246,245,242,0.12)'
  }

  static heroScrimBottom(dark: boolean): string {
    return dark ? 'rgba(18,26,44,1)' : 'rgba(246,245,242,1)'
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
    c.brandPrimary = '#7AA0E4'
    c.brandPrimaryPressed = '#8AADD8'
    c.brandPrimaryContainer = '#243250'
    c.brandOnPrimary = '#F6F5F2'
    c.brandDeep = '#10182A'
    c.surfacePage = '#121A2C'
    c.surfaceSubtle = '#1A2438'
    c.surfaceCard = '#1E2A40'
    c.surfaceGlass = 'rgba(30,42,64,0.88)'
    c.surfaceInverse = '#F6F5F2'
    c.textPrimary = '#F3F1EC'
    c.textSecondary = '#B4BBC8'
    c.textTertiary = '#8A93A3'
    c.textOnInverse = '#1B2744'
    c.strokeHairline = 'rgba(246,245,242,0.08)'
    c.strokeStrong = 'rgba(246,245,242,0.16)'
    c.success = '#7AA0E4'
    c.successContainer = '#243250'
    c.warning = '#D6A86E'
    c.warningContainer = '#3D2A0A'
    c.danger = '#E08A8A'
    c.dangerContainer = '#3F1520'
    c.info = '#7AA0E4'
    c.overlayScrim = 'rgba(0,0,0,0.56)'
    c.chart1 = '#7AA0E4'
    c.chart2 = '#F3F1EC'
    c.chart3 = '#8A93A3'
    return c
  }

  static shadowSm(): string {
    return Theme.isDark() ? '0 1vp 2vp rgba(0,0,0,0.25)' : '0 1vp 3vp rgba(27,39,68,0.04)'
  }

  static shadowMd(): string {
    return Theme.isDark() ? '0 4vp 16vp rgba(0,0,0,0.35)' : '0 6vp 20vp rgba(27,39,68,0.06)'
  }
}
