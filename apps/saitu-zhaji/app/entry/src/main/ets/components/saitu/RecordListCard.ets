import { Theme } from '../design-system/Theme'
import { SaituRecord } from '../../models/SaituModels'
import { DateHelper } from '../../services/DateHelper'
import { ImagePathUtil } from '../../services/ImagePathUtil'

@Component
export struct RecordListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop record: SaituRecord = new SaituRecord()
  @Prop journeyName: string = ''
  onTap: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      if (this.record.images.length > 0) {
        Image(ImagePathUtil.toDisplayUri(this.record.images[0]))
          .width(72)
          .height(72)
          .borderRadius(Theme.radius.md)
          .objectFit(ImageFit.Cover)
      } else {
        Column() {
          Image($r('app.media.empty_trail'))
            .width(72)
            .height(72)
            .borderRadius(Theme.radius.md)
            .objectFit(ImageFit.Cover)
        }
        .width(72)
        .height(72)
      }
      Column({ space: Theme.space.s1 }) {
        Text(DateHelper.displayDateTime(this.record.createdAt))
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
        Text(this.record.summaryLine(64))
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textPrimary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        if (this.journeyName.length > 0 || this.record.tags.length > 0) {
          Row({ space: Theme.space.s1 }) {
            if (this.journeyName.length > 0) {
              Text(this.journeyName)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandPrimary)
                .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
            }
            if (this.record.tags.length > 0) {
              Text(this.record.tags[0])
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }
          }
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .onClick((): void => this.onTap())
  }
}
