import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AuthService } from '../services/AuthService'
import { PrivacyService } from '../services/PrivacyService'
import { MathBizService } from '../services/MathBizService'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { SettingsOverlay } from '../components/math/SettingsOverlay'
import { MathLocalStore } from '../services/MathLocalStore'
import { MathRefresh } from '../services/MathRefresh'
import { MathSettings } from '../models/MathModels'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '童趣算坊'
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @State showSettings: boolean = false
  @State showAbout: boolean = false
  @State showPrivacy: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  @State stars: number = 0
  @State streak: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  private reload(): void {
    const g = MathBizService.growth()
    this.stars = g.stars
    this.streak = g.streak
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
    this.showPrivacy = false
    this.showToast('已撤回隐私同意，再次登录须重新勾选协议')
  }

  private async handleDeleteAccount(): Promise<void> {
    const ok = await PrivacyService.deleteAccount()
    if (ok) {
      await AuthService.logout()
      this.showSettings = false
      this.showPrivacy = false
      this.onLogout()
      this.showToast('账号已注销')
      return
    }
    this.showToast('注销失败，请稍后重试')
  }

  private diffHint(d: string): string {
    if (d === 'hard') {
      return '进阶'
    }
    if (d === 'medium') {
      return '熟练'
    }
    return '入门'
  }

  private gradeHint(g: string): string {
    if (g === 'age35') {
      return '3-5岁'
    }
    if (g === 'age912' || g === 'g3') {
      return '9-12岁'
    }
    return '6-8岁'
  }

  build() {
    Stack() {
      if (this.showSettings) {
        SettingsOverlay({
          settings: MathLocalStore.settings(),
          onClose: () => { this.showSettings = false },
          onChange: (next: MathSettings) => {
            void MathBizService.saveSettings(next).then(() => {
              const tick = (AppStorage.get<number>('mathSettingsTick') ?? 0) + 1
              AppStorage.setOrCreate('mathSettingsTick', tick)
              this.showToast(`已更新：每日 ${next.dailyCount} 题 · ${this.diffHint(next.difficulty)} · ${this.gradeHint(next.grade)}`)
            })
          },
          onClear: (): void => {
            void MathBizService.clearAll().then(() => {
              MathRefresh.bump()
              this.reload()
              this.showToast('本地练习记录已清除')
            })
          }
        })
      } else {
        Column() {
          Text('我的')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              top: Theme.space.pageY
            })
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Column({ space: Theme.space.s2 }) {
                Text(this.appName)
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Text(`累计 ${this.stars} 星 · 连续 ${this.streak} 天`)
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s5)
              .alignItems(HorizontalAlign.Start)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)

              this.menuRow('设置', '题量、难度、声音与数据', () => { this.showSettings = true })
              this.menuRow('隐私政策', '查看全文', () => {
                this.legalKind = 'privacy'
                this.showLegal = true
              })
              this.menuRow('用户协议', '查看全文', () => {
                this.legalKind = 'agreement'
                this.showLegal = true
              })
              this.menuRow('关于童趣算坊', '版本 1.0.6', () => { this.showAbout = true })
              this.menuRow('设置与隐私', '协议 · 撤回 · 注销', () => { this.showPrivacy = true })
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s10,
              top: Theme.space.s3
            })
            .constraintSize({ maxWidth: 720 })
            .width('100%')
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      }

      if (this.showAbout) {
        this.AboutPanel()
      }
      if (this.showPrivacy) {
        this.PrivacyPanel()
      }
      if (this.showLegal) {
        LegalDocOverlay({
          kind: this.legalKind,
          onClose: () => { this.showLegal = false }
        })
      }
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('#2563EB')
          .borderRadius(Theme.radius.pill)
          .margin({ top: 48 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  menuRow(title: string, hint: string, tap: () => void) {
    Row() {
      Column({ space: Theme.space.s1 }) {
        Text(title)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        Text(hint)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
      }
      .layoutWeight(1)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .onClick(tap)
  }

  @Builder
  AboutPanel() {
    Column() {
      Row() {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick(() => { this.showAbout = false })
        Text('关于童趣算坊')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.s2, top: Theme.space.s2 })
      Column({ space: Theme.space.s3 }) {
        Text('童趣算坊')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        Text('快乐计算，聪明成长')
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        Text('版本 1.0.6')
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        Text('面向儿童的数学学习工作台。按年龄练习、家长出题、周目标、打卡与时间轴。不承诺提高考试成绩。')
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        Text('运营者：魏文波')
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
      }
      .padding(Theme.space.s6)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  PrivacyPanel() {
    Column() {
      Row() {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick(() => { this.showPrivacy = false })
        Text('设置与隐私')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.s2, top: Theme.space.s2 })
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          this.menuRow('查看《用户协议》', '打开全文', () => {
            this.legalKind = 'agreement'
            this.showLegal = true
          })
          this.menuRow('查看《隐私政策》', '打开全文', () => {
            this.legalKind = 'privacy'
            this.showLegal = true
          })
          if (!this.isLoggedIn()) {
            AppButton({ label: '登录或注册（可选）', variant: 'ghost', onTap: () => this.onOpenLogin() })
          } else {
            Text(`已登录：${this.currentUsername}`)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            AppButton({
              label: '退出登录',
              variant: 'secondary',
              onTap: (): void => { void AuthService.logout().then(() => this.onLogout()) }
            })
          }
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
            label: '注销账号',
            variant: 'ghost',
            onTap: (): void => { void this.handleDeleteAccount() }
          })
        }
        .padding(Theme.space.s5)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
