/**
 * HCDS Theme — ArkTS strict-mode compatible token accessors.
 * Source of truth: knowledge/design-system/tokens.json
 */

export type ColorMode = 'light' | 'dark' | 'system'

export class ThemeColors {
  brandPrimary: string = '#FF8A65'
  brandPrimaryPressed: string = '#E56F4B'
  brandPrimaryContainer: string = '#FFE4D6'
  brandOnPrimary: string = '#2D2D2D'
  brandDeep: string = '#4A2A1C'
  brandAccent: string = '#C9A227'
  surfacePage: string = '#FDF8F5'
  surfaceSubtle: string = '#F4EBE4'
  surfaceCard: string = '#FFFFFF'
  surfaceGlass: string = 'rgba(255,255,255,0.82)'
  surfaceInverse: string = '#4A2A1C'
  textPrimary: string = '#2D2D2D'
  textSecondary: string = '#5C534C'
  textTertiary: string = '#6B625B'
  textOnInverse: string = '#FDF8F5'
  strokeHairline: string = 'rgba(45,45,45,0.08)'
  strokeStrong: string = 'rgba(45,45,45,0.14)'
  success: string = '#2F8A80'
  successContainer: string = '#D8F3EF'
  warning: string = '#B45309'
  warningContainer: string = '#FEF3C7'
  danger: string = '#BE123C'
  dangerContainer: string = '#FFE4E6'
  info: string = '#C94E2A'
  overlayScrim: string = 'rgba(45,32,24,0.42)'
  chart1: string = '#C94E2A'
  chart2: string = '#2F8A80'
  chart3: string = '#C9A227'
  chart4: string = '#FF8A65'
  chart5: string = '#6B625B'
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
  card: number = 20
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
    c.brandPrimary = '#FF8A65'
    c.brandPrimaryPressed = '#FFA184'
    c.brandPrimaryContainer = '#4A2C22'
    c.brandOnPrimary = '#1C1410'
    c.brandDeep = '#1C1410'
    c.brandAccent = '#E8C766'
    c.surfacePage = '#1C1410'
    c.surfaceSubtle = '#2A1F1A'
    c.surfaceCard = '#2F231C'
    c.surfaceGlass = 'rgba(47,35,28,0.78)'
    c.surfaceInverse = '#F5EDE8'
    c.textPrimary = '#F5EDE8'
    c.textSecondary = '#E0D2C6'
    c.textTertiary = '#C4B4A6'
    c.textOnInverse = '#1C1410'
    c.strokeHairline = 'rgba(245,237,232,0.10)'
    c.strokeStrong = 'rgba(245,237,232,0.18)'
    c.success = '#5EE0D0'
    c.successContainer = '#143833'
    c.warning = '#FBBF24'
    c.warningContainer = '#3D2A0A'
    c.danger = '#FB7185'
    c.dangerContainer = '#3F1520'
    c.info = '#FF8A65'
    c.overlayScrim = 'rgba(0,0,0,0.58)'
    c.chart1 = '#FF8A65'
    c.chart2 = '#5EE0D0'
    c.chart3 = '#E8C766'
    c.chart4 = '#A5B4FC'
    c.chart5 = '#94A3B8'
    return c
  }

  static shadowSm(): string {
    return Theme.isDark() ? '0 1vp 2vp rgba(0,0,0,0.25)' : '0 1vp 2vp rgba(10,37,64,0.04)'
  }

  static shadowMd(): string {
    return Theme.isDark() ? '0 4vp 16vp rgba(0,0,0,0.35)' : '0 4vp 16vp rgba(10,37,64,0.06)'
  }
}
