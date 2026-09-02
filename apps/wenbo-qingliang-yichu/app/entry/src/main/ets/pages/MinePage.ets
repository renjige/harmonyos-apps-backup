import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { AuthService } from '../services/AuthService'
import { PrivacyService } from '../services/PrivacyService'
import { WardrobeLocalStore } from '../services/WardrobeLocalStore'
import { WardrobeSummaryModel } from '../models/WardrobeModels'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { SmartOrganizeOverlay } from '../components/wardrobe/SmartOrganizeOverlay'
import { PreferenceSettingsDialog } from '../components/mine/PreferenceSettingsDialog'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '清凉衣橱'
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth?: () => void

  @State showSettings: boolean = false
  @State showPreferenceDialog: boolean = false
  @State showOrganizeOverlay: boolean = false
  @State showAboutDialog: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  @State summary: WardrobeSummaryModel = new WardrobeSummaryModel()
  @State isDarkMode: boolean = false

  aboutToAppear(): void {
    this.summary = WardrobeLocalStore.getSummary()
    this.isDarkMode = Theme.isDark()
  }

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

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        if (this.showSettings) {
          this.SettingsPanel()
        } else {
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              // 1. Top Header
              Row() {
                Text('我的')
                  .fontSize(Theme.type.title1)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Theme.colors().textPrimary)
                Blank()
                Row() {
                  AppIcon({ name: 'user', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
                }
                .padding(8)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.pill)
              }
              .width('100%')
              .padding({ top: Theme.space.s4 })

              // 2. User Profile Card
              Column({ space: Theme.space.s3 }) {
                Row({ space: Theme.space.s3 }) {
                  // Avatar
                  Stack({ alignContent: Alignment.Center }) {
                    Circle({ width: 56, height: 56 })
                      .fill(Theme.isDark() ? '#1C332D' : '#DDF2EB')
                    AppIcon({ name: 'user', iconSize: 28, color: Theme.colors().brandPrimary })
                  }

                  Column({ space: 4 }) {
                    Text(this.isLoggedIn() ? (this.currentUsername || '清凉生活家') : '清凉生活家 (未登录)')
                      .fontSize(Theme.type.title3)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(Theme.colors().textPrimary)

                    Text(this.isLoggedIn()
                      ? '个人衣橱已开启本地与云端备份'
                      : '本地轻量使用中，登录可同步多设备')
                      .fontSize(Theme.type.caption1)
                      .fontColor(Theme.colors().textSecondary)
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)

                  if (!this.isLoggedIn()) {
                    AppButton({
                      label: '登录 / 注册',
                      variant: 'primary',
                      onTap: () => { this.onOpenLogin() }
                    })
                  }
                }
                .width('100%')

                Divider().color(Theme.colors().strokeHairline)

                // 3 Stats Metrics: 衣物数量 / 穿搭记录 / 常穿颜色
                Row() {
                  this.UserStatCol('衣物数量', `${this.summary.totalItems} 件`)
                  this.UserStatDivider()
                  this.UserStatCol('穿搭记录', `${this.summary.monthlyLooks} 次`)
                  this.UserStatDivider()
                  this.UserStatCol('常穿颜色', this.summary.topColor)
                }
                .width('100%')
                .padding({ top: 4 })
              }
              .width('100%')
              .padding(Theme.space.cardPadding)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .shadow({
                radius: 12,
                color: Theme.isDark() ? 'rgba(0,0,0,0.3)' : 'rgba(10,37,64,0.05)',
                offsetY: 2
              })

              // 3. Wardrobe Management Section (衣橱管理)
              Column({ space: 2 }) {
                this.SectionTitle('衣橱管理')

                this.MenuItemRow('智慧整理', '季节 · 类型 · 颜色 · 闲置提醒', 'sparkle', () => {
                  this.showOrganizeOverlay = true
                })

                this.MenuItemRow('衣橱分类总览', `上装 ${this.summary.tops} · 下装 ${this.summary.bottoms} · 连衣裙 ${this.summary.dresses}`, 'wardrobe', () => {
                  this.showOrganizeOverlay = true
                })
              }
              .width('100%')

              // 4. Preference Settings (偏好设置)
              Column({ space: 2 }) {
                this.SectionTitle('偏好设置')

                this.MenuItemRow('默认穿搭习惯', '默认季节 / 风格 / 场景定制', 'hanger', () => {
                  this.showPreferenceDialog = true
                })
              }
              .width('100%')

              // 5. App & Privacy Settings (应用设置)
              Column({ space: 2 }) {
                this.SectionTitle('应用设置')

                this.MenuItemRow('深色模式', this.isDarkMode ? '已开启深色' : '浅色清新模式', 'weather_sun', () => {
                  this.isDarkMode = !this.isDarkMode
                  Theme.setThemeMode(this.isDarkMode ? 'dark' : 'light')
                  this.showToast(this.isDarkMode ? '已切换至深色模式' : '已切换至浅色模式')
                })

                this.MenuItemRow('设置与隐私', '用户协议 · 隐私政策 · 撤回同意 · 注销', 'alert', () => {
                  this.showSettings = true
                })

                this.MenuItemRow('关于清凉衣橱', '版本 v1.0.0 · 极简轻量生活方式', 'check', () => {
                  this.showAboutDialog = true
                })
              }
              .width('100%')

              // Logout button if logged in
              if (this.isLoggedIn()) {
                AppButton({
                  label: '退出登录',
                  variant: 'secondary',
                  onTap: () => {
                    void AuthService.logout()
                    this.onLogout()
                    this.showToast('已退出登录')
                  }
                })
                .width('100%')
                .margin({ top: Theme.space.s2 })
              }
            }
            .padding({
              left: Theme.space.pagePadding,
              right: Theme.space.pagePadding,
              bottom: 40
            })
          }
          .layoutWeight(1)
          .width('100%')
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfaceBackground)

      // Settings & Privacy Second-level Panel
      // Preference dialog
      if (this.showPreferenceDialog) {
        PreferenceSettingsDialog({
          onClose: () => { this.showPreferenceDialog = false },
          onSave: () => { this.showToast('偏好设置已保存') }
        })
      }

      // Organize Overlay
      if (this.showOrganizeOverlay) {
        SmartOrganizeOverlay({
          onClose: () => { this.showOrganizeOverlay = false }
        })
      }

      // Legal Overlay
      if (this.showLegal) {
        LegalDocOverlay({
          kind: this.legalKind,
          appName: this.appName,
          onClose: () => { this.showLegal = false }
        })
      }

      // About Dialog
      if (this.showAboutDialog) {
        Stack({ alignContent: Alignment.Center }) {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor(Theme.colors().surfaceMask)
            .onClick(() => { this.showAboutDialog = false })

          Column({ space: Theme.space.s3 }) {
            Circle({ width: 56, height: 56 })
              .fill(Theme.isDark() ? '#1C332D' : '#DDF2EB')
            Text(this.appName)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textPrimary)

            Text('版本 1.0.0 (HarmonyOS NEXT 商业级)')
              .fontSize(Theme.type.caption1)
              .fontColor(Theme.colors().brandSecondary)

            Text('让每天穿什么变得简单又有条理。\n极简衣橱管理，支持离线优先、智慧整理与穿搭日历。')
              .fontSize(Theme.type.subheadline)
              .fontColor(Theme.colors().textSecondary)
              .textAlign(TextAlign.Center)
              .lineHeight(20)

            Text('运营者：魏文波')
              .fontSize(Theme.type.caption2)
              .fontColor(Theme.colors().textTertiary)
              .margin({ top: 4 })

            AppButton({
              label: '关闭',
              variant: 'primary',
              onTap: () => { this.showAboutDialog = false }
            })
            .width('100%')
            .margin({ top: Theme.space.s2 })
          }
          .width('86%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .shadow({ radius: 24, color: 'rgba(0,0,0,0.25)', offsetY: 4 })
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .height('100%')
      }

      // Top Toast (Stack Top zIndex)
      if (this.toastText.length > 0) {
        Column() {
          Row({ space: 8 }) {
            AppIcon({ name: 'check', iconSize: 16, color: '#FFFFFF' })
            Text(this.toastText)
              .fontSize(Theme.type.subheadline)
              .fontColor('#FFFFFF')
          }
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(31,41,39,0.92)')
          .borderRadius(Theme.radius.pill)
          .shadow({ radius: 12, color: 'rgba(0,0,0,0.25)', offsetY: 4 })
        }
        .width('100%')
        .padding({ top: 30 })
        .alignItems(HorizontalAlign.Center)
        .hitTestBehavior(HitTestMode.None)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private SectionTitle(title: string) {
    Text(title)
      .fontSize(Theme.type.caption1)
      .fontWeight(FontWeight.Bold)
      .fontColor(Theme.colors().brandSecondary)
      .margin({ left: 4, bottom: 4 })
      .width('100%')
  }

  @Builder
  private MenuItemRow(title: string, subtitle: string, iconName: AppIconName, onTap: () => void) {
    Row({ space: Theme.space.s3 }) {
      AppIcon({ name: iconName, iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })

      Column({ space: 2 }) {
        Text(title)
          .fontSize(Theme.type.callout)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Text(subtitle)
          .fontSize(Theme.type.caption2)
          .fontColor(Theme.colors().textTertiary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      AppIcon({ name: 'chevron', iconSize: 14, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .shadow({
      radius: 6,
      color: Theme.isDark() ? 'rgba(0,0,0,0.2)' : 'rgba(0,0,0,0.02)',
      offsetY: 1
    })
    .margin({ bottom: 6 })
    .onClick(onTap)
  }

  @Builder
  private UserStatCol(label: string, value: string) {
    Column({ space: 2 }) {
      Text(label)
        .fontSize(Theme.type.caption2)
        .fontColor(Theme.colors().textTertiary)
      Text(value)
        .fontSize(Theme.type.subheadline)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().textPrimary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private UserStatDivider() {
    Divider()
      .vertical(true)
      .height(18)
      .color(Theme.colors().strokeHairline)
  }

  @Builder
  private SettingsPanel() {
    Column({ space: Theme.space.s4 }) {
      Row() {
        Row({ space: 4 }) {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          Text('设置与隐私')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
        }
        .onClick(() => { this.showSettings = false })

        Blank()

        Row() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
        }
        .padding(8)
        .onClick(() => { this.showSettings = false })
      }
      .width('100%')
      .padding({ top: Theme.space.s4 })

      Column({ space: Theme.space.s3 }) {
        this.SettingsActionRow('用户协议', '阅读清凉衣橱完整用户服务协议', () => {
          this.legalKind = 'agreement'
          this.showLegal = true
        })

        this.SettingsActionRow('隐私政策', '阅读个人信息处理与隐私保护说明', () => {
          this.legalKind = 'privacy'
          this.showLegal = true
        })
      }
      .width('100%')

      Column({ space: Theme.space.s3 }) {
        Row() {
          AppButton({
            label: '撤回隐私同意',
            variant: 'secondary',
            onTap: (): void => { void this.handleRevokePrivacy() }
          })
        }
        .width('100%')
        .onClick((): void => { void this.handleRevokePrivacy() })

        Row() {
          AppButton({
            label: '注销账号',
            variant: 'danger',
            onTap: (): void => { void this.handleDeleteAccount() }
          })
        }
        .width('100%')
        .onClick((): void => { void this.handleDeleteAccount() })
      }
      .width('100%')
      .margin({ top: Theme.space.s4 })
    }
    .width('100%')
    .height('100%')
    .padding({
      left: Theme.space.pagePadding,
      right: Theme.space.pagePadding,
      bottom: Theme.space.s6
    })
  }

  @Builder
  private SettingsActionRow(title: string, hint: string, onTap: () => void) {
    Row() {
      Column({ space: 2 }) {
        Text(title)
          .fontSize(Theme.type.callout)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Text(hint)
          .fontSize(Theme.type.caption2)
          .fontColor(Theme.colors().textTertiary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick(onTap)
  }
}
