import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { JianEntry } from '../../models/JianModels'
import { DateHelper } from '../../services/DateHelper'
import { MoodCatalog } from '../../services/MoodCatalog'

@Component
export struct JianListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop entry: JianEntry = new JianEntry()
  onTap: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      Column() {
        Text(MoodCatalog.emojiOf(this.entry.moodId))
          .fontSize(18)
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(MoodCatalog.colorOf(this.entry.moodId))
      .opacity(0.35)
      .borderRadius(Theme.radius.pill)

      Column({ space: 4 }) {
        Row() {
          Text(DateHelper.displayDate(this.entry.dateKey))
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text(this.entry.timeStr)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .margin({ left: 8 })
          if (this.entry.isFavorite) {
            Text('★')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandAccent)
              .margin({ left: 6 })
          }
        }
        Text(this.entry.previewLine())
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .shadow({ radius: 8, color: 'rgba(61,61,61,0.06)', offsetY: 2 })
    .onClick((): void => { this.onTap() })
  }
}
