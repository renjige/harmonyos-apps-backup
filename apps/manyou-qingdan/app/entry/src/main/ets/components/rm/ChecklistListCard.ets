import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { RmChecklist, RmLabels } from '../../models/RmModels'

@Component
export struct ChecklistListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop entry: RmChecklist = new RmChecklist()
  @Prop categoryLabel: string = ''
  onOpen: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      Column() {
        AppIcon({ name: 'book', iconSize: Theme.icon.md, color: Theme.colors().brandOnPrimary })
      }
      .width(56)
      .height(56)
      .borderRadius(Theme.radius.sm)
      .backgroundColor(Theme.colors().brandPrimary)
      .justifyContent(FlexAlign.Center)

      Column({ space: 4 }) {
        Text(this.entry.title)
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(`${this.categoryLabel} · ${RmLabels.statusLabel(this.entry.status)}`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
          .width('100%')
        Text(this.entry.summaryText())
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textSecondary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick((): void => { this.onOpen() })
  }
}
