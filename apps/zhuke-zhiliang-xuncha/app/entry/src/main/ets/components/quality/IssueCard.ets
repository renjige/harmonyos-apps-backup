import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { StatusChip } from './StatusChip'
import { CoverImage } from './CoverImage'
import { IssueRecord, QualityDates } from '../../models/QualityModels'

@Component
export struct IssueCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: IssueRecord = new IssueRecord()
  @State pressed: boolean = false
  onOpen: (id: string) => void = (_id: string) => {}

  build() {
    Row({ space: 12 }) {
      CoverImage({ coverKey: this.item.coverKey, imgWidth: 72, imgHeight: 72, radius: 12 })
      Column({ space: 6 }) {
        Row({ space: 8 }) {
          Text(this.item.title)
            .fontSize(Theme.type.subtitleM)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          StatusChip({ label: this.item.severity })
        }
        .width('100%')
        Text(`${this.item.projectName}  ·  ${this.item.location}`)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Row({ space: 8 }) {
          StatusChip({ label: this.item.status })
          Text(QualityDates.displayTime(this.item.foundAt))
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
    }
    .width('100%')
    .padding(14)
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
