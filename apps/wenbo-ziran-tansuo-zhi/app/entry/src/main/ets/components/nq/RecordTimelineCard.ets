import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { ExploreRecord } from '../../models/ExploreRecordModels'

@Component
export struct RecordTimelineCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: ExploreRecord = new ExploreRecord()
  onTap: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      Column({ space: 4 }) {
        Text(this.item.date)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .width('100%')
        Column()
          .width(2)
          .height(48)
          .backgroundColor(Theme.colors().brandPrimaryContainer)
      }
      .width(56)
      .alignItems(HorizontalAlign.Center)

      Column({ space: Theme.space.s2 }) {
        Text(this.item.title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Row({ space: Theme.space.s2 }) {
          if (this.item.location.length > 0) {
            Text(`📍 ${this.item.location}`)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          if (this.item.weather.length > 0) {
            Text(this.item.weather)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandAccent)
          }
        }
        .width('100%')
        if (this.item.body.length > 0) {
          Text(this.item.body)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .padding(Theme.space.s3)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
      .border({ width: 1, color: Theme.colors().strokeHairline })

      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
    .onClick(() => this.onTap())
  }
}
