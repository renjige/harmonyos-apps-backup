import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { TrainingRecord } from '../../models/TrainingModels'

@Component
export struct TrainingListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop record: TrainingRecord = new TrainingRecord()
  onTap: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      Column() {
        AppIcon({ name: 'chart', iconSize: Theme.icon.lg, color: Theme.colors().brandPrimary })
      }
      .width(48)
      .height(48)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.md)

      Column({ space: 4 }) {
        Text(this.record.trainingType)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Text(`${this.record.durationMin} 分钟 · ${this.record.recordDate} · ${this.record.completeStatus}`)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textSecondary)
        if (this.record.note.length > 0) {
          Text(this.record.note)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick((): void => { this.onTap() })
  }
}
