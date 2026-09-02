import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { WorkoutRecord, WorkoutTypeOption } from '../../models/WorkoutModels'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct WorkoutListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop record: WorkoutRecord = new WorkoutRecord()
  onTap: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      Column() {
        AppIcon({ name: 'chart', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
      }
      .width(48)
      .height(48)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.md)
      Column({ space: 4 }) {
        Text(WorkoutTypeOption.labelFor(this.record.typeKey))
          .fontSize(Theme.type.body)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Text(`${DateHelper.formatDuration(this.record.durationSeconds)} · ${this.record.distanceKm} km`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
        if (this.record.note.length > 0) {
          Text(this.record.note)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .onClick((): void => { this.onTap() })
  }
}
