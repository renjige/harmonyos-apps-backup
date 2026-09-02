import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppCard } from '../components/design-system/AppCard'
import { HttpClient } from '../services/HttpClient'
import { FamilyNotice, ListPayload } from '../models/FamilyTaskModels'

@Component
export struct MessagesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: FamilyNotice[] = []

  aboutToAppear(): void {
    void this.loadMessages()
  }

  private async loadMessages(): Promise<void> {
    const res = await HttpClient.get<ListPayload<FamilyNotice>>('/messages')
    if (res.code === 0 && res.data !== undefined) {
      this.items = res.data.list.length > 0 ? res.data.list : res.data.items
      return
    }
    this.items = []
  }

  build() {
    Column() {
      AppHeader({ title: '消息中心' })
      if (this.items.length === 0) {
        AppEmpty({ title: '暂无消息', description: '机构通知将显示在这里，可下拉返回后重新进入刷新。' })
      } else {
        List() {
          ForEach(this.items, (m: FamilyNotice) => {
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
          }, (m: FamilyNotice) => m.id.length > 0 ? m.id : m.title)
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
