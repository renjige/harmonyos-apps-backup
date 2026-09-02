import { Theme } from '../design-system/Theme'

/** 观察类型标识 — 区分五感卡 / 对照 / 自由观察，非通用「笔记」 */
@Component
export struct ObserveKindBadge {
  @Prop kind: string = ''

  private label(): string {
    if (this.kind === 'contrast') {
      return '对照观察'
    }
    if (this.kind === 'card') {
      return '五感观察卡'
    }
    return '自由观察'
  }

  build() {
    Text(this.label())
      .fontSize(Theme.type.caption)
      .fontWeight(FontWeight.Medium)
      .fontColor('#1A2A3A')
      .padding({ left: 10, right: 10, top: 4, bottom: 4 })
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.pill)
  }
}
