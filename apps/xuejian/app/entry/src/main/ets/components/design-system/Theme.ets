/**
 * HCDS Theme — ArkTS strict-mode compatible token accessors.
 * Source of truth: knowledge/design-system/tokens.json
 */

export type ColorMode = 'light' | 'dark' | 'system'

export class ThemeColors {
  brandPrimary: string = '#1A2A4A'
  brandPrimaryPressed: string = '#121C32'
  brandPrimaryContainer: string = '#FDF0D5'
  brandOnPrimary: string = '#FFFFFF'
  brandDeep: string = '#121C32'
  brandAccent: string = '#F5A623'
  surfacePage: string = '#F8F6F3'
  surfaceSubtle: string = '#EFEAE3'
  surfaceCard: string = '#FFFFFF'
  surfaceGlass: string = 'rgba(255,255,255,0.72)'
  surfaceInverse: string = '#0A2540'
  textPrimary: string = '#0F172A'
  textSecondary: string = '#1E293B'
  textTertiary: string = '#475569'
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
    AppStorage.setOrCreate('xuejianDark', mode === 'dark')
    AppStorage.setOrCreate('themeEpoch', Date.now())
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
    c.brandPrimary = '#E8EEF7'
    c.brandPrimaryPressed = '#CBD5E1'
    c.brandPrimaryContainer = '#3A4558'
    c.brandOnPrimary = '#1A2A4A'
    c.brandDeep = '#121C32'
    c.brandAccent = '#F5A623'
    c.surfacePage = '#1C1C1E'
    c.surfaceSubtle = '#242426'
    c.surfaceCard = '#2C2C2E'
    c.surfaceGlass = 'rgba(23,31,46,0.72)'
    c.surfaceInverse = '#E8EEF7'
    c.textPrimary = '#F8FAFC'
    c.textSecondary = '#E2E8F0'
    c.textTertiary = '#94A3B8'
    c.textOnInverse = '#0F172A'
    c.strokeHairline = 'rgba(248,250,252,0.08)'
    c.strokeStrong = 'rgba(248,250,252,0.16)'
    c.success = '#2DD4BF'
    c.successContainer = '#0F3D38'
    c.warning = '#FBBF24'
    c.warningContainer = '#3D2A0A'
    c.danger = '#FB7185'
    c.dangerContainer = '#3F1520'
    c.info = '#38BDF8'
    c.overlayScrim = 'rgba(0,0,0,0.56)'
    c.chart1 = '#5BA3E0'
    c.chart2 = '#2DD4BF'
    c.chart3 = '#FBBF24'
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

  /** 输入框始终白底深字，避免系统深色与主题不同步时看不清 */
  static inputFill(): string {
    return '#FFFFFF'
  }

  static inputInk(): string {
    return '#0F172A'
  }

  static inputHint(): string {
    return '#475569'
  }

  /** 品牌深蓝 #1A2A4A 上的辅助文字 */
  static inkOnNavy(): string {
    return '#F8FAFC'
  }

  /** 品牌橙 #F5A623 上的辅助文字 */
  static inkOnAccent(): string {
    return '#0F172A'
  }

  /** 卡片/页面浅底上的副标题（≥4.5:1） */
  static bodyMuted(): string {
    return Theme.isDark() ? '#CBD5E1' : '#1E293B'
  }

  /** #EFEAE3 / #3A4558 等 tinted 区块上的说明文字 */
  static bodyMutedOnTint(): string {
    return Theme.isDark() ? '#F1F5F9' : '#1E293B'
  }

  /** 次级描边按钮（如「换一张」） */
  static softButtonFg(): string {
    return Theme.isDark() ? '#FFFFFF' : '#0F172A'
  }

  static softButtonBg(): string {
    return Theme.isDark() ? '#64748B' : '#FFFFFF'
  }

  static softButtonBorder(): string {
    return Theme.isDark() ? '#CBD5E1' : '#475569'
  }

  /** 底栏 Tab 未选中 */
  static tabInactiveFg(): string {
    return Theme.isDark() ? '#CBD5E1' : '#475569'
  }

  static chipFill(): string {
    return '#1A2A4A'
  }

  static chipInk(): string {
    return '#FFFFFF'
  }
}
