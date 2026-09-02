import { common } from '@kit.AbilityKit'
import { Theme } from '../components/design-system/Theme'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { AuthService } from '../services/AuthService'
import { ExportService } from '../services/ExportService'
import { ZhixingStore } from '../services/ZhixingStore'
import { PrivacyService } from '../services/PrivacyService'
import { StatChip } from '../components/zhixing/StatChip'

@Component
export struct MinePage {
  @Prop appName: string = '知行页'
  @Prop @Watch('onReloadTokenChange') reloadToken: number = 0
  @StorageLink('dataEpoch') @Watch('onDataEpochChange') dataEpoch: number = 0
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @State knowText: string = '0'
  @State planText: string = '0'
  @State checkText: string = '0/0'
  @State nick: string = ''
  @State bio: string = ''
  @State showSettings: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  @State confirmDelete: boolean = false
  @State darkMode: boolean = false
  @State showAbout: boolean = false
  @State showProfile: boolean = false
  private uiContext: common.UIAbilityContext | null = null
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onOpenFavorites: () => void = () => {}
  onOpenAchievements: () => void = () => {}
  onOpenGrowth: () => void = () => {}
  onOpenTimeline: () => void = () => {}
  onOpenReviewQueue: () => void = () => {}
  onOpenWeeklyGoal: () => void = () => {}

  aboutToAppear(): void {
    this.uiContext = this.getUIContext().getHostContext() as common.UIAbilityContext
    void this.load()
  }

  onReloadTokenChange(): void {
    void this.load()
  }

