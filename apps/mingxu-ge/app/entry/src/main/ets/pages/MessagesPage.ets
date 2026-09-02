import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppCard } from '../components/design-system/AppCard'
import { XuBizService } from '../services/XuBizService'
import { XuMsgItem } from '../models/XuModels'

@Component
export struct MessagesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: XuMsgItem[] = []
  @State loaded: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await XuBizService.loadMessages()
    this.loaded = true
  }

  build() {
    Column() {
      if (!this.loaded || this.items.length === 0) {
        AppEmpty({
          title: '暂无消息',
          description: '机构通知会显示在这里。下拉或返回后重进可刷新。',
          actionLabel: '重试',
          onAction: (): void => { void this.reload() }
        })
      } else {
        List() {
          ForEach(this.items, (m: XuMsgItem) => {
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
          }, (m: XuMsgItem) => m.id)
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
