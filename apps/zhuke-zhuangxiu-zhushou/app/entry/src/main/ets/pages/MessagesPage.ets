import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppCard } from '../components/design-system/AppCard'
import { RenoNotice } from '../models/RenoModels'
import { RenoCatalog } from '../services/RenoCatalog'

@Component
export struct MessagesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: RenoNotice[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await RenoCatalog.notices()
  }

  build() {
    Column() {
      AppHeader({ title: '提醒与通知', subtitle: '机构通知与事项提醒' })
      if (this.items.length === 0) {
        AppEmpty({ title: '暂无通知', description: '事项提醒可在「我的」中开关。系统通知将显示在这里。' })
      } else {
        List() {
          ForEach(this.items, (m: RenoNotice) => {
            ListItem() {
              AppCard({ title: m.title }) {
                Text(m.body)
                  .fontSize(Theme.type.callout)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s3
            })
          }, (m: RenoNotice) => m.id)
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
