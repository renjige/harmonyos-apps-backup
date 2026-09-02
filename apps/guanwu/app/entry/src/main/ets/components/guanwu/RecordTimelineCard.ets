import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { ObserveRecord } from '../../models/ObserveModels'
import { ObserveMedia } from '../../services/ObserveMedia'
import { DateHelper } from '../../services/DateHelper'
import { CategoryEmojiUtil } from '../../utils/CategoryEmojiUtil'
import { ObserveImage } from './ObserveImage'

@Component
export struct RecordTimelineCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRecordChange') record: ObserveRecord = new ObserveRecord()
  onTap: () => void = () => {}

  onRecordChange(): void {
  }

  private imageKey(): string {
    if (this.record.imagePaths.length === 0) {
      return 'none'
    }
    return `${this.record.updatedAt}-${this.record.imagePaths[0]}`
  }

  build() {
    Row({ space: Theme.space.s3 }) {
      if (this.record.hasImage()) {
        ObserveImage({
          path: this.record.imagePaths[0],
          imgWidth: 72,
          imgHeight: 72,
          radius: Theme.radius.md,
          refreshKey: this.imageKey()
        })
      } else {
        Image(ObserveMedia.kindCover(this.record.kind))
          .width(72)
          .height(72)
          .borderRadius(Theme.radius.md)
          .objectFit(ImageFit.Cover)
      }
      Column({ space: 6 }) {
        Row() {
          Text(CategoryEmojiUtil.chipLabel(this.record.kind, this.record.kindLabel()))
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          if (this.record.subtypeLabel().length > 0) {
            Text(this.record.subtypeLabel())
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .margin({ left: 8 })
          }
        }
        Text(this.record.preview())
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(`${DateHelper.displayDate(this.record.dateKey)} · ${DateHelper.timeLabel(this.record.createdAt)}`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .shadow({ radius: 12, color: 'rgba(26,26,46,0.06)', offsetY: 4 })
    .onClick((): void => this.onTap())
  }
}
