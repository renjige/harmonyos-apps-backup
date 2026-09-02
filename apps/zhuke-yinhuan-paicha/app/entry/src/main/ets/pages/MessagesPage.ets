import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppCard } from '../components/design-system/AppCard'
import { HazardNotice } from '../models/HazardModels'
import { HazardBizService } from '../services/HazardBizService'

@Component
export struct MessagesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: HazardNotice[] = []
  @State loaded: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await HazardBizService.notices()
    this.loaded = true
  }

  build() {
    Column() {
      AppHeader({ title: '消息中心', subtitle: '机构通知与检查提醒' })
      if (this.items.length === 0) {
        AppEmpty({
          title: '暂无消息',
          description: '机构通知、检查提醒将显示在这里。下拉或返回后可再次刷新。',
          actionLabel: '重新加载',
          onAction: (): void => { void this.reload() }
        })
      } else {
        List() {
          ForEach(this.items, (m: HazardNotice) => {
            ListItem() {
              AppCard({ title: m.title }) {
                Text(m.body)
                  .fontSize(Theme.type.callout)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              }
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })
          }, (m: HazardNotice) => m.id)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
