import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { FamilyMemo } from '../../models/JujiaModels'
import { TaskMedia } from '../../services/TaskMedia'

@Component
export struct MemoRow {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: FamilyMemo = new FamilyMemo()
  onTap: () => void = () => {}

  build() {
    Row({ space: 12 }) {
      Image(TaskMedia.cover(this.item.coverKey()))
        .width(56)
        .height(56)
        .borderRadius(Theme.radius.md)
        .objectFit(ImageFit.Cover)
      Column({ space: 4 }) {
        Row({ space: 6 }) {
          if (this.item.pinned) {
            Text('📌')
              .fontSize(12)
          }
          Text(this.item.title)
            .fontSize(Theme.type.body)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')
        Text(this.item.body.length > 0 ? this.item.body : '暂无内容')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(this.item.tag)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: 16, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(14)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .onClick(() => this.onTap())
  }
}
