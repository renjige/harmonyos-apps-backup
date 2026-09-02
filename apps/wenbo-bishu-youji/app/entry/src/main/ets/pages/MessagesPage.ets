import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { DetailShell } from '../components/detail/DetailShell'
import { MessageItem } from '../models/EscapeModels'
import { EscapeBizService } from '../services/EscapeBizService'
import { EscapeDetailNav } from '../services/EscapeDetailNav'

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
    this.items = await EscapeBizService.loadMessages()
    this.loading = false
  }

  build() {
    DetailShell({ title: '通知', onClose: () => EscapeDetailNav.close() }) {
      Column({ space: 12 }) {
        if (this.loading) {
          AppLoading({ label: '查看机构通知' })
        } else if (this.items.length === 0) {
          AppEmpty({
            title: '暂时没有通知',
            description: '机构广播会出现在这里。新账号默认是空的。',
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
              if (m.createdAt.length > 0) {
                Text(m.createdAt)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              }
            }
            .width('100%')
            .padding(18)
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
