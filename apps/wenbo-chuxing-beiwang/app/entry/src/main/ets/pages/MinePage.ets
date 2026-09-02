import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { HomeStatCard } from '../components/travel/TravelCards'
import { AuthService } from '../services/AuthService'
import { PrivacyService } from '../services/PrivacyService'
import { TravelGrowthService } from '../services/TravelGrowthService'
import { TravelService } from '../services/TravelService'
import { TravelStatsSnapshot } from '../models/TravelGrowthModels'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { AboutOverlay } from '../components/travel/AboutOverlay'
import { BrandIdentity } from '../config/BrandIdentity'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '出行备忘'
  @Prop @Watch('onEpochChange') dataEpoch: number = 0
  @State stats: TravelStatsSnapshot = new TravelStatsSnapshot()
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @State showSettings: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State showAbout: boolean = false
  @State toastText: string = ''
  onOpenLogin: () => void = () => {}
  onOpenTrips: () => void = () => {}
  onOpenPrepare: () => void = () => {}
  onOpenGuide: () => void = () => {}
  onOpenSearch: () => void = () => {}
  onOpenGrowth: (segment: string) => void = () => {}
  onLogout: () => void = () => {}

  aboutToAppear(): void {
    void this.loadStats()
  }

  onEpochChange(): void {
    void this.loadStats()
  }

  private async loadStats(): Promise<void> {
    const trips = await TravelService.trips()
    const checklist = await TravelService.checklistItems()
    const notes = await TravelService.notes()
    const reminders = await TravelService.reminders()
    const favorites = await TravelGrowthService.listFavorites()
    const streak = this.isLoggedIn() ? await TravelGrowthService.prepStreakDays() : 0
    this.stats = TravelGrowthService.computeStats(trips, checklist, favorites, streak, notes, reminders)
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
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Text(this.isLoggedIn()
                  ? '行程、清单与提醒已开启云端同步'
                  : '游客可浏览公开模板；写操作需登录')
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s5)
              .alignItems(HorizontalAlign.Start)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
              .border({ width: 1, color: Theme.colors().strokeHairline })

              Row({ space: Theme.space.s3 }) {
                HomeStatCard({ label: '我的行程', value: `${this.stats.tripCount}` })
                HomeStatCard({ label: '清单完成', value: `${this.stats.checklistDone}` })
              }
              Row({ space: Theme.space.s3 }) {
                HomeStatCard({ label: '收藏', value: `${this.stats.favoriteCount}` })
                HomeStatCard({ label: '连续准备', value: `${this.stats.prepStreakDays}天` })
              }

              this.MenuRow('全局搜索', '搜索行程、清单、备忘与攻略', 'search', () => {
                this.onOpenSearch()
              })
              this.MenuRow('出行成长', '统计 · 成就 · 收藏 · 回顾', 'chart', () => {
                this.onOpenGrowth('stats')
              })
              this.MenuRow('我的行程', '查看已创建的旅行计划', 'biz', () => {
                if (!this.isLoggedIn()) {
                  this.onOpenLogin()
                } else {
                  this.onOpenTrips()
                }
              })
              this.MenuRow('准备中心', '清单核对 · 出发提醒 · 旅途备忘', 'check', () => {
                this.onOpenPrepare()
              })
              this.MenuRow('出行攻略', '行程模板与出发前实用贴士', 'chart', () => {
                this.onOpenGuide()
              })
              this.MenuRow('设置与隐私', '协议 · 撤回同意 · 注销', 'user', () => {
                this.showSettings = true
              })
              this.MenuRow(`关于${BrandIdentity.appName()}`,
                `开发者 ${BrandIdentity.developer()} · 版本 ${BrandIdentity.version()}`, 'message', () => {
                this.showAbout = true
              })

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

      if (this.showAbout) {
        AboutOverlay({
          onClose: () => { this.showAbout = false }
        })
          .width('100%')
          .height('100%')
      }

      if (this.showLegal) {
        LegalDocOverlay({
          kind: this.legalKind,
          onClose: () => { this.showLegal = false }
        })
          .width('100%')
          .height('100%')
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  MenuRow(title: string, subtitle: string, icon: 'biz' | 'home' | 'user' | 'message' | 'check' | 'chart' | 'search', action: () => void) {
    Row({ space: Theme.space.s3 }) {
      Row() {
        AppIcon({ name: icon, iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.lg)
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
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick(() => action())
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
        .onClick(() => { this.showSettings = false })
        Text('设置与隐私')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
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
          Text('个人信息收集清单\n注册账号、姓名、联系电话，以及您主动创建的行程、清单、提醒和备忘。')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .lineHeight(22)
            .width('100%')
          Text('第三方共享清单\n当前版本不接入广告、支付、地图或社交 SDK，不向第三方出售个人信息。')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .lineHeight(22)
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
