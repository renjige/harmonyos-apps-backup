import { Theme } from '../components/design-system/Theme'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { common } from '@kit.AbilityKit'
import { AppButton } from '../components/design-system/AppButton'
import { MinePrefRow, MineSettingsPane } from '../components/mine/MineSheets'
import { MineStatTile } from '../components/mine/MineStatsCards'
import { AuthService } from '../services/AuthService'
import { PrivacyService } from '../services/PrivacyService'
import { KnowledgeStore } from '../services/KnowledgeStore'
import { KnowledgeNav } from '../services/KnowledgeNav'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '轻知阁'
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @StorageLink('knowledgeRefresh') @Watch('onRefresh') knowledgeRefresh: number = 0
  @State showSettings: boolean = false
  @State showData: boolean = false
  @State showAbout: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  @State knowledgeCount: number = 0
  @State favoriteCount: number = 0
  @State sparkCount: number = 0
  @State reviewCount: number = 0
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}

  aboutToAppear(): void {
    this.refreshStats()
  }

  onRefresh(): void {
    this.refreshStats()
  }

  private refreshStats(): void {
    this.knowledgeCount = KnowledgeStore.all().length
    this.favoriteCount = KnowledgeStore.favorites().length
    this.sparkCount = KnowledgeStore.sparksAll().length
    this.reviewCount = KnowledgeStore.reviewCount()
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
    AppStorage.setOrCreate('minePanelOpen', false)
    AppStorage.setOrCreate('tabBarHidden', false)
    this.showToast('已撤回隐私同意，再次登录须重新勾选协议')
  }

  private async handleDeleteAccount(): Promise<void> {
    const ok = await PrivacyService.deleteAccount()
    if (ok) {
      await AuthService.logout()
      this.showSettings = false
      AppStorage.setOrCreate('minePanelOpen', false)
      AppStorage.setOrCreate('tabBarHidden', false)
      this.onLogout()
      this.showToast('账号已注销')
      return
    }
    this.showToast('注销失败，请稍后重试')
  }

  private async toggleDark(on: boolean): Promise<void> {
    ThemeAppearance.apply(on ? 'dark' : 'light', this.getUIContext().getHostContext() as common.UIAbilityContext)
    await KnowledgeStore.setDark(on)
  }

  private openSettings(): void {
    this.showSettings = true
    AppStorage.setOrCreate('minePanelOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        if (this.showSettings) {
          MineSettingsPane({
            onClose: (): void => {
              this.showSettings = false
              AppStorage.setOrCreate('minePanelOpen', false)
              AppStorage.setOrCreate('tabBarHidden', false)
            },
            onOpenAgreement: (): void => { this.legalKind = 'agreement'; this.showLegal = true },
            onOpenPrivacy: (): void => { this.legalKind = 'privacy'; this.showLegal = true },
            onDeleteAccount: (): void => { void this.handleDeleteAccount() },
            onRevoke: (): void => { void this.handleRevokePrivacy() }
          })
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
          .zIndex(20)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 48 })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  MainPanel() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Text('我的轻知空间')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')

        if (this.isLoggedIn()) {
          Text(this.currentUsername)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        } else {
          AppButton({
            label: '登录 / 注册（可选）',
            variant: 'secondary',
            onTap: (): void => { this.onOpenLogin() }
          })
        }

        Row({ space: Theme.space.s2 }) {
          MineStatTile({ value: `${this.knowledgeCount}`, label: '知识总数' })
          MineStatTile({ value: `${this.favoriteCount}`, label: '收藏数量' })
        }
        .width('100%')
        Row({ space: Theme.space.s2 }) {
          MineStatTile({ value: `${this.sparkCount}`, label: '记录数量' })
          MineStatTile({ value: `${this.reviewCount}`, label: '复习数量' })
        }
        .width('100%')

        MinePrefRow({ title: '内容管理', caption: '查看、打开或删除轻知', onTap: (): void => { KnowledgeNav.openManage() } })
        MinePrefRow({ title: '分类管理', caption: '生活、科普、阅读、工作、兴趣、其他', onTap: (): void => { KnowledgeNav.switchTab(1) } })
        MinePrefRow({
          title: '隐私设置',
          caption: '协议 · 撤回 · 注销',
          onTap: (): void => { this.openSettings() }
        })
        MinePrefRow({
          title: '数据说明',
          caption: '内容优先保存在这台设备',
          onTap: (): void => { this.showData = !this.showData }
        })
        if (this.showData) {
          Text('知识、收藏、灵感与复习状态默认保存在本机。可选登录后，才可能把你主动写下的内容同步到运营者服务器。卸载或清空后可能无法恢复。')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }
        MinePrefRow({
          title: '用户协议',
          caption: '使用轻知阁的约定',
          onTap: (): void => { this.legalKind = 'agreement'; this.showLegal = true }
        })
        MinePrefRow({
          title: '隐私政策',
          caption: '我们如何处理信息',
          onTap: (): void => { this.legalKind = 'privacy'; this.showLegal = true }
        })
        MinePrefRow({
          title: '关于轻知阁',
          caption: '每天一点轻知。',
          onTap: (): void => { this.showAbout = !this.showAbout }
        })
        if (this.showAbout) {
          Text('轻知阁是一款轻量个人知识整理工具。发现、阅读、收藏、整理、记录、复习。不提供社交、支付与会员。')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }

        Row() {
          Text('深色模式')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().textPrimary)
            .layoutWeight(1)
          Toggle({ type: ToggleType.Switch, isOn: this.darkModeOn })
            .onChange((on: boolean) => { void this.toggleDark(on) })
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.card)

        MinePrefRow({
          title: '机构通知',
          caption: '来自轻知阁的提醒',
          onTap: (): void => { KnowledgeNav.openMessages() }
        })

        if (this.isLoggedIn()) {
          AppButton({
            label: '退出登录',
            variant: 'ghost',
            onTap: (): void => {
              void AuthService.logout().then(() => { this.onLogout() })
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
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .align(Alignment.Top)
  }
}
