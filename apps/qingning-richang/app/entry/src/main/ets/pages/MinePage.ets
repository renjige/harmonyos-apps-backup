import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppListRow } from '../components/design-system/AppListRow'
import { StatisticsCard } from '../components/daily/StatisticsCard'
import { AuthService } from '../services/AuthService'
import { PrivacyService } from '../services/PrivacyService'
import { DailyLocalStore } from '../services/DailyLocalStore'
import { DailyConstants, DailyStats, UserProfile } from '../models/DailyModels'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '青柠日常'
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @State showSettings: boolean = false
  @State showFavorites: boolean = false
  @State showAbout: boolean = false
  @State showNicknameEdit: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  @State confirmDelete: boolean = false
  @State stats: DailyStats = new DailyStats()
  @State profile: UserProfile = UserProfile.defaultProfile()
  @State nicknameInput: string = ''
  @State favQuotes: string[] = []
  @Prop @Watch('onAppearToken') appearToken: number = 0
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onAppearToken(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.stats = await DailyLocalStore.loadStats()
    this.profile = await DailyLocalStore.loadProfile()
    this.nicknameInput = this.profile.nickname
    const ids = await DailyLocalStore.loadFavoriteQuoteIds()
    const texts: string[] = []
    const quotes = DailyConstants.quotes()
    for (const id of ids) {
      for (const q of quotes) {
        if (q.id === id) {
          texts.push(q.text)
        }
      }
    }
    this.favQuotes = texts
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

  private async saveNickname(): Promise<void> {
    const p = UserProfile.defaultProfile()
    p.nickname = this.nicknameInput.length > 0 ? this.nicknameInput : '青柠用户'
    await DailyLocalStore.saveProfile(p)
    this.profile = p
    this.showNicknameEdit = false
    this.showToast('昵称已更新')
  }

  build() {
    Stack() {
      Column() {
        if (this.showSettings) {
          this.SettingsPanel()
        } else if (this.showFavorites) {
          this.FavoritesPanel()
        } else if (this.showAbout) {
          this.AboutPanel()
        } else {
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Row({ space: Theme.space.s4 }) {
                Column() {
                  AppIcon({ name: 'user', iconSize: Theme.icon.xl, color: Theme.colors().brandPrimary })
                }
                .width(64)
                .height(64)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)

                Column({ space: 4 }) {
                  Text(this.profile.nickname)
                    .fontSize(Theme.type.title3)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Theme.colors().textPrimary)
                  Text('轻触编辑昵称 · 数据保存在本机')
                    .fontSize(Theme.type.footnote)
                    .fontColor(Theme.colors().textSecondary)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')
              .padding(Theme.space.s5)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
              .onClick(() => {
                this.nicknameInput = this.profile.nickname
                this.showNicknameEdit = true
              })

              if (this.showNicknameEdit) {
                Column({ space: Theme.space.s3 }) {
                  TextInput({ text: this.nicknameInput, placeholder: '昵称' })
                    .onChange((v: string) => { this.nicknameInput = v })
                  Row({ space: Theme.space.s3 }) {
                    AppButton({
                      label: '取消',
                      variant: 'secondary',
                      onTap: (): void => { this.showNicknameEdit = false }
                    }).layoutWeight(1)
                    AppButton({
                      label: '保存',
                      onTap: (): void => { void this.saveNickname() }
                    }).layoutWeight(1)
                  }
                  .width('100%')
                }
                .padding(Theme.space.s4)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.lg)
              }

              StatisticsCard({ stats: this.stats })

              AppListRow({
                title: '我的收藏',
                subtitle: `${this.stats.favoriteCount} 句温暖短句`,
                onTap: (): void => {
                  AppStorage.setOrCreate('tabBarHidden', true)
                  this.showFavorites = true
                }
              })
              AppListRow({
                title: '关于青柠日常',
                subtitle: '版本 1.0.0 · 青柠生活',
                onTap: (): void => {
                  AppStorage.setOrCreate('tabBarHidden', true)
                  this.showAbout = true
                }
              })
              AppListRow({
                title: '设置与隐私',
                subtitle: '协议 · 撤回同意 · 注销',
                onTap: (): void => {
                  this.confirmDelete = false
                  AppStorage.setOrCreate('tabBarHidden', true)
                  this.showSettings = true
                }
              })

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
                  label: '登录 / 注册（可选）',
                  variant: 'secondary',
                  onTap: (): void => { this.onOpenLogin() }
                })
              }
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              top: Theme.space.pageY,
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
  FavoritesPanel() {
    Column() {
      this.SubPanelHeader('我的收藏', () => {
        this.showFavorites = false
        AppStorage.setOrCreate('tabBarHidden', false)
      })
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          if (this.favQuotes.length === 0) {
            Image($r('app.media.empty_calm'))
              .width('100%')
              .height(140)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.lg)
            Text('还没有收藏，去首页点亮爱心吧')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textSecondary)
          } else {
            ForEach(this.favQuotes, (text: string, idx: number) => {
              Text(`「${text}」`)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
                .lineHeight(24)
                .padding(Theme.space.s4)
                .width('100%')
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.lg)
            }, (text: string, idx: number) => `${idx}`)
          }
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  AboutPanel() {
    Column() {
      this.SubPanelHeader('关于青柠日常', () => {
        this.showAbout = false
        AppStorage.setOrCreate('tabBarHidden', false)
      })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('用智慧的方式，记录每一天的小确幸。')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textPrimary)
          Text('每日一事 · 心情日记 · 今日智慧，全部保存在本机，无社交、无广告、无支付。')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .lineHeight(22)
          AppButton({
            label: '查看隐私政策',
            variant: 'secondary',
            onTap: (): void => {
              this.legalKind = 'privacy'
              this.showLegal = true
            }
          })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  SettingsPanel() {
    Column({ space: Theme.space.s4 }) {
      this.SubPanelHeader('设置与隐私', () => {
        this.showSettings = false
        AppStorage.setOrCreate('tabBarHidden', false)
      })
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
            label: '清除缓存',
            variant: 'secondary',
            onTap: (): void => { this.handleClearCache() }
          })
          AppButton({
            label: this.confirmDelete ? '再点一次确认注销' : '注销账号',
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
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  SubPanelHeader(title: string, onBack: () => void) {
    Row({ space: Theme.space.s2 }) {
      Column() {
        AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
      }
      .width(44)
      .height(44)
      .justifyContent(FlexAlign.Center)
      .rotate({ angle: 180 })
      .onClick(() => onBack())
      Text(title)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
    }
    .width('100%')
    .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.pageY })
  }
}
