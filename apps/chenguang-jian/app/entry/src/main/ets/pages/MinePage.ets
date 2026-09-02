import { pasteboard } from '@kit.BasicServicesKit'
import { Theme } from '../components/design-system/Theme'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { common } from '@kit.AbilityKit'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { AuthService } from '../services/AuthService'
import { PrivacyService } from '../services/PrivacyService'
import { EssayNav } from '../services/EssayNav'
import { EssayStore } from '../services/EssayStore'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '晨光笺'
  @Prop @Watch('onRefresh') refreshToken: number = 0
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @State showSettings: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  @State confirmDelete: boolean = false
  @State total: number = 0
  @State streak: number = 0
  @State words: number = 0
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}

  aboutToAppear(): void {
    this.loadStats()
  }

  onRefresh(): void {
    this.loadStats()
  }

  private loadStats(): void {
    this.total = EssayStore.totalCount()
    this.streak = EssayStore.streakDays()
    this.words = EssayStore.totalWords()
  }

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2800)
  }

  private async handleRevokePrivacy(): Promise<void> {
    await PrivacyService.revoke()
    if (this.isLoggedIn()) {
      await AuthService.logout()
      this.onLogout()
    }
    this.showSettings = false
    EssayNav.restoreBar()
    this.showToast('已撤回隐私同意，再次登录须重新勾选协议')
  }

  private async handleDeleteAccount(): Promise<void> {
    const ok = await PrivacyService.deleteAccount()
    if (ok) {
      await AuthService.logout()
      this.showSettings = false
      EssayNav.restoreBar()
      this.onLogout()
      this.showToast('账号已注销')
      return
    }
    this.showToast('注销失败，请稍后重试')
  }

  private handleClearCache(): void {
    AppStorage.setOrCreate('localCacheEpoch', Date.now())
    this.showToast('已清除本地缓存')
  }

  private async toggleDark(on: boolean): Promise<void> {
    ThemeAppearance.apply(on ? 'dark' : 'light', this.getUIContext().getHostContext() as common.UIAbilityContext)
    await EssayStore.setDark(on)
  }

  private async copyExport(): Promise<void> {
    const text = EssayStore.exportText()
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      await pasteboard.getSystemPasteboard().setData(data)
      this.showToast('已复制为纯文本，可粘贴到备忘或文件')
    } catch {
      this.showToast('复制失败，请稍后重试')
    }
  }

  private openSettings(): void {
    this.showSettings = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeSettings(): void {
    this.showSettings = false
    EssayNav.restoreBar()
  }

  build() {
    Stack() {
      Column() {
        if (this.showSettings) {
          this.SettingsPanel()
        } else {
          this.MainPanel()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.showLegal) {
        LegalDocOverlay({
          kind: this.legalKind,
          onClose: (): void => { this.showLegal = false }
        })
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 18 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Top)
  }

  @Builder
  MainPanel() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Row({ space: 12 }) {
          Column() {
            AppIcon({ name: 'user', iconSize: Theme.icon.xl, color: Theme.colors().brandOnPrimary })
          }
          .width(56)
          .height(56)
          .borderRadius(28)
          .backgroundColor(Theme.colors().brandPrimary)
          .justifyContent(FlexAlign.Center)
          Column({ space: 4 }) {
            Text(this.isLoggedIn() ? this.currentUsername : '游客')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Text(this.isLoggedIn() ? '已登录，笺仍保存在本机' : '未登录也可写笺 · 🌿')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          if (!this.isLoggedIn()) {
            AppButton({ label: '登录', variant: 'secondary', onTap: (): void => { this.onOpenLogin() } })
          }
        }
        .width('100%')

        Row({ space: 8 }) {
          this.StatCell('总篇数', `${this.total}`)
          this.StatCell('连续天数', `${this.streak}`)
          this.StatCell('总字数', `${this.words}`)
        }
        .width('100%')

        this.MenuRow('bookmark', '收藏的晨语', (): void => { EssayNav.openFav() })
        this.MenuRow('book', '书写习惯自检', (): void => { EssayNav.openDiagnose() })
        this.MenuRow('message', '机构通知', (): void => { EssayNav.openMessages() })
        this.MenuRow('biz', '导出为纯文本', (): void => { void this.copyExport() })
        this.MenuRow('gear', '设置与隐私', (): void => { this.openSettings() })

        if (this.isLoggedIn()) {
          AppButton({
            label: '退出登录',
            variant: 'secondary',
            onTap: (): void => {
              void AuthService.logout()
              this.onLogout()
            }
          })
        }
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s4,
        bottom: Theme.space.s10
      })
      .width('100%')
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }

  @Builder
  StatCell(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().textPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding({ top: 14, bottom: 14 })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
  }

  @Builder
  MenuRow(icon: AppIconName, title: string, action: () => void) {
    Row() {
      AppIcon({ name: icon, iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
      Text(title)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textPrimary)
        .layoutWeight(1)
        .margin({ left: 12 })
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick(action)
  }

  @Builder
  SettingsPanel() {
    Column({ space: Theme.space.s4 }) {
      Row() {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { this.closeSettings() })
        Text('设置与隐私')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
      }
      .width('100%')

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          Row() {
            Text('深色模式')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .layoutWeight(1)
            Toggle({ type: ToggleType.Switch, isOn: this.darkModeOn })
              .selectedColor(Theme.colors().brandPrimary)
              .onChange((on: boolean) => { void this.toggleDark(on) })
          }
          .width('100%')
          .padding(14)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)

          AppButton({
            label: '查看《用户协议》',
            variant: 'secondary',
            onTap: (): void => {
              this.legalKind = 'agreement'
              this.showLegal = true
            }
          })
          AppButton({
            label: '查看《隐私政策》',
            variant: 'secondary',
            onTap: (): void => {
              this.legalKind = 'privacy'
              this.showLegal = true
            }
          })
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
            label: '清除缓存',
            variant: 'secondary',
            onTap: (): void => { this.handleClearCache() }
          })
          AppButton({
            label: this.confirmDelete ? '再点一次确认注销' : '注销账号',
            variant: 'secondary',
            onTap: (): void => {
              if (!this.confirmDelete) {
                this.confirmDelete = true
                this.showToast('再点一次确认注销账号')
                return
              }
              void this.handleDeleteAccount()
            }
          })
          Text('关于晨光笺  1.0.0')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
            .margin({ top: 8 })
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s2 })
  }
}
