/**
 * HCDS Theme — ArkTS strict-mode compatible token accessors.
 * Source of truth: knowledge/design-system/tokens.json
 */

export type ColorMode = 'light' | 'dark' | 'system'

export class ThemeColors {
  brandPrimary: string = '#1A2A3A'
  brandPrimaryPressed: string = '#121C28'
  brandPrimaryContainer: string = '#E8E0D4'
  brandOnPrimary: string = '#FAF8F5'
  brandDeep: string = '#1A2A3A'
  brandAccent: string = '#8A6D32'
  surfacePage: string = '#F5F0E8'
  surfaceSubtle: string = '#EDE6DA'
  surfaceCard: string = '#FFFcf7'
  surfaceGlass: string = 'rgba(255,252,247,0.78)'
  surfaceInverse: string = '#1A2A3A'
  textPrimary: string = '#2C2C2C'
  textSecondary: string = '#4A5560'
  textTertiary: string = '#5C6773'
  textOnInverse: string = '#FAF8F5'
  strokeHairline: string = 'rgba(26,42,58,0.08)'
  strokeStrong: string = 'rgba(26,42,58,0.16)'
  success: string = '#2F6B4F'
  successContainer: string = '#DCEFE4'
  warning: string = '#8A6D32'
  warningContainer: string = '#F4E6C8'
  danger: string = '#9B2C2C'
  dangerContainer: string = '#F8E0E0'
  info: string = '#1A2A3A'
  overlayScrim: string = 'rgba(26,42,58,0.46)'
  chart1: string = '#1A2A3A'
  chart2: string = '#C9A96E'
  chart3: string = '#2F6B4F'
  chart4: string = '#8A6D32'
  chart5: string = '#5C6773'
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
  md: number = 12
  lg: number = 16
  xl: number = 24
  sheet: number = 32
  pill: number = 999
  card: number = 12
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
    c.brandPrimary = '#E8D5A3'
    c.brandPrimaryPressed = '#C9A96E'
    c.brandPrimaryContainer = '#2A3544'
    c.brandOnPrimary = '#1A2A3A'
    c.brandDeep = '#0E141C'
    c.brandAccent = '#E0C78A'
    c.surfacePage = '#121820'
    c.surfaceSubtle = '#1A222C'
    c.surfaceCard = '#1C2630'
    c.surfaceGlass = 'rgba(28,38,48,0.78)'
    c.surfaceInverse = '#F5F0E8'
    c.textPrimary = '#F5F0E8'
    c.textSecondary = '#D4CBB8'
    c.textTertiary = '#A89F8E'
    c.textOnInverse = '#1A2A3A'
    c.strokeHairline = 'rgba(245,240,232,0.10)'
    c.strokeStrong = 'rgba(245,240,232,0.18)'
    c.success = '#6BC4A0'
    c.successContainer = '#163328'
    c.warning = '#E0C78A'
    c.warningContainer = '#3A2E14'
    c.danger = '#F0A0A0'
    c.dangerContainer = '#3A1A1A'
    c.info = '#E8D5A3'
    c.overlayScrim = 'rgba(0,0,0,0.58)'
    c.chart1 = '#E8D5A3'
    c.chart2 = '#C9A96E'
    c.chart3 = '#6BC4A0'
    c.chart4 = '#D4CBB8'
    c.chart5 = '#A89F8E'
    return c
  }

  static shadowSm(): string {
    return Theme.isDark() ? '0 1vp 2vp rgba(0,0,0,0.25)' : '0 1vp 2vp rgba(10,37,64,0.04)'
  }

  static shadowMd(): string {
    return Theme.isDark() ? '0 4vp 16vp rgba(0,0,0,0.35)' : '0 4vp 16vp rgba(10,37,64,0.06)'
  }
}
