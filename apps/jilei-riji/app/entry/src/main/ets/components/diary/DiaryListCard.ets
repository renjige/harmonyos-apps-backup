import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { DiaryEntry } from '../../models/DiaryModels'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct DiaryListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop entry: DiaryEntry = new DiaryEntry()
  onTap: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      Column() {
        Text(DateHelper.monthShort(this.entry.dateKey))
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
        Text(DateHelper.dayNumber(this.entry.dateKey))
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
      }
      .width(52)
      .alignItems(HorizontalAlign.Center)

      Column({ space: Theme.space.s1 }) {
        Text(this.entry.previewLine())
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(`${this.entry.wordCount} 字`)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      if (this.entry.imagePath.length > 0) {
        Image(this.entry.imagePath)
          .width(56)
          .height(56)
          .borderRadius(Theme.radius.sm)
          .objectFit(ImageFit.Cover)
      }

      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick((): void => { this.onTap() })
  }
}
