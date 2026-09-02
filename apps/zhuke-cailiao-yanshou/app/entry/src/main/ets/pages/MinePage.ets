import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { ConfirmDialog } from '../components/inspect/ConfirmDialog'
import { MineMenuRow } from '../components/inspect/MineMenuRow'
import { MineAboutPane, MineSettingsPane, MineStatsPane } from '../components/inspect/MineExtraPanes'
import { AuthService } from '../services/AuthService'
import { PrivacyService } from '../services/PrivacyService'
import { InspectLocalStore } from '../services/InspectLocalStore'
import { InspectService } from '../services/InspectService'
import { BrandIdentity } from '../config/BrandIdentity'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '筑科材料验收'
  @Prop @Watch('onTick') refreshToken: number = 0
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('mineOpenSettings') @Watch('onMineFlag') mineFlag: boolean = false
  @StorageLink('notifyEnabled') notifyEnabled: boolean = true
  @StorageLink('appearance') appearance: string = 'system'
  @StorageLink('defaultCategory') defaultCategory: string = '瓷砖'
  @StorageLink('defaultUnit') defaultUnit: string = '箱'
  @State showSettings: boolean = false
  @State showStats: boolean = false
  @State showAbout: boolean = false
  @State showClear: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  @State allTotal: number = 0
  @State allPass: number = 0
  @State allPending: number = 0
  @State allFail: number = 0
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}

  aboutToAppear(): void {
    this.reloadStats()
    this.onMineFlag()
  }

  onTick(): void {
    this.reloadStats()
  }

  onMineFlag(): void {
    if (this.mineFlag) {
      this.showSettings = true
      AppStorage.setOrCreate('mineOpenSettings', false)
      AppStorage.setOrCreate('tabBarHidden', true)
    }
  }

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
  }

  private reloadStats(): void {
    const s = InspectService.stats()
    this.allTotal = s.allTotal
    this.allPass = s.allPass
    this.allPending = s.allPending
    this.allFail = s.allFail
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2800)
  }

  private closePanel(): void {
    this.showSettings = false
    this.showStats = false
    this.showAbout = false
    const mode = AppStorage.get<string>('inspectNavMode')
    if (mode === undefined || mode.length === 0) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  private async handleRevokePrivacy(): Promise<void> {
    await PrivacyService.revoke()
    if (this.isLoggedIn()) {
      await AuthService.logout()
      this.onLogout()
    }
    this.closePanel()
    this.showToast('已撤回隐私同意，再次登录须重新勾选协议')
  }

  private async handleDeleteAccount(): Promise<void> {
    const ok = await PrivacyService.deleteAccount()
    if (ok) {
      await AuthService.logout()
      this.closePanel()
      this.onLogout()
      this.showToast('账号已注销')
      return
    }
    this.showToast('注销失败，请稍后重试')
  }

  private async clearAll(): Promise<void> {
    this.showClear = false
    await InspectLocalStore.clearAll()
    this.reloadStats()
    this.showToast('本地验收记录已全部删除')
  }

  build() {
    Stack() {
      Column() {
        if (this.showSettings) {
          MineSettingsPane({
            notifyEnabled: this.notifyEnabled,
            appearance: this.appearance,
            defaultCategory: this.defaultCategory,
            defaultUnit: this.defaultUnit,
            themeTick: this.refreshToken,
            onBack: () => this.closePanel(),
            onToggleNotify: (): void => { void InspectLocalStore.setNotifyEnabled(!this.notifyEnabled) },
            onAppearanceChange: (v: string) => { void InspectLocalStore.setAppearance(v) },
            onOpenAgreement: () => { this.legalKind = 'agreement'; this.showLegal = true },
            onOpenPrivacy: () => { this.legalKind = 'privacy'; this.showLegal = true },
            onDeleteAccount: (): void => { void this.handleDeleteAccount() },
            onRevoke: (): void => { void this.handleRevokePrivacy() }
          })
        } else if (this.showStats) {
          MineStatsPane({
            allTotal: this.allTotal,
            allPass: this.allPass,
            allPending: this.allPending,
            allFail: this.allFail,
            onBack: () => this.closePanel()
          })
        } else if (this.showAbout) {
          MineAboutPane({ onBack: () => this.closePanel() })
        } else {
          this.MainPanel()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
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
          onClose: () => { this.showLegal = false }
        })
          .width('100%')
          .height('100%')
      }

      if (this.showClear) {
        ConfirmDialog({
          title: '清理本地数据',
          message: '确定删除全部本地验收记录吗？',
          confirmLabel: '删除',
          onCancel: () => { this.showClear = false },
          onConfirm: () => { void this.clearAll() }
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  MainPanel() {
    Column() {
      Column({ space: 6 }) {
        Text(this.appName)
          .fontSize(Theme.type.title1)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        Text(BrandIdentity.tagline())
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s3
      })

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          Column({ space: 6 }) {
            Text(this.isLoggedIn() ? this.currentUsername : '游客')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Text(this.isLoggedIn() ? '已登录，可将记录同步到云端' : '游客可完成本机验收；登录后可同步记录')
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s5)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.card)
          .border({ width: 1, color: Theme.colors().strokeHairline })

          MineMenuRow({
            title: '数据统计',
            subtitle: '全部验收与通过情况',
            onTap: () => {
              this.reloadStats()
              this.showStats = true
              AppStorage.setOrCreate('tabBarHidden', true)
            }
          })
          MineMenuRow({
            title: '清理本地数据',
            subtitle: '删除本机全部验收记录',
            onTap: () => { this.showClear = true }
          })
          MineMenuRow({
            title: '设置与隐私',
            subtitle: '协议 · 撤回同意 · 注销',
            onTap: () => {
              this.showSettings = true
              AppStorage.setOrCreate('tabBarHidden', true)
            }
          })
          MineMenuRow({
            title: '关于应用',
            subtitle: `版本 ${BrandIdentity.version()}`,
            onTap: () => {
              this.showAbout = true
              AppStorage.setOrCreate('tabBarHidden', true)
            }
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
    }
    .width('100%')
    .height('100%')
    .opacity(this.refreshToken >= 0 ? 1 : 1)
  }
}
