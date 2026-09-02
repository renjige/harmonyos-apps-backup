import { Theme } from './Theme'

export type AppIconName =
  | 'home' | 'biz' | 'ai' | 'chart' | 'message' | 'user'
  | 'add' | 'search' | 'alert' | 'check' | 'close' | 'chevron' | 'empty' | 'refresh'
  | 'calendar' | 'star'

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
    if (this.name === 'calendar') {
      return $r('sys.symbol.calendar')
    }
    if (this.name === 'star') {
      return $r('sys.symbol.star')
    }
    return $r('sys.symbol.circle')
  }

  build() {
    // 尺寸跟随 iconSize，勿写死 minTouch(44)，否则在底栏矮容器内会被压扁变形
    // 热区 ≥44vp 由父级点击容器保证（如 Tab 项），不是 SymbolGlyph 自身宽高
    SymbolGlyph(this.symbol())
      .fontSize(this.iconSize)
      .fontColor([this.resolvedColor()])
      .renderingStrategy(SymbolRenderingStrategy.SINGLE)
      .width(this.iconSize + 4)
      .height(this.iconSize + 4)
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
