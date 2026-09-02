import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppCard } from '../components/design-system/AppCard'
import { StudyBizService } from '../services/StudyBizService'
import { MsgWire } from '../models/StudyModels'

@Component
export struct MessagesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: MsgWire[] = []
  @State loading: boolean = false
  onClose: () => void = () => {}
  onOpenDetail: (title: string, body: string, time: string) => void = (_t: string, _b: string, _time: string) => {}

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.items = await StudyBizService.loadMessages()
    this.loading = false
  }

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .constraintSize({ minHeight: 44 })
          .onClick((): void => { this.onClose() })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      AppHeader({ title: '消息中心' })
      if (this.items.length === 0) {
        AppEmpty({
          title: '暂无消息',
          description: '机构通知将显示在这里',
          actionLabel: '重新加载',
          onAction: (): void => { void this.reload() }
        })
      } else {
        List() {
          ForEach(this.items, (m: MsgWire, idx: number) => {
            ListItem() {
              AppCard({ title: m.title.length > 0 ? m.title : '通知' }) {
                Text(m.body)
                  .fontSize(Theme.type.callout)
                  .fontColor(Theme.bodyMuted())
                  .maxLines(2)
              }
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s3
            })
            .onClick((): void => {
              this.onOpenDetail(m.title, m.body, m.createdAt)
            })
          }, (m: MsgWire, idx: number) => `msg-${idx}-${m.title}`)
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
