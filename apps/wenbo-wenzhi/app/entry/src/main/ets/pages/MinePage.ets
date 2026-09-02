import { Theme, ThemeColors } from '../components/design-system/Theme'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { common } from '@kit.AbilityKit'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AuthService } from '../services/AuthService'
import { PrivacyService } from '../services/PrivacyService'
import { VaultStore } from '../services/VaultStore'
import { AskNav } from '../services/AskNav'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { MineAboutPane, MineSettingsPane } from '../components/mine/MinePanels'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '问知'
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @State paintTick: number = 0
  @StorageLink('vaultRefresh') @Watch('onRefresh') vaultRefresh: number = 0
  @State showSettings: boolean = false
  @State showAbout: boolean = false
  @State nickDraft: string = ''
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  @State confirmDelete: boolean = false
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}

  aboutToAppear(): void {
    this.nickDraft = VaultStore.nick()
  }

  onRefresh(): void {
    this.nickDraft = VaultStore.nick()
  }

  private palette(): ThemeColors {
    return Theme.colorOf(this.themeEpoch + this.paintTick)
  }

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2800)
  }

  private async toggleDark(on: boolean): Promise<void> {
    if (Theme.isDark() === on && this.darkModeOn === on) {
      return
    }
    ThemeAppearance.apply(on ? 'dark' : 'light', this.getUIContext().getHostContext() as common.UIAbilityContext)
    this.paintTick += 1
    await VaultStore.setDark(on)
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
    void VaultStore.clearLocalCache()
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

  private async saveNick(): Promise<void> {
    await VaultStore.setNick(this.nickDraft)
    this.showToast('昵称已更新')
  }

  build() {
    Stack() {
      Column() {
        if (this.showSettings) {
          MineSettingsPane({
            confirmDelete: this.confirmDelete,
            onClose: (): void => { this.showSettings = false },
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
          MineAboutPane({ onClose: (): void => { this.showAbout = false } })
        } else {
          AppHeader({ title: '我的', subtitle: this.appName })
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Column({ space: 8 }) {
                Text(this.isLoggedIn() ? this.currentUsername : VaultStore.nick())
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.palette().textPrimary)
                  .width('100%')
                TextInput({ text: this.nickDraft, placeholder: '编辑昵称' })
                  .height(44)
                  .fontSize(Theme.type.body)
                  .fontColor(this.palette().textPrimary)
                  .backgroundColor(this.palette().surfaceSubtle)
                  .onChange((v: string) => { this.nickDraft = v })
                AppButton({
                  label: '保存昵称',
                  variant: 'secondary',
                  onTap: (): void => { void this.saveNick() }
                })
              }
              .width('100%')
              .padding(Theme.space.s5)
              .alignItems(HorizontalAlign.Start)
              .backgroundColor(this.palette().surfaceCard)
              .borderRadius(Theme.radius.card)

              Row() {
                this.StatCell('问答', `${VaultStore.asks()}`)
                this.StatCell('收藏', `${VaultStore.count()}`)
                this.StatCell('连续', `${VaultStore.streakDays()}`)
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.palette().surfaceCard)
              .borderRadius(Theme.radius.card)

              Text('成长中心')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.palette().textPrimary)
                .width('100%')
                .margin({ top: Theme.space.s2 })
              this.MenuRow('学习动态', '按时间回顾提问、收藏与答题', (): void => { AskNav.openLearn('timeline') })
              this.MenuRow('学习回顾', '今日 / 本周 / 本月摘要', (): void => { AskNav.openLearn('review') })
              this.MenuRow('成就墙', '解锁学习里程碑徽章', (): void => { AskNav.openLearn('achievements') })
              this.MenuRow('我的笔记', '新建与管理个人知识笔记', (): void => { AskNav.openLearn('notes') })

              this.MenuRow('知识检索', '按分类与关键词查找', (): void => { AskNav.openLearn('catalog') })
              this.MenuRow('知识挑战', '随机答题测一测', (): void => { AskNav.openChallenge(5) })
              this.MenuRow('提问记录', '再看自己问过的问题', (): void => { AskNav.openLearn('history') })
              this.MenuRow('错题本', '答错的题目再练一次', (): void => { AskNav.openLearn('wrong') })
              this.MenuRow('学习计划', '每日目标与进度', (): void => { AskNav.openLearn('plan') })
              this.MenuRow('成长统计', '阅读、答题与积累', (): void => { AskNav.openLearn('stats') })
              this.MenuRow('知识卡片', '保存的要点卡片', (): void => { AskNav.openLearn('cards') })
              this.MenuRow('求知偏好', '问卷匹配主题', (): void => { AskNav.openDiagnose() })

              this.DarkModeRow()

              this.MenuRow('设置与隐私', '协议 · 撤回 · 注销', (): void => {
                this.confirmDelete = false
                this.showSettings = true
              })
              this.MenuRow('关于', '版本与简介', (): void => { this.showAbout = true })

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
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.palette().surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(this.palette().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(this.palette().brandPrimary)
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
  }

  @Builder
  StatCell(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.palette().brandPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(this.palette().textSecondary)
    }
    .layoutWeight(1)
  }

  @Builder
  DarkModeRow() {
    Row({ space: Theme.space.s3 }) {
      Column({ space: 2 }) {
        Text('深色模式')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.palette().textPrimary)
        Text(this.darkModeOn ? '已开启 · 界面已切换' : '已关闭 · 浅色界面')
          .fontSize(Theme.type.caption)
          .fontColor(this.palette().textSecondary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Toggle({ type: ToggleType.Switch, isOn: this.darkModeOn })
        .selectedColor(this.palette().brandPrimary)
        .onChange((isOn: boolean): void => { void this.toggleDark(isOn) })
    }
    .width('100%')
    .constraintSize({ minHeight: 56 })
    .padding(Theme.space.s4)
    .backgroundColor(this.palette().surfaceCard)
    .borderRadius(Theme.radius.card)
  }

  @Builder
  MenuRow(title: string, sub: string, tap: () => void) {
    Row({ space: Theme.space.s3 }) {
      Column({ space: 2 }) {
        Text(title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.palette().textPrimary)
        Text(sub)
          .fontSize(Theme.type.caption)
          .fontColor(this.palette().textSecondary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
    }
    .width('100%')
    .constraintSize({ minHeight: 48 })
    .padding(Theme.space.s4)
    .backgroundColor(this.palette().surfaceCard)
    .borderRadius(Theme.radius.card)
    .onClick(tap)
  }
}
