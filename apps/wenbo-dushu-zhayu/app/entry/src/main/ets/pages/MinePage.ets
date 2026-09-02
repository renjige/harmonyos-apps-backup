import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AuthService } from '../services/AuthService'
import { PrivacyService } from '../services/PrivacyService'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { common } from '@kit.AbilityKit'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '读书札语'
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @State showSettings: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  onSwitchTab: (index: number) => void = () => {}
  onOpenQuotes: () => void = () => {}
  onOpenOrganize: () => void = () => {}
  onOpenReport: () => void = () => {}
  onOpenCheckin: () => void = () => {}
  onOpenReviews: () => void = () => {}
  onOpenBooklists: () => void = () => {}
  onOpenInspirations: () => void = () => {}
  onOpenMonthly: () => void = () => {}
  onOpenMessages: () => void = () => {}
  onOpenLamp: () => void = () => {}
  onOpenDialogue: () => void = () => {}
  onOpenStudioPlay: () => void = () => {}
  onOpenBookAsk: () => void = () => {}
  onOpenNotes: () => void = () => {}
  onOpenChainTab: () => void = () => {}
  onOpenShelf: () => void = () => {}
  onOpenPlans: () => void = () => {}

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => {
      this.toastText = ''
    }, 2800)
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

  private applyTheme(mode: string): void {
    try {
      const ctx = getContext(this) as common.UIAbilityContext
      ThemeAppearance.apply(mode, ctx)
    } catch {
      ThemeAppearance.apply(mode)
    }
    if (mode === 'dark') {
      this.showToast('已切换深色模式')
      return
    }
    if (mode === 'light') {
      this.showToast('已切换浅色模式')
      return
    }
    this.showToast('已跟随系统外观')
  }

  build() {
    Stack() {
      Column() {
        if (this.showSettings) {
          this.SettingsPanel()
        } else {
          AppHeader({ title: '我的', subtitle: '玩法产出 · 账号与辅助工具' })
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Row({ space: 12 }) {
                Image($r('app.media.app_icon'))
                  .width(56)
                  .height(56)
                  .borderRadius(14)
                  .objectFit(ImageFit.Cover)
                Column({ space: 8 }) {
                  Text(this.isLoggedIn() ? this.currentUsername : '游客')
                    .fontSize(Theme.type.title3)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                  Text(this.isLoggedIn()
                    ? '核心在「书房玩法」三种交互；以下为辅助管理'
                    : '游客可浏览；登录后可完成灯下共读 / 对读札 / 问书三札')
                    .fontSize(Theme.type.footnote)
                    .fontColor(Theme.colors().textSecondary)
                    .width('100%')
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(Theme.space.s5)
              .alignItems(VerticalAlign.Center)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
              .border({ width: 1, color: Theme.colors().strokeHairline })

              Text('核心玩法')
                .fontSize(Theme.type.caption)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
              this.MenuRow('札语链', '三种玩法产出串联（独立 Tab）', 'chart', (): void => { this.onOpenChainTab() })
              this.MenuRow('灯下共读', '计时陪读，结束须写今日一句', 'calendar', (): void => { this.onOpenLamp() })
              this.MenuRow('对读札', '两句金句对照，写下它们为何对话', 'heart', (): void => { this.onOpenDialogue() })
              this.MenuRow('问书三札', '三问结构化反思，不是自由笔记', 'biz', (): void => { this.onOpenBookAsk() })

              Text('辅助工具（非主路径）')
                .fontSize(Theme.type.caption)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
                .margin({ top: Theme.space.s2 })
              this.MenuRow('我的书架', '在读 / 已读 / 想读与进度', 'book', (): void => { this.onOpenShelf() })
              this.MenuRow('阅读计划', '目标与截止日管理', 'calendar', (): void => { this.onOpenPlans() })
              this.MenuRow('阅读札记', '补充札记，非核心玩法', 'biz', (): void => { this.onOpenNotes() })
              this.MenuRow('每日打卡', '连续阅读与打卡天数', 'calendar', (): void => { this.onOpenCheckin() })
              this.MenuRow('金句摘录', '对读札素材库', 'heart', (): void => { this.onOpenQuotes() })
              this.MenuRow('书评记录', '阅读评价与体验', 'photo', (): void => { this.onOpenReviews() })
              this.MenuRow('灵感收藏', '玩法产出归档', 'ai', (): void => { this.onOpenInspirations() })
              this.MenuRow('专题书单', '成长 / 旅行 / 亲子 / 经典', 'biz', (): void => { this.onOpenBooklists() })
              this.MenuRow('标签整理', '自定义标签与检索', 'search', (): void => { this.onOpenOrganize() })
              this.MenuRow('月度回顾', '按月查看阅读总结', 'calendar', (): void => { this.onOpenMonthly() })
              this.MenuRow('阅读统计', '时长、次数与习惯变化', 'chart', (): void => { this.onOpenReport() })
              this.MenuRow('消息中心', '阅读提醒与机构通知', 'message', (): void => { this.onOpenMessages() })
              this.MenuRow('设置与隐私', '协议 · 撤回同意 · 注销', 'chevron', (): void => { this.showSettings = true })

              Column({ space: Theme.space.s3 }) {
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
              .width('100%')
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
  MenuRow(title: string, subtitle: string, icon: string, onTap: () => void) {
    Row({ space: Theme.space.s3 }) {
      Column({ space: 2 }) {
        Text(title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Text(subtitle)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      if (icon === 'book') {
        AppIcon({ name: 'book', iconSize: Theme.icon.sm, color: Theme.colors().brandPrimary })
      } else if (icon === 'heart') {
        AppIcon({ name: 'heart', iconSize: Theme.icon.sm, color: Theme.colors().brandAccent })
      } else if (icon === 'search') {
        AppIcon({ name: 'search', iconSize: Theme.icon.sm, color: Theme.colors().brandPrimary })
      } else if (icon === 'chart') {
        AppIcon({ name: 'chart', iconSize: Theme.icon.sm, color: Theme.colors().brandPrimary })
      } else if (icon === 'calendar') {
        AppIcon({ name: 'calendar', iconSize: Theme.icon.sm, color: Theme.colors().brandPrimary })
      } else if (icon === 'photo') {
        AppIcon({ name: 'photo', iconSize: Theme.icon.sm, color: Theme.colors().brandAccent })
      } else if (icon === 'ai') {
        AppIcon({ name: 'ai', iconSize: Theme.icon.sm, color: Theme.colors().brandAccent })
      } else if (icon === 'biz') {
        AppIcon({ name: 'biz', iconSize: Theme.icon.sm, color: Theme.colors().brandPrimary })
      } else if (icon === 'message') {
        AppIcon({ name: 'message', iconSize: Theme.icon.sm, color: Theme.colors().brandPrimary })
      } else {
        AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
      }
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick((): void => { onTap() })
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
        .onClick((): void => { this.showSettings = false })
        Text('设置与隐私')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX })

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          Text('外观')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          AppButton({
            label: '跟随系统',
            variant: 'secondary',
            onTap: (): void => { this.applyTheme('system') }
          })
          AppButton({
            label: '浅色模式',
            variant: 'secondary',
            onTap: (): void => { this.applyTheme('light') }
          })
          AppButton({
            label: '深色模式',
            variant: 'secondary',
            onTap: (): void => { this.applyTheme('dark') }
          })
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
          Text('应用名称：读书札语')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          Text('运营者：承德锐泓科技信息有限公司')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          Text('个人信息收集清单与第三方共享清单可在协议全文中查阅。')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
          AppButton({
            label: '注销账号',
            variant: 'danger',
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
}
