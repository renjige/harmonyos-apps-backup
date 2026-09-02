import { Theme } from './Theme'

export type AppIconName =
  | 'home' | 'biz' | 'ai' | 'chart' | 'message' | 'user'
  | 'add' | 'search' | 'alert' | 'check' | 'close' | 'chevron' | 'empty' | 'refresh'
  | 'bookmark' | 'book' | 'grid' | 'list' | 'calendar' | 'heart' | 'edit' | 'trash'
  | 'sparkle' | 'gear' | 'bell' | 'clock' | 'tag' | 'photo'

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
    if (this.name === 'biz') {
      return $r('sys.symbol.doc_text')
    }
    if (this.name === 'ai' || this.name === 'sparkle') {
      return $r('sys.symbol.star')
    }
    if (this.name === 'chart') {
      return $r('sys.symbol.histogram')
    }
    if (this.name === 'message') {
      return $r('sys.symbol.message')
    }
    if (this.name === 'user') {
      return $r('sys.symbol.person')
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
    if (this.name === 'bookmark' || this.name === 'tag') {
      return $r('sys.symbol.bookmark')
    }
    if (this.name === 'book') {
      return $r('sys.symbol.book')
    }
    if (this.name === 'grid') {
      return $r('sys.symbol.square_grid_2x2')
    }
    if (this.name === 'list') {
      return $r('sys.symbol.doc_text')
    }
    if (this.name === 'calendar') {
      return $r('sys.symbol.calendar')
    }
    if (this.name === 'heart') {
      return $r('sys.symbol.heart')
    }
    if (this.name === 'edit') {
      return $r('sys.symbol.square_and_pencil')
    }
    if (this.name === 'trash') {
      return $r('sys.symbol.trash')
    }
    if (this.name === 'gear') {
      return $r('sys.symbol.gearshape')
    }
    if (this.name === 'bell') {
      return $r('sys.symbol.bell')
    }
    if (this.name === 'clock') {
      return $r('sys.symbol.clock')
    }
    if (this.name === 'photo') {
      return $r('sys.symbol.camera')
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
