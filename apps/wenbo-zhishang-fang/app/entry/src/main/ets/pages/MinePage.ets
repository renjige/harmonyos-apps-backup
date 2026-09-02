import { common } from '@kit.AbilityKit'
import { Theme } from '../components/design-system/Theme'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { PrivacySettingsPane } from '../components/settings/PrivacySettingsPane'
import { AuthService } from '../services/AuthService'
import { ExportService } from '../services/ExportService'
import { ReviewStatBar } from '../components/note/ReviewStatBar'
import { NoteStore } from '../services/NoteStore'
import { PrivacyService } from '../services/PrivacyService'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '纸上方'
  @Prop @Watch('onReloadTokenChange') reloadToken: number = 0
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @State showSettings: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  @State confirmDelete: boolean = false
  @State darkMode: boolean = false
  @State showAbout: boolean = false
  private uiContext: common.UIAbilityContext | null = null
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onClose: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  onReloadTokenChange(): void {
    void this.load()
  }

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
  }

  private async load(): Promise<void> {
    this.darkMode = Theme.isDark()
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout((): void => { this.toastText = '' }, 2800)
  }

  private async handleRevokePrivacy(): Promise<void> {
    await PrivacyService.revoke()
    if (this.isLoggedIn()) {
      await AuthService.logout()
      this.onLogout()
    }
    this.showSettings = false
    this.showToast('已撤回隐私同意，再次登录须重新勾选协议')
  }

  private handleClearCache(): void {
    AppStorage.setOrCreate('localCacheEpoch', Date.now())
    this.showToast('已清除本地缓存')
  }

  private async handleDeleteAccount(): Promise<void> {
    if (!this.confirmDelete) {
      this.confirmDelete = true
      this.showToast('再点一次确认注销账号')
      return
    }
    const ok = await PrivacyService.deleteAccount()
    if (ok) {
      await AuthService.logout()
      this.showSettings = false
      this.onLogout()
      this.showToast('账号已注销')
      return
    }
    this.showToast('注销失败，请稍后重试')
  }

  private async toggleDark(on: boolean): Promise<void> {
    this.darkMode = on
    ThemeAppearance.apply(on ? 'dark' : 'light', this.getUIContext().getHostContext() as common.UIAbilityContext)
    await NoteStore.saveDark(on)
  }

  private async exportData(): Promise<void> {
    if (this.uiContext === null) {
      this.showToast('导出环境未就绪')
      return
    }
    try {
      const path = await ExportService.exportCsvFile(this.uiContext)
      const copied = await ExportService.copyCsv()
      this.showToast(copied ? `已导出并复制 CSV：${path}` : `已导出：${path}`)
    } catch {
      this.showToast('导出失败，请稍后重试')
    }
  }

  build() {
    Stack() {
      Column() {
        if (this.showSettings) {
          PrivacySettingsPane({
            confirmDelete: this.confirmDelete,
            onBack: (): void => { this.showSettings = false },
            onOpenAgreement: (): void => {
              this.legalKind = 'agreement'
              this.showLegal = true
            },
            onOpenPrivacy: (): void => {
              this.legalKind = 'privacy'
              this.showLegal = true
            },
            onClearCache: (): void => { this.handleClearCache() },
            onDeleteAccount: (): void => { void this.handleDeleteAccount() },
            onRevoke: (): void => { void this.handleRevokePrivacy() }
          })
        } else if (this.showAbout) {
          this.AboutPanel()
        } else {
          this.MainBody()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor('#FFFFFF')
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandDeep)
            .borderRadius(Theme.radius.pill)
            .maxLines(3)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .padding({ top: Theme.space.s6, left: Theme.space.pageX, right: Theme.space.pageX })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }

      if (this.showLegal) {
        LegalDocOverlay({
          kind: this.legalKind,
          onClose: (): void => { this.showLegal = false }
        })
          .width('100%')
          .height('100%')
      }
    }
    .width('100%')
    .height('100%')
    .onAppear((): void => {
      const host = this.getUIContext().getHostContext()
      if (host) {
        this.uiContext = host as common.UIAbilityContext
      }
    })
  }

  @Builder
  MainBody() {
    Column() {
      Row() {
        Row() {
          AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.onClose() })
        Text('设置')
          .fontSize(Theme.type.titleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Row({ space: Theme.space.s3 }) {
            Column() {
              AppIcon({ name: 'user', iconSize: 28, color: '#FFFFFF' })
            }
            .width(56)
            .height(56)
            .justifyContent(FlexAlign.Center)
            .borderRadius(Theme.radius.pill)
            .linearGradient({
              angle: 135,
              colors: [[Theme.colors().brandPrimary, 0], [Theme.colors().brandDeep, 1]]
            })
            Column({ space: 4 }) {
              Text(this.isLoggedIn() ? this.currentUsername : '游客')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              Text(this.isLoggedIn() ? '账号已登录' : '游客可本机摘录；登录后可同步账号')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
            }
            .layoutWeight(1)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(12)

          ReviewStatBar()

          Row() {
            Text('深色模式')
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().textPrimary)
              .layoutWeight(1)
            Toggle({ type: ToggleType.Switch, isOn: this.darkMode })
              .selectedColor(Theme.colors().brandPrimary)
              .onChange((on: boolean): void => { void this.toggleDark(on) })
          }
          .width('100%')
          .height(52)
          .padding({ left: 16, right: 16 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(12)

          AppButton({
            label: '导出 CSV',
            variant: 'secondary',
            onTap: (): void => { void this.exportData() }
          })
          AppButton({
            label: '关于我们',
            variant: 'secondary',
            onTap: (): void => { this.showAbout = true }
          })

          Row({ space: Theme.space.s3 }) {
            Column({ space: 2 }) {
              Text('设置与隐私')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
              Text('协议 · 撤回 · 注销')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(12)
          .onClick((): void => {
            this.confirmDelete = false
            this.showSettings = true
          })

          if (this.isLoggedIn()) {
            AppButton({
              label: '退出登录',
              variant: 'secondary',
              onTap: (): void => {
                void AuthService.logout()
                this.onLogout()
              }
            })
          } else {
            AppButton({
              label: '登录 / 注册',
              onTap: (): void => { this.onOpenLogin() }
            })
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  AboutPanel() {
    Column({ space: Theme.space.s4 }) {
      Row() {
        Row() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { this.showAbout = false })
        Text('关于我们')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      Text('纸上方（PaperWise）是智能书摘工具。把纸质书中的金句与感悟做成卡片，用智慧分类整理，并在抽卡回顾中主动回想出处。数据默认保存在本机。版本 1.0.2。运营者：承德锐泓科技有限公司。')
        .fontSize(Theme.type.bodyM)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
    }
    .width('100%')
    .height('100%')
  }
}
