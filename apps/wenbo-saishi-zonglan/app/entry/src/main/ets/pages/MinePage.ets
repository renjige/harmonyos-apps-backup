import { Theme, ThemeColors, ColorMode } from '../components/design-system/Theme'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { common } from '@kit.AbilityKit'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AuthService } from '../services/AuthService'
import { PrivacyService } from '../services/PrivacyService'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'

@Component
export struct MinePage {
  @Prop appName: string = '赛事纵览'
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('themeColorMode') themeColorMode: string = 'light'
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State showSettings: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onOpenMessages: () => void = () => {}
  onOpenCalendar: () => void = () => {}
  onOpenReminderSettings: () => void = () => {}
  onOpenGrowth: () => void = () => {}

  private isDarkMode(): boolean {
    return this.themeColorMode === 'dark'
  }

  private palette(): ThemeColors {
    return Theme.palette(this.isDarkMode())
  }

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout((): void => {
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

  private handleDarkModeToggle(enabled: boolean): void {
    const mode: ColorMode = enabled ? 'dark' : 'light'
    ThemeAppearance.apply(mode, this.getUIContext().getHostContext() as common.UIAbilityContext)
  }

  @Builder
  MenuRow(title: string, subtitle: string, onTap: () => void) {
    Row({ space: Theme.space.s3 }) {
      Column({ space: 2 }) {
        Text(title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.palette().textPrimary)
        Text(subtitle)
          .fontSize(Theme.type.caption)
          .fontColor(this.palette().textTertiary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: this.palette().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.palette().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: this.palette().strokeHairline })
    .onClick((): void => onTap())
  }

  build() {
    Stack() {
      Column() {
        if (this.showSettings) {
          this.SettingsPanel()
        } else {
          AppHeader({ title: '我的', subtitle: this.appName })
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Column({ space: 8 }) {
                Text(this.isLoggedIn() ? this.currentUsername : '游客')
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.palette().textPrimary)
                  .width('100%')
                Text(this.isLoggedIn()
                  ? '账号已登录 · 关注与提醒将同步到云端'
                  : '游客可浏览赛事；关注与提醒需登录')
                  .fontSize(Theme.type.footnote)
                  .fontColor(this.palette().textSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s5)
              .alignItems(HorizontalAlign.Start)
              .backgroundColor(this.palette().surfaceCard)
              .borderRadius(Theme.radius.card)
              .border({ width: 1, color: this.palette().strokeHairline })

              this.MenuRow('赛事日历', '按月查看比赛安排', (): void => { this.onOpenCalendar() })
              this.MenuRow('观赛数据中心', '统计 · 成就 · 时间轴 · 周回顾', (): void => { this.onOpenGrowth() })
              this.MenuRow('消息中心', '赛事通知与提醒', (): void => { this.onOpenMessages() })
              this.MenuRow('提醒设置', '默认提前量与通知开关', (): void => { this.onOpenReminderSettings() })

              Row({ space: Theme.space.s3 }) {
                Column({ space: 2 }) {
                  Text('竞技深色模式')
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.palette().textPrimary)
                  Text('更适合夜间查看赛程')
                    .fontSize(Theme.type.caption)
                    .fontColor(this.palette().textTertiary)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                Toggle({ type: ToggleType.Switch, isOn: this.isDarkMode() })
                  .onChange((v: boolean): void => { this.handleDarkModeToggle(v) })
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.palette().surfaceCard)
              .borderRadius(Theme.radius.xl)
              .border({ width: 1, color: this.palette().strokeHairline })

              this.MenuRow('设置与隐私', '协议 · 撤回同意 · 注销', (): void => { this.showSettings = true })

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
  SettingsPanel() {
    Column({ space: Theme.space.s4 }) {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: this.palette().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { this.showSettings = false })
        Text('设置与隐私')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.palette().textPrimary)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX })

      Scroll() {
        Column({ space: Theme.space.s3 }) {
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
          Text('个人信息收集清单 · 第三方共享清单见 store/ 上架资料')
            .fontSize(Theme.type.footnote)
            .fontColor(this.palette().textTertiary)
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
    .backgroundColor(this.palette().surfacePage)
  }
}