  onDataEpochChange(): void {
    void this.load()
  }

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
  }

  private async load(): Promise<void> {
    const ov = await ZhixingStore.overview()
    const weekly = await ZhixingStore.weeklyInsight()
    this.knowText = `${ov.notes + ov.cards + ov.digests}`
    this.planText = `${ov.plans}`
    this.checkText = `${weekly.checkedHabitsToday}/${ov.habits}`
    this.darkMode = Theme.isDark()
    this.nick = await ZhixingStore.loadNick()
    this.bio = await ZhixingStore.loadBio()
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
    await ZhixingStore.saveDark(on)
  }

  private pageBg(): string {
    return this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage
  }

  private async saveProfile(): Promise<void> {
    await ZhixingStore.saveNick(this.nick.trim())
    await ZhixingStore.saveBio(this.bio.trim())
    this.showProfile = false
    this.showToast('资料已保存')
  }

  private async exportData(): Promise<void> {
    if (this.uiContext === null) {
      this.showToast('导出环境未就绪')
      return
    }
    try {
      const message = await ExportService.exportForUser(this.uiContext)
      this.showToast(message)
    } catch {
      this.showToast('导出失败，请稍后重试')
    }
  }

  private async copyExport(): Promise<void> {
    const ok = await ExportService.copyAll()
    this.showToast(ok ? '已复制全部学习数据到剪贴板' : '复制失败，请稍后重试')
  }

  private displayName(): string {
    if (this.nick.length > 0) {
      return this.nick
    }
    if (this.isLoggedIn() && this.currentUsername.length > 0) {
      return this.currentUsername
    }
    return '知行访客'
  }

  build() {
    Stack() {
      Column() {
        if (this.showSettings) {
          this.SettingsPanel()
        } else if (this.showProfile) {
          this.ProfilePanel()
        } else if (this.showAbout) {
          this.AboutPanel()
        } else {
          this.MainBody()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.pageBg())

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
      }
    }
    .width('100%')
    .height('100%')
    .onVisibleAreaChange([0.4], (isExpanding: boolean, currentRatio: number) => {
      if (isExpanding && currentRatio >= 0.4) {
        void this.load()
      }
    })
  }

  @Builder
  MainBody() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Row({ space: 12 }) {
          Column() {
            AppIcon({ name: 'user', iconSize: 28, color: Theme.colors().brandOnPrimary })
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
            Text(this.displayName())
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text(this.bio.length > 0 ? this.bio : '把知识变成行动')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }
        .width('100%')
        .padding({ top: Theme.space.s5 })

        Row({ space: 8 }) {
          StatChip({ label: '知识', value: this.knowText })
          StatChip({ label: '计划', value: this.planText })
          StatChip({ label: '打卡', value: this.checkText })
        }
        .width('100%')

        if (!this.isLoggedIn()) {
          AppButton({ label: '登录 / 注册', onTap: (): void => { this.onOpenLogin() } })
        } else {
          AppButton({
            label: '退出登录',
            variant: 'secondary',
            onTap: (): void => {
              void AuthService.logout().then((): void => { this.onLogout() })
            }
          })
        }

        this.MenuRow('user', '个人资料', (): void => { this.showProfile = true })
        this.MenuRow('gear', '设置与隐私', (): void => { this.showSettings = true })
        this.MenuRow('heart', '我的收藏', (): void => { this.onOpenFavorites() })
        this.MenuRow('book', '今日复习队列', (): void => { this.onOpenReviewQueue() })
        this.MenuRow('flag', '本周学习目标', (): void => { this.onOpenWeeklyGoal() })
        this.MenuRow('chart', '成长仪表盘', (): void => { this.onOpenGrowth() })
        this.MenuRow('flag', '成就墙', (): void => { this.onOpenAchievements() })
        this.MenuRow('list', '成长时间轴', (): void => { this.onOpenTimeline() })
        this.MenuRow('biz', '导出学习数据', (): void => { void this.exportData() })
        this.MenuRow('message', '复制数据到剪贴板', (): void => { void this.copyExport() })
        this.MenuRow('sparkle', '关于知行页', (): void => { this.showAbout = true })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      .width('100%')
    }
    .layoutWeight(1)
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
  }

  @Builder
  MenuRow(icon: AppIconName, label: string, tap: () => void) {
    Row({ space: 12 }) {
      Column() {
        AppIcon({ name: icon, iconSize: 18, color: Theme.colors().brandPrimary })
      }
      .width(36)
      .height(36)
      .borderRadius(10)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      Text(label)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textPrimary)
        .layoutWeight(1)
      AppIcon({ name: 'chevron', iconSize: 16, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(14)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick(tap)
  }

  @Builder
  ProfilePanel() {
    Column({ space: Theme.space.s4 }) {
      Row() {
        Text('个人资料')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Blank()
        Text('关闭')
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { this.showProfile = false })
      }
      .width('100%')
      .padding({ top: Theme.space.s5 })
      TextInput({ text: this.nick, placeholder: '昵称' })
        .onChange((v: string) => { this.nick = v })
        .height(44)
        .fontColor(Theme.colors().textPrimary)
        .placeholderColor(Theme.colors().textTertiary)
        .backgroundColor(Theme.colors().surfaceCard)
      TextArea({ text: this.bio, placeholder: '简介' })
        .onChange((v: string) => { this.bio = v })
        .height(80)
        .fontColor(Theme.colors().textPrimary)
        .placeholderColor(Theme.colors().textTertiary)
        .backgroundColor(Theme.colors().surfaceCard)
      AppButton({ label: '保存', onTap: (): void => { void this.saveProfile() } })
    }
    .padding(Theme.space.pageX)
    .width('100%')
    .height('100%')
    .backgroundColor(this.pageBg())
  }

  @Builder
  AboutPanel() {
    Column({ space: Theme.space.s4 }) {
      Row() {
        Text('关于')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Blank()
        Text('关闭')
          .onClick((): void => { this.showAbout = false })
          .fontColor(Theme.colors().brandPrimary)
      }
      .width('100%')
      .padding({ top: Theme.space.s5 })
      Text(`${this.appName} 1.0.0`)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textPrimary)
      Text('知行合一学习工具。数据保存在本机，不含支付与生成式对话。运营者：承德锐泓科技信息有限公司。')
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.colors().textSecondary)
    }
    .padding(Theme.space.pageX)
    .width('100%')
    .height('100%')
    .backgroundColor(this.pageBg())
  }

  @Builder
  SettingsPanel() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Row() {
          Text(this.themeEpoch >= 0 ? '设置与隐私' : '设置与隐私')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
          Blank()
          Text('关闭')
            .fontColor(Theme.colors().brandPrimary)
            .onClick((): void => { this.showSettings = false; void this.load() })
        }
        .width('100%')
        .padding({ top: Theme.space.s5 })

        Row() {
          Text('深色模式')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textPrimary)
          Blank()
          Toggle({ type: ToggleType.Switch, isOn: this.darkMode })
            .selectedColor(Theme.colors().brandPrimary)
            .onChange((on: boolean) => { void this.toggleDark(on) })
        }
        .width('100%')
        .padding(14)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)

        AppButton({
          label: '查看《用户协议》',
          variant: 'secondary',
          onTap: (): void => { this.legalKind = 'agreement'; this.showLegal = true }
        })
        AppButton({
          label: '查看《隐私政策》',
          variant: 'secondary',
          onTap: (): void => { this.legalKind = 'privacy'; this.showLegal = true }
        })
        AppButton({
          label: '清除缓存',
          variant: 'secondary',
          onTap: (): void => { this.handleClearCache() }
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

        if (this.isLoggedIn()) {
          AppButton({
            label: '注销账号',
            variant: 'danger',
            onTap: (): void => { void this.handleDeleteAccount() }
          })
        }
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      .width('100%')
    }
    .layoutWeight(1)
    .align(Alignment.Top)
    .backgroundColor(this.pageBg())
  }
}
