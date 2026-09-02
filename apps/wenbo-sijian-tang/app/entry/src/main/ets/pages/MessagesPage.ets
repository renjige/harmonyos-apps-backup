import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppCard } from '../components/design-system/AppCard'
import { AppIcon } from '../components/design-system/AppIcon'
import { MsgWire } from '../models/WisdomHallModels'
import { WisdomHallBizService } from '../services/WisdomHallBizService'
import { WisdomHallNav } from '../services/WisdomHallNav'

@Component
export struct MessagesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('whRefresh') @Watch('onRefresh') whRefresh: number = 0
  @State items: MsgWire[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefresh(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.items = await WisdomHallBizService.loadMessages()
    this.loading = false
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { WisdomHallNav.closeMessages() })
        AppHeader({ title: '消息中心', subtitle: '机构通知' })
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 8, right: Theme.space.pageX })

      if (this.loading) {
        Text('加载中…')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .layoutWeight(1)
      } else if (this.items.length === 0) {
        AppEmpty({ title: '暂无消息', description: '机构通知将显示在这里' })
          .layoutWeight(1)
      } else {
        List() {
          ForEach(this.items, (m: MsgWire) => {
            ListItem() {
              AppCard({ title: m.title }) {
                Text(m.body.length > 0 ? m.body : m.summary)
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
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
