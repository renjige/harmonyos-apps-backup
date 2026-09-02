import { common } from '@kit.AbilityKit'
import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { LegalDocs } from '../models/LegalDocs'
import { ExportService } from '../services/ExportService'
import { PrivacyService } from '../services/PrivacyService'

@Component
export struct SettingsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State toastText: string = ''
  @State showPrivacy: boolean = false
  @State showAgreement: boolean = false
  @State darkMode: boolean = false
  private uiContext: common.UIAbilityContext | null = null

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2800)
  }

  private async exportData(): Promise<void> {
    if (this.uiContext === null) {
      return
    }
    try {
      const path = await ExportService.exportToFile(this.uiContext)
      this.showToast(`已导出至应用目录：${path}`)
    } catch {
      this.showToast('导出失败，请稍后重试')
    }
  }

  private async handleRevoke(): Promise<void> {
    await PrivacyService.revoke()
    this.showToast('已撤回隐私同意，再次进入须重新同意')
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s2 }) {
          Text('设置')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .margin({ bottom: Theme.space.s2 })

          this.SettingRow('数据导出（纯文本）', (): void => { void this.exportData() })
          this.SettingRow('隐私政策', (): void => { this.showPrivacy = true })
          this.SettingRow('用户协议', (): void => { this.showAgreement = true })
          this.SettingRow('关于积累日记', (): void => {
            this.showToast('积累日记 v1.0 — 每日积累，见证成长')
          })
          this.SettingRow('撤回隐私同意', (): void => { void this.handleRevoke() })

          Row({ space: Theme.space.s3 }) {
            Text('深色模式')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
            Blank()
            Toggle({ type: ToggleType.Switch, isOn: this.darkMode })
              .selectedColor(Theme.colors().brandPrimary)
              .onChange((v: boolean) => {
                this.darkMode = v
                Theme.setColorMode(v ? 'dark' : 'light')
              })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
        }
        .width('100%')
        .padding(Theme.space.pageX)
        .padding({ bottom: Theme.space.s10 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '8%', y: 48 })
          .zIndex(20)
      }

      if (this.showPrivacy) {
        LegalDocOverlay({
          kind: 'privacy',
          onClose: (): void => { this.showPrivacy = false }
        })
      }
      if (this.showAgreement) {
        LegalDocOverlay({
          kind: 'agreement',
          onClose: (): void => { this.showAgreement = false }
        })
      }
    }
    .width('100%')
    .height('100%')
    .onAppear((): void => {
      const host = this.getUIContext().getHostContext()
      if (host !== undefined) {
        this.uiContext = host as common.UIAbilityContext
      }
      this.darkMode = Theme.isDark()
    })
  }

  @Builder
  SettingRow(label: string, onTap: () => void) {
    Row() {
      Text(label)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textPrimary)
      Blank()
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick(onTap)
  }
}
