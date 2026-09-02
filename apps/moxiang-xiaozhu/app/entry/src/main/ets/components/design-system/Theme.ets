/**
 * HCDS Theme — ArkTS strict-mode compatible token accessors.
 * Source of truth: knowledge/design-system/tokens.json
 */

export type ColorMode = 'light' | 'dark' | 'system'

export class ThemeColors {
  brandPrimary: string = '#1A1A2E'
  brandPrimaryPressed: string = '#12121C'
  brandPrimaryContainer: string = '#EDE6D6'
  brandOnPrimary: string = '#F4EFE4'
  brandDeep: string = '#12121C'
  brandAccent: string = '#8A6F3D'
  surfacePage: string = '#F4EFE4'
  surfaceSubtle: string = '#E8E0D2'
  surfaceCard: string = '#FFFCF7'
  surfaceGlass: string = 'rgba(255,252,247,0.82)'
  surfaceInverse: string = '#1A1A2E'
  textPrimary: string = '#1A1A2E'
  textSecondary: string = '#4A4458'
  textTertiary: string = '#5C5348'
  textOnInverse: string = '#F4EFE4'
  strokeHairline: string = '#E0D5C4'
  strokeStrong: string = '#CFC2AE'
  success: string = '#3D5A45'
  successContainer: string = '#D8E4DE'
  warning: string = '#B45309'
  warningContainer: string = '#F8ECD8'
  danger: string = '#C0392B'
  dangerContainer: string = '#F5DCD8'
  info: string = '#5C7A6A'
  overlayScrim: string = 'rgba(26,26,46,0.40)'
  chart1: string = '#1A1A2E'
  chart2: string = '#C9A96E'
  chart3: string = '#C0392B'
  chart4: string = '#B8A48E'
  chart5: string = '#5C5348'
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
  card: number = 16
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
    c.brandPrimaryContainer = '#2A2A3C'
    c.brandOnPrimary = '#12121C'
    c.brandDeep = '#0E0E16'
    c.brandAccent = '#E8D5A3'
    c.surfacePage = '#12121C'
    c.surfaceSubtle = '#1A1A28'
    c.surfaceCard = '#1E1E2C'
    c.surfaceGlass = 'rgba(30,30,44,0.82)'
    c.surfaceInverse = '#F4EFE4'
    c.textPrimary = '#F4EFE4'
    c.textSecondary = '#D4CBB8'
    c.textTertiary = '#B8A48E'
    c.textOnInverse = '#1A1A2E'
    c.strokeHairline = 'rgba(244,239,228,0.10)'
    c.strokeStrong = 'rgba(244,239,228,0.18)'
    c.success = '#86C5A0'
    c.successContainer = '#1A3324'
    c.warning = '#FBBF24'
    c.warningContainer = '#3D2A0A'
    c.danger = '#FB7185'
    c.dangerContainer = '#3F1520'
    c.info = '#A8C4B4'
    c.overlayScrim = 'rgba(0,0,0,0.56)'
    c.chart1 = '#E8D5A3'
    c.chart2 = '#C9A96E'
    c.chart3 = '#FB7185'
    c.chart4 = '#B8A48E'
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
