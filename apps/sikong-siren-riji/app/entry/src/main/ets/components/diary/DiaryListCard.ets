import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { DiaryEntry, MoodOption } from '../../models/DiaryModels'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct DiaryListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop entry: DiaryEntry = new DiaryEntry()
  onTap: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      Column({ space: 4 }) {
        Text(DateHelper.displayShort(this.entry.dateKey))
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        Text(this.moodTag())
          .fontSize(20)
      }
      .width(56)
      .alignItems(HorizontalAlign.Center)

      Column({ space: 4 }) {
        Row() {
          Text(this.entry.previewLine())
            .fontSize(Theme.type.body)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
          if (this.entry.isFavorite) {
            AppIcon({ name: 'star', iconSize: 14, color: Theme.colors().brandAccent })
          }
        }
        .width('100%')

        Row({ space: Theme.space.s2 }) {
          Text(`${this.entry.wordCount} 字`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
          if (this.entry.weather.length > 0) {
            Text(this.entry.weather)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
          }
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      if (this.entry.firstImagePath().length > 0) {
        Image(this.entry.firstImagePath())
          .width(48)
          .height(48)
          .borderRadius(Theme.radius.sm)
          .objectFit(ImageFit.Cover)
      } else {
        AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
      }
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick(() => this.onTap())
  }

  private moodTag(): string {
    const opt = MoodOption.find(this.entry.moodKey)
    return opt !== undefined ? opt.tag : '📝'
  }
}
