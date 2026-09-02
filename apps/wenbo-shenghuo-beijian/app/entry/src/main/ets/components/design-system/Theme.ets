/**
 * HCDS Theme — ArkTS strict-mode compatible token accessors.
 * Source of truth: knowledge/design-system/tokens.json
 */

export type ColorMode = 'light' | 'dark' | 'system'

export class ThemeColors {
  brandPrimary: string = '#3D8277'
  brandPrimaryPressed: string = '#326B62'
  brandPrimaryContainer: string = '#E4EEEB'
  brandOnPrimary: string = '#FFFFFF'
  brandDeep: string = '#24312F'
  brandAccent: string = '#D6A86E'
  surfacePage: string = '#F7F5EF'
  surfaceSubtle: string = '#EFEDE6'
  surfaceCard: string = '#FFFFFF'
  surfaceGlass: string = 'rgba(255,255,255,0.82)'
  surfaceInverse: string = '#24312F'
  textPrimary: string = '#25312F'
  textSecondary: string = '#5F6A67'
  textTertiary: string = '#7B8582'
  textOnInverse: string = '#F7F5EF'
  strokeHairline: string = '#E8E6DF'
  strokeStrong: string = '#D9D6CC'
  success: string = '#3D8277'
  successContainer: string = '#E4EEEB'
  warning: string = '#B45309'
  warningContainer: string = '#F8ECD8'
  danger: string = '#C46A6A'
  dangerContainer: string = '#F8E4E2'
  info: string = '#7DA69D'
  overlayScrim: string = 'rgba(36,49,47,0.40)'
  chart1: string = '#3D8277'
  chart2: string = '#7DA69D'
  chart3: string = '#D6A86E'
  chart4: string = '#C4B4A8'
  chart5: string = '#7B8582'
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
  sheet: number = 28
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
    c.brandPrimary = '#7DA69D'
    c.brandPrimaryPressed = '#8FB5AD'
    c.brandPrimaryContainer = '#2A3A37'
    c.brandOnPrimary = '#F7F5EF'
    c.brandDeep = '#141A19'
    c.brandAccent = '#D6A86E'
    c.surfacePage = '#1A211F'
    c.surfaceSubtle = '#242C2A'
    c.surfaceCard = '#2A3330'
    c.surfaceGlass = 'rgba(42,51,48,0.82)'
    c.surfaceInverse = '#F7F5EF'
    c.textPrimary = '#F4F1EA'
    c.textSecondary = '#B7BFBB'
    c.textTertiary = '#8A938F'
    c.textOnInverse = '#24312F'
    c.strokeHairline = 'rgba(247,245,239,0.08)'
    c.strokeStrong = 'rgba(247,245,239,0.16)'
    c.success = '#7DA69D'
    c.successContainer = '#243833'
    c.warning = '#D6A86E'
    c.warningContainer = '#3D2A0A'
    c.danger = '#E08A8A'
    c.dangerContainer = '#3F1520'
    c.info = '#7DA69D'
    c.overlayScrim = 'rgba(0,0,0,0.56)'
    c.chart1 = '#7DA69D'
    c.chart2 = '#3D8277'
    c.chart3 = '#D6A86E'
    c.chart4 = '#C4B4A8'
    c.chart5 = '#B7BFBB'
    return c
  }

  static shadowSm(): string {
    return Theme.isDark() ? '0 1vp 2vp rgba(0,0,0,0.25)' : '0 1vp 2vp rgba(10,37,64,0.04)'
  }

  static shadowMd(): string {
    return Theme.isDark() ? '0 4vp 16vp rgba(0,0,0,0.35)' : '0 4vp 16vp rgba(10,37,64,0.06)'
  }
}
