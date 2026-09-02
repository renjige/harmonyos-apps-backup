import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppCard } from '../components/design-system/AppCard'
import { MessageWire } from '../models/InkModels'
import { InkBizService } from '../services/InkBizService'

@Component
export struct MessagesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: MessageWire[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.items = await InkBizService.loadMessages()
    this.loading = false
  }

  build() {
    Column() {
      AppHeader({ title: '消息中心' })
      if (this.items.length === 0) {
        AppEmpty({
          title: '暂无消息',
          description: '机构通知将显示在这里。',
          actionLabel: '刷新',
          onAction: (): void => { void this.reload() }
        })
      } else {
        List() {
          ForEach(this.items, (m: MessageWire) => {
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
          }, (m: MessageWire) => m.id)
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
