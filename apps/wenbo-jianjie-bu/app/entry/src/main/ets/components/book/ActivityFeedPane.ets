import { Theme } from '../design-system/Theme'
import { DetailShell } from '../detail/DetailShell'
import { AppEmpty } from '../design-system/AppEmpty'
import { ActivityItem } from '../../models/GrowthModels'
import { AchievementService } from '../../services/AchievementService'
import { GrowthStore } from '../../services/GrowthStore'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct ActivityFeedPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  @State items: ActivityItem[] = []
  @State loaded: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await GrowthStore.recentActivities(50)
    this.loaded = true
  }

  build() {
    Column() {
      DetailShell({ title: '活动流', onClose: (): void => { this.onClose() } })
      if (this.loaded && this.items.length === 0) {
        AppEmpty({
          title: '暂无动态',
          description: '写下见解、星标、验收判断或完成打卡后会出现在这里',
          actionLabel: '',
          onAction: (): void => {}
        })
          .layoutWeight(1)
      } else {
        List({ space: 0 }) {
          ForEach(this.items, (a: ActivityItem) => {
            ListItem() {
              Column({ space: 4 }) {
                Row({ space: 8 }) {
                  Text(AchievementService.labelForKind(a.kind))
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandPrimary)
                    .width(72)
                  Text(a.title)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().textPrimary)
                    .layoutWeight(1)
                }
                .width('100%')
                Text(DateHelper.displayDate(a.dateKey))
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding({ top: 12, bottom: 12 })
            }
          }, (a: ActivityItem) => a.id)
        }
        .layoutWeight(1)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
