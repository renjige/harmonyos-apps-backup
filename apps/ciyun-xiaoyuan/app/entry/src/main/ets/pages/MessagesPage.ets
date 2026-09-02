import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppCard } from '../components/design-system/AppCard'
import { CourtyardBizService } from '../services/CourtyardBizService'
import { MessageWire } from '../models/CourtyardModels'

@Component
export struct MessagesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: MessageWire[] = []

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.items = await CourtyardBizService.loadMessages()
  }

  build() {
    Column() {
      AppHeader({ title: '院中消息' })
      if (this.items.length === 0) {
        AppEmpty({ title: '暂无消息', description: '机构通知将显示在这里', actionLabel: '重试', onAction: (): void => { void this.load() } })
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
