/**
 * 悦知坊 Theme — 深蓝 #1A2A6C × 琥珀 #F5A623 × 浅灰页底
 */

export type ColorMode = 'light' | 'dark' | 'system'

export class ThemeColors {
  brandPrimary: string = '#1A2A6C'
  brandPrimaryPressed: string = '#142056'
  brandPrimaryContainer: string = '#E8ECF8'
  brandOnPrimary: string = '#FFFFFF'
  brandDeep: string = '#0F1A4A'
  brandAccent: string = '#F5A623'
  surfacePage: string = '#F8F9FA'
  surfaceSubtle: string = '#EEF0F3'
  surfaceCard: string = '#FFFFFF'
  surfaceGlass: string = 'rgba(255,255,255,0.82)'
  surfaceInverse: string = '#1A2A6C'
  textPrimary: string = '#2D2D2D'
  textSecondary: string = '#5C5C62'
  textTertiary: string = '#4A4A50'
  textOnInverse: string = '#F8F9FA'
  strokeHairline: string = '#E4E6EA'
  strokeStrong: string = '#D0D3D8'
  success: string = '#2F6B4F'
  successContainer: string = '#DCE8E0'
  warning: string = '#B45309'
  warningContainer: string = '#F8ECD8'
  danger: string = '#A33B3B'
  dangerContainer: string = '#F5DCDC'
  info: string = '#1A2A6C'
  overlayScrim: string = 'rgba(26,42,108,0.40)'
  chart1: string = '#1A2A6C'
  chart2: string = '#F5A623'
  chart3: string = '#2F6B4F'
  chart4: string = '#5C5C62'
  chart5: string = '#4A4A50'
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
  card: number = 12
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
    AppStorage.setOrCreate('darkModeOn', Theme.isDark())
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

  /** 传入 themeEpoch，深浅色切换时 ArkUI 才会重绘绑定的文字/背景色 */
  static colorOf(_epoch: number): ThemeColors {
    return Theme.colors()
  }

  static applyBrandPrimary(hex: string): void {
    AppStorage.setOrCreate('brandPrimary', hex)
  }

  static lightColors(): ThemeColors {
    return new ThemeColors()
  }

  static darkColors(): ThemeColors {
    const c = new ThemeColors()
    c.brandPrimary = '#7B8FD9'
    c.brandPrimaryPressed = '#9AA8E3'
    c.brandPrimaryContainer = '#2C2C4A'
    c.brandOnPrimary = '#0F1020'
    c.brandDeep = '#121214'
    c.brandAccent = '#F5A623'
    c.surfacePage = '#1C1C1E'
    c.surfaceSubtle = '#232326'
    c.surfaceCard = '#2C2C2E'
    c.surfaceGlass = 'rgba(44,44,46,0.82)'
    c.surfaceInverse = '#F8F9FA'
    c.textPrimary = '#F5F5F7'
    c.textSecondary = '#C7C7CC'
    c.textTertiary = '#AEAEB2'
    c.textOnInverse = '#2D2D2D'
    c.strokeHairline = 'rgba(245,245,247,0.10)'
    c.strokeStrong = 'rgba(245,245,247,0.18)'
    c.success = '#8FBF9A'
    c.successContainer = '#24332A'
    c.warning = '#F5A623'
    c.warningContainer = '#3D2A0A'
    c.danger = '#E08A8A'
    c.dangerContainer = '#3F1520'
    c.info = '#7B8FD9'
    c.overlayScrim = 'rgba(0,0,0,0.56)'
    c.chart1 = '#7B8FD9'
    c.chart2 = '#F5A623'
    c.chart3 = '#8FBF9A'
    c.chart4 = '#C7C7CC'
    c.chart5 = '#AEAEB2'
    return c
  }

  static shadowSm(): string {
    return Theme.isDark() ? '0 1vp 2vp rgba(0,0,0,0.25)' : '0 1vp 2vp rgba(10,37,64,0.04)'
  }

  static shadowMd(): string {
    return Theme.isDark() ? '0 4vp 16vp rgba(0,0,0,0.35)' : '0 4vp 16vp rgba(10,37,64,0.06)'
  }

  /** 输入框底：浅底深字，避免系统深色与 App 主题不同步时文字不可见 */
  static inputFill(): string {
    return Theme.isDark() ? '#3A3A3C' : '#FFFFFF'
  }

  static inputInk(): string {
    return Theme.isDark() ? '#F5F5F7' : '#0F172A'
  }

  static inputHint(): string {
    return Theme.isDark() ? '#AEAEB2' : '#475569'
  }

  /** 顶部 Toast：深浅色均保证正文对比度 ≥4.5:1 */
  static toastFill(_epoch: number): string {
    return Theme.isDark() ? '#7B8FD9' : '#0F1A4A'
  }

  static toastInk(_epoch: number): string {
    return '#FFFFFF'
  }

  static toastBorder(_epoch: number): string {
    return Theme.isDark() ? '#9AA8E3' : '#1A2A6C'
  }
}
