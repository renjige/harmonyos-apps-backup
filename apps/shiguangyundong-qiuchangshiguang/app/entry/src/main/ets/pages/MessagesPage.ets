import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppCard } from '../components/design-system/AppCard'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppError } from '../components/design-system/AppError'
import { MessageItem, MessageListData } from '../models/ApiModels'
import { HttpClient } from '../services/HttpClient'

class NoticeItem {
  id: string = ''
  title: string = ''
  body: string = ''

  static fromWire(row: MessageItem): NoticeItem {
    const item = new NoticeItem()
    item.id = row.id
    item.title = row.title
    item.body = row.body
    return item
  }
}

@Component
export struct MessagesPage {
  @State items: NoticeItem[] = []
  @State loading: boolean = true
  @State loadFailed: boolean = false

  aboutToAppear(): void {
    void this.loadRemote()
  }

  private async loadRemote(): Promise<void> {
    this.loading = true
    this.loadFailed = false
    const res = await HttpClient.get<MessageListData>('/messages')
    if (res.code === 0 && res.data !== undefined) {
      const out: NoticeItem[] = []
      for (let row of res.data.list) {
        out.push(NoticeItem.fromWire(row))
      }
      this.items = out
      this.loading = false
      return
    }
    this.items = []
    this.loadFailed = true
    this.loading = false
  }

  build() {
    Column() {
      AppHeader({ title: '消息中心', subtitle: '预约提醒 · 活动通知' })
      if (this.loading) {
        Text('加载中…')
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textSecondary)
          .padding(Theme.space.pageX)
      } else if (this.loadFailed) {
        AppError({
          title: '消息加载失败',
          message: '请检查网络后重试',
          retryLabel: '重试',
          onRetry: (): void => {
            void this.loadRemote()
          }
        }).layoutWeight(1)
      } else if (this.items.length === 0) {
        AppEmpty({ title: '暂无消息', description: '预约与活动通知将显示在这里' })
      } else {
        List({ space: Theme.space.s3 }) {
          ForEach(this.items, (it: NoticeItem) => {
            ListItem() {
              AppCard({ title: it.title }) {
                Text(it.body)
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().textSecondary)
              }
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          }, (it: NoticeItem) => it.id)
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
