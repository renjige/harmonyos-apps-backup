import { Theme } from '../design-system/Theme'
import { MemoryBooklet } from '../../models/MemoryModels'

@Component
export struct BookletCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: MemoryBooklet = new MemoryBooklet()
  onOpen: () => void = () => {}

  build() {
    Column({ space: Theme.space.s2 }) {
      Text(this.item.title.length > 0 ? this.item.title : '未命名册')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
      Text(this.item.summary.length > 0 ? this.item.summary : '把相关记忆收进同一本册')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
      Text(this.item.countLabel())
        .fontSize(Theme.type.overline)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        .width('100%')
    }
    .width(168)
    .height(118)
    .padding(Theme.space.s4)
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .shadow({
      radius: 8,
      color: Theme.isDark() ? 'rgba(0,0,0,0.28)' : 'rgba(26,109,245,0.08)',
      offsetX: 0,
      offsetY: 2
    })
    .onClick((): void => { this.onOpen() })
  }
}
