import { Theme } from '../components/design-system/Theme'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { common } from '@kit.AbilityKit'
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
  @Prop appName: string = '夏日漫游'
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @StorageLink('wanderDataRefresh') @Watch('onWanderDataRefresh') wanderDataRefresh: number = 0
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @State showSettings: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  @State visitCount: number = 0
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

  onWanderDataRefresh(): void {
    void this.loadStats()
  }

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
  }

  private async loadStats(): Promise<void> {
    const journals = await WanderLocalStore.loadJournals()
    const routeFavs = await WanderLocalStore.loadFavoriteIds()
    const inspFavs = await WanderLocalStore.loadInspirationFavoriteIds()
    this.journalCount = journals.length
    this.favoriteCount = routeFavs.length + inspFavs.length
    const places: string[] = []
    for (const j of journals) {
      if (j.place.length > 0) {
        let found = false
        for (const p of places) {
          if (p === j.place) {
            found = true
            break
          }
        }
        if (!found) {
          places.push(j.place)
        }
      }
    }
    this.visitCount = places.length
  }

  private async handleClearCache(): Promise<void> {
    AppStorage.setOrCreate('detailRoute', '')
    AppStorage.setOrCreate('tabBarHidden', false)
    this.showToast('已清除本地界面缓存')
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

  private async toggleDark(on: boolean): Promise<void> {
    AppStorage.setOrCreate('darkModeOn', on)
    ThemeAppearance.apply(on ? 'dark' : 'light', this.getUIContext().getHostContext() as common.UIAbilityContext)
    await WanderLocalStore.saveDarkMode(on)
    this.showToast(on ? '已切换深色模式' : '已切换浅色模式')
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
                Text(this.isLoggedIn() ? '账号已登录' : '游客可浏览地图与灵感，记录保存在本机')
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
                this.StatCell('记录', `${this.journalCount}`)
                this.StatCell('地点', `${this.visitCount}`)
                this.StatCell('收藏', `${this.favoriteCount}`)
              }
              .width('100%')

              this.MenuRow('我的记录', '漫游时间线', (): void => this.onSwitchTab(1))
              this.MenuRow('收藏漫游点', '想再走一次的地点', (): void => WanderDetailNav.openFavorites())
              this.MenuRow('收藏灵感', '今日灵感里留住的卡片', (): void => WanderDetailNav.openInspirationFavorites())
              this.MenuRow('出行清单', '出门前轻轻勾选', (): void => WanderDetailNav.openChecklist())
              this.MenuRow('智慧匹配', '按此刻状态推荐漫游点', (): void => WanderDetailNav.openDiagnose())
              this.MenuRow('通知', '机构活动提醒', (): void => WanderDetailNav.openMessages())
              this.MenuRow('关于', '用智慧的方式记录夏日漫游', (): void => WanderDetailNav.openAbout())
              this.MenuRow('意见反馈', '告诉风，也告诉我们', (): void => WanderDetailNav.openFeedback())

              Row() {
                Text('深色模式')
                  .fontSize(Theme.type.subhead)
                  .fontColor(Theme.colors().textPrimary)
                  .layoutWeight(1)
                Toggle({ type: ToggleType.Switch, isOn: this.darkModeOn })
                  .onChange((on: boolean) => { void this.toggleDark(on) })
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)

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
          AppButton({
            label: '清除缓存',
            variant: 'secondary',
            onTap: (): void => { void this.handleClearCache() }
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
