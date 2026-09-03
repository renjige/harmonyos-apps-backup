/**
 * Hand-Drawn Sketch Theme — 网格纸 · 便签 · 墨线 · 硬阴影
 */

export type ColorMode = 'light' | 'dark' | 'system'

export class ThemeColors {
  brandPrimary: string = '#3D5A80'
  brandPrimaryPressed: string = '#2F4663'
  brandPrimaryContainer: string = '#E3F2FF'
  brandOnPrimary: string = '#FFFDF6'
  brandDeep: string = '#243447'
  brandAccent: string = '#6B9AC4'
  textOnBrandContainer: string = '#2C3E50'
  surfacePage: string = '#F7F3E8'
  surfaceSubtle: string = '#FFF6C8'
  surfaceCard: string = '#FFFDF6'
  surfaceGlass: string = 'rgba(255,253,246,0.88)'
  surfaceInverse: string = '#2C3E50'
  textPrimary: string = '#2C3E50'
  textSecondary: string = '#4A5568'
  textTertiary: string = '#64748B'
  textOnInverse: string = '#FFFDF6'
  strokeHairline: string = 'rgba(44,62,80,0.14)'
  strokeStrong: string = 'rgba(44,62,80,0.55)'
  sketchGrid: string = 'rgba(44,62,80,0.07)'
  stickyYellow: string = '#FFF6C8'
  stickyPink: string = '#FFE8F0'
  stickyBlue: string = '#E3F2FF'
  stickyGreen: string = '#E8F5E9'
  success: string = '#2F855A'
  successContainer: string = '#E8F5E9'
  warning: string = '#B7791F'
  warningContainer: string = '#FFF6C8'
  danger: string = '#C53030'
  dangerContainer: string = '#FFE8F0'
  info: string = '#3D5A80'
  overlayScrim: string = 'rgba(44,62,80,0.42)'
  chart1: string = '#3D5A80'
  chart2: string = '#2F855A'
  chart3: string = '#B7791F'
  chart4: string = '#6B46C1'
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
  xs: number = 3
  sm: number = 6
  md: number = 10
  lg: number = 14
  xl: number = 18
  sheet: number = 22
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
  instant: number = 120
  fast: number = 220
  normal: number = 380
  slow: number = 480
  emphasis: number = 520
  sketch: number = 420
  staggerMs: number = 55
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

  static pageClear(): string {
    return 'rgba(0,0,0,0)'
  }

  static lightColors(): ThemeColors {
    return new ThemeColors()
  }

  static darkColors(): ThemeColors {
    const c = new ThemeColors()
    c.brandPrimary = '#8EB4E0'
    c.brandPrimaryPressed = '#A8C8EB'
    c.brandPrimaryContainer = '#2A3544'
    c.brandOnPrimary = '#1E1B16'
    c.brandDeep = '#14110E'
    c.brandAccent = '#9FD4FF'
    c.textOnBrandContainer = '#F7F3E8'
    c.surfacePage = '#1E1B16'
    c.surfaceSubtle = '#2A2620'
    c.surfaceCard = '#2F2A24'
    c.surfaceGlass = 'rgba(47,42,36,0.92)'
    c.surfaceInverse = '#F7F3E8'
    c.textPrimary = '#F7F3E8'
    c.textSecondary = '#D4CFC4'
    c.textTertiary = '#A8A093'
    c.textOnInverse = '#2C3E50'
    c.strokeHairline = 'rgba(247,243,232,0.12)'
    c.strokeStrong = 'rgba(247,243,232,0.42)'
    c.sketchGrid = 'rgba(247,243,232,0.06)'
    c.stickyYellow = '#3D3520'
    c.stickyPink = '#3D2830'
    c.stickyBlue = '#243040'
    c.stickyGreen = '#243528'
    c.success = '#68D391'
    c.successContainer = '#243528'
    c.warning = '#F6E05E'
    c.warningContainer = '#3D3520'
    c.danger = '#FC8181'
    c.dangerContainer = '#3D2830'
    c.info = '#8EB4E0'
    c.overlayScrim = 'rgba(0,0,0,0.58)'
    c.chart1 = '#8EB4E0'
    c.chart2 = '#68D391'
    c.chart3 = '#F6E05E'
    c.chart4 = '#B794F4'
    c.chart5 = '#A8A093'
    return c
  }

  static sketchShadow(offsetY: number = 5): ShadowOptions {
    return {
      radius: 0,
      color: Theme.sketchShadowColor(),
      offsetX: 4,
      offsetY: offsetY
    }
  }

  static sketchRadius(): BorderRadiuses {
    return {
      topLeft: 14,
      topRight: 20,
      bottomLeft: 18,
      bottomRight: 12
    }
  }

  static sketchShadowColor(): string {
    return Theme.isDark() ? 'rgba(0,0,0,0.48)' : 'rgba(44,62,80,0.24)'
  }

  static stickyNoteColors(): string[] {
    const c = Theme.colors()
    const out: string[] = []
    out.push(c.stickyYellow)
    out.push(c.stickyPink)
    out.push(c.stickyBlue)
    out.push(c.stickyGreen)
    return out
  }

  static shadowSm(): ShadowOptions {
    return {
      radius: 0,
      color: Theme.sketchShadowColor(),
      offsetX: 2,
      offsetY: 2
    }
  }

  static shadowMd(): ShadowOptions {
    return {
      radius: 0,
      color: Theme.sketchShadowColor(),
      offsetX: 4,
      offsetY: 4
    }
  }
}
