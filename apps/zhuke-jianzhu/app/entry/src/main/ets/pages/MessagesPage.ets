import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppCard } from '../components/design-system/AppCard'

class MsgItem {
  title: string = ''
  body: string = ''

  static seed(): MsgItem[] {
    const a = new MsgItem()
    a.title = '合同审批提醒'
    a.body = 'Q3 服务续约待您审批。'
    const b = new MsgItem()
    b.title = 'AI 周报已生成'
    b.body = '本月经营概况可在 AI 助手查看。'
    return [a, b]
  }
}

@Component
export struct MessagesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: MsgItem[] = MsgItem.seed()

  build() {
    Column() {
      AppHeader({ title: '消息中心' })
      if (this.items.length === 0) {
        AppEmpty({ title: '暂无消息', description: '业务通知将显示在这里' })
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
