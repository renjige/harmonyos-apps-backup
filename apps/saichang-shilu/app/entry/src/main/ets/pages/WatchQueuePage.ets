import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { RecordCard } from '../components/sport/RecordCard'
import { SportRecord } from '../models/SportRecord'
import { AnalyticsService } from '../services/AnalyticsService'
import { MatchWorkbenchPage } from './MatchWorkbenchPage'

@Component
export struct WatchQueuePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State queue: SportRecord[] = []
  @State workbenchId: string = ''
  @State showWorkbench: boolean = false
  onClose: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.queue = await AnalyticsService.watchQueue()
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Blank()
          Text('待看清单')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Column().width(44)
        }
        .width('100%')
        .padding(Theme.space.pageX)

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text(`共 ${this.queue.length} 场待看或重点关注，按日期排序。`)
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)

            if (this.queue.length === 0) {
              AppEmpty({
                title: '清单是空的',
                description: '记录赛事时选择「待看」或「重点关注」会出现在这里',
                actionLabel: '',
                onAction: (): void => {}
              })
            } else {
              ForEach(this.queue, (m: SportRecord) => {
                RecordCard({
                  record: m,
                  onTap: (): void => {
                    this.workbenchId = m.id
                    this.showWorkbench = true
                  }
                })
              }, (m: SportRecord) => m.id)
            }
          }
          .width('100%')
          .padding(Theme.space.pageX)
          .padding({ bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.showWorkbench && this.workbenchId.length > 0) {
        MatchWorkbenchPage({
          seedId: this.workbenchId,
          onClose: (): void => { this.showWorkbench = false },
          onSaved: (): void => { void this.reload() }
        })
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(80)
    .onAppear((): void => { AppStorage.setOrCreate('tabBarHidden', true) })
    .onDisAppear((): void => { AppStorage.setOrCreate('tabBarHidden', false) })
  }
}
