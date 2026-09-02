import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppCard } from '../components/design-system/AppCard'
import { HttpClient } from '../services/HttpClient'

class MsgWire {
  id: string = ''
  title: string = ''
  body: string = ''
  summary: string = ''
}

class MsgListData {
  list: MsgWire[] = []
}

class MsgItem {
  id: string = ''
  title: string = ''
  body: string = ''
}

@Component
export struct MessagesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: MsgItem[] = []
  @State loading: boolean = true
  onClose: () => void = () => {}

  aboutToAppear(): void {
    void this.loadMessages()
  }

  private async loadMessages(): Promise<void> {
    this.loading = true
    const res = await HttpClient.get<MsgListData>('/messages')
    const out: MsgItem[] = []
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      for (const w of res.data.list) {
        const m = new MsgItem()
        m.id = w.id
        m.title = w.title
        m.body = w.body.length > 0 ? w.body : w.summary
        out.push(m)
      }
    }
    this.items = out
    this.loading = false
  }

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick((): void => { this.onClose() })
        Blank()
        Text('机构通知')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 8 })
      if (this.loading) {
        Text('加载中…')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .padding(Theme.space.pageX)
      } else if (this.items.length === 0) {
        AppEmpty({ title: '暂无消息', description: '机构通知将显示在这里' })
      } else {
        List() {
          ForEach(this.items, (m: MsgItem) => {
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
          }, (m: MsgItem) => m.id)
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
