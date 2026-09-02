import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AuthService } from '../services/AuthService'
import { PrivacyService } from '../services/PrivacyService'
import { WanderDetailNav } from '../services/WanderDetailNav'
import { WanderLocalStore } from '../services/WanderLocalStore'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '发现之旅'
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @State showSettings: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  @State routeCount: number = 12
  @State journalCount: number = 0
  @State favoriteCount: number = 0
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onSwitchTab: (index: number) => void = (_i: number) => {}

  aboutToAppear(): void {
    void this.loadStats()
  }

  onRefreshTokenChange(): void {
    void this.loadStats()
  }

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
  }

  private async loadStats(): Promise<void> {
    const journals = await WanderLocalStore.loadJournals()
    const favs = await WanderLocalStore.loadFavoriteIds()
    this.journalCount = journals.length
    this.favoriteCount = favs.length
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
    AppStorage.setOrCreate('tabBarHidden', false)
    this.showToast('已撤回隐私同意，再次登录须重新勾选协议')
  }

  private async handleDeleteAccount(): Promise<void> {
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
        if (this.showSettings) {
          this.SettingsPanel()
        } else {
          AppHeader({ title: '我的', subtitle: this.appName })
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Column({ space: 8 }) {
                Text(this.isLoggedIn() ? this.currentUsername : '慢慢走的人')
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Text(this.isLoggedIn() ? '账号已登录' : '游客也可浏览探索点、写旅记与收藏心愿')
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s5)
              .alignItems(HorizontalAlign.Start)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)

              Row({ space: 10 }) {
                this.StatCell('探索点', `${this.routeCount}`)
                this.StatCell('旅记', `${this.journalCount}`)
                this.StatCell('收藏', `${this.favoriteCount}`)
              }
              .width('100%')

              Scroll() {
                Row({ space: 10 }) {
                  this.BadgeCell('初探者', this.journalCount >= 1)
                  this.BadgeCell('漫步者', this.journalCount >= 3)
                  this.BadgeCell('探索家', this.journalCount >= 8)
                  this.BadgeCell('收藏家', this.favoriteCount >= 5)
                }
                .padding({ left: 2, right: 2 })
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              .width('100%')

              this.MenuRow('收藏夹', '想再去一次的探索点', (): void => WanderDetailNav.openFavorites())
              this.MenuRow('我的旅记', '记录每一次发现', (): void => this.onSwitchTab(2))
              this.MenuRow('出行清单', '出发前轻轻勾选', (): void => WanderDetailNav.openChecklist())
              this.MenuRow('通知', '探索灵感提醒', (): void => WanderDetailNav.openMessages())
              this.MenuRow('关于', '让每一次出行，都成为发现之旅', (): void => WanderDetailNav.openAbout())
              this.MenuRow('意见反馈', '告诉我们你的发现', (): void => WanderDetailNav.openFeedback())

              Row() {
                Column({ space: 2 }) {
                  Text('设置与隐私')
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                  Text('协议 · 撤回同意 · 注销')
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
              .borderRadius(Theme.radius.md)
              .onClick(() => this.openSettings())

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
                  variant: 'ghost',
                  onTap: (): void => this.onOpenLogin()
                })
              }
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
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
            .backgroundColor(Theme.colors().brandDeep)
            .borderRadius(Theme.radius.pill)
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
  StatCell(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().textPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding({ top: 16, bottom: 16 })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
  }

  @Builder
  BadgeCell(title: string, unlocked: boolean) {
    Column({ space: 4 }) {
      Text(unlocked ? '🏅' : '🔒')
        .fontSize(22)
      Text(title)
        .fontSize(Theme.type.caption)
        .fontColor(unlocked ? Theme.colors().brandPrimary : Theme.colors().textTertiary)
    }
    .padding({ left: 14, right: 14, top: 10, bottom: 10 })
    .backgroundColor(unlocked ? Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
    .borderRadius(Theme.radius.md)
  }

  @Builder
  MenuRow(title: string, caption: string, action: () => void) {
    Row() {
      Column({ space: 2 }) {
        Text(title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Text(caption)
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
    .borderRadius(Theme.radius.md)
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
        .onClick(() => this.closeSettings())
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
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
  }
}
