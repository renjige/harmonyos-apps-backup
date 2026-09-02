/**
 * 心笺日常 Theme — 暖杏红 + 米白 + 深灰；深色保持暖色调。
 */

export type ColorMode = 'light' | 'dark' | 'system'

export class ThemeColors {
  brandPrimary: string = '#E98D83'
  brandPrimaryPressed: string = '#D57A70'
  brandPrimaryContainer: string = '#F8E4DF'
  brandOnPrimary: string = '#FFFFFF'
  brandDeep: string = '#272321'
  brandAccent: string = '#F5C9BE'
  surfacePage: string = '#FFF9F6'
  surfaceSubtle: string = '#F6EEEA'
  surfaceCard: string = '#FFFFFF'
  surfaceGlass: string = 'rgba(255,255,255,0.82)'
  surfaceInverse: string = '#272321'
  textPrimary: string = '#272321'
  textSecondary: string = '#817A76'
  textTertiary: string = '#8E8884'
  textOnInverse: string = '#F4ECE8'
  strokeHairline: string = '#EEE7E3'
  strokeStrong: string = '#E4DBD6'
  success: string = '#7EAD89'
  successContainer: string = '#E5F1E8'
  warning: string = '#D9A85F'
  warningContainer: string = '#F8ECD8'
  danger: string = '#C46A6A'
  dangerContainer: string = '#F8E4E2'
  info: string = '#8E8884'
  overlayScrim: string = 'rgba(39,35,33,0.40)'
  chart1: string = '#E98D83'
  chart2: string = '#7EAD89'
  chart3: string = '#D9A85F'
  chart4: string = '#C4B4A8'
  chart5: string = '#8E8884'
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
  card: number = 20
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
    c.brandPrimary = '#EA9188'
    c.brandPrimaryPressed = '#F0A59E'
    c.brandPrimaryContainer = '#3A2C2A'
    c.brandOnPrimary = '#171514'
    c.brandDeep = '#171514'
    c.brandAccent = '#E8C4B8'
    c.surfacePage = '#171514'
    c.surfaceSubtle = '#1F1C1A'
    c.surfaceCard = '#24211F'
    c.surfaceGlass = 'rgba(36,33,31,0.82)'
    c.surfaceInverse = '#F4ECE8'
    c.textPrimary = '#F4ECE8'
    c.textSecondary = '#B7ABA5'
    c.textTertiary = '#8E8580'
    c.textOnInverse = '#272321'
    c.strokeHairline = 'rgba(244,236,232,0.10)'
    c.strokeStrong = 'rgba(244,236,232,0.18)'
    c.success = '#8FBF9A'
    c.successContainer = '#243028'
    c.warning = '#E0B56E'
    c.warningContainer = '#3A2F1C'
    c.danger = '#E08A86'
    c.dangerContainer = '#3A2422'
    c.info = '#B7ABA5'
    c.overlayScrim = 'rgba(0,0,0,0.56)'
    c.chart1 = '#EA9188'
    c.chart2 = '#8FBF9A'
    c.chart3 = '#E0B56E'
    c.chart4 = '#C4B4A8'
    c.chart5 = '#B7ABA5'
    return c
  }

  static shadowSm(): string {
    return Theme.isDark() ? '0 1vp 2vp rgba(0,0,0,0.25)' : '0 1vp 2vp rgba(39,35,33,0.04)'
  }

  static shadowMd(): string {
    return Theme.isDark() ? '0 4vp 16vp rgba(0,0,0,0.35)' : '0 4vp 16vp rgba(39,35,33,0.06)'
  }
}
