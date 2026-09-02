import { Theme } from '../components/design-system/Theme'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { AuthService } from '../services/AuthService'
import { PrivacyService } from '../services/PrivacyService'
import { StudyStore } from '../services/StudyStore'
import { StudySettings } from '../models/StudyModels'
import { MineQuickRecord } from '../components/study/MineQuickRecord'

@Component
export struct MinePage {
  @Prop appName: string = '学见'
  @Prop @Watch('onReloadTokenChange') reloadToken: number = 0
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('xuejianDark') xuejianDark: boolean = false
  @StorageLink('studyDataEpoch') @Watch('onDataEpoch') studyDataEpoch: number = 0
  @State showSettings: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  @State confirmDelete: boolean = false
  @State nickname: string = '学习者'
  @State goalText: string = '90'
  @State darkMode: boolean = false
  @State todayMin: number = 0
  @State cardCount: number = 0
  @State noteCount: number = 0
  @State showAbout: boolean = false
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onOpenToday: () => void = () => {}
  onNewNote: () => void = () => {}
  onNewCard: () => void = () => {}
  onOpenTasks: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  onReloadTokenChange(): void {
    void this.load()
  }

  onDataEpoch(): void {
    void this.load()
  }

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
  }

  private async load(): Promise<void> {
    const s: StudySettings = await StudyStore.loadSettings()
    this.nickname = s.nickname
    this.goalText = `${s.dailyGoalMinutes}`
    this.darkMode = Theme.isDark()
    const sessions = await StudyStore.loadSessions()
    this.todayMin = StudyStore.todayMinutes(sessions)
    this.cardCount = (await StudyStore.loadCards()).length
    this.noteCount = (await StudyStore.loadNotes()).length
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

  private async saveProfile(): Promise<void> {
    const s = new StudySettings()
    s.nickname = this.nickname.trim().length > 0 ? this.nickname.trim() : '学习者'
    const g = Number.parseInt(this.goalText, 10)
    s.dailyGoalMinutes = (g !== g || g < 10) ? 90 : g
    s.reminderHour = 21
    await StudyStore.saveSettings(s)
    this.nickname = s.nickname
    this.goalText = `${s.dailyGoalMinutes}`
    this.showToast('学习目标已保存')
  }

  private ink(): string {
    return (this.xuejianDark || Theme.isDark()) ? '#F8FAFC' : '#0F172A'
  }

  private muted(): string {
    return Theme.bodyMuted()
  }

  private async toggleDark(): Promise<void> {
    const next = !Theme.isDark()
    this.darkMode = next
    try {
      ThemeAppearance.apply(next ? 'dark' : 'light', this.getUIContext().getHostContext())
    } catch {
      ThemeAppearance.apply(next ? 'dark' : 'light')
    }
    await StudyStore.saveDark(next)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        if (this.showSettings) {
          this.SettingsPanel()
        } else if (this.showAbout) {
          this.AboutPanel()
        } else {
          this.MainPanel()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.showLegal) {
        LegalDocOverlay({
          kind: this.legalKind,
          onClose: (): void => { this.showLegal = false }
        })
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .zIndex(20)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding(12)
          .backgroundColor('#1A2A4A')
          .borderRadius(12)
          .margin({ top: 18 })
          .constraintSize({ maxWidth: '86%' })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  MainPanel() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Row({ space: 12 }) {
          Column() {
            AppIcon({ name: 'user', iconSize: 28, color: '#FFFFFF' })
          }
          .width(56)
          .height(56)
          .justifyContent(FlexAlign.Center)
          .borderRadius(28)
          .linearGradient({
            angle: 135,
            colors: [['#1A2A4A', 0], ['#F5A623', 1]]
          })
          Column({ space: 4 }) {
            Text(this.isLoggedIn() ? this.currentUsername : this.nickname)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.ink())
            Text(this.isLoggedIn() ? '已登录 · 学见' : '游客也可以完成本机学习')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.muted())
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }
        .width('100%')

        MineQuickRecord({
          onOpenToday: (): void => { this.onOpenToday() },
          onToast: (msg: string): void => { this.showToast(msg) }
        })

        this.MenuRow('clock', '今日待学清单', '勾选今天要完成的事', (): void => { this.onOpenTasks() })

        if (!this.isLoggedIn()) {
          AppButton({ label: '登录 / 注册', onTap: (): void => { this.onOpenLogin() } })
        } else {
          AppButton({
            label: '退出登录',
            variant: 'secondary',
            onTap: (): void => {
              void AuthService.logout()
              this.onLogout()
            }
          })
        }

        this.MenuRow('gear', '设置与隐私', '协议 · 撤回 · 注销', (): void => { this.showSettings = true })
        this.MenuRow('clock', '每日目标', '目标时长与昵称', (): void => { this.showSettings = true })
        this.MenuRow('book', '关于学见', '版本 1.0.5', (): void => { this.showAbout = true })
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s8
      })
    }
    .layoutWeight(1)
  }

  @Builder
  MiniStat(label: string, value: string, hint: string, tap: () => void) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.subtitleM)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.ink())
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(this.ink())
      Text(hint)
        .fontSize(Theme.type.caption)
        .fontColor(this.muted())
    }
    .layoutWeight(1)
    .padding(12)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(14)
    .constraintSize({ minHeight: 48 })
    .onClick(tap)
  }

  @Builder
  MenuRow(icon: string, title: string, sub: string, tap: () => void) {
    Row({ space: 12 }) {
      Column() {
        AppIcon({
          name: icon === 'gear' ? 'gear' : (icon === 'clock' ? 'clock' : 'book'),
          iconSize: 20,
          color: Theme.colors().brandPrimary
        })
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(12)
      Column({ space: 2 }) {
        Text(title)
          .fontSize(Theme.type.body)
          .fontColor(this.ink())
        Text(sub)
          .fontSize(Theme.type.caption)
          .fontColor(this.muted())
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      AppIcon({ name: 'chevron', iconSize: 16, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(14)
    .constraintSize({ minHeight: 48 })
    .onClick(tap)
  }

  @Builder
  AboutPanel() {
    Column({ space: Theme.space.s4 }) {
      Row() {
        Text('返回')
          .fontSize(Theme.type.body)
          .fontColor(this.ink())
          .constraintSize({ minHeight: 44 })
          .onClick((): void => { this.showAbout = false })
      }
      .width('100%')
      Text('关于学见')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.ink())
        .width('100%')
      Text('版本 1.0.5')
        .fontSize(Theme.type.bodyS)
        .fontColor(this.muted())
        .width('100%')
      Text('学见是智慧学习助手。用专注计时、笔记、知识卡片翻转复习、今日待学与学习轨迹，让每一次学习都被看见。不含支付，不提供生成式对话。')
        .fontSize(Theme.type.body)
        .fontColor(this.ink())
        .width('100%')
    }
    .padding(Theme.space.pageX)
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  SettingsPanel() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Row() {
        Text('返回')
          .fontSize(Theme.type.body)
          .fontColor(this.ink())
          .constraintSize({ minHeight: 44 })
          .onClick((): void => { this.showSettings = false })
      }
      .width('100%')
        Text('设置与隐私')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.ink())
          .width('100%')

        Text('每日目标')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.ink())
          .width('100%')
        TextInput({ text: this.nickname, placeholder: '昵称' })
          .width('100%')
          .height(44)
          .fontColor(Theme.inputInk())
          .placeholderColor(Theme.inputHint())
          .backgroundColor(Theme.inputFill())
          .border({ width: 1, color: '#CBD5E1' })
          .borderRadius(12)
          .onChange((v: string) => { this.nickname = v })
        TextInput({ text: this.goalText, placeholder: '每日目标分钟' })
          .width('100%')
          .height(44)
          .fontColor(Theme.inputInk())
          .placeholderColor(Theme.inputHint())
          .backgroundColor(Theme.inputFill())
          .border({ width: 1, color: '#CBD5E1' })
          .borderRadius(12)
          .onChange((v: string) => { this.goalText = v })
        AppButton({ label: '保存学习目标', onTap: (): void => { void this.saveProfile() } })

        Row() {
          Text(this.darkMode ? '深色模式：开' : '深色模式：关')
            .fontSize(Theme.type.body)
            .fontColor(this.ink())
            .layoutWeight(1)
          AppButton({
            label: '切换',
            variant: 'secondary',
            onTap: (): void => { void this.toggleDark() }
          })
        }
        .width('100%')
        .constraintSize({ minHeight: 48 })
        .onClick((): void => { void this.toggleDark() })

        Text('查看《用户协议》')
          .fontSize(Theme.type.body)
          .fontColor(this.ink())
          .constraintSize({ minHeight: 44 })
          .onClick((): void => {
            this.legalKind = 'agreement'
            this.showLegal = true
          })
          .width('100%')
        Text('查看《隐私政策》')
          .fontSize(Theme.type.body)
          .fontColor(this.ink())
          .constraintSize({ minHeight: 44 })
          .onClick((): void => {
            this.legalKind = 'privacy'
            this.showLegal = true
          })
          .width('100%')

        Row() {
          AppButton({
            label: '撤回隐私同意',
            variant: 'secondary',
            onTap: (): void => { void this.handleRevokePrivacy() }
          })
        }
        .width('100%')
        .onClick((): void => { void this.handleRevokePrivacy() })

        AppButton({ label: '清除缓存', variant: 'ghost', onTap: (): void => { this.handleClearCache() } })
        AppButton({
          label: '注销账号',
          variant: 'danger',
          onTap: (): void => { void this.handleDeleteAccount() }
        })
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s10
      })
      .backgroundColor((this.xuejianDark || Theme.isDark()) ? '#1C1C1E' : '#F8F6F3')
    }
    .layoutWeight(1)
  }
}
