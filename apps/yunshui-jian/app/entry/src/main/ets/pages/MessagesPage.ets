import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppCard } from '../components/design-system/AppCard'

class MsgItem {
  title: string = ''
  body: string = ''
}

@Component
export struct MessagesPage {
  /** 禁止 MsgItem.seed() 预填；新用户首次进入须为空态 */
  @State items: MsgItem[] = []

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
