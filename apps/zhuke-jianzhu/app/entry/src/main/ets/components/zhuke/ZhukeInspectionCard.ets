import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { SafetyItem, SafetyService } from '../../services/SafetyService'

@Component
export struct ZhukeInspectionCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: SafetyItem = new SafetyItem()
  onTap: () => void = () => {}

  private levelColor(): string {
    return SafetyService.levelColor(this.item.level)
  }

  private statusBg(): string {
    if (this.item.status === 'closed') {
      return Theme.colors().successContainer
    }
    if (this.item.status === 'rectifying') {
      return Theme.colors().warningContainer
    }
    return Theme.colors().dangerContainer
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Column({ space: Theme.space.s1 }) {
          Text(this.item.title)
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(`${SafetyService.typeLabel(this.item.type)} · ${this.item.projectName}`)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textTertiary)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Text(SafetyService.levelLabel(this.item.level))
          .fontSize(Theme.type.caption)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.levelColor())
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          .backgroundColor(this.statusBg())
          .borderRadius(Theme.radius.pill)
      }
      .width('100%')

      Row() {
        Text(SafetyService.statusLabel(this.item.status))
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        Blank()
        AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
      }
      .width('100%')
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .shadow(Theme.cardShadow())
    .onClick(() => this.onTap())
  }
}
