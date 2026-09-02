import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppCard } from '../components/design-system/AppCard'
import { MsgWire } from '../models/HandcraftModels'
import { HandcraftBizService } from '../services/HandcraftBizService'

@Component
export struct MessagesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: MsgWire[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.items = await HandcraftBizService.loadMessages()
    this.loading = false
  }

  build() {
    Column() {
      AppHeader({ title: '消息中心', subtitle: '创作提醒与教程更新' })
      if (this.loading) {
        AppLoading({ label: '加载消息…' }).layoutWeight(1)
      } else if (this.items.length === 0) {
        AppEmpty({
          title: '暂无消息',
          description: '机构活动提醒、教程更新通知将显示在这里'
        })
          .layoutWeight(1)
      } else {
        List() {
          ForEach(this.items, (m: MsgWire) => {
            ListItem() {
              AppCard({ title: m.title }) {
                Text(m.body)
                  .fontSize(Theme.type.callout)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
                  .lineHeight(22)
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
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
