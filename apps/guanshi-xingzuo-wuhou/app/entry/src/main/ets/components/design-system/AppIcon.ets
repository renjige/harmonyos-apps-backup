import { Theme } from './Theme'

export type AppIconName =
  | 'home' | 'biz' | 'ai' | 'chart' | 'message' | 'user'
  | 'star' | 'moon' | 'leaf' | 'sun' | 'heart' | 'book'
  | 'add' | 'search' | 'alert' | 'check' | 'close' | 'chevron' | 'empty' | 'refresh'

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
    if (this.name === 'home' || this.name === 'sun') {
      return $r('sys.symbol.sun_max')
    }
    if (this.name === 'star' || this.name === 'ai') {
      return $r('sys.symbol.star')
    }
    if (this.name === 'moon') {
      return $r('sys.symbol.moon')
    }
    if (this.name === 'leaf') {
      return $r('sys.symbol.leaf')
    }
    if (this.name === 'biz' || this.name === 'book') {
      return $r('sys.symbol.book')
    }
    if (this.name === 'heart') {
      return $r('sys.symbol.heart')
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
