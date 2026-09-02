import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { DetailShell } from '../components/detail/DetailShell'
import { MessageItem } from '../models/MxModels'
import { MxBizService } from '../services/MxBizService'
import { MxDetailNav } from '../services/MxDetailNav'

@Component
export struct MessagesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State items: MessageItem[] = []
  @State loading: boolean = true
  @State expandedId: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.items = await MxBizService.loadMessages()
    this.loading = false
  }

  private toggle(id: string): void {
    if (this.expandedId === id) {
      this.expandedId = ''
      return
    }
    this.expandedId = id
  }

  build() {
    DetailShell({ title: '消息中心', onClose: () => MxDetailNav.close() }) {
      Column({ space: 12 }) {
        if (this.loading) {
          AppLoading({ label: '读取通知' })
        } else if (this.items.length === 0) {
          AppEmpty({
            title: '暂无通知',
            description: '机构广播会出现在这里。不会预填他人的私有单据。',
            actionLabel: '重新加载',
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
              if (this.expandedId === m.id) {
                Text(m.body)
                  .fontSize(Theme.type.footnote)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              } else {
                Text('点开展开正文')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  .width('100%')
              }
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick(() => this.toggle(m.id))
          }, (m: MessageItem) => m.id)
        }
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
  }
}
