/**
 * 知微集 Theme — 雪域灰页底 · 墨蓝深底 · 华为蓝 CTA
 */

export type ColorMode = 'light' | 'dark' | 'system'

export class ThemeColors {
  brandPrimary: string = '#007AFF'
  brandPrimaryPressed: string = '#0066D6'
  brandPrimaryContainer: string = '#E8F1FC'
  brandOnPrimary: string = '#FFFFFF'
  brandDeep: string = '#1A1A2E'
  brandAccent: string = '#007AFF'
  surfacePage: string = '#F5F7FA'
  surfaceSubtle: string = '#EEF1F6'
  surfaceCard: string = '#FFFFFF'
  surfaceGlass: string = 'rgba(255,255,255,0.88)'
  surfaceInverse: string = '#1A1A2E'
  textPrimary: string = '#1A1A2E'
  textSecondary: string = '#4A4A6A'
  textTertiary: string = '#5C5C78'
  textOnInverse: string = '#F5F7FA'
  strokeHairline: string = 'rgba(26,26,46,0.08)'
  strokeStrong: string = 'rgba(26,26,46,0.16)'
  success: string = '#2F6B4F'
  successContainer: string = '#E3F0E9'
  warning: string = '#8A5A18'
  warningContainer: string = '#F6EBD8'
  danger: string = '#E53E3E'
  dangerContainer: string = '#FDE8E8'
  info: string = '#007AFF'
  overlayScrim: string = 'rgba(26,26,46,0.44)'
  chart1: string = '#007AFF'
  chart2: string = '#1A1A2E'
  chart3: string = '#2F6B4F'
  chart4: string = '#E53E3E'
  chart5: string = '#5C5C78'
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
  xs: number = 8
  sm: number = 12
  md: number = 16
  lg: number = 20
  xl: number = 22
  sheet: number = 28
  pill: number = 999
  tag: number = 14
  card: number = 16
  button: number = 20
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
  bodyM: number = 15
  bodyS: number = 14
  captionL: number = 12
  captionM: number = 10
  display: number = 38
  title1: number = 30
  title2: number = 24
  title3: number = 20
  body: number = 14
  callout: number = 16
  subhead: number = 16
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

  /** Bind UI to themeEpoch so dark/light repaints on the same page. */
  static colorOf(epoch: number): ThemeColors {
    if (epoch < 0) {
      return Theme.lightColors()
    }
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
    c.brandPrimary = '#58A6FF'
    c.brandPrimaryPressed = '#79B8FF'
    c.brandPrimaryContainer = '#1C2A3D'
    c.brandOnPrimary = '#0D1117'
    c.brandDeep = '#E7E9EA'
    c.brandAccent = '#58A6FF'
    c.surfacePage = '#0D1117'
    c.surfaceSubtle = '#12171E'
    c.surfaceCard = '#161B22'
    c.surfaceGlass = 'rgba(22,27,34,0.86)'
    c.surfaceInverse = '#E7E9EA'
    c.textPrimary = '#E7E9EA'
    c.textSecondary = '#CBD5E1'
    c.textTertiary = '#94A3B8'
    c.textOnInverse = '#1A1A2E'
    c.strokeHairline = 'rgba(231,233,234,0.10)'
    c.strokeStrong = 'rgba(231,233,234,0.18)'
    c.success = '#86C9A8'
    c.successContainer = '#1A2E24'
    c.warning = '#E0C08A'
    c.warningContainer = '#2E2618'
    c.danger = '#F08080'
    c.dangerContainer = '#3A2020'
    c.info = '#58A6FF'
    c.overlayScrim = 'rgba(0,0,0,0.56)'
    c.chart1 = '#58A6FF'
    c.chart2 = '#E7E9EA'
    c.chart3 = '#86C9A8'
    c.chart4 = '#F08080'
    c.chart5 = '#94A3B8'
    return c
  }

  static shadowSm(): string {
    return Theme.isDark() ? '0 1vp 2vp rgba(0,0,0,0.28)' : '0 1vp 2vp rgba(26,26,46,0.06)'
  }

  static shadowMd(): string {
    return Theme.isDark() ? '0 4vp 16vp rgba(0,0,0,0.38)' : '0 4vp 12vp rgba(26,26,46,0.08)'
  }
}
