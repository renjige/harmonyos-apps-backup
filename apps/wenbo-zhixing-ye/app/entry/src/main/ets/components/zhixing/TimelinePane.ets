import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppNavBar } from '../design-system/AppNavBar'
import { TimelineEvent } from '../../models/ZhixingModels'
import { ZhixingStore } from '../../services/ZhixingStore'

@Component
export struct TimelinePane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onTok') reloadToken: number = 0
  @State events: TimelineEvent[] = []
  onClose: () => void = () => {}
  onOpenKnowledge: (id: string) => void = (_id: string) => {}
  onOpenAction: (kind: string, id: string) => void = (_k: string, _id: string) => {}

  aboutToAppear(): void {
    void this.load()
  }

  onTok(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.events = await ZhixingStore.loadTimeline(40)
  }

  private openEvent(ev: TimelineEvent): void {
    if (ev.eventType === 'create' || ev.eventType === 'favorite') {
      this.onOpenKnowledge(ev.refId)
      return
    }
    if (ev.eventType === 'check') {
      this.onOpenAction('habit', ev.refId)
      return
    }
    if (ev.eventType === 'done') {
      this.onOpenAction('plan', ev.refId)
      return
    }
    if (ev.eventType === 'log') {
      this.onOpenAction('log', ev.refId)
    }
  }

  build() {
    Column() {
      AppNavBar({ title: '成长时间轴', onBack: (): void => { this.onClose() } })
      if (this.events.length === 0) {
        AppEmpty({
          title: '还没有学习记录',
          description: '写卡片、打卡或完成计划后，这里会串起你的成长轨迹',
          actionLabel: '返回',
          onAction: (): void => { this.onClose() }
        })
      } else {
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.events, (ev: TimelineEvent) => {
              Row({ space: 12 }) {
                Column() {
                  Text(ev.dateKey.substring(5))
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandPrimary)
                  Text(ev.typeLabel())
                    .fontSize(10)
                    .fontColor(Theme.colors().textTertiary)
                }
                .width(56)
                Column({ space: 4 }) {
                  Text(ev.title)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(14)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .onClick((): void => { this.openEvent(ev) })
            }, (ev: TimelineEvent) => `${ev.refId}_${ev.createTime}_${ev.eventType}`)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          .width('100%')
        }
        .layoutWeight(1)
        .align(Alignment.Top)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
