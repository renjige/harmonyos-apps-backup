import { common } from '@kit.AbilityKit'
import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AuthService } from '../services/AuthService'
import { PrivacyService } from '../services/PrivacyService'
import { GearBizService } from '../services/GearBizService'
import { GearDetailNav } from '../services/GearDetailNav'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { MineMenuRow } from '../components/mine/MineMenuRow'
import { MineSettingsPanel } from '../components/mine/MineSettingsPanel'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '户外装备库'
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('appearance') appearance: string = 'system'
  @StorageLink('notifyEnabled') notifyEnabled: boolean = true
  @State showSettings: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  @State confirmDelete: boolean = false
  @State gearCount: number = 0
  @State favCount: number = 0
  @State postCount: number = 0
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}

  aboutToAppear(): void {
    void this.loadStats()
  }

  onRefreshTokenChange(): void {
    void this.loadStats()
  }

  private async loadStats(): Promise<void> {
    const gear = await GearBizService.loadMine('gear')
    const favs = await GearBizService.loadMine('favorites')
    const posts = await GearBizService.loadMine('posts')
    this.gearCount = gear.length
    this.favCount = favs.length
    this.postCount = posts.length
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

  private applyAppearance(mode: string): void {
    this.appearance = mode
    AppStorage.setOrCreate('appearance', mode)
    try {
      const host = getContext(this) as common.UIAbilityContext
      ThemeAppearance.apply(mode, host)
    } catch {
      ThemeAppearance.apply(mode)
    }
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

  build() {
    Stack() {
      Column() {
        if (this.showSettings) {
          MineSettingsPanel({
            appearance: this.appearance,
            notifyEnabled: this.notifyEnabled,
            confirmDelete: this.confirmDelete,
            onBack: (): void => {
              this.showSettings = false
              AppStorage.setOrCreate('tabBarHidden', false)
            },
            onAppearance: (mode: string): void => { this.applyAppearance(mode) },
            onNotify: (on: boolean): void => {
              this.notifyEnabled = on
              AppStorage.setOrCreate('notifyEnabled', on)
            },
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
            onRevokePrivacy: (): void => { void this.handleRevokePrivacy() }
          })
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
                  ? '克重账本与收藏将按账号同步'
                  : '游客可浏览图鉴与路线；录入装备需登录')
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s5)
              .alignItems(HorizontalAlign.Start)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.card)

              Row({ space: 8 }) {
                this.StatChip('装备', `${this.gearCount}`)
                this.StatChip('收藏', `${this.favCount}`)
                this.StatChip('动态', `${this.postCount}`)
              }
              .width('100%')

              MineMenuRow({
                title: '设置与隐私',
                caption: '协议 · 撤回同意 · 注销',
                onTap: (): void => {
                  this.confirmDelete = false
                  this.showSettings = true
                  AppStorage.setOrCreate('tabBarHidden', true)
                }
              })
              MineMenuRow({
                title: '收藏路线',
                caption: `${this.favCount} 条精选路线`,
                onTap: (): void => GearDetailNav.openFavorites()
              })
              MineMenuRow({
                title: '我的动态',
                caption: this.postCount > 0 ? `${this.postCount} 篇` : '新用户为空',
                onTap: (): void => GearDetailNav.openMyPosts()
              })
              MineMenuRow({
                title: '出装检视',
                caption: '问卷对照类别缺口',
                onTap: (): void => GearDetailNav.openInspect()
              })
              MineMenuRow({
                title: '消息中心',
                caption: '机构广播',
                onTap: (): void => GearDetailNav.openMessages()
              })
              MineMenuRow({
                title: '关于户外装备库',
                caption: '版本 1.0.0',
                onTap: (): void => GearDetailNav.openAbout()
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
  StatChip(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().textPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding({ top: 12, bottom: 12 })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
  }
}
