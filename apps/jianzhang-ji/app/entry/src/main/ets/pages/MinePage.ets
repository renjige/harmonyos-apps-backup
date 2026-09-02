import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { AuthService } from '../services/AuthService'
import { PrivacyService } from '../services/PrivacyService'
import { FavoriteService } from '../services/FavoriteService'
import { CompareStore } from '../services/CompareStore'
import { WatchlistService } from '../services/WatchlistService'
import { BrowseHistoryService } from '../services/BrowseHistoryService'
import { BrochureBizService } from '../services/BrochureBizService'
import { BrochureDetailNav } from '../services/BrochureDetailNav'
import { HistoryEntry, BrochureItem } from '../models/BrochureModels'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '简章集'
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('favoriteTick') favoriteTick: number = 0
  @StorageLink('compareTick') compareTick: number = 0
  @StorageLink('watchTick') watchTick: number = 0
  @StorageLink('historyTick') historyTick: number = 0
  @State showSettings: boolean = false
  @State showWatchPanel: boolean = false
  @State showHistoryPanel: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  @State confirmDelete: boolean = false
  @State history: HistoryEntry[] = []
  @State watchItems: BrochureItem[] = []
  onOpenLogin: () => void = () => {}
  onOpenMessages: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.refreshPanels()
  }

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
  }

  private async refreshPanels(): Promise<void> {
    this.history = BrowseHistoryService.list(12)
    if (AuthService.isLoggedIn()) {
      await WatchlistService.syncFromServer()
    }
    const ids = WatchlistService.listIds()
    const all = await BrochureBizService.loadBrochures()
    const out: BrochureItem[] = []
    for (let id of ids) {
      const row = BrochureBizService.findBrochure(all, id)
      if (row !== undefined) {
        out.push(row)
      }
    }
    this.watchItems = out
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
          this.SettingsPanel()
        } else if (this.showWatchPanel) {
          this.WatchPanel()
        } else if (this.showHistoryPanel) {
          this.HistoryPanel()
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
                  ? '账号已登录 · 收藏与关注可同步云端'
                  : '游客可浏览简章；收藏与对比保存在本机')
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s5)
              .alignItems(HorizontalAlign.Start)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.card)
              .border({ width: 1, color: Theme.colors().strokeHairline })

              Row({ space: Theme.space.s3 }) {
                AppStatCard({
                  label: '收藏',
                  value: `${FavoriteService.count()}`,
                  trend: '简章',
                  positive: true
                }).layoutWeight(1)
                AppStatCard({
                  label: '对比',
                  value: `${CompareStore.count()}`,
                  trend: `最多${CompareStore.maxCount()}`,
                  positive: true
                }).layoutWeight(1)
              }
              .width('100%')

              this.MenuRow('浏览历史', `${BrowseHistoryService.count()} 条`, (): void => {
                void this.refreshPanels()
                this.showHistoryPanel = true
              })
              this.MenuRow('关注院校', `${WatchlistService.count()} 所`, (): void => {
                void this.refreshPanels()
                this.showWatchPanel = true
              })
              this.MenuRow('消息中心', '政策与提醒', (): void => {
                this.onOpenMessages()
              })
              this.MenuRow('设置与隐私', '协议 · 撤回 · 注销', (): void => {
                this.confirmDelete = false
                this.showSettings = true
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
  MenuRow(title: string, subtitle: string, onTap: () => void) {
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
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick((): void => { onTap() })
  }

  @Builder
  WatchPanel() {
    Column({ space: Theme.space.s4 }) {
      this.SubPanelHeader('关注院校', (): void => { this.showWatchPanel = false })
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          if (this.watchItems.length === 0) {
            Text('暂无关注院校，可在简章详情页点击「关注院校」')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          } else {
            ForEach(this.watchItems, (row: BrochureItem) => {
              Row({ space: Theme.space.s2 }) {
                Text(row.title)
                  .fontSize(Theme.type.subhead)
                  .fontColor(Theme.colors().textPrimary)
                  .layoutWeight(1)
                Text('查看')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandPrimary)
                  .onClick((): void => { BrochureDetailNav.openBrochure(row.id) })
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.card)
            }, (row: BrochureItem) => row.id)
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  HistoryPanel() {
    Column({ space: Theme.space.s4 }) {
      this.SubPanelHeader('浏览历史', (): void => { this.showHistoryPanel = false })
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          if (this.history.length === 0) {
            Text('还没有浏览记录，去首页看看招生简章吧')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          } else {
            ForEach(this.history, (row: HistoryEntry) => {
              Row({ space: Theme.space.s2 }) {
                Column({ space: 2 }) {
                  Text(row.title)
                    .fontSize(Theme.type.subhead)
                    .fontColor(Theme.colors().textPrimary)
                  Text(row.kind === 'article' ? '资讯' : '简章')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                Text('打开')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandPrimary)
                  .onClick((): void => {
                    if (row.kind === 'article') {
                      BrochureDetailNav.openArticle(row.id)
                    } else {
                      BrochureDetailNav.openBrochure(row.id)
                    }
                  })
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.card)
            }, (row: HistoryEntry) => `${row.kind}-${row.id}`)
            AppButton({
              label: '清空历史',
              variant: 'secondary',
              onTap: (): void => {
                void BrowseHistoryService.clear().then((): void => {
                  void this.refreshPanels()
                })
              }
            })
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
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
      .onClick((): void => { onBack() })
      Text(title)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
    }
    .width('100%')
    .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX })
  }

  @Builder
  SettingsPanel() {
    Column({ space: Theme.space.s4 }) {
      this.SubPanelHeader('设置与隐私', (): void => { this.showSettings = false })
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
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
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
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
  }
}
