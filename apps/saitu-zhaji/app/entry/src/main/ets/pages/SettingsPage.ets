import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppListRow } from '../components/design-system/AppListRow'
import { AppIcon } from '../components/design-system/AppIcon'
import { LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { UserProfile } from '../models/SaituModels'
import { SaituLocalStore } from '../services/SaituLocalStore'
import { PrivacyService } from '../services/PrivacyService'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { AppContextService } from '../services/AppContextService'
import { pasteboard } from '@kit.BasicServicesKit'

@Component
export struct SettingsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  onDataCleared: () => void = () => {}
  @State profile: UserProfile = new UserProfile()
  @State nicknameInput: string = ''
  @State themeMode: string = 'system'
  @State showPrivacyDoc: boolean = false
  @State showAgreementDoc: boolean = false
  @State toastText: string = ''
  @State confirmClear: boolean = false
  @State confirmRevoke: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.profile = await SaituLocalStore.loadProfile()
    this.nicknameInput = this.profile.nickname
    const mode = this.profile.themeMode.length > 0 ? this.profile.themeMode : 'system'
    this.themeMode = mode
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2600)
  }

  private async saveNickname(): Promise<void> {
    this.profile.nickname = this.nicknameInput.trim().length > 0 ? this.nicknameInput.trim() : '赛途旅人'
    await SaituLocalStore.saveProfile(this.profile)
    this.showToast('昵称已保存')
  }

  private async exportAndCopy(): Promise<void> {
    const json = await SaituLocalStore.exportJson()
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, json)
      const board = pasteboard.getSystemPasteboard()
      await board.setData(data)
      this.showToast('JSON 已复制到剪贴板')
    } catch {
      this.showToast('复制失败，请稍后重试')
    }
  }

  private async clearAllData(): Promise<void> {
    await SaituLocalStore.clearAll()
    this.confirmClear = false
    this.onDataCleared()
    this.showToast('全部数据已清除')
  }

  private async persistTheme(mode: string): Promise<void> {
    this.themeMode = mode
    this.profile.themeMode = mode
    ThemeAppearance.apply(mode, AppContextService.getContext() ?? undefined)
    AppStorage.setOrCreate('colorMode', mode)
    await SaituLocalStore.saveProfile(this.profile)
    this.showToast('主题已切换')
  }

  private async handleRevokePrivacy(): Promise<void> {
    await PrivacyService.revoke()
    this.confirmRevoke = false
    this.showPrivacyDoc = true
    this.showToast('已清除本机隐私同意记录，请重新阅读隐私政策')
  }

  @Builder
  ThemeChip(label: string, mode: string) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.themeMode === mode ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor(this.themeMode === mode ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { void this.persistTheme(mode) })
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
            .opacity(this.themeEpoch >= 0 ? 1 : 1)

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
                .fontSize(Theme.type.body)
                .onChange((v: string): void => { this.nicknameInput = v })
              AppButton({
                label: '保存昵称',
                variant: 'secondary',
                onTap: (): void => { void this.saveNickname() }
              })
            }
            .layoutWeight(1)
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          Text('外观')
            .fontSize(Theme.type.overline)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
          Row({ space: Theme.space.s2 }) {
            this.ThemeChip('跟随系统', 'system')
            this.ThemeChip('浅色', 'light')
            this.ThemeChip('深色', 'dark')
          }

          Text('数据')
            .fontSize(Theme.type.overline)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
          AppButton({
            label: '导出 JSON（复制到剪贴板）',
            variant: 'secondary',
            onTap: (): void => { void this.exportAndCopy() }
          })
          AppButton({
            label: '清除缓存',
            variant: 'ghost',
            onTap: (): void => this.showToast('界面缓存已清理（数据未删除）')
          })
          if (!this.confirmClear) {
            AppButton({
              label: '清除全部数据',
              variant: 'danger',
              onTap: (): void => { this.confirmClear = true }
            })
          } else {
            Column({ space: Theme.space.s2 }) {
              Text('确定清除全部札记、旅途与赛事档案？不可恢复')
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().danger)
                .width('100%')
              AppButton({ label: '取消', variant: 'secondary', onTap: (): void => { this.confirmClear = false } })
              AppButton({ label: '确认清除', variant: 'danger', onTap: (): void => { void this.clearAllData() } })
            }
            .width('100%')
          }

          Text('协议与隐私')
            .fontSize(Theme.type.overline)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
          AppListRow({ title: '隐私政策', onTap: (): void => { this.showPrivacyDoc = true } })
          AppListRow({ title: '用户协议', onTap: (): void => { this.showAgreementDoc = true } })
          if (!this.confirmRevoke) {
            AppButton({
              label: '撤回隐私同意',
              variant: 'ghost',
              onTap: (): void => { this.confirmRevoke = true }
            })
          } else {
            Column({ space: Theme.space.s2 }) {
              Text('将清除本机隐私同意记录；协议可在下方重新阅读。首次安装时的隐私确认由华为 AppGallery Connect 平台托管，非应用内弹窗。')
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
              AppButton({ label: '取消', variant: 'secondary', onTap: (): void => { this.confirmRevoke = false } })
              AppButton({ label: '确认撤回', variant: 'danger', onTap: (): void => { void this.handleRevokePrivacy() } })
            }
            .width('100%')
          }

          Column({ space: 4 }) {
            Text('关于赛途札记')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            Text('版本 1.3.3 · 赛途记\n赛事档案 + 旅途成长 · 数据仅存本机 · 无内购')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .lineHeight(20)
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          Blank().height(this.bottomInset)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().surfaceInverse)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 48 })
          .zIndex(20)
      }
      if (this.showPrivacyDoc) {
        LegalDocOverlay({ kind: 'privacy', onClose: (): void => { this.showPrivacyDoc = false } })
      }
      if (this.showAgreementDoc) {
        LegalDocOverlay({ kind: 'agreement', onClose: (): void => { this.showAgreementDoc = false } })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
