import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppCard } from '../components/design-system/AppCard'
import { AppError } from '../components/design-system/AppError'
import { HttpClient } from '../services/HttpClient'

class MsgItem {
  id: string = ''
  title: string = ''
  body: string = ''
}

class MsgListData {
  list: MsgItem[] = []
}

@Component
export struct MessagesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: MsgItem[] = []
  @State failed: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  async reload(): Promise<void> {
    this.failed = false
    const res = await HttpClient.get<MsgListData>('/messages')
    if (res.code === 0 && res.data !== undefined) {
      this.items = res.data.list
      return
    }
    this.items = []
    this.failed = true
  }

  build() {
    Column() {
      AppHeader({ title: '消息中心' })
      if (this.failed && this.items.length === 0) {
        AppError({
          title: '暂时没有消息',
          message: '请检查网络后重试。',
          retryLabel: '重试',
          onRetry: () => { void this.reload() }
        })
      } else if (this.items.length === 0) {
        AppEmpty({ title: '暂无消息', description: '机构通知会显示在这里。' })
      } else {
        List() {
          ForEach(this.items, (m: MsgItem, idx: number) => {
            ListItem() {
              AppCard({ title: m.title }) {
                Text(m.body)
                  .fontSize(Theme.type.callout)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s3
            })
          }, (m: MsgItem, idx: number) => m.id.length > 0 ? m.id : `msg-${idx}`)
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
