import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { JournalEntry } from '../../models/ShiyiModels'
import { MoodCatalog } from '../../services/MoodCatalog'
import { ShiyiMedia } from '../../services/ShiyiMedia'
import { ShiyiStore } from '../../services/ShiyiStore'

@Component
export struct JournalListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop entry: JournalEntry = new JournalEntry()
  onTap: () => void = () => {}

  private summary(): string {
    if (this.entry.oneLiner.length > 0) {
      return this.entry.oneLiner
    }
    if (this.entry.body.length > 0) {
      return this.entry.body
    }
    return '把这一刻留下来'
  }

  private titleText(): string {
    if (this.entry.title.length > 0) {
      return this.entry.title
    }
    return '未题名的拾意'
  }

  build() {
    Row({ space: Theme.space.s3 }) {
      Image(ShiyiMedia.cover(MoodCatalog.coverOf(this.entry.mood)))
        .width(72)
        .height(72)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.lg)
      Column({ space: 4 }) {
        Text(ShiyiStore.displayDate(this.entry.entryDate))
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandAccent)
          .width('100%')
        Text(this.titleText())
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(`${MoodCatalog.labelOf(this.entry.mood)}  ·  ${this.summary()}`)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
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
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick(() => this.onTap())
  }
}
