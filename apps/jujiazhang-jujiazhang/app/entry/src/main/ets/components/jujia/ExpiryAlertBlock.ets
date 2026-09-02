import { common } from '@kit.AbilityKit'
import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { HomeItem } from '../../models/JujiaModels'
import { ReminderService } from '../../services/ReminderService'

@Component
export struct ExpiryAlertBlock {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop items: HomeItem[] = []
  onOpenItems: () => void = () => {}
  onToast: (msg: string) => void = (_m: string) => {}

  private async ring(name: string): Promise<void> {
    const host = this.getUIContext().getHostContext() as common.UIAbilityContext
    const ok = await ReminderService.testRing(host, name)
    if (ok) {
      this.onToast(ReminderService.lastAction)
      return
    }
    this.onToast(ReminderService.lastError.length > 0 ? ReminderService.lastError : '提醒未开启')
  }

  build() {
    Column({ space: 8 }) {
      Row() {
        Text('到期提醒')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('试响通道')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
          .onClick(() => { void this.ring(this.items.length > 0 ? this.items[0].name : '') })
      }
      .width('100%')

      if (this.items.length === 0) {
        Column({ space: 6 }) {
          Text('暂无 30 天内到期物品')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text('登记保修/药品/证件并选择提醒时间后，系统会在到达时间推送通知。点「试响通道」可立即验证。')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')
        .padding(12)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().warningContainer : Theme.colors().warningContainer)
        .borderRadius(Theme.radius.lg)
        .onClick(() => this.onOpenItems())
      } else {
        ForEach(this.items, (row: HomeItem) => {
          Row({ space: 8 }) {
            AppIcon({ name: 'bell', iconSize: 18, color: Theme.colors().danger })
            Column({ space: 2 }) {
              Text(row.name)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text(row.expiryLabel())
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().danger)
                .width('100%')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            .onClick(() => this.onOpenItems())
            Text('试响')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandOnPrimary)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .backgroundColor(Theme.colors().brandPrimary)
              .borderRadius(Theme.radius.sm)
              .onClick(() => { void this.ring(row.name) })
          }
          .width('100%')
          .padding(12)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().dangerContainer : Theme.colors().dangerContainer)
          .borderRadius(Theme.radius.lg)
        }, (row: HomeItem) => row.id)
      }
    }
    .width('100%')
  }
}
