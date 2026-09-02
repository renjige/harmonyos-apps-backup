/**
 * HCDS Theme — ArkTS strict-mode compatible token accessors.
 * Source of truth: knowledge/design-system/tokens.json
 */

export type ColorMode = 'light' | 'dark' | 'system'

export class ThemeColors {
  brandPrimary: string = '#24443A'
  brandPrimaryPressed: string = '#1A322B'
  brandPrimaryContainer: string = '#E4EBE4'
  brandOnPrimary: string = '#F6F1E8'
  brandDeep: string = '#1A322B'
  brandAccent: string = '#C4A574'
  surfacePage: string = '#F6F1E8'
  surfaceSubtle: string = '#EFE8DC'
  surfaceCard: string = '#FFFFFF'
  surfaceGlass: string = 'rgba(255,255,255,0.78)'
  surfaceInverse: string = '#24443A'
  textPrimary: string = '#1D2421'
  textSecondary: string = '#5F6864'
  textTertiary: string = '#7B837F'
  textOnInverse: string = '#F6F1E8'
  strokeHairline: string = 'rgba(29,36,33,0.06)'
  strokeStrong: string = 'rgba(29,36,33,0.12)'
  success: string = '#3D6B54'
  successContainer: string = '#E3EFE6'
  warning: string = '#C67A3A'
  warningContainer: string = '#F8E8D4'
  danger: string = '#B54A3C'
  dangerContainer: string = '#F6E4E0'
  info: string = '#3D6B54'
  overlayScrim: string = 'rgba(26,50,43,0.44)'
  chart1: string = '#24443A'
  chart2: string = '#3D6B54'
  chart3: string = '#C4A574'
  chart4: string = '#7B837F'
  chart5: string = '#C67A3A'
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
  // Official: https://developer.huawei.com/consumer/cn/doc/design-guides/corner-radius-parameter-0000002556468705
  xs: number = 4
  sm: number = 8
  md: number = 16
  lg: number = 20
  xl: number = 24
  sheet: number = 32
  pill: number = 999
  card: number = 22
  button: number = 16
  input: number = 14
}

export class ThemeTypeScale {
  // Official HarmonyOS phone tokens (vp)
  // https://developer.huawei.com/consumer/cn/doc/design-guides/typography-0000002622688363
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

  // HCDS aliases → official phone scale
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

  static lightColors(): ThemeColors {
    return new ThemeColors()
  }

  static darkColors(): ThemeColors {
    const c = new ThemeColors()
    c.brandPrimary = '#C9D7CF'
    c.brandPrimaryPressed = '#E4EBE4'
    c.brandPrimaryContainer = '#2A3C35'
    c.brandOnPrimary = '#1A322B'
    c.brandDeep = '#121A17'
    c.brandAccent = '#D4C0A0'
    c.surfacePage = '#121714'
    c.surfaceSubtle = '#1A211D'
    c.surfaceCard = '#1C2420'
    c.surfaceGlass = 'rgba(28,36,32,0.78)'
    c.surfaceInverse = '#F6F1E8'
    c.textPrimary = '#F6F1E8'
    c.textSecondary = '#9AA39E'
    c.textTertiary = '#7B837F'
    c.textOnInverse = '#1A322B'
    c.strokeHairline = 'rgba(246,241,232,0.08)'
    c.strokeStrong = 'rgba(246,241,232,0.16)'
    c.success = '#8FBFB0'
    c.successContainer = '#243832'
    c.warning = '#E0B07A'
    c.warningContainer = '#3A2C1C'
    c.danger = '#E08A7C'
    c.dangerContainer = '#3A2420'
    c.info = '#8FBFB0'
    c.overlayScrim = 'rgba(0,0,0,0.56)'
    c.chart1 = '#C9D7CF'
    c.chart2 = '#8FBFB0'
    c.chart3 = '#D4C0A0'
    c.chart4 = '#9AA39E'
    c.chart5 = '#E0B07A'
    return c
  }

  static shadowSm(): string {
    return Theme.isDark() ? '0 1vp 2vp rgba(0,0,0,0.25)' : '0 1vp 2vp rgba(36,68,58,0.06)'
  }

  static shadowMd(): string {
    return Theme.isDark() ? '0 4vp 16vp rgba(0,0,0,0.35)' : '0 4vp 16vp rgba(36,68,58,0.08)'
  }
}
