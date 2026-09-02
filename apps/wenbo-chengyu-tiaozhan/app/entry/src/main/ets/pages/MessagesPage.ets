import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppCard } from '../components/design-system/AppCard'
import { MsgItem } from '../models/IdiomModels'
import { IdiomBizService } from '../services/IdiomBizService'

@Component
export struct MessagesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: MsgItem[] = []
  @State loaded: boolean = false
  onBack: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  async reload(): Promise<void> {
    this.items = await IdiomBizService.loadMessages()
    this.loaded = true
  }

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(15)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick(() => this.onBack())
        Blank()
        Text('机构通知')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
      }
      .width('100%')
      .padding({ left: 20, right: 16, top: 12, bottom: 8 })

      if (this.loaded && this.items.length === 0) {
        AppEmpty({
          title: '暂无通知',
          description: '机构广播会出现在这里。新账号没有个人假单据。',
          actionLabel: '刷新',
          onAction: () => { void this.reload() }
        })
      } else {
        List() {
          ForEach(this.items, (m: MsgItem) => {
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
          }, (m: MsgItem) => m.id)
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
