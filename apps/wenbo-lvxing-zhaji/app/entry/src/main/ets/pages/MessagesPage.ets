import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppCard } from '../components/design-system/AppCard'
import { HttpClient } from '../services/HttpClient'

class MsgItem {
  title: string = ''
  body: string = ''
}

class MessageWire {
  id: string = ''
  title: string = ''
  body: string = ''
}

class MessageListPayload {
  list: MessageWire[] = []
}

@Component
export struct MessagesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: MsgItem[] = []
  onClose: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const res = await HttpClient.get<MessageListPayload>('/messages')
    const next: MsgItem[] = []
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      for (const w of res.data.list) {
        const m = new MsgItem()
        m.title = w.title
        m.body = w.body
        next.push(m)
      }
    }
    this.items = next
  }

  build() {
    Column() {
      AppHeader({ title: '消息中心' })
      if (this.items.length === 0) {
        AppEmpty({
          title: '暂无消息',
          description: '机构通知会显示在这里，新账号默认为空'
        })
          .layoutWeight(1)
      } else {
        List() {
          ForEach(this.items, (m: MsgItem, idx: number) => {
            ListItem() {
              AppCard({ title: m.title }) {
                Text(m.body)
                  .fontSize(Theme.type.callout)
                  .fontColor(Theme.colors().textSecondary)
              }
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s3
            })
          }, (m: MsgItem, idx: number) => `msg-${idx}`)
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
