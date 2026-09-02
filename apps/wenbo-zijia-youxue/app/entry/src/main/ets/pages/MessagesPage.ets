import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { DetailShell } from '../components/detail/DetailShell'
import { MessageItem } from '../models/RoadModels'
import { RoadBizService } from '../services/RoadBizService'
import { RoadDetailNav } from '../services/RoadDetailNav'

@Component
export struct MessagesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State items: MessageItem[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.items = await RoadBizService.loadMessages()
    this.loading = false
  }

  build() {
    DetailShell({ title: '消息', contentKey: `${this.refreshToken}`, onClose: (): void => { RoadDetailNav.close() } }) {
      Column({ space: 12 }) {
        if (this.loading) {
          AppLoading({ label: '读取通知' })
        } else if (this.items.length === 0) {
          AppEmpty({
            title: '暂无机构通知',
            description: '出行前提醒会显示在这里',
            actionLabel: '重试',
            onAction: (): void => { void this.reload() }
          })
        } else {
          ForEach(this.items, (m: MessageItem) => {
            Column({ space: 6 }) {
              Text(m.title)
                .fontSize(Theme.type.subtitleM)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text(m.body)
                .fontSize(Theme.type.subhead)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }
            .width('100%')
            .padding(18)
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
          }, (m: MessageItem) => m.id)
        }
      }
      .width('100%')
    }
  }
}
