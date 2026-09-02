import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { StatusChip } from './StatusChip'
import { InspectionRecord, QualityDates } from '../../models/QualityModels'

@Component
export struct InspectionCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: InspectionRecord = new InspectionRecord()
  @State pressed: boolean = false
  onOpen: (id: string) => void = (_id: string) => {}

  build() {
    Row() {
      Column({ space: 6 }) {
        Row({ space: 8 }) {
          Text(this.item.projectName)
            .fontSize(Theme.type.subtitleM)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          StatusChip({ label: this.item.status })
        }
        .width('100%')
        Text(`${this.item.area}  ·  ${this.item.inspectType}`)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(`${QualityDates.display(this.item.inspectDate)}  ·  检查项 ${this.item.itemCount}  ·  问题 ${this.item.issueCount}`)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(16)
    .opacity(this.pressed ? 0.88 : 1)
    .scale({ x: this.pressed ? 0.98 : 1, y: this.pressed ? 0.98 : 1 })
    .animation({ duration: Theme.motion.instant, curve: Curve.EaseOut })
    .onTouch((e: TouchEvent) => {
      if (e.type === TouchType.Down) {
        this.pressed = true
      }
      if (e.type === TouchType.Up || e.type === TouchType.Cancel) {
        this.pressed = false
      }
    })
    .onClick(() => this.onOpen(this.item.id))
  }
}
