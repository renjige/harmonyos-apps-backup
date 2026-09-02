import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { TeaNav } from '../services/TeaNav'
import { PrivacyService } from '../services/PrivacyService'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { pasteboard } from '@kit.BasicServicesKit'
import { TeaStore } from '../services/TeaStore'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State showSettings: boolean = false
  @State showPrivacyDoc: boolean = false
  @State showAgreementDoc: boolean = false
  @State confirmRevoke: boolean = false
  @State toastText: string = ''
  @State themeMode: string = 'system'
  onPrivacyRevoked: () => void = () => {}

  aboutToAppear(): void {
    this.themeMode = TeaStore.settings().themeMode
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2800)
  }

  private async handleRevokePrivacy(): Promise<void> {
    await PrivacyService.revoke()
    this.showSettings = false
    this.confirmRevoke = false
    this.showToast('已撤回隐私同意，再次使用须重新勾选协议')
    this.onPrivacyRevoked()
  }

  private async exportJson(): Promise<void> {
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, TeaStore.exportJson())
      const board = pasteboard.getSystemPasteboard()
      await board.setData(data)
      this.showToast('JSON 已复制到剪贴板')
    } catch {
      this.showToast('复制失败')
    }
  }

  @Builder
  menuRow(title: string, sub: string, onTap: () => void) {
    Row() {
      Column({ space: 2 }) {
        Text(title).fontSize(Theme.type.subtitleS).fontColor(Theme.colors().textPrimary)
        Text(sub).fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick(onTap)
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          Text('我的')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
            .padding({ top: Theme.space.s4 })
          Text('茶单、主题与整理都在这里。')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          this.menuRow('我的茶单', '日常 / 珍品 / 分享', (): void => { TeaNav.openSheet('listSheetOpen') })
          this.menuRow('茶主题册', '春茶、旅行、家庭茶记', (): void => { TeaNav.openSheet('albumSheetOpen') })
          this.menuRow('茶计划', '年度品茶目标', (): void => { TeaNav.openSheet('planSheetOpen') })
          this.menuRow('智慧整理', '补分类、补标签、补档案', (): void => { TeaNav.openSheet('organizeOpen') })
          this.menuRow('导出备份', '复制 JSON 到剪贴板', (): void => { void this.exportJson() })
          this.menuRow('设置与隐私', '协议 · 撤回 · 外观', (): void => { this.showSettings = true })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 96 })
      }
      .width('100%')
      .height('100%')
      .align(Alignment.Top)
      .scrollBar(BarState.Off)

      if (this.showSettings) {
        Column({ space: Theme.space.s3 }) {
          Text('设置与隐私')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          AppButton({ label: '查看《用户协议》', variant: 'secondary', onTap: (): void => { this.showAgreementDoc = true } })
          AppButton({ label: '查看《隐私政策》', variant: 'secondary', onTap: (): void => { this.showPrivacyDoc = true } })
          AppButton({
            label: this.themeMode === 'dark' ? '切换浅色模式' : '切换深色模式',
            variant: 'secondary',
            onTap: (): void => {
              const next = this.themeMode === 'dark' ? 'light' : 'dark'
              this.themeMode = next
              ThemeAppearance.apply(next)
              const s = TeaStore.settings()
              s.themeMode = next
              void TeaStore.saveSettings(s)
            }
          })
          if (!this.confirmRevoke) {
            AppButton({
              label: '撤回隐私同意',
              variant: 'secondary',
              onTap: (): void => { this.confirmRevoke = true }
            })
          } else {
            Row() {
              AppButton({
                label: '确认撤回隐私同意',
                variant: 'danger',
                onTap: (): void => { void this.handleRevokePrivacy() }
              })
            }
            .width('100%')
            .onClick((): void => { void this.handleRevokePrivacy() })
          }
          AppButton({ label: '关闭', variant: 'ghost', onTap: (): void => { this.showSettings = false } })
        }
        .width('100%')
        .height('100%')
        .padding(Theme.space.pageX)
        .backgroundColor(Theme.colors().surfacePage)
      }

      if (this.showPrivacyDoc) {
        LegalDocOverlay({ kind: 'privacy', onClose: (): void => { this.showPrivacyDoc = false } })
      }
      if (this.showAgreementDoc) {
        LegalDocOverlay({ kind: 'agreement', onClose: (): void => { this.showAgreementDoc = false } })
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 48 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
