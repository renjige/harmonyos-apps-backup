/**
 * HCDS Theme — ArkTS strict-mode compatible token accessors.
 * Source of truth: knowledge/design-system/tokens.json
 */

export type ColorMode = 'light' | 'dark' | 'system'

export class ThemeColors {
  brandPrimary: string = '#6B8FA3'
  brandPrimaryPressed: string = '#3D5566'
  brandPrimaryContainer: string = '#E4EDF2'
  brandOnPrimary: string = '#FFFFFF'
  brandDeep: string = '#3D5566'
  brandAccent: string = '#E8A86B'
  surfacePage: string = '#F7F4EF'
  surfaceSubtle: string = '#EDE8E0'
  surfaceCard: string = '#FFFCF8'
  surfaceGlass: string = 'rgba(255,252,248,0.82)'
  surfaceInverse: string = '#3D5566'
  textPrimary: string = '#2A2620'
  textSecondary: string = '#5C574E'
  textTertiary: string = '#6B645A'
  textOnInverse: string = '#F7F4EF'
  strokeHairline: string = 'rgba(61,85,102,0.08)'
  strokeStrong: string = 'rgba(61,85,102,0.16)'
  success: string = '#8FAE9E'
  successContainer: string = '#E2F0EA'
  warning: string = '#B45309'
  warningContainer: string = '#FEF3C7'
  danger: string = '#BE123C'
  dangerContainer: string = '#FFE4E6'
  info: string = '#6B8FA3'
  overlayScrim: string = 'rgba(61,85,102,0.42)'
  chart1: string = '#6B8FA3'
  chart2: string = '#E8A86B'
  chart3: string = '#E8D5C4'
  chart4: string = '#3D5566'
  chart5: string = '#8FAE9E'
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
    c.brandPrimary = '#8FAEC0'
    c.brandPrimaryPressed = '#A8C0D0'
    c.brandPrimaryContainer = '#243038'
    c.brandOnPrimary = '#101820'
    c.brandDeep = '#1A2530'
    c.brandAccent = '#E8B880'
    c.surfacePage = '#14110E'
    c.surfaceSubtle = '#1C1915'
    c.surfaceCard = '#221E19'
    c.surfaceGlass = 'rgba(34,30,25,0.78)'
    c.surfaceInverse = '#F7F4EF'
    c.textPrimary = '#F7F4EF'
    c.textSecondary = '#D4CFC6'
    c.textTertiary = '#B8B0A4'
    c.textOnInverse = '#2A2620'
    c.strokeHairline = 'rgba(247,244,239,0.10)'
    c.strokeStrong = 'rgba(247,244,239,0.18)'
    c.success = '#8FAE9E'
    c.successContainer = '#1A3A2E'
    c.warning = '#FBBF24'
    c.warningContainer = '#3D2A0A'
    c.danger = '#FB7185'
    c.dangerContainer = '#3F1520'
    c.info = '#8FAEC0'
    c.overlayScrim = 'rgba(0,0,0,0.56)'
    c.chart1 = '#8FAEC0'
    c.chart2 = '#E8B880'
    c.chart3 = '#E8D5C4'
    c.chart4 = '#F7F4EF'
    c.chart5 = '#B8B0A4'
    return c
  }

  static shadowSm(): string {
    return Theme.isDark() ? '0 1vp 2vp rgba(0,0,0,0.25)' : '0 1vp 2vp rgba(10,37,64,0.04)'
  }

  static shadowMd(): string {
    return Theme.isDark() ? '0 4vp 16vp rgba(0,0,0,0.35)' : '0 4vp 16vp rgba(10,37,64,0.06)'
  }
}
