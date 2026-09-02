import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppListRow } from '../components/design-system/AppListRow'
import { AppIcon } from '../components/design-system/AppIcon'
import { LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { UserProfile } from '../models/InsightModels'
import { InsightStore } from '../services/InsightStore'
import { PrivacyService } from '../services/PrivacyService'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { AppContextService } from '../services/AppContextService'
import { pasteboard } from '@kit.BasicServicesKit'

@Component
export struct SettingsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onClose: () => void = () => {}
  onPrivacyRevoked: () => void = () => {}
  @State profile: UserProfile = new UserProfile()
  @State nicknameInput: string = ''
  @State themeMode: string = 'system'
  @State showPrivacyDoc: boolean = false
  @State showAgreementDoc: boolean = false
  @State toastText: string = ''
  @State confirmRevoke: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.profile = await InsightStore.loadProfile()
    this.nicknameInput = this.profile.nickname
    const mode = this.profile.themeMode.length > 0 ? this.profile.themeMode : 'system'
    this.themeMode = mode
    const ctx = AppContextService.getContext()
    if (ctx !== null) {
      ThemeAppearance.apply(mode, ctx)
    } else {
      ThemeAppearance.apply(mode)
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2600)
  }

  private async saveNickname(): Promise<void> {
    this.profile.nickname = this.nicknameInput.trim().length > 0 ? this.nicknameInput.trim() : '思考者'
    await InsightStore.saveProfile(this.profile)
    this.showToast('昵称已保存')
  }

  private async applyTheme(mode: string): Promise<void> {
    this.themeMode = mode
    this.profile.themeMode = mode
    const ctx = AppContextService.getContext()
    if (ctx !== null) {
      ThemeAppearance.apply(mode, ctx)
    } else {
      ThemeAppearance.apply(mode)
    }
    await InsightStore.saveProfile(this.profile)
    this.showToast('外观已更新')
  }

  private async copyExport(): Promise<void> {
    const json = await InsightStore.exportJson()
    try {
      const board = pasteboard.getSystemPasteboard()
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, json)
      await board.setData(data)
      this.showToast('已复制到剪贴板')
    } catch {
      this.showToast('复制失败，请稍后重试')
    }
  }

  private async clearCache(): Promise<void> {
    this.showToast('本地缓存已清理')
  }

  private async handleRevokePrivacy(): Promise<void> {
    await PrivacyService.revoke()
    this.confirmRevoke = false
    this.showToast('已撤回隐私同意。首次启动隐私声明由华为应用市场托管，本应用不再二次弹窗。')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row() {
          Text('关闭')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().brandPrimary)
            .padding(12)
            .onClick((): void => { this.onClose() })
          Text('设置与隐私')
            .fontSize(Theme.type.subtitleL)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
          Column().width(48)
        }
        .width('100%')

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Row({ space: 12 }) {
              Column() {
                AppIcon({ name: 'user', iconSize: Theme.icon.xl, color: Theme.colors().brandOnPrimary })
              }
              .width(56)
              .height(56)
              .borderRadius(28)
              .justifyContent(FlexAlign.Center)
              .linearGradient({
                angle: 135,
                colors: [[Theme.colors().brandDeep, 0], [Theme.colors().brandPrimary, 1]]
              })
              Column({ space: 4 }) {
                Text(this.profile.nickname)
                  .fontSize(Theme.type.subtitleL)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Theme.colors().textPrimary)
                Text('🌿 游客模式 · 数据仅保存在本机')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
              }
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)

            TextInput({ text: this.nicknameInput, placeholder: '本机昵称' })
              .width('100%')
              .height(44)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textSecondary)
              .onChange((v: string) => { this.nicknameInput = v })
            AppButton({
              label: '保存昵称',
              variant: 'secondary',
              onTap: (): void => { void this.saveNickname() }
            })

            Text('外观')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Row({ space: 8 }) {
              this.ThemeChip('浅色', 'light')
              this.ThemeChip('深色', 'dark')
              this.ThemeChip('跟随系统', 'system')
            }
            .width('100%')

            Column() {
              AppListRow({
                title: '导出见解',
                subtitle: '复制 JSON 到剪贴板',
                onTap: (): void => { void this.copyExport() }
              })
              AppListRow({
                title: '《用户协议》',
                onTap: (): void => { this.showAgreementDoc = true }
              })
              AppListRow({
                title: '《隐私政策》',
                onTap: (): void => { this.showPrivacyDoc = true }
              })
              AppListRow({
                title: '清除缓存',
                subtitle: '不删除见解，不清空账号',
                onTap: (): void => { void this.clearCache() }
              })
              AppListRow({
                title: '撤回隐私同意',
                subtitle: '由系统托管弹窗承接；本应用不再二次弹窗',
                danger: true,
                showDivider: false,
                onTap: (): void => { this.confirmRevoke = true }
              })
            }
            .width('100%')
            .padding({ left: Theme.space.s4, right: Theme.space.s4 })
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)

            Text('见解簿 1.0.0 · 承德锐泓科技信息有限公司')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
              .textAlign(TextAlign.Center)
              .margin({ top: 8, bottom: 32 })
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 40 })
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.confirmRevoke) {
        Column() {
          Column({ space: Theme.space.s4 }) {
            Text('撤回隐私同意？')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textPrimary)
            Text('撤回后将返回同意页，本机见解仍保留在设备上。')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textSecondary)
            Row() {
              AppButton({
                label: '确认撤回',
                variant: 'danger',
                onTap: (): void => { void this.handleRevokePrivacy() }
              })
            }
            .width('100%')
            .onClick((): void => { void this.handleRevokePrivacy() })
            AppButton({
              label: '取消',
              variant: 'secondary',
              onTap: (): void => { this.confirmRevoke = false }
            })
          }
          .width('86%')
          .padding(Theme.space.s6)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.colors().overlayScrim)
      }

      if (this.showPrivacyDoc) {
        LegalDocOverlay({ kind: 'privacy', onClose: (): void => { this.showPrivacyDoc = false } })
      }
      if (this.showAgreementDoc) {
        LegalDocOverlay({ kind: 'agreement', onClose: (): void => { this.showAgreementDoc = false } })
      }
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontColor('#FFFFFF')
          .fontSize(Theme.type.footnote)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 52 })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  ThemeChip(label: string, mode: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.themeMode === mode ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .layoutWeight(1)
      .textAlign(TextAlign.Center)
      .backgroundColor(this.themeMode === mode ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.sm)
      .onClick((): void => { void this.applyTheme(mode) })
  }
}
