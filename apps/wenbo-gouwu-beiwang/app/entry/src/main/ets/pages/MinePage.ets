import { Theme } from '../components/design-system/Theme'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AuthService } from '../services/AuthService'
import { PrivacyService } from '../services/PrivacyService'
import { ShoppingLocalStore } from '../services/ShoppingLocalStore'
import { ShoppingReminder } from '../models/ShoppingModels'
import { ShoppingService } from '../services/ShoppingService'
import { ShoppingNotifyService } from '../services/ShoppingNotifyService'
import { ShoppingStatsService, ShoppingInsight } from '../services/ShoppingStatsService'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { AboutOverlay } from '../components/shop/AboutOverlay'
import { BrandIdentity } from '../config/BrandIdentity'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = BrandIdentity.appName()
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('notifyEnabled') notifyEnabled: boolean = true
  @StorageLink('appearance') appearance: string = 'system'
  @State showSettings: boolean = false
  @State showReminders: boolean = false
  @State showAppearance: boolean = false
  @State reminders: ShoppingReminder[] = []
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State showAbout: boolean = false
  @State toastText: string = ''
  @State insight: ShoppingInsight = new ShoppingInsight()
  @Prop @Watch('onRefresh') refreshToken: number = 0
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onOpenLists: () => void = () => {}
  onOpenTemplates: () => void = () => {}
  onOpenVerify: () => void = () => {}
  onOpenHabit: () => void = () => {}
  onOpenAisle: () => void = () => {}
  onOpenLibrary: () => void = () => {}
  onOpenHistory: () => void = () => {}
  onOpenSpend: () => void = () => {}
  onOpenMessages: () => void = () => {}

  aboutToAppear(): void {
    this.insight = ShoppingStatsService.insight()
  }

  onRefresh(): void {
    this.insight = ShoppingStatsService.insight()
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
    this.showToast('已撤回隐私同意，再次登录须重新勾选协议')
  }

  private async handleDeleteAccount(): Promise<void> {
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

  private async openReminders(): Promise<void> {
    this.reminders = await ShoppingService.reminders()
    this.showReminders = true
  }

  private pickAppearance(mode: string): void {
    ThemeAppearance.apply(mode)
    void ShoppingLocalStore.setAppearance(mode)
  }

  build() {
    Stack() {
      Column() {
        if (this.showSettings) {
          this.SettingsPanel()
        } else if (this.showReminders) {
          this.RemindersPanel()
        } else if (this.showAppearance) {
          this.AppearancePanel()
        } else {
          AppHeader({ title: '我的', subtitle: this.appName })
          Scroll() {
            Column({ space: Theme.space.s3 }) {
              Column({ space: 8 }) {
                Text(BrandIdentity.appName())
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Theme.paint(this.themeEpoch).textPrimary)
                  .width('100%')
                Text(`开发者：${BrandIdentity.developer()}`)
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.paint(this.themeEpoch).textSecondary)
                  .width('100%')
                Text(this.isLoggedIn() ? `${this.currentUsername} · 清单将同步到云端` : '游客 · 清单保存在本机，登录后可同步')
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.paint(this.themeEpoch).textSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s5)
              .alignItems(HorizontalAlign.Start)
              .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
              .borderRadius(Theme.radius.xl)

              Row({ space: 10 }) {
                this.MiniStat('清单', `${ShoppingService.weekStats().listCount}`)
                this.MiniStat('已完成', `${ShoppingService.weekStats().doneCount}`)
                this.MiniStat('本周勾选', `${this.insight.weekChecked}`)
              }
              .width('100%')

              this.MenuRow('采购通知', '机构提醒与补货通知', () => this.onOpenMessages())
              this.MenuRow('出门核对', `还有 ${ShoppingService.weekStats().remainCount} 项待购`, () => this.onOpenVerify())
              this.MenuRow('常购物品库', '保存常买商品，一点加入清单', () => this.onOpenLibrary())
              this.MenuRow('购物历史', '已完成清单，一键再买一次', () => this.onOpenHistory())
              this.MenuRow('花费统计', '预估、实付、分类与常购', () => this.onOpenSpend())
              this.MenuRow('卖场路线', '按超市动线排列未购项', () => this.onOpenAisle())
              this.MenuRow('采购习惯诊断', '3 分钟问卷 + 可执行建议', () => this.onOpenHabit())
              this.MenuRow('我的清单', '查看进行中与已完成的清单', () => this.onOpenLists())
              this.MenuRow('我的模板', '家庭采购、日常用品等一键创建', () => this.onOpenTemplates())
              this.MenuRow('智慧提醒', '今天、明天或自定义时间', () => { void this.openReminders() })
              this.MenuRow('通知设置', this.notifyEnabled ? '已开启系统通知提醒' : '已关闭提醒', () => {
                const next = !this.notifyEnabled
                void ShoppingLocalStore.setNotifyEnabled(next)
                if (next) {
                  void ShoppingNotifyService.ensurePermission()
                  void ShoppingService.rescheduleReminders()
                }
                this.showToast(next ? '已开启提醒' : '已关闭提醒')
              })
              this.MenuRow('外观设置', '浅色 / 深色 / 跟随系统', () => { this.showAppearance = true })
              this.MenuRow(`关于${BrandIdentity.appName()}`, `开发者 ${BrandIdentity.developer()} · 版本 ${BrandIdentity.version()}`, () => {
                this.showAbout = true
              })
              this.MenuRow('用户协议', '查看全文', () => {
                this.legalKind = 'agreement'
                this.showLegal = true
              })
              this.MenuRow('隐私政策', '查看全文', () => {
                this.legalKind = 'privacy'
                this.showLegal = true
              })
              this.MenuRow('设置与隐私', '协议 · 撤回同意 · 注销', () => { this.showSettings = true })

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
                AppButton({ label: '登录 / 注册', onTap: (): void => { this.onOpenLogin() } })
              }
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.paint(this.themeEpoch).surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.paint(this.themeEpoch).brandPrimary)
          .borderRadius(Theme.radius.pill)
          .position({ x: Theme.space.pageX, y: Theme.space.s6 })
          .zIndex(20)
      }
      if (this.showLegal) {
        LegalDocOverlay({ kind: this.legalKind, onClose: () => { this.showLegal = false } })
          .width('100%')
          .height('100%')
          .zIndex(16)
      }
      if (this.showAbout) {
        AboutOverlay({ onClose: () => { this.showAbout = false } })
          .width('100%')
          .height('100%')
          .zIndex(16)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  MiniStat(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.paint(this.themeEpoch).brandPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.paint(this.themeEpoch).textSecondary)
    }
    .layoutWeight(1)
    .padding({ top: 12, bottom: 12 })
    .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
    .borderRadius(Theme.radius.lg)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  MenuRow(title: string, caption: string, action: () => void) {
    Row() {
      Column({ space: 2 }) {
        Text(title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.paint(this.themeEpoch).textPrimary)
        Text(caption)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.paint(this.themeEpoch).textSecondary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.paint(this.themeEpoch).textTertiary })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
    .borderRadius(Theme.radius.xl)
    .onClick(() => action())
  }

  @Builder
  SettingsPanel() {
    Column({ space: Theme.space.s4 }) {
      this.BackRow('设置与隐私', () => { this.showSettings = false })
      Text(BrandIdentity.aboutLine())
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.paint(this.themeEpoch).textSecondary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      Column({ space: Theme.space.s3 }) {
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
        AppButton({ label: '注销账号', variant: 'danger', onTap: (): void => { void this.handleDeleteAccount() } })
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
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  RemindersPanel() {
    Column({ space: Theme.space.s4 }) {
      this.BackRow('智慧提醒', () => { this.showReminders = false })
      Scroll() {
        Column({ space: 10 }) {
          if (this.reminders.length === 0) {
            Text('还没有提醒。在清单详情里可以设置今天或明天。')
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.paint(this.themeEpoch).textSecondary)
              .width('100%')
          }
          ForEach(this.reminders, (r: ShoppingReminder) => {
            Column({ space: 4 }) {
              Text(r.title)
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.paint(this.themeEpoch).textPrimary)
                .width('100%')
              Text(r.remindAt)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.paint(this.themeEpoch).textSecondary)
                .width('100%')
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
            .borderRadius(Theme.radius.xl)
          }, (r: ShoppingReminder) => r.id)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  AppearancePanel() {
    Column({ space: Theme.space.s4 }) {
      this.BackRow('外观设置', () => { this.showAppearance = false })
      Text('选择后立即生效。跟随系统时，会随手机深色模式自动切换。')
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.paint(this.themeEpoch).textSecondary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      Column({ space: 10 }) {
        this.AppearChip('浅色', 'light')
        this.AppearChip('深色', 'dark')
        this.AppearChip('跟随系统', 'system')
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  AppearChip(label: string, mode: string) {
    Text(label)
      .fontSize(Theme.type.body)
      .fontColor(this.appearance === mode ? Theme.paint(this.themeEpoch).brandOnPrimary : Theme.paint(this.themeEpoch).textPrimary)
      .width('100%')
      .padding(16)
      .backgroundColor(this.appearance === mode ? Theme.paint(this.themeEpoch).brandPrimary :
        (Theme.paint(this.themeEpoch).surfaceCard))
      .borderRadius(Theme.radius.xl)
      .onClick((): void => {
        this.pickAppearance(mode)
      })
  }

  @Builder
  BackRow(title: string, back: () => void) {
    Row({ space: 8 }) {
      Text('返回')
        .fontSize(Theme.type.subhead)
        .fontColor(Theme.paint(this.themeEpoch).brandPrimary)
        .onClick(() => back())
      Text(title)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.paint(this.themeEpoch).textPrimary)
    }
    .width('100%')
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 12 })
  }
}
