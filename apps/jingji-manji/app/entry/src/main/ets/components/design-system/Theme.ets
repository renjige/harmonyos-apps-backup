/**
 * HCDS Theme — 竞技漫记 · 竞技蓝 + 活力橙 · 默认深色
 */

export type ColorMode = 'light' | 'dark' | 'system'

export class ThemeColors {
  brandPrimary: string = '#1A5CFF'
  brandPrimaryPressed: string = '#1448CC'
  brandPrimaryContainer: string = '#E8EFFF'
  brandOnPrimary: string = '#FFFFFF'
  brandDeep: string = '#0A0E1A'
  brandAccent: string = '#FF6B35'
  surfacePage: string = '#FFFFFF'
  surfaceSubtle: string = '#E5E7EB'
  surfaceCard: string = '#FFFFFF'
  surfaceGlass: string = 'rgba(255,255,255,0.72)'
  surfaceInverse: string = '#0A0E1A'
  textPrimary: string = '#1A1A2E'
  textSecondary: string = '#374151'
  textTertiary: string = '#4B5563'
  textOnInverse: string = '#FFFFFF'
  /** 摄影 Hero / 深色遮罩上的正文（深浅模式均为浅色字） */
  textOnScrim: string = '#FFFFFF'
  /** 摄影 Hero 上的次要说明（实色，禁止低透明度白字） */
  textOnScrimMuted: string = '#E2E8F0'
  strokeHairline: string = 'rgba(26,26,46,0.08)'
  strokeStrong: string = 'rgba(26,26,46,0.14)'
  success: string = '#10B981'
  successContainer: string = '#D1FAE5'
  warning: string = '#FF6B35'
  warningContainer: string = '#FFEDD5'
  danger: string = '#EF4444'
  dangerContainer: string = '#FEE2E2'
  info: string = '#1A5CFF'
  overlayScrim: string = 'rgba(10,14,26,0.55)'
  chart1: string = '#1A5CFF'
  chart2: string = '#FF6B35'
  chart3: string = '#10B981'
  chart4: string = '#8B5CF6'
  chart5: string = '#6B7280'
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
  section: number = 28
  cardPadding: number = 18
  listItemY: number = 14
  inline: number = 8
  textStack: number = 4
}

export class ThemeRadius {
  xs: number = 6
  sm: number = 10
  md: number = 16
  lg: number = 22
  xl: number = 28
  sheet: number = 32
  pill: number = 999
}

export class ThemeTypeScale {
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
  tabHeight: number = 64
  tabMax: number = 5
}

export class Theme {
  static readonly space: ThemeSpace = new ThemeSpace()
  static readonly radius: ThemeRadius = new ThemeRadius()
  static readonly type: ThemeTypeScale = new ThemeTypeScale()
  static readonly motion: ThemeMotion = new ThemeMotion()
  static readonly icon: ThemeIconSize = new ThemeIconSize()
  static readonly nav: ThemeNav = new ThemeNav()

  private static mode: ColorMode = 'dark'
  private static forcedDark: boolean = true

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
    const c = new ThemeColors()
    c.surfaceSubtle = '#E2E8F0'
    c.textSecondary = '#334155'
    c.textTertiary = '#475569'
    c.brandPrimaryContainer = '#DBEAFE'
    c.textOnScrim = '#FFFFFF'
    c.textOnScrimMuted = '#E2E8F0'
    return c
  }

  static darkColors(): ThemeColors {
    const c = new ThemeColors()
    c.brandPrimary = '#60A5FA'
    c.brandPrimaryPressed = '#3B82F6'
    c.brandPrimaryContainer = '#1D4ED8'
    c.brandOnPrimary = '#FFFFFF'
    c.brandDeep = '#0A0E1A'
    c.brandAccent = '#FF8A5C'
    c.surfacePage = '#070B14'
    c.surfaceSubtle = '#1E293B'
    c.surfaceCard = '#162032'
    c.surfaceGlass = 'rgba(22,32,50,0.98)'
    c.surfaceInverse = '#FFFFFF'
    c.textPrimary = '#F8FAFC'
    c.textSecondary = '#E2E8F0'
    c.textTertiary = '#CBD5E1'
    c.textOnInverse = '#0F172A'
    c.textOnScrim = '#FFFFFF'
    c.textOnScrimMuted = '#E2E8F0'
    c.strokeHairline = 'rgba(255,255,255,0.10)'
    c.strokeStrong = 'rgba(255,255,255,0.18)'
    c.success = '#34D399'
    c.successContainer = 'rgba(52,211,153,0.15)'
    c.warning = '#FF6B35'
    c.warningContainer = 'rgba(255,107,53,0.15)'
    c.danger = '#F87171'
    c.dangerContainer = 'rgba(248,113,113,0.15)'
    c.info = '#60A5FA'
    c.overlayScrim = 'rgba(0,0,0,0.62)'
    c.chart1 = '#1A5CFF'
    c.chart2 = '#FF6B35'
    c.chart3 = '#34D399'
    c.chart4 = '#A78BFA'
    c.chart5 = '#94A3B8'
    return c
  }

  static shadowSm(): string {
    return Theme.isDark() ? '0 2vp 8vp rgba(0,0,0,0.28)' : '0 2vp 8vp rgba(26,35,50,0.06)'
  }

  static shadowMd(): string {
    return Theme.isDark() ? '0 8vp 24vp rgba(0,0,0,0.38)' : '0 8vp 28vp rgba(26,35,50,0.10)'
  }

  static heroScrim(): Array<[ResourceColor, number]> {
    if (Theme.isDark()) {
      return [
        ['rgba(7,11,20,0.42)', 0.0],
        ['rgba(7,11,20,0.78)', 0.42],
        ['rgba(7,11,20,0.97)', 1.0]
      ]
    }
    return [
      ['rgba(7,11,20,0.12)', 0.0],
      ['rgba(7,11,20,0.58)', 0.45],
      ['rgba(7,11,20,0.94)', 1.0]
    ]
  }

  static brandGradient(): Array<[ResourceColor, number]> {
    return [
      [Theme.colors().brandPrimary, 0.0],
      ['#3B82F6', 0.55],
      [Theme.colors().brandAccent, 1.0]
    ]
  }
}
