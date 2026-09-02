import { Theme } from '../components/design-system/Theme'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { common } from '@kit.AbilityKit'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { AuthService } from '../services/AuthService'
import { PrivacyService } from '../services/PrivacyService'
import { ProfileStore } from '../services/ProfileStore'
import { ArchiveSnap, GoalState, MoveItem, GoalProgress } from '../models/TuceModels'
import { TuceEngine } from '../services/TuceEngine'
import { TuceStore } from '../services/TuceStore'
import { MoveLibrary } from '../services/MoveLibrary'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { TuceNav } from '../services/TuceNav'
import { GoalProgressCard } from '../components/tuce/GoalProgressCard'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '运动图册'
  @Prop @Watch('onRefresh') refreshToken: number = 0
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @State showSettings: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  @State confirmDelete: boolean = false
  @State snap: ArchiveSnap = new ArchiveSnap()
  @State goal: GoalState = new GoalState()
  @State favMoves: MoveItem[] = []
  @State goalProgress: GoalProgress = new GoalProgress()
  @State weeklyText: string = '3'
  @State monthlyText: string = '15'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}

  aboutToAppear(): void {
    void this.loadStats()
  }

  onRefresh(): void {
    void this.loadStats()
  }

  private async loadStats(): Promise<void> {
    this.snap = await TuceEngine.archive()
    this.goal = await TuceStore.goal()
    this.goalProgress = await TuceEngine.goalProgress()
    this.weeklyText = `${this.goal.weekly}`
    this.monthlyText = `${this.goal.monthly}`
    const ids = await TuceStore.favIds()
    const moves: MoveItem[] = []
    for (const id of ids) {
      const m = MoveLibrary.find(id)
      if (m !== undefined) {
        moves.push(m)
      }
    }
    this.favMoves = moves
  }

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
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
    AppStorage.setOrCreate('tabBarHidden', false)
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
      AppStorage.setOrCreate('tabBarHidden', false)
      this.onLogout()
      this.showToast('账号已注销')
      return
    }
    this.showToast('注销失败，请稍后重试')
  }

  private async toggleDark(on: boolean): Promise<void> {
    ThemeAppearance.apply(on ? 'dark' : 'light', this.getUIContext().getHostContext() as common.UIAbilityContext)
    this.darkModeOn = on
    await ProfileStore.setDarkMode(on)
  }

  private async saveGoals(): Promise<void> {
    const g = new GoalState()
    g.weekly = parseInt(this.weeklyText, 10)
    g.monthly = parseInt(this.monthlyText, 10)
    g.streak = this.goal.streak
    await TuceStore.saveGoal(g)
    this.showToast('目标已保存')
  }

  private openSettings(): void {
    this.showSettings = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeSettings(): void {
    this.showSettings = false
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  build() {
    Stack() {
      Column() {
        AppHeader({ title: '我的图册', subtitle: this.isLoggedIn() ? this.currentUsername : '游客模式，训练数据保存在本机' })
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image($r('app.media.cat_flex'))
                .width('100%')
                .height(120)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.lg)
              Text(this.isLoggedIn() ? `你好，${this.currentUsername}` : '游客模式 · 数据保存在本机')
                .fontSize(Theme.type.body)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .width('100%')
                .padding(Theme.space.s4)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0.72)', 1]]
                })
            }
            .width('100%')
            .height(120)

            GoalProgressCard({ progress: this.goalProgress })

            Row({ space: Theme.space.s3 }) {
              AppStatCard({ label: '累计训练', value: `${this.snap.sessions}` }).layoutWeight(1)
              AppStatCard({ label: '坚持天数', value: `${this.snap.streak}` }).layoutWeight(1)
            }
            .width('100%')
            Row({ space: Theme.space.s3 }) {
              AppStatCard({ label: '收藏动作', value: `${this.snap.favs}` }).layoutWeight(1)
              AppStatCard({ label: '训练方案', value: `${this.snap.plans}` }).layoutWeight(1)
            }
            .width('100%')

            AppButton({
              label: '成就墙',
              variant: 'secondary',
              onTap: (): void => { TuceNav.open('achieve', '') }
            })
            Row({ space: Theme.space.s3 }) {
              AppButton({
                label: '收藏夹',
                variant: 'secondary',
                onTap: (): void => { TuceNav.open('favorites', '') }
              }).layoutWeight(1)
              AppButton({
                label: '运动回顾',
                variant: 'secondary',
                onTap: (): void => { TuceNav.open('review', '') }
              }).layoutWeight(1)
            }
            .width('100%')

            Text('我的收藏')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.favMoves, (m: MoveItem) => {
              Text(`${m.category} · ${m.name}`)
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
                .padding(Theme.space.s3)
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.sm)
                .onClick((): void => { TuceNav.open('move', m.id) })
            }, (m: MoveItem) => m.id)

            if (!this.isLoggedIn()) {
              AppButton({ label: '登录 / 注册', variant: 'primary', onTap: (): void => { this.onOpenLogin() } })
            } else {
              AppButton({
                label: '退出登录',
                variant: 'secondary',
                onTap: (): void => { void AuthService.logout().then((): void => { this.onLogout() }) }
              })
            }
            AppButton({
              label: '设置与隐私',
              variant: 'ghost',
              onTap: (): void => { this.openSettings() }
            })
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.showSettings) {
        this.SettingsPanel()
      }
      if (this.showLegal) {
        LegalDocOverlay({ kind: this.legalKind, onClose: (): void => { this.showLegal = false } })
      }
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 16 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Top)
  }

  @Builder
  SettingsPanel() {
    Column({ space: Theme.space.s4 }) {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
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
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX })

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          Row() {
            Text('深色模式')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .layoutWeight(1)
            Toggle({ type: ToggleType.Switch, isOn: this.darkModeOn })
              .onChange((on: boolean): void => { void this.toggleDark(on) })
          }
          .width('100%')

          Text('每周 / 每月训练目标（次）')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().textSecondary)
          TextInput({ text: this.weeklyText, placeholder: '每周次数' })
            .onChange((v: string): void => { this.weeklyText = v })
          TextInput({ text: this.monthlyText, placeholder: '每月次数' })
            .onChange((v: string): void => { this.monthlyText = v })
          AppButton({ label: '保存目标', variant: 'secondary', onTap: (): void => { void this.saveGoals() } })

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
          AppButton({ label: '清除缓存', variant: 'secondary', onTap: (): void => { this.handleClearCache() } })
          AppButton({
            label: this.confirmDelete ? '再点一次确认注销' : '注销账号',
            variant: 'secondary',
            onTap: (): void => { void this.handleDeleteAccount() }
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
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .width('100%')
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
