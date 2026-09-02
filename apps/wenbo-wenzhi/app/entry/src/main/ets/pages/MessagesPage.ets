import { Theme } from '../components/design-system/Theme'
import { AppNavBar } from '../components/design-system/AppNavBar'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppCard } from '../components/design-system/AppCard'
import { MsgWire } from '../models/AskModels'
import { AskBizService } from '../services/AskBizService'
import { AskNav } from '../services/AskNav'

@Component
export struct MessagesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: MsgWire[] = []
  @State loaded: boolean = false

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.items = await AskBizService.loadMessages()
    this.loaded = true
  }

  build() {
    Column() {
      AppNavBar({ title: '消息中心', onBack: (): void => { AskNav.closeMessages() } })
      if (this.loaded && this.items.length === 0) {
        AppEmpty({
          title: '暂无消息',
          description: '机构通知将显示在这里',
          actionLabel: '重试',
          onAction: (): void => { void this.load() }
        })
      } else {
        List() {
          ForEach(this.items, (m: MsgWire) => {
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
          }, (m: MsgWire) => m.id)
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
