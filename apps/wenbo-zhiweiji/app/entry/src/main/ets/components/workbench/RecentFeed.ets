import { Theme } from '../design-system/Theme'
import { TimelineEvent } from '../../models/ZhiweiModels'
import { ZhiweiNav } from '../../services/ZhiweiNav'
import { ZhiweiStore } from '../../services/ZhiweiStore'

@Component
export struct RecentFeed {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop events: TimelineEvent[] = []

  build() {
    Column({ space: Theme.space.s2 }) {
      Row() {
        Text('最近动态')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
        Blank()
        Text('时间轴')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colorOf(this.themeEpoch).brandPrimary)
          .onClick(() => ZhiweiNav.openTimeline())
      }
      .width('100%')
      if (this.events.length === 0) {
        Text('记下第一条微知识，这里会出现你的成长轨迹')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
          .width('100%')
          .padding(Theme.space.s3)
          .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
          .borderRadius(Theme.radius.sm)
      } else {
        ForEach(this.events, (e: TimelineEvent) => {
          Row({ space: 10 }) {
            Column({ space: 2 }) {
              Text(e.title)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .width('100%')
              Text(`${e.subtitle} · ${ZhiweiStore.displayTime(e.ts)}`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
                .width('100%')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding(Theme.space.s3)
          .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
          .borderRadius(Theme.radius.sm)
          .onClick(() => {
            if (e.type === 'capture' && e.refId.length > 0) {
              ZhiweiNav.openCapture(e.refId)
            }
          })
        }, (e: TimelineEvent) => e.id)
      }
    }
    .width('100%')
  }
}
