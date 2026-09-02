import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { MsgWire } from '../models/AtelierModels'
import { AtelierBizService } from '../services/AtelierBizService'
import { AtelierDetailNav } from '../services/AtelierDetailNav'

@Component
export struct MessagesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: MsgWire[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await AtelierBizService.loadMessages()
  }

  build() {
    Column() {
      AppHeader({ title: '消息中心' })
      if (this.items.length === 0) {
        AppEmpty({
          title: '暂无通知',
          description: '工坊广播会显示在这里。',
          actionLabel: '打开消息',
          onAction: (): void => { AtelierDetailNav.openMessages() }
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
