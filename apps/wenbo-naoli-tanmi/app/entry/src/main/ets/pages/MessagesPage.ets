import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppError } from '../components/design-system/AppError'
import { DetailShell } from '../components/detail/DetailShell'
import { BrainNav } from '../services/BrainNav'
import { BrainBizService } from '../services/BrainBizService'
import { MsgItem } from '../models/BrainModels'

@Component
export struct MessagesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: MsgItem[] = []
  @State err: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.err = ''
    const list = await BrainBizService.loadMessages()
    this.items = list
    if (list.length === 0) {
      this.err = BrainBizService.lastHint()
    }
  }

  build() {
    Column() {
      DetailShell({ title: '机构通知', onBack: () => BrainNav.close() })
      if (this.items.length === 0) {
        if (this.err.length > 0) {
          AppError({ retryLabel: '重试', onRetry: () => { void this.reload() } })
        } else {
          AppEmpty({ title: '暂无通知', description: '机构广播会显示在这里' })
        }
      } else {
        List() {
          ForEach(this.items, (m: MsgItem) => {
            ListItem() {
              Column({ space: 6 }) {
                Text(m.title)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(m.body)
                  .fontSize(14)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding(14)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(14)
            }
            .padding({ left: 16, right: 16, bottom: 10 })
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
