import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { RenoDates, RenoNote } from '../../models/RenoModels'

@Component
export struct NoteRow {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: RenoNote = new RenoNote()
  onOpen: (item: RenoNote) => void = (_i: RenoNote) => {}

  build() {
    Row({ space: 12 }) {
      Column() {
        AppIcon({ name: 'camera', iconSize: 18, color: Theme.colors().brandPrimary })
      }
      .width(40)
      .height(40)
      .borderRadius(12)
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .justifyContent(FlexAlign.Center)
      Column({ space: 4 }) {
        Text(this.item.title)
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(1)
          .width('100%')
        Text(`${RenoDates.displayDate(this.item.date)} · ${this.item.kind}`)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(14)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick(() => this.onOpen(this.item))
  }
}
