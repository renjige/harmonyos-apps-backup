/**
 * HCDS Theme — ArkTS strict-mode compatible token accessors.
 * Source of truth: knowledge/design-system/tokens.json
 */

export type ColorMode = 'light' | 'dark' | 'system'

export class ThemeColors {
  brandPrimary: string = '#0B6BCB'
  brandPrimaryPressed: string = '#0958A8'
  brandPrimaryContainer: string = '#D7E9F8'
  brandOnPrimary: string = '#FFFFFF'
  brandDeep: string = '#0A2540'
  brandAccent: string = '#3D8BDB'
  surfacePage: string = '#F2F4F7'
  surfaceSubtle: string = '#E8ECF1'
  surfaceCard: string = '#FFFFFF'
  surfaceGlass: string = 'rgba(255,255,255,0.72)'
  surfaceInverse: string = '#0A2540'
  surfaceInput: string = '#FFFFFF'
  textPrimary: string = '#0F172A'
  textSecondary: string = '#475569'
  textTertiary: string = '#94A3B8'
  textOnInverse: string = '#F8FAFC'
  strokeHairline: string = 'rgba(15,23,42,0.06)'
  strokeStrong: string = 'rgba(15,23,42,0.12)'
  success: string = '#0F766E'
  successContainer: string = '#CCFBF1'
  warning: string = '#B45309'
  warningContainer: string = '#FEF3C7'
  danger: string = '#BE123C'
  dangerContainer: string = '#FFE4E6'
  info: string = '#0369A1'
  overlayScrim: string = 'rgba(10,37,64,0.40)'
  chart1: string = '#0B6BCB'
  chart2: string = '#0F766E'
  chart3: string = '#B45309'
  chart4: string = '#6366F1'
  chart5: string = '#64748B'
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

  /** 标签/胶囊：深色模式禁止 brandPrimary 字叠 brandPrimaryContainer 底（对比度≈1.2） */
  static tagForeground(): string {
    const c = Theme.colors()
    if (Theme.isDark()) {
      return c.textPrimary
    }
    return c.brandPrimary
  }

  static tagBackground(): string {
    const c = Theme.colors()
    if (Theme.isDark()) {
      return c.surfaceSubtle
    }
    return c.brandPrimaryContainer
  }

  /** 底栏 Tab 选中：深色模式用实心 brandPrimary + brandOnPrimary，避免 mint-on-mint ≈1.2 */
  static tabSelectedIconBackground(): string {
    const c = Theme.colors()
    if (Theme.isDark()) {
      return c.brandPrimary
    }
    return c.brandPrimaryContainer
  }

  static tabSelectedIconForeground(): string {
    const c = Theme.colors()
    if (Theme.isDark()) {
      return c.brandOnPrimary
    }
    return c.brandPrimary
  }

  static tabSelectedLabelForeground(): string {
    const c = Theme.colors()
    if (Theme.isDark()) {
      return c.textPrimary
    }
    return c.brandPrimary
  }

  /** 卡片内强调链接/差异说明 — 深色不用 brandPrimary 叠 container */
  static linkForeground(): string {
    const c = Theme.colors()
    if (Theme.isDark()) {
      return c.brandAccent
    }
    return c.brandPrimary
  }

  /** 摄影 Hero 叠字 — 深浅模式均浅色（勿用 textOnInverse，深色模式会变深字） */
  static heroTitleColor(): string {
    return '#FFFFFF'
  }

  static heroSubtitleColor(): string {
    return '#F3EDE4'
  }

  static heroScrimStops(): Array<[string, number]> {
    const top: [string, number] = ['rgba(0,0,0,0.32)', 0]
    const mid: [string, number] = ['rgba(0,0,0,0.62)', 0.52]
    const bottom: [string, number] = ['rgba(0,0,0,0.90)', 1]
    const stops: Array<[string, number]> = [top, mid, bottom]
    return stops
  }

  static applyBrandPrimary(hex: string): void {
    AppStorage.setOrCreate('brandPrimary', hex)
  }

  static lightColors(): ThemeColors {
    const c = new ThemeColors()
    c.brandPrimary = '#2D5A4A'
    c.brandPrimaryPressed = '#244A3D'
    c.brandPrimaryContainer = '#E4EDE8'
    c.brandOnPrimary = '#FFFFFF'
    c.brandDeep = '#6B5344'
    c.brandAccent = '#C9A962'
    c.surfacePage = '#F7F3EB'
    c.surfaceSubtle = '#EDE7DB'
    c.surfaceCard = '#FFFFFF'
    c.surfaceGlass = 'rgba(255,255,255,0.78)'
    c.surfaceInverse = '#2D5A4A'
    c.surfaceInput = '#FFFFFF'
    c.textPrimary = '#2C2824'
    c.textSecondary = '#5C534A'
    c.textTertiary = '#6F675E'
    c.textOnInverse = '#F7F3EB'
    c.strokeHairline = 'rgba(44,40,36,0.08)'
    c.strokeStrong = 'rgba(44,40,36,0.14)'
    c.success = '#2D5A4A'
    c.successContainer = '#E4EDE8'
    c.warning = '#C9A962'
    c.warningContainer = '#F5EDD8'
    c.info = '#6B5344'
    c.chart1 = '#2D5A4A'
    c.chart2 = '#6B5344'
    c.chart3 = '#C9A962'
    c.chart4 = '#8B7355'
    c.chart5 = '#A0826D'
    return c
  }

  static darkColors(): ThemeColors {
    const c = new ThemeColors()
    c.brandPrimary = '#8FBFB0'
    c.brandPrimaryPressed = '#A8D0C4'
    c.brandPrimaryContainer = '#4A5A52'
    c.brandOnPrimary = '#1A1612'
    c.brandDeep = '#E8D5B5'
    c.brandAccent = '#E8D5B5'
    c.surfacePage = '#1A1612'
    c.surfaceSubtle = '#241F1A'
    c.surfaceCard = '#2A241E'
    c.surfaceGlass = 'rgba(42,36,30,0.88)'
    c.surfaceInverse = '#F5F0E8'
    c.surfaceInput = '#3A332C'
    c.textPrimary = '#F5F0E8'
    c.textSecondary = '#E8DED0'
    c.textTertiary = '#D8CFC0'
    c.textOnInverse = '#1A1612'
    c.strokeHairline = 'rgba(245,240,232,0.16)'
    c.strokeStrong = 'rgba(245,240,232,0.28)'
    c.success = '#8FDBB0'
    c.successContainer = '#2A4A38'
    c.warning = '#FBBF24'
    c.warningContainer = '#4A3A18'
    c.danger = '#E85A6B'
    c.dangerContainer = '#5A2430'
    c.info = '#8FBFB0'
    c.overlayScrim = 'rgba(20,16,12,0.55)'
    c.chart1 = '#8FBFB0'
    c.chart2 = '#E8D5B5'
    c.chart3 = '#FBBF24'
    c.chart4 = '#C4B5FD'
    c.chart5 = '#D4C9B8'
    return c
  }

  static shadowSm(): string {
    return Theme.isDark() ? '0 1vp 2vp rgba(0,0,0,0.25)' : '0 1vp 2vp rgba(10,37,64,0.04)'
  }

  static shadowMd(): string {
    return Theme.isDark() ? '0 4vp 16vp rgba(0,0,0,0.35)' : '0 4vp 16vp rgba(10,37,64,0.06)'
  }
}
