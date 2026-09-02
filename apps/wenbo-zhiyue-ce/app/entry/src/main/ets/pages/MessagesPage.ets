import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppCard } from '../components/design-system/AppCard'
import { AppIcon } from '../components/design-system/AppIcon'
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
    if (res.code === 0 && res.data !== undefined) {
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
      Row() {
        Row() {
          AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.onClose() })
        Text('消息中心')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      }
      .width('100%')
      .padding({ left: 8, right: 16, top: 8, bottom: 8 })
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
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
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
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
