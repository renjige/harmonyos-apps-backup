/**
 * 识趣阁 Theme — 暖灰褐 × 香槟金 × 米白
 */

export type ColorMode = 'light' | 'dark' | 'system'

export class ThemeColors {
  brandPrimary: string = '#8B7A6B'
  brandPrimaryPressed: string = '#736559'
  brandPrimaryContainer: string = '#EDE6DC'
  brandOnPrimary: string = '#FFFFFF'
  brandDeep: string = '#3D342C'
  brandAccent: string = '#C4A882'
  surfacePage: string = '#F7F4F0'
  surfaceSubtle: string = '#EFE8E0'
  surfaceCard: string = '#FFFFFF'
  surfaceGlass: string = 'rgba(255,255,255,0.82)'
  surfaceInverse: string = '#3D342C'
  textPrimary: string = '#2C2C2C'
  textSecondary: string = '#5C5348'
  textTertiary: string = '#756B5E'
  textOnInverse: string = '#F7F4F0'
  strokeHairline: string = '#E4DCD2'
  strokeStrong: string = '#D2C6B8'
  success: string = '#4A6B58'
  successContainer: string = '#DCE8E0'
  warning: string = '#B45309'
  warningContainer: string = '#F8ECD8'
  danger: string = '#A33B3B'
  dangerContainer: string = '#F5DCDC'
  info: string = '#6B5E52'
  overlayScrim: string = 'rgba(61,52,44,0.40)'
  chart1: string = '#8B7A6B'
  chart2: string = '#C4A882'
  chart3: string = '#4A6B58'
  chart4: string = '#B8A48E'
  chart5: string = '#756B5E'
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
    if (mode === 'dark') {
      Theme.forcedDark = true
    }
    if (mode === 'light') {
      Theme.forcedDark = false
    }
    AppStorage.setOrCreate('darkModeOn', Theme.isDark())
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

  /** 把 epoch / dark 写进表达式，避免 ArkUI 缓存浅色值导致切换后底栏不刷新 */
  static pageBg(epoch: number, dark: boolean): string {
    return (epoch >= 0 && dark) ? '#1C1916' : '#F7F4F0'
  }

  static cardBg(epoch: number, dark: boolean): string {
    return (epoch >= 0 && dark) ? '#2A2622' : '#FFFFFF'
  }

  static textMain(epoch: number, dark: boolean): string {
    return (epoch >= 0 && dark) ? '#F5F0EA' : '#2C2C2C'
  }

  static textSub(epoch: number, dark: boolean): string {
    return (epoch >= 0 && dark) ? '#D4CDC4' : '#5C5348'
  }

  static brandInk(epoch: number, dark: boolean): string {
    return (epoch >= 0 && dark) ? '#C4A882' : '#8B7A6B'
  }

  static brandBox(epoch: number, dark: boolean): string {
    return (epoch >= 0 && dark) ? '#3D342C' : '#EDE6DC'
  }

  static hairline(epoch: number, dark: boolean): string {
    return (epoch >= 0 && dark) ? 'rgba(245,240,234,0.16)' : '#E4DCD2'
  }

  static applyBrandPrimary(hex: string): void {
    AppStorage.setOrCreate('brandPrimary', hex)
  }

  static lightColors(): ThemeColors {
    return new ThemeColors()
  }

  static darkColors(): ThemeColors {
    const c = new ThemeColors()
    c.brandPrimary = '#C4A882'
    c.brandPrimaryPressed = '#D4BC9A'
    c.brandPrimaryContainer = '#3D342C'
    c.brandOnPrimary = '#1A1510'
    c.brandDeep = '#1C1916'
    c.brandAccent = '#D4BC9A'
    c.surfacePage = '#1C1916'
    c.surfaceSubtle = '#26211C'
    c.surfaceCard = '#2A2622'
    c.surfaceGlass = 'rgba(42,38,34,0.82)'
    c.surfaceInverse = '#F7F4F0'
    c.textPrimary = '#F5F0EA'
    c.textSecondary = '#D4CDC4'
    c.textTertiary = '#A89E90'
    c.textOnInverse = '#2C2C2C'
    c.strokeHairline = 'rgba(245,240,234,0.08)'
    c.strokeStrong = 'rgba(245,240,234,0.16)'
    c.success = '#8FBF9A'
    c.successContainer = '#24332A'
    c.warning = '#D4A574'
    c.warningContainer = '#3D2A0A'
    c.danger = '#E08A8A'
    c.dangerContainer = '#3F1520'
    c.info = '#B8A48E'
    c.overlayScrim = 'rgba(0,0,0,0.56)'
    c.chart1 = '#C4A882'
    c.chart2 = '#8FBF9A'
    c.chart3 = '#D4A574'
    c.chart4 = '#D4CDC4'
    c.chart5 = '#A89E90'
    return c
  }

  static shadowSm(): string {
    return Theme.isDark() ? '0 1vp 2vp rgba(0,0,0,0.25)' : '0 1vp 2vp rgba(10,37,64,0.04)'
  }

  static shadowMd(): string {
    return Theme.isDark() ? '0 4vp 16vp rgba(0,0,0,0.35)' : '0 4vp 16vp rgba(10,37,64,0.06)'
  }
}
