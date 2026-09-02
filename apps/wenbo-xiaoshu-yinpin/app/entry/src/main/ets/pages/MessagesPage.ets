import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { DetailShell } from '../components/detail/DetailShell'
import { MessageItem } from '../models/DrinkModels'
import { DrinkBizService } from '../services/DrinkBizService'
import { DrinkDetailNav } from '../services/DrinkDetailNav'

@Component
export struct MessagesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State items: MessageItem[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.items = await DrinkBizService.loadMessages()
    this.loading = false
  }

  build() {
    DetailShell({
      title: '消息',
      contentKey: `${this.items.length}`,
      onClose: () => DrinkDetailNav.close()
    }) {
      Column({ space: Theme.space.s3 }) {
        if (this.loading) {
          AppLoading({ label: '正在打开消息' })
        } else if (this.items.length === 0) {
          AppEmpty({ title: '暂无消息', description: '机构通知会显示在这里' })
        } else {
          ForEach(this.items, (m: MessageItem) => {
            Column({ space: 6 }) {
              Text(m.title)
                .fontSize(Theme.type.subtitleS)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text(m.body)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
              Text(m.createdAt)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }, (m: MessageItem) => m.id)
        }
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
  }
}
