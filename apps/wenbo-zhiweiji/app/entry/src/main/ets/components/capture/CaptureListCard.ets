import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { ZhiweiMedia } from '../../services/ZhiweiMedia'
import { CategoryEmojiUtil } from '../../utils/CategoryEmojiUtil'

@Component
export struct CaptureListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop title: string = ''
  @Prop summary: string = ''
  @Prop category: string = 'spark'
  @Prop priority: string = 'mid'
  @Prop status: string = 'inbox'
  @Prop timeLabel: string = ''
  onTap: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      Image(ZhiweiMedia.coverOf(ZhiweiMedia.coverKeyOfCategory(this.category)))
        .width(72)
        .height(72)
        .borderRadius(Theme.radius.sm)
        .objectFit(ImageFit.Cover)
      Column({ space: 4 }) {
        Text(this.title.length > 0 ? this.title : this.summary)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(this.summary)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Row({ space: 8 }) {
          Text(CategoryEmojiUtil.chipLabel(this.category))
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          Text(`优先级 ${CategoryEmojiUtil.priorityLabel(this.priority)}`)
            .fontSize(Theme.type.caption)
            .fontColor(this.priority === 'high' ? Theme.colorOf(this.themeEpoch).danger : Theme.colorOf(this.themeEpoch).textSecondary)
          Text(CategoryEmojiUtil.statusLabel(this.status))
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colorOf(this.themeEpoch).brandPrimary)
          Text(this.timeLabel)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .layoutWeight(1)
        }
        .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .shadow({ radius: 8, color: Theme.isDark() ? 'rgba(0,0,0,0.28)' : 'rgba(26,26,46,0.06)', offsetX: 0, offsetY: 2 })
    .onClick(() => this.onTap())
  }
}
