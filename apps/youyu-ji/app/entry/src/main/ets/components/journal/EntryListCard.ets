import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { MoodCatalog } from '../../services/MoodCatalog'
import { CornerEntry } from '../../models/YouyuModels'

@Component
export struct EntryListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop mood: string = 'calm'
  @Prop summary: string = ''
  @Prop timeLabel: string = ''
  @Prop tagsLine: string = ''
  @Prop photoPath: string = ''
  onTap: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      Column() {
        AppIcon({
          name: MoodCatalog.iconOf(this.mood),
          iconSize: Theme.icon.lg,
          color: Theme.colors().brandOnPrimary
        })
      }
      .width(48)
      .height(48)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimary)
      .borderRadius(Theme.radius.pill)

      Column({ space: 4 }) {
        Text(this.summary)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Row({ space: 8 }) {
          Text(`${MoodCatalog.emojiMark(this.mood)} ${MoodCatalog.labelOf(this.mood)}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandDeep)
          if (this.tagsLine.length > 0) {
            Text(this.tagsLine)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .maxLines(1)
              .layoutWeight(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
        .width('100%')
        Text(this.timeLabel)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      if (this.photoPath.length > 0) {
        Image(this.photoPath)
          .width(56)
          .height(56)
          .borderRadius(Theme.radius.sm)
          .objectFit(ImageFit.Cover)
      } else {
        AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
      }
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .shadow({ radius: 8, color: Theme.isDark() ? 'rgba(0,0,0,0.28)' : 'rgba(61,43,31,0.06)', offsetX: 0, offsetY: 2 })
    .onClick(() => this.onTap())
  }
}

export class EntryListCardBinder {
  static timeOf(item: CornerEntry): string {
    if (item.entryDate.length < 10) {
      return ''
    }
    return item.entryDate.substring(5)
  }
}
