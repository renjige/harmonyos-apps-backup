/**
 * HCDS Theme — 赛事纵览竞技风 token
 */

export type ColorMode = 'light' | 'dark' | 'system'

export class ThemeColors {
  brandPrimary: string = '#1677FF'
  brandPrimaryPressed: string = '#0958D9'
  brandPrimaryContainer: string = '#E6F4FF'
  brandOnPrimary: string = '#FFFFFF'
  brandDeep: string = '#0F172A'
  brandAccent: string = '#7C3AED'
  surfacePage: string = '#F6F8FC'
  surfaceSubtle: string = '#EEF2F8'
  surfaceCard: string = '#FFFFFF'
  surfaceGlass: string = 'rgba(255,255,255,0.72)'
  surfaceInverse: string = '#0F172A'
  textPrimary: string = '#0F172A'
  textSecondary: string = '#475569'
  textTertiary: string = '#64748B'
  textOnInverse: string = '#F8FAFC'
  strokeHairline: string = 'rgba(15,23,42,0.06)'
  strokeStrong: string = 'rgba(15,23,42,0.12)'
  success: string = '#0F766E'
  successContainer: string = '#CCFBF1'
  warning: string = '#B45309'
  warningContainer: string = '#FEF3C7'
  danger: string = '#BE123C'
  dangerContainer: string = '#FFE4E6'
  info: string = '#1677FF'
  overlayScrim: string = 'rgba(15,23,42,0.48)'
  chart1: string = '#1677FF'
  chart2: string = '#7C3AED'
  chart3: string = '#0F766E'
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
    AppStorage.setOrCreate('themeColorMode', mode)
    AppStorage.setOrCreate('darkModeOn', mode === 'dark')
    const epoch = (AppStorage.get<number>('themeEpoch') ?? 0) + 1
    AppStorage.setOrCreate('themeEpoch', epoch)
  }

  static setForcedDark(dark: boolean): void {
    Theme.forcedDark = dark
    AppStorage.setOrCreate('themeForcedDark', dark)
  }

  static isDark(): boolean {
    const stored = AppStorage.get<string>('themeColorMode')
    if (stored === 'dark') {
      return true
    }
    if (stored === 'light') {
      return false
    }
    const forcedStore = AppStorage.get<boolean>('themeForcedDark')
    if (forcedStore === true) {
      return true
    }
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
    const brand = AppStorage.get<string>('brandPrimary')
    if (brand !== undefined && brand.length > 0) {
      c.brandPrimary = brand
    }
    return c
  }

  static darkColors(): ThemeColors {
    const c = new ThemeColors()
    const brand = AppStorage.get<string>('brandPrimary')
    if (brand !== undefined && brand.length > 0) {
      c.brandPrimary = '#69B1FF'
    } else {
      c.brandPrimary = '#69B1FF'
    }
    c.brandPrimaryPressed = '#91CAFF'
    c.brandPrimaryContainer = '#163A6B'
    c.brandOnPrimary = '#FFFFFF'
    c.brandDeep = '#0B1220'
    c.brandAccent = '#C4B5FD'
    c.surfacePage = '#0B1220'
    c.surfaceSubtle = '#152033'
    c.surfaceCard = '#1A2740'
    c.surfaceGlass = 'rgba(26,39,64,0.92)'
    c.surfaceInverse = '#1A2740'
    c.textPrimary = '#FFFFFF'
    c.textSecondary = '#E2E8F0'
    c.textTertiary = '#CBD5E1'
    c.textOnInverse = '#FFFFFF'
    c.strokeHairline = 'rgba(248,250,252,0.18)'
    c.strokeStrong = 'rgba(248,250,252,0.32)'
    c.success = '#5EEAD4'
    c.successContainer = '#134E4A'
    c.warning = '#FCD34D'
    c.warningContainer = '#78350F'
    c.danger = '#FDA4AF'
    c.dangerContainer = '#881337'
    c.info = '#69B1FF'
    c.overlayScrim = 'rgba(0,0,0,0.62)'
    c.chart1 = '#69B1FF'
    c.chart2 = '#C4B5FD'
    c.chart3 = '#5EEAD4'
    c.chart4 = '#A5B4FC'
    c.chart5 = '#E2E8F0'
    return c
  }

  static shadowSm(): string {
    return Theme.isDark() ? '0 1vp 2vp rgba(0,0,0,0.25)' : '0 1vp 2vp rgba(15,23,42,0.04)'
  }

  static shadowMd(): string {
    return Theme.isDark() ? '0 4vp 16vp rgba(0,0,0,0.35)' : '0 4vp 16vp rgba(15,23,42,0.06)'
  }
}
