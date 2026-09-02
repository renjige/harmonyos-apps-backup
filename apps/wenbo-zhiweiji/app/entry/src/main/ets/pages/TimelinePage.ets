import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { TimelineEvent } from '../models/ZhiweiModels'
import { ZhiweiNav } from '../services/ZhiweiNav'
import { ZhiweiStore } from '../services/ZhiweiStore'

@Component
export struct TimelinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('zwRev') @Watch('onRev') storeRev: number = 0
  @State events: TimelineEvent[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onRev(): void {
    this.reload()
  }

  private reload(): void {
    this.events = ZhiweiStore.timelineEvents(50)
  }

  build() {
    Column() {
      Row() {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colorOf(this.themeEpoch).textPrimary })
        }
        .width(48)
        .height(48)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick(() => ZhiweiNav.closeTimeline())
        Text('成长时间轴')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          if (this.events.length === 0) {
            AppEmpty({
              title: '时间轴还是空的',
              description: '记录、消化、打卡与收藏都会出现在这里。',
              actionLabel: '记微知识',
              onAction: (): void => {
                ZhiweiNav.closeTimeline()
                ZhiweiNav.openCompose('', false)
              }
            })
          } else {
            ForEach(this.events, (e: TimelineEvent) => {
              Row({ space: 12 }) {
                Column()
                  .width(4)
                  .height(48)
                  .backgroundColor(Theme.colorOf(this.themeEpoch).brandPrimary)
                  .borderRadius(2)
                Column({ space: 4 }) {
                  Text(e.title)
                    .fontSize(Theme.type.body)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
                    .width('100%')
                  Text(e.subtitle)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
                    .width('100%')
                  Text(ZhiweiStore.displayTime(e.ts))
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colorOf(this.themeEpoch).brandPrimary)
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
          Blank().height(Theme.space.s10)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colorOf(this.themeEpoch).surfacePage)
  }
}
