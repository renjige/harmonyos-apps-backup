import { Theme } from '../components/design-system/Theme'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { common } from '@kit.AbilityKit'
import { AppButton } from '../components/design-system/AppButton'
import { AppListRow } from '../components/design-system/AppListRow'
import { AppIcon } from '../components/design-system/AppIcon'
import { LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { UserProfile } from '../models/ObservationModels'
import { ObservationStore } from '../services/ObservationStore'
import { PrivacyService } from '../services/PrivacyService'
import { pasteboard } from '@kit.BasicServicesKit'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  onPrivacyRevoked: () => void = () => {}
  @State profile: UserProfile = new UserProfile()
  @State nicknameInput: string = ''
  @State themeMode: string = 'system'
  @State showPrivacyDoc: boolean = false
  @State showAgreementDoc: boolean = false
  @State showSettings: boolean = false
  @State toastText: string = ''
  @State confirmRevoke: boolean = false
  @State confirmClear: boolean = false
  @State aboutOpen: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.profile = await ObservationStore.loadProfile()
    this.nicknameInput = this.profile.nickname
    const mode = this.profile.themeMode.length > 0 ? this.profile.themeMode : 'system'
    this.themeMode = mode
    ThemeAppearance.apply(mode as 'light' | 'dark' | 'system', this.getUIContext().getHostContext() as common.UIAbilityContext)
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2600)
  }

  private async saveNickname(): Promise<void> {
    this.profile.nickname = this.nicknameInput.trim().length > 0 ? this.nicknameInput.trim() : '观察者'
    await ObservationStore.saveProfile(this.profile)
    this.showToast('昵称已保存')
  }

  private async persistTheme(mode: string): Promise<void> {
    this.themeMode = mode
    this.profile.themeMode = mode
    ThemeAppearance.apply(mode as 'light' | 'dark' | 'system', this.getUIContext().getHostContext() as common.UIAbilityContext)
    AppStorage.setOrCreate('colorMode', mode)
    await ObservationStore.saveProfile(this.profile)
    this.showToast('主题已切换')
  }

  private async copyText(text: string, ok: string): Promise<void> {
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      const board = pasteboard.getSystemPasteboard()
      await board.setData(data)
      this.showToast(ok)
    } catch {
      this.showToast('复制失败')
    }
  }

  private async exportJson(): Promise<void> {
    const json = await ObservationStore.exportJson()
    await this.copyText(json, 'JSON 已复制到剪贴板')
  }

  private async exportCsv(): Promise<void> {
    const csv = await ObservationStore.exportCsv()
    await this.copyText(csv, 'CSV 已复制到剪贴板')
  }

  private async handleRevokePrivacy(): Promise<void> {
    await PrivacyService.revoke()
    this.confirmRevoke = false
    this.showSettings = false
    AppStorage.setOrCreate('tabBarHidden', false)
    this.onPrivacyRevoked()
    this.showToast('已撤回隐私同意，再次进入须重新勾选协议')
  }

  private async clearAll(): Promise<void> {
    await ObservationStore.clearAll()
    this.confirmClear = false
    this.showToast('全部观察记录已清除')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('我的')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
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
              TextInput({ text: this.nicknameInput, placeholder: '昵称' })
                .onChange((v: string): void => { this.nicknameInput = v })
              AppButton({ label: '保存昵称', variant: 'secondary', onTap: (): void => { void this.saveNickname() } })
            }
            .layoutWeight(1)
          }
          .width('100%')

          Column() {
            AppListRow({ title: '导出 JSON', subtitle: '复制到剪贴板后可粘贴保存', onTap: (): void => { void this.exportJson() } })
            AppListRow({ title: '导出 CSV', subtitle: '适合用表格软件打开', onTap: (): void => { void this.exportCsv() } })
            AppListRow({ title: '关于应用', subtitle: '昆虫观察簿 1.0.0', onTap: (): void => { this.aboutOpen = true } })
            AppListRow({
              title: '设置与隐私',
              subtitle: '协议 · 撤回 · 主题',
              showDivider: false,
              onTap: (): void => {
                this.showSettings = true
                AppStorage.setOrCreate('tabBarHidden', true)
              }
            })
          }
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.pageY,
          bottom: this.bottomInset + Theme.space.s6
        })
      }
      .scrollBar(BarState.Off)

      if (this.showSettings) {
        this.SettingsPanel()
      }
      if (this.aboutOpen) {
        this.AboutPanel()
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
          .fontColor(Theme.colors().brandOnPrimary)
          .padding(12)
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 48 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  SettingsPanel() {
    Column() {
      Row() {
        Text('设置与隐私')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('关闭')
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => {
            this.showSettings = false
            AppStorage.setOrCreate('tabBarHidden', false)
          })
      }
      .width('100%')
      .padding(Theme.space.pageX)

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('主题')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          Row({ space: 8 }) {
            this.ThemeChip('浅色', 'light')
            this.ThemeChip('深色', 'dark')
            this.ThemeChip('跟随系统', 'system')
          }
          AppListRow({ title: '用户协议', onTap: (): void => { this.showAgreementDoc = true } })
          AppListRow({ title: '隐私政策', onTap: (): void => { this.showPrivacyDoc = true } })
          AppButton({
            label: '清除缓存',
            variant: 'secondary',
            onTap: (): void => this.showToast('界面缓存已清理（观察记录未删除）')
          })
          AppButton({
            label: '清除全部观察记录',
            variant: 'secondary',
            onTap: (): void => { this.confirmClear = true }
          })
          Row() {
            AppButton({
              label: '撤回隐私同意',
              variant: 'secondary',
              onTap: (): void => { this.confirmRevoke = true }
            })
          }
          .width('100%')
          .onClick((): void => { this.confirmRevoke = true })

          if (this.confirmClear) {
            Text('将删除本机全部观察记录，不可恢复。')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().danger)
            AppButton({ label: '确认清除记录', variant: 'danger', onTap: (): void => { void this.clearAll() } })
            AppButton({ label: '取消', variant: 'ghost', onTap: (): void => { this.confirmClear = false } })
          }
          if (this.confirmRevoke) {
            Text('撤回后将返回协议页，再次使用须重新勾选。')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
            AppButton({
              label: '确认撤回',
              variant: 'danger',
              onTap: (): void => { void this.handleRevokePrivacy() }
            })
            AppButton({ label: '取消', variant: 'ghost', onTap: (): void => { this.confirmRevoke = false } })
          }
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  ThemeChip(label: string, mode: string) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.themeMode === mode ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.themeMode === mode ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { void this.persistTheme(mode) })
  }

  @Builder
  AboutPanel() {
    Column({ space: Theme.space.s4 }) {
      Text('昆虫观察簿')
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().textPrimary)
      Text('版本 1.0.0\n林涧博物 · 运营者薛茂新\n本地观察记录，无账号、无识别、无社交。知识卡片为科普参考。')
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textSecondary)
        .lineHeight(22)
      AppButton({ label: '关闭', onTap: (): void => { this.aboutOpen = false } })
    }
    .width('88%')
    .padding(Theme.space.s6)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .margin({ top: 120 })
  }
}
