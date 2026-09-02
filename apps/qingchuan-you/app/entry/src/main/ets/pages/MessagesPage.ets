import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { DetailShell } from '../components/detail/DetailShell'
import { MessageItem } from '../models/ScenicModels'
import { ScenicBizService } from '../services/ScenicBizService'
import { ScenicDetailNav } from '../services/ScenicDetailNav'

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
    this.items = await ScenicBizService.loadMessages()
    this.loading = false
  }

  build() {
    DetailShell({ title: '通知', onClose: () => ScenicDetailNav.close() }) {
      Column({ space: 12 }) {
        if (this.loading) {
          AppLoading({ label: '读取通知' })
        } else if (this.items.length === 0) {
          AppEmpty({
            title: '暂无通知',
            description: '机构广播会出现在这里。新用户没有私人单据。',
            actionLabel: '重试',
            onAction: (): void => { void this.reload() }
          })
        } else {
          ForEach(this.items, (m: MessageItem) => {
            Column({ space: 6 }) {
              Text(m.title)
                .fontSize(Theme.type.subtitleS)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text(m.body)
                .fontSize(Theme.type.footnote)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }
            .width('100%')
            .padding(14)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
          }, (m: MessageItem) => m.id)
        }
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
  }
}
