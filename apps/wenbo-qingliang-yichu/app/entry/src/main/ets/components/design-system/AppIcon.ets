import { Theme } from './Theme'

export type AppIconName =
  | 'home' | 'biz' | 'ai' | 'chart' | 'message' | 'user'
  | 'add' | 'search' | 'alert' | 'check' | 'close' | 'chevron' | 'empty' | 'refresh'
  | 'wardrobe' | 'outfit' | 'calendar' | 'mine' | 'hanger' | 'filter' | 'heart' | 'gear'
  | 'weather_sun' | 'weather_cloud' | 'weather_rain' | 'sparkle' | 'edit' | 'trash' | 'share' | 'sort'
  | 'camera' | 'photo' | 'star'

/**
 * HarmonyOS Design icons via SymbolGlyph — never Emoji or text glyphs.
 * See .cursor/rules/icons-harmonyos.mdc
 */
@Component
export struct AppIcon {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop name: AppIconName = 'home'
  @Prop iconSize: number = Theme.icon.lg
  @Prop color: string = ''
  @Prop active: boolean = false

  private resolvedColor(): ResourceColor {
    if (this.color.length > 0) {
      return this.color
    }
    const c = Theme.colors()
    return this.active ? c.brandPrimary : c.textSecondary
  }

  private symbol(): Resource {
    if (this.name === 'home') {
      return $r('sys.symbol.house')
    }
    if (this.name === 'wardrobe') {
      return $r('sys.symbol.square_grid_2x2')
    }
    if (this.name === 'outfit' || this.name === 'sparkle' || this.name === 'ai' || this.name === 'star') {
      return $r('sys.symbol.star')
    }
    if (this.name === 'calendar') {
      return $r('sys.symbol.calendar')
    }
    if (this.name === 'mine' || this.name === 'user') {
      return $r('sys.symbol.person')
    }
    if (this.name === 'biz') {
      return $r('sys.symbol.doc_text')
    }
    if (this.name === 'chart') {
      return $r('sys.symbol.histogram')
    }
    if (this.name === 'message') {
      return $r('sys.symbol.message')
    }
    if (this.name === 'add') {
      return $r('sys.symbol.plus')
    }
    if (this.name === 'search') {
      return $r('sys.symbol.magnifyingglass')
    }
    if (this.name === 'alert') {
      return $r('sys.symbol.exclamationmark_triangle')
    }
    if (this.name === 'check') {
      return $r('sys.symbol.checkmark')
    }
    if (this.name === 'close') {
      return $r('sys.symbol.xmark')
    }
    if (this.name === 'chevron') {
      return $r('sys.symbol.chevron_right')
    }
    if (this.name === 'empty') {
      return $r('sys.symbol.circle')
    }
    if (this.name === 'refresh') {
      return $r('sys.symbol.arrow_clockwise')
    }
    if (this.name === 'hanger') {
      return $r('sys.symbol.bag')
    }
    if (this.name === 'filter') {
      return $r('sys.symbol.gearshape')
    }
    if (this.name === 'heart') {
      return $r('sys.symbol.bookmark')
    }
    if (this.name === 'gear') {
      return $r('sys.symbol.gearshape')
    }
    if (this.name === 'weather_sun') {
      return $r('sys.symbol.sun_max')
    }
    if (this.name === 'weather_cloud' || this.name === 'weather_rain') {
      return $r('sys.symbol.cloud')
    }
    if (this.name === 'edit') {
      return $r('sys.symbol.square_and_pencil')
    }
    if (this.name === 'trash') {
      return $r('sys.symbol.trash')
    }
    if (this.name === 'camera') {
      return $r('sys.symbol.camera')
    }
    if (this.name === 'photo') {
      return $r('sys.symbol.picture')
    }
    return $r('sys.symbol.circle')
  }

  build() {
    SymbolGlyph(this.symbol())
      .fontSize(this.iconSize)
      .fontColor([this.resolvedColor()])
      .renderingStrategy(SymbolRenderingStrategy.SINGLE)
      .width(this.iconSize + 4)
      .height(this.iconSize + 4)
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
