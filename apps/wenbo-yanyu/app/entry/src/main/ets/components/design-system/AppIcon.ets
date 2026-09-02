import { Theme } from './Theme'

export type AppIconName =
  | 'home' | 'biz' | 'ai' | 'chart' | 'message' | 'user'
  | 'add' | 'search' | 'alert' | 'check' | 'close' | 'chevron' | 'empty' | 'refresh'
  | 'heart' | 'bookmark' | 'edit' | 'sparkle' | 'moon'

@Component
export struct AppIcon {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop name: AppIconName = 'home'
  @Prop iconSize: number = Theme.icon.lg
  @Prop color: string = ''
  @Prop active: boolean = false

  private symbol(): Resource {
    if (this.name === 'home') {
      return $r('sys.symbol.house')
    }
    if (this.name === 'biz') {
      return $r('sys.symbol.doc_text')
    }
    if (this.name === 'ai') {
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
    if (this.name === 'heart') {
      return $r('sys.symbol.heart')
    }
    if (this.name === 'bookmark') {
      return $r('sys.symbol.bookmark')
    }
    if (this.name === 'edit') {
      return $r('sys.symbol.square_and_pencil')
    }
    if (this.name === 'sparkle') {
      return $r('sys.symbol.star')
    }
    if (this.name === 'moon') {
      return $r('sys.symbol.moon')
    }
    return $r('sys.symbol.circle')
  }

  build() {
    SymbolGlyph(this.symbol())
      .fontSize(this.iconSize)
      .fontColor([this.color.length > 0 ? this.color :
        (this.active ? Theme.of(this.darkModeOn).brandPrimary : Theme.of(this.darkModeOn).textSecondary)])
      .renderingStrategy(SymbolRenderingStrategy.SINGLE)
      .width(this.iconSize + 4)
      .height(this.iconSize + 4)
  }
}
