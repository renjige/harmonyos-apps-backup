import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { DetailShell } from '../components/detail/DetailShell'
import { TimelineEvent } from '../models/ExplorationModels'
import { ExplorationStore } from '../services/ExplorationStore'
import { ExploreNav } from '../services/ExploreNav'

@Component
export struct TimelineOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('progressRev') @Watch('onRev') progressRev: number = 0
  @State events: TimelineEvent[] = []

  aboutToAppear(): void {
    this.reload()
    void ExplorationStore.completeTask('task_review1')
  }

  onRev(): void {
    this.reload()
  }

  private reload(): void {
    this.events = ExplorationStore.snapshot().timeline
  }

  build() {
    DetailShell({
      title: '探索时间轴',
      onClose: (): void => { ExploreNav.closeTimeline() }
    }) {
      if (this.events.length === 0) {
        AppEmpty({ title: '暂无动态', description: '完成探索、记录或任务后会出现在这里' })
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.events, (ev: TimelineEvent) => {
              Column({ space: 4 }) {
                Text(ev.title)
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Text(ev.detail)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
                Text(ev.dateKey)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .border({ width: 1, color: Theme.colors().strokeHairline })
            }, (ev: TimelineEvent) => ev.id)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
          .width('100%')
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .width('100%')
        .height('100%')
      }
    }
  }
}
