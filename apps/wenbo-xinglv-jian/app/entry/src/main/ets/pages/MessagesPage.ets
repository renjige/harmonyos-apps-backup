import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
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

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.loading = true
    const res = await HttpClient.get<MsgListData>('/messages')
    const out: MsgItem[] = []
    if (res.code === 0 && res.data !== undefined) {
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
      AppHeader({ title: '消息中心' })
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
