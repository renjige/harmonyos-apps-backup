import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { CatalogOptions } from '../../services/AnalyzeEngine'
import { WrongMedia } from '../../services/WrongMedia'
import { WrongEntry } from '../../models/WrongModels'

@Component
export struct EntryListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop entry: WrongEntry = new WrongEntry()
  onOpen: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      Image(WrongMedia.resource(this.entry.coverKey.length > 0 ?
        this.entry.coverKey : WrongMedia.subjectCover(this.entry.subjectCode)))
        .width(72)
        .height(72)
        .borderRadius(Theme.radius.sm)
        .objectFit(ImageFit.Cover)
      Column({ space: 4 }) {
        Row({ space: 8 }) {
          Text(CatalogOptions.subjectLabel(this.entry.subjectCode))
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .fontWeight(FontWeight.Medium)
          Text(CatalogOptions.statusLabel(this.entry.status))
            .fontSize(Theme.type.caption)
            .fontColor(this.entry.status === 'mastered' ?
              Theme.colors().success : Theme.colors().brandAccent)
        }
        .width('100%')
        Text(this.entry.stem)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(CatalogOptions.causeLabel(this.entry.causeCode))
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .shadow({ radius: 8, color: 'rgba(11,31,74,0.06)', offsetY: 2, offsetX: 0 })
    .onClick(() => this.onOpen())
  }
}
