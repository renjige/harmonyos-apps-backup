import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppListRow } from '../components/design-system/AppListRow'
import { AppIcon } from '../components/design-system/AppIcon'
import { LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { UserProfile } from '../models/ZizaiModels'
import { ZizaiStore } from '../services/ZizaiStore'
import { PrivacyService } from '../services/PrivacyService'

@Component
export struct ZizaiMinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  onPrivacyRevoked: () => void = () => {}
  onDataCleared: () => void = () => {}
  @State profile: UserProfile = new UserProfile()
  @State nicknameInput: string = ''
  @State showSettings: boolean = false
  @State showPrivacyDoc: boolean = false
  @State showAgreementDoc: boolean = false
  @State toastText: string = ''
  @State confirmClear: boolean = false
  @State confirmRevoke: boolean = false
  @State themeMode: string = 'system'

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.profile = await ZizaiStore.loadProfile()
    this.nicknameInput = this.profile.nickname
    const mode = AppStorage.get<string>('colorMode')
    this.themeMode = mode !== undefined ? `${mode}` : 'system'
    Theme.setForcedDark(this.profile.darkMode)
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2600)
  }

  private async saveNickname(): Promise<void> {
    this.profile.nickname = this.nicknameInput.trim().length > 0 ? this.nicknameInput.trim() : '生活旅人'
    await ZizaiStore.saveProfile(this.profile)
    this.showToast('昵称已保存')
  }

  private setTheme(mode: string): void {
    this.themeMode = mode
    Theme.setColorMode(mode as 'light' | 'dark' | 'system')
    AppStorage.setOrCreate('colorMode', mode)
    this.showToast('主题已切换')
  }

  private async clearCache(): Promise<void> {
    await ZizaiStore.clearAllData()
    this.confirmClear = false
    this.showSettings = false
    this.onDataCleared()
    this.showToast('本地记录已清除')
  }

  private async handleRevokePrivacy(): Promise<void> {
    await PrivacyService.revoke()
    this.confirmRevoke = false
    this.showSettings = false
    this.onPrivacyRevoked()
    this.showToast('已撤回隐私同意，再次进入须重新勾选协议')
  }

  @Builder
  ThemeChip(label: string, mode: string) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.themeMode === mode ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor(this.themeMode === mode ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => this.setTheme(mode))
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('我的')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')

          Row({ space: Theme.space.s4 }) {
            Column() {
              AppIcon({ name: 'user', iconSize: Theme.icon.lg, color: Theme.colors().brandPrimary })
            }
            .width(56)
            .height(56)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
            Column({ space: Theme.space.s2 }) {
              Text(this.profile.nickname)
                .fontSize(Theme.type.title3)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Text('本机数据 · 无需登录')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          AppListRow({
            title: '设置与隐私',
            subtitle: '协议 · 主题 · 清除缓存',
            onTap: (): void => { this.showSettings = true }
          })

          AppListRow({
            title: '关于自在生活',
            subtitle: '版本 1.0.0 · 智慧生活助理',
            onTap: (): void => { this.showToast('自在生活 v1.0.0 — 找回生活的节奏感') }
          })

          AppListRow({
            title: '意见反馈',
            subtitle: '通过华为应用市场留言',
            onTap: (): void => { this.showToast('请在应用市场详情页提交反馈') }
          })
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.pageY,
          bottom: this.bottomInset + Theme.space.s6
        })
      }

      if (this.showSettings) {
        this.SettingsPanel()
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().surfaceInverse)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 48 })
          .zIndex(40)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  SettingsPanel() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)
        .onClick((): void => { this.showSettings = false })

      Column({ space: Theme.space.s4 }) {
        Text('设置与隐私')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')

        TextInput({ text: this.nicknameInput, placeholder: '昵称' })
          .onChange((v: string): void => { this.nicknameInput = v })
        AppButton({
          label: '保存昵称',
          variant: 'secondary',
          onTap: (): void => { void this.saveNickname() }
        })

        Text('外观模式')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Row({ space: Theme.space.s2 }) {
          this.ThemeChip('跟随系统', 'system')
          this.ThemeChip('浅色', 'light')
          this.ThemeChip('深色', 'dark')
        }

        AppListRow({
          title: '用户协议',
          onTap: (): void => { this.showAgreementDoc = true }
        })
        AppListRow({
          title: '隐私政策',
          onTap: (): void => { this.showPrivacyDoc = true }
        })

        Row() {
          AppButton({
            label: '清除本地记录',
            variant: 'secondary',
            onTap: (): void => { this.confirmClear = true }
          })
        }
        .width('100%')
        .onClick((): void => { this.confirmClear = true })

        Row() {
          AppButton({
            label: '撤回隐私同意',
            variant: 'secondary',
            onTap: (): void => { void this.handleRevokePrivacy() }
          })
        }
        .width('100%')
        .onClick((): void => { void this.handleRevokePrivacy() })

        AppButton({
          label: '关闭',
          variant: 'primary',
          onTap: (): void => { this.showSettings = false }
        })
      }
      .width('90%')
      .padding(Theme.space.s5)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)

      if (this.showPrivacyDoc) {
        LegalDocOverlay({ kind: 'privacy', onClose: (): void => { this.showPrivacyDoc = false } })
      }
      if (this.showAgreementDoc) {
        LegalDocOverlay({ kind: 'agreement', onClose: (): void => { this.showAgreementDoc = false } })
      }

      if (this.confirmClear) {
        Column({ space: Theme.space.s4 }) {
          Text('确认清除全部本地记录？此操作不可恢复。')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Row({ space: Theme.space.s3 }) {
            AppButton({ label: '取消', variant: 'secondary', onTap: (): void => { this.confirmClear = false } })
            AppButton({ label: '确认清除', variant: 'primary', onTap: (): void => { void this.clearCache() } })
          }
        }
        .width('80%')
        .padding(Theme.space.s5)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(30)
  }
}
