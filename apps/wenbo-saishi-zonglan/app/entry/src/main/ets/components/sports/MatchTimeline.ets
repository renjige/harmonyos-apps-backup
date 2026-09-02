import { Theme } from '../design-system/Theme'
import { TimelineEvent } from '../../models/MatchModels'

@Component
export struct MatchTimeline {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop events: TimelineEvent[] = []

  build() {
    if (this.events.length === 0) {
      Column()
    } else {
      Column({ space: Theme.space.s3 }) {
        Text('赛况速递')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        ForEach(this.events, (ev: TimelineEvent, index: number) => {
          Row({ space: Theme.space.s3 }) {
            Column() {
              Text(ev.time)
                .fontSize(Theme.type.caption)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            }
            .width(52)
            Column() {
              if (index < this.events.length - 1) {
                Column()
                  .width(2)
                  .height('100%')
                  .backgroundColor(Theme.colors().strokeHairline)
              }
            }
            .width(2)
            .height(36)
            Column({ space: 4 }) {
              Text(ev.text)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              if (ev.side === 'home') {
                Text('主队')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              } else if (ev.side === 'away') {
                Text('客队')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .alignItems(VerticalAlign.Top)
        }, (ev: TimelineEvent, index: number) => `${ev.time}_${index}`)
      }
      .width('100%')
      .padding(Theme.space.s4)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)
      .border({ width: 1, color: Theme.colors().strokeHairline })
    }
  }
}
