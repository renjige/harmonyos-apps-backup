import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppListRow } from '../components/design-system/AppListRow'
import { LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { AppLockOverlay } from '../components/security/AppLockOverlay'
import { AppLockService } from '../services/AppLockService'
import { DiaryStore } from '../services/DiaryStore'
import { PrivacyService } from '../services/PrivacyService'
import { SettingsService } from '../services/SettingsService'

@Component
export struct SettingsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State themeMode: string = 'system'
  @State fontScale: string = 'medium'
  @State lockEnabled: boolean = false
  @State showPrivacyDoc: boolean = false
  @State showAgreementDoc: boolean = false
  @State showLockSetup: boolean = false
  @State toastText: string = ''
  @State exportPreview: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const s = await SettingsService.load()
    this.themeMode = s.themeMode
    this.fontScale = s.fontScale
    this.lockEnabled = await AppLockService.isEnabled()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2600)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('设置')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
            .padding({ top: Theme.space.pageY })

          Text('隐私安全')
            .fontSize(Theme.type.overline)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')

          AppListRow({
            title: '应用锁',
            subtitle: this.lockEnabled ? '已开启数字密码' : '未开启',
            onTap: (): void => {
              if (this.lockEnabled) {
                void this.disableLock()
              } else {
                this.showLockSetup = true
              }
            }
          })

          Text('个性化')
            .fontSize(Theme.type.overline)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
            .margin({ top: Theme.space.s3 })

          Row({ space: Theme.space.s2 }) {
            this.ThemeChip('跟随系统', 'system')
            this.ThemeChip('浅色', 'light')
            this.ThemeChip('深色', 'dark')
          }

          Row({ space: Theme.space.s2 }) {
            this.FontChip('小', 'small')
            this.FontChip('中', 'medium')
            this.FontChip('大', 'large')
          }

          Text('数据管理')
            .fontSize(Theme.type.overline)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
            .margin({ top: Theme.space.s3 })

          AppButton({
            label: '导出全部日记（TXT）',
            variant: 'secondary',
            onTap: () => { void this.exportTxt() }
          })

          AppButton({
            label: '清除本地缓存',
            variant: 'ghost',
            onTap: () => this.showToast('已清除界面缓存（日记数据保留）')
          })

          Text('关于')
            .fontSize(Theme.type.overline)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
            .margin({ top: Theme.space.s3 })

          AppListRow({
            title: '隐私政策',
            onTap: (): void => { this.showPrivacyDoc = true }
          })
          AppListRow({
            title: '用户协议',
            onTap: (): void => { this.showAgreementDoc = true }
          })
          AppListRow({
            title: '撤回隐私同意',
            subtitle: '撤回后须重新同意方可继续使用',
            onTap: (): void => { void this.handleRevoke() }
          })

          Text('版本 1.0.0 · 运营者：承德锐泓科技有限公司')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
            .textAlign(TextAlign.Center)
            .margin({ top: Theme.space.s6, bottom: Theme.space.s10 })

          if (this.exportPreview.length > 0) {
            Text(this.exportPreview)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
              .maxLines(6)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .padding(Theme.space.s3)
              .borderRadius(Theme.radius.md)
          }
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: this.bottomInset })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().surfaceInverse)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 48 })
          .zIndex(20)
      }

      if (this.showPrivacyDoc) {
        LegalDocOverlay({ kind: 'privacy', onClose: () => { this.showPrivacyDoc = false } })
      }
      if (this.showAgreementDoc) {
        LegalDocOverlay({ kind: 'agreement', onClose: () => { this.showAgreementDoc = false } })
      }
      if (this.showLockSetup) {
        AppLockOverlay({
          settingMode: true,
          onUnlocked: () => {
            this.showLockSetup = false
            this.lockEnabled = true
            this.showToast('应用锁已开启')
          },
          onCancel: () => { this.showLockSetup = false }
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  ThemeChip(label: string, mode: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.themeMode === mode ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.themeMode === mode ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick(() => {
        this.themeMode = mode
        void SettingsService.saveTheme(mode)
      })
  }

  @Builder
  FontChip(label: string, scale: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.fontScale === scale ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.fontScale === scale ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick(() => {
        this.fontScale = scale
        void SettingsService.saveFontScale(scale)
      })
  }

  private async exportTxt(): Promise<void> {
    const text = await DiaryStore.exportAllText()
    this.exportPreview = text.length > 200 ? `${text.substring(0, 200)}…` : text
    this.showToast('导出内容已生成，可在 DevEco 联调时对接系统分享保存')
  }

  private async disableLock(): Promise<void> {
    await AppLockService.clearLock()
    this.lockEnabled = false
    this.showToast('应用锁已关闭')
  }

  private async handleRevoke(): Promise<void> {
    await PrivacyService.revoke()
    this.showToast('已撤回隐私同意，请重启应用并重新同意')
  }
}
