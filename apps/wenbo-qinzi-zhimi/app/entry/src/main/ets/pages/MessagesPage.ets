import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppCard } from '../components/design-system/AppCard'
import { AppError } from '../components/design-system/AppError'
import { AppLoading } from '../components/design-system/AppLoading'
import { MessageItem, MessageListData } from '../models/PuzzleModels'
import { HttpClient } from '../services/HttpClient'

@Component
export struct MessagesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: MessageItem[] = []
  @State loading: boolean = false
  @State loadFailed: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.loadFailed = false
    const res = await HttpClient.get<MessageListData>('/messages')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      this.items = res.data.list
      this.loadFailed = false
    } else {
      this.items = []
      this.loadFailed = res.code !== 0
    }
    this.loading = false
  }

  build() {
    Column() {
      AppHeader({ title: '消息中心' })
      if (this.loading && this.items.length === 0) {
        AppLoading({ label: '读取通知' }).layoutWeight(1)
      } else if (this.loadFailed) {
        AppError({
          message: '消息加载失败',
          retryLabel: '重试',
          onRetry: (): void => { void this.reload() }
        }).layoutWeight(1)
      } else if (this.items.length === 0) {
        AppEmpty({
          title: '暂无消息',
          description: '机构通知与活动提醒将显示在这里',
          iconName: 'message'
        }).layoutWeight(1)
      } else {
        List({ space: Theme.space.s3 }) {
          ForEach(this.items, (m: MessageItem) => {
            ListItem() {
              AppCard({ title: m.title }) {
                Text(m.body.length > 0 ? m.body : m.summary)
                  .fontSize(Theme.type.callout)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .lineHeight(22)
                  .width('100%')
              }
            }
          }, (m: MessageItem) => m.id)
        }
        .layoutWeight(1)
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s3,
          bottom: Theme.space.s10
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
