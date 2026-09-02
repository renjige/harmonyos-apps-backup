/**
 * HCDS Theme — ArkTS strict-mode compatible token accessors.
 * Source of truth: knowledge/design-system/tokens.json
 */

export type ColorMode = 'light' | 'dark' | 'system'

export class ThemeColors {
  brandPrimary: string = '#4ECDC4'
  brandPrimaryPressed: string = '#3BB8B0'
  brandPrimaryContainer: string = '#D8F5F2'
  brandOnPrimary: string = '#FFFFFF'
  brandDeep: string = '#45B7D1'
  brandAccent: string = '#FFB347'
  surfacePage: string = '#F7F9FC'
  surfaceSubtle: string = '#EEF2F7'
  surfaceCard: string = '#FFFFFF'
  surfaceGlass: string = 'rgba(255,255,255,0.82)'
  surfaceInverse: string = '#2D3436'
  textPrimary: string = '#2D3436'
  textSecondary: string = '#636E72'
  textTertiary: string = '#7A8589'
  textOnInverse: string = '#FFFFFF'
  strokeHairline: string = 'rgba(45,52,54,0.08)'
  strokeStrong: string = 'rgba(45,52,54,0.16)'
  success: string = '#4ECDC4'
  successContainer: string = '#D8F5F2'
  warning: string = '#B45309'
  warningContainer: string = '#F8E6D4'
  danger: string = '#BE123C'
  dangerContainer: string = '#FFE4E6'
  info: string = '#45B7D1'
  overlayScrim: string = 'rgba(45,52,54,0.46)'
  chart1: string = '#4ECDC4'
  chart2: string = '#45B7D1'
  chart3: string = '#FFB347'
  chart4: string = '#6B736E'
  chart5: string = '#A8C4C0'
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
  pageY: number = 24
  section: number = 32
  cardPadding: number = 18
  listItemY: number = 12
  inline: number = 8
  textStack: number = 2
}

export class ThemeRadius {
  // Official: https://developer.huawei.com/consumer/cn/doc/design-guides/corner-radius-parameter-0000002556468705
  xs: number = 8
  sm: number = 12
  md: number = 16
  lg: number = 16
  xl: number = 28
  sheet: number = 32
  pill: number = 999
  card: number = 24
}

export class ThemeTypeScale {
  // Official HarmonyOS phone tokens (vp)
  // https://developer.huawei.com/consumer/cn/doc/design-guides/typography-0000002622688363
  displayL: number = 56
  displayM: number = 48
  displayS: number = 38
  titleL: number = 32
  titleM: number = 26
  titleS: number = 20
  subtitleL: number = 18
  subtitleM: number = 16
  subtitleS: number = 14
  bodyL: number = 16
  bodyM: number = 15
  bodyS: number = 13
  captionL: number = 13
  captionM: number = 11

  display: number = 32
  title1: number = 32
  title2: number = 26
  title3: number = 20
  body: number = 16
  callout: number = 16
  subhead: number = 14
  footnote: number = 13
  caption: number = 13
  overline: number = 11
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
    c.brandPrimary = '#6EDDD6'
    c.brandPrimaryPressed = '#4ECDC4'
    c.brandPrimaryContainer = '#1A3D3A'
    c.brandOnPrimary = '#0F1419'
    c.brandDeep = '#5CC4DE'
    c.brandAccent = '#FFC870'
    c.surfacePage = '#121820'
    c.surfaceSubtle = '#1A2230'
    c.surfaceCard = '#1E2836'
    c.surfaceGlass = 'rgba(30,40,54,0.82)'
    c.surfaceInverse = '#F7F9FC'
    c.textPrimary = '#E8EDF2'
    c.textSecondary = '#CBD5E1'
    c.textTertiary = '#94A3B8'
    c.textOnInverse = '#2D3436'
    c.strokeHairline = 'rgba(232,237,242,0.08)'
    c.strokeStrong = 'rgba(232,237,242,0.16)'
    c.success = '#6EDDD6'
    c.successContainer = '#1A3D3A'
    c.warning = '#FBBF24'
    c.warningContainer = '#3D2A0A'
    c.danger = '#FB7185'
    c.dangerContainer = '#3F1520'
    c.info = '#A8B5A0'
    c.overlayScrim = 'rgba(0,0,0,0.56)'
    c.chart1 = '#A8B5A0'
    c.chart2 = '#E8A06A'
    c.chart3 = '#F3EFE7'
    c.chart4 = '#6B736E'
    c.chart5 = '#C4B7A6'
    return c
  }

  static shadowSm(): string {
    return Theme.isDark() ? '0 1vp 2vp rgba(0,0,0,0.25)' : '0 1vp 2vp rgba(10,37,64,0.04)'
  }

  static shadowMd(): string {
    return Theme.isDark() ? '0 4vp 16vp rgba(0,0,0,0.35)' : '0 4vp 16vp rgba(10,37,64,0.06)'
  }
}
