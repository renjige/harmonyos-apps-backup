import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppError } from '../components/design-system/AppError'
import { MsgItem } from '../models/PoetryModels'
import { PoetryBizService } from '../services/PoetryBizService'
import { PoetryNav } from '../services/PoetryNav'

@Component
export struct MessagesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: MsgItem[] = []
  @State failed: boolean = false
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  async reload(): Promise<void> {
    this.loading = true
    this.failed = false
    this.items = await PoetryBizService.loadMessages()
    this.loading = false
    this.failed = false
  }

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(15)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick(() => PoetryNav.close())
        Blank()
        Text('机构消息')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 8 })

      if (this.failed) {
        AppError({
          title: '消息暂不可用',
          message: '请检查网络后重试。',
          retryLabel: '重试',
          onRetry: () => { void this.reload() }
        })
      } else if (this.items.length === 0 && !this.loading) {
        AppEmpty({ title: '暂无消息', description: '机构通知将显示在这里' })
      } else {
        List({ space: 10 }) {
          ForEach(this.items, (m: MsgItem) => {
            ListItem() {
              Column({ space: 6 }) {
                Text(m.title)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(m.body)
                  .fontSize(14)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              }
              .padding(16)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(16)
              .width('100%')
            }
          }, (m: MsgItem) => m.id)
        }
        .layoutWeight(1)
        .padding({ left: 16, right: 16, bottom: 24 })
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
