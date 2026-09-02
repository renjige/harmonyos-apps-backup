import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppCard } from '../components/design-system/AppCard'
import { AppIcon } from '../components/design-system/AppIcon'
import { MsgItem } from '../models/KingdomModels'
import { KingdomBizService } from '../services/KingdomBizService'

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
    this.items = await KingdomBizService.loadMessages()
    this.loaded = true
  }

  build() {
    Column() {
      Row() {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(48)
        .height(48)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick(() => this.onBack())
        Text('王国通知')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      }
      .width('100%')
      .padding({ left: Theme.space.s2, right: Theme.space.pageX, top: Theme.space.s3 })

      if (this.loaded && this.items.length === 0) {
        AppEmpty({
          title: '暂无通知',
          description: '机构广播会出现在这里。新探索者没有个人假单据。',
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
