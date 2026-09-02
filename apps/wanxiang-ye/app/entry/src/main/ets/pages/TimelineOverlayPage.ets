import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { TimelineEvent } from '../models/UserKnowledgeModels'
import { TimelineService } from '../services/TimelineService'

@Component
export struct TimelineOverlayPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  @State events: TimelineEvent[] = []

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.events = await TimelineService.listAll()
  }

  build() {
    Column() {
      Row() {
        Text('成长时间轴')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Blank()
        Text('返回')
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => this.onClose())
      }
      .width('100%')
      .padding(Theme.space.pageX)

      if (this.events.length === 0) {
        AppEmpty({
          title: '还没有记录',
          description: '阅读、收藏、新建知识后会出现在这里',
          actionLabel: '返回',
          onAction: (): void => this.onClose()
        }).layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.events, (ev: TimelineEvent) => {
              Row({ space: Theme.space.s3 }) {
                Column() {
                  Text('●')
                    .fontSize(10)
                    .fontColor(Theme.colors().brandPrimary)
                }
                .width(20)
                Column({ space: 4 }) {
                  Text(ev.title)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().textPrimary)
                  Text(`${TimelineService.formatDay(ev.timestamp)} ${TimelineService.formatTime(ev.timestamp)}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
            }, (ev: TimelineEvent) => ev.id)
          }
          .padding(Theme.space.pageX)
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
    .zIndex(22)
  }
}
