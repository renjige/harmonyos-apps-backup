import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { InsightEntry } from '../../models/InsightModels'
import { DateHelper } from '../../services/DateHelper'
import { CategoryEmojiUtil } from '../../utils/CategoryEmojiUtil'

@Component
export struct EntryListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: InsightEntry = new InsightEntry()
  @Prop highlight: string = ''
  @Prop starredFlag: boolean = false
  @Prop stamp: number = 0
  onOpen: () => void = () => {}

  private firstTag(): string {
    const tags = this.item.tagList()
    for (const t of tags) {
      return t
    }
    return ''
  }

  private highlightedTitle(): string {
    return this.item.title
  }

  build() {
    Row({ space: Theme.space.s3 }) {
      Column() {
        AppIcon({
          name: this.item.imagePath.length > 0 ? 'photo' : 'book',
          iconSize: Theme.icon.lg,
          color: Theme.colors().brandOnPrimary
        })
      }
      .width(56)
      .height(56)
      .borderRadius(Theme.radius.md)
      .justifyContent(FlexAlign.Center)
      .linearGradient({
        angle: 160,
        colors: [[Theme.colors().brandDeep, 0], [Theme.colors().brandPrimary, 1]]
      })

      Column({ space: 4 }) {
        Text(this.highlightedTitle())
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(this.item.summaryLine().length > 0 ? this.item.summaryLine() : '尚未写下正文')
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Row({ space: 8 }) {
          Text(DateHelper.clockLabel(this.item.updatedAt))
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          if (this.starredFlag) {
            Text('星标')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          }
          if (this.item.pinned) {
            Text('置顶')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          }
          if (this.firstTag().length > 0) {
            Text(CategoryEmojiUtil.chipLabel(this.firstTag()))
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .shadow({ radius: 12, color: 'rgba(0,0,0,0.06)', offsetY: 2 })
    .onClick((): void => { this.onOpen() })
    .opacity(this.stamp >= 0 ? 1 : 1)
  }
}
