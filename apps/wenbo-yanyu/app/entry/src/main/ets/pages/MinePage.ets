import { Theme } from '../components/design-system/Theme'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { common } from '@kit.AbilityKit'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AuthService } from '../services/AuthService'
import { PrivacyService } from '../services/PrivacyService'
import { ResearchStore } from '../services/ResearchStore'
import { HubStore } from '../services/HubStore'
import { AppStores } from '../services/AppStores'
import { ResearchNav } from '../services/ResearchNav'
import { LanguageCraftNav } from '../services/LanguageCraftNav'
import { MineStatTile } from '../models/MineStatTile'
import { HubDashboard } from '../models/HubModels'
import { MineStatCell } from '../components/mine/MineStatCell'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'

@Component
export struct MinePage {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop appName: string = '研语'
  @Prop @Watch('onTabActive') tabActive: boolean = false
  @StorageLink('mainTabIndex') @Watch('onMainTab') mainTabIndex: number = 0
  @StorageLink('storesReady') @Watch('onStoresReady') storesReady: boolean = false
  @StorageLink('researchRefresh') @Watch('onResearchRefresh') researchRefresh: number = 0
  @StorageLink('hubRefresh') @Watch('onHubRefresh') hubRefresh: number = 0
  @StorageLink('favRefresh') @Watch('onFavRefresh') favRefresh: number = 0
  @StorageLink('recordRefresh') @Watch('onRecordRefresh') recordRefresh: number = 0
  @StorageLink('researchHubRefresh') @Watch('onResearchRefresh') researchHubRefresh: number = 0
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @State showSettings: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  @State confirmDelete: boolean = false
  @State statTiles: MineStatTile[] = []
  @State statsEpoch: number = 0
  @State polishCount: number = 0
  @State summaryCount: number = 0
  @State favoriteTotal: number = 0
  @State noteCount: number = 0
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}

  aboutToAppear(): void {
    this.statTiles = this.buildStatTiles(new HubDashboard())
    void this.reloadStats()
  }

  onRecordRefresh(): void {
    void this.reloadStats()
  }

  onFavRefresh(): void {
    void this.reloadStats()
  }

  onResearchRefresh(): void {
    void this.reloadStats()
  }

  onHubRefresh(): void {
    void this.reloadStats()
  }

  onStoresReady(): void {
    if (this.storesReady) {
      void this.reloadStats()
    }
  }

  onTabActive(): void {
    if (this.tabActive) {
      void this.reloadStats()
    }
  }

  onMainTab(): void {
    if (this.mainTabIndex === 4) {
      void this.reloadStats()
    }
  }

  private buildStatTiles(d: HubDashboard): MineStatTile[] {
    return [
      MineStatTile.of('polish', '润色记录', d.polishCount),
      MineStatTile.of('summary', '摘要记录', d.summaryCount),
      MineStatTile.of('favorite', '收藏', d.favoriteCount + d.starredNoteCount),
      MineStatTile.of('note', '研究笔记', d.noteCount)
    ]
  }

  private handleStatTap(key: string): void {
    if (key === 'polish') {
      this.openPolishStats()
      return
    }
    if (key === 'summary') {
      this.openSummaryStats()
      return
    }
    if (key === 'favorite') {
      this.openFavoriteStats()
      return
    }
    this.openNoteStats()
  }

  private async reloadStats(): Promise<void> {
    const readyFlag = AppStorage.get<boolean>('storesReady') ?? false
    if (!readyFlag) {
      await AppStores.warmUp()
    }
    await HubStore.ensureReady()
    await ResearchStore.ensureReady()
    const d = await HubStore.dashboard()
    this.polishCount = d.polishCount
    this.summaryCount = d.summaryCount
    this.favoriteTotal = d.favoriteCount + d.starredNoteCount
    this.noteCount = d.noteCount
    this.statTiles = this.buildStatTiles(d)
    this.statsEpoch = Date.now()
  }

  private openPolishStats(): void {
    if (this.polishCount <= 0) {
      AppStorage.setOrCreate('mainTabIndex', 1)
      AppStorage.setOrCreate('expressSegment', 0)
      this.showToast('去表达页润色，次数会自动累计')
      return
    }
    LanguageCraftNav.openHistory('polish')
  }

  private openSummaryStats(): void {
    if (this.summaryCount <= 0) {
      AppStorage.setOrCreate('mainTabIndex', 1)
      AppStorage.setOrCreate('expressSegment', 1)
      this.showToast('去表达页生成摘要，次数会自动累计')
      return
    }
    LanguageCraftNav.openHistory('summary')
  }

  private openFavoriteStats(): void {
    if (this.favoriteTotal <= 0) {
      this.showToast('可在灵感详情或笔记详情里收藏')
      return
    }
    LanguageCraftNav.openFavorites()
  }

  private openNoteStats(): void {
    if (this.noteCount <= 0) {
      AppStorage.setOrCreate('mainTabIndex', 2)
      this.showToast('去研究工作台写第一条笔记')
      return
    }
    ResearchNav.open('notes')
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

  private toggleDark(): void {
    const next = !this.darkModeOn
    AppStorage.setOrCreate('darkModeOn', next)
    ThemeAppearance.apply(next ? 'dark' : 'light', this.getUIContext().getHostContext() as common.UIAbilityContext)
    this.showToast(next ? '已切换深色模式' : '已切换浅色模式')
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
                  .fontColor(Theme.of(this.darkModeOn).textPrimary)
                  .width('100%')
                Text('润色、摘要与研究笔记保存在本机；点数字可进详情，下方可刷新统计')
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.of(this.darkModeOn).textSecondary)
                  .width('100%')
                Row({ space: 24 }) {
                  ForEach(this.statTiles, (tile: MineStatTile) => {
                    MineStatCell({
                      label: tile.label,
                      valueText: tile.valueText,
                      onTap: (): void => { this.handleStatTap(tile.key) }
                    })
                  }, (tile: MineStatTile) => `${tile.key}_${tile.valueText}_${this.statsEpoch}`)
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceAround)
                .padding({ top: Theme.space.s2 })
                Row() {
                  AppButton({
                    label: '刷新统计',
                    variant: 'secondary',
                    onTap: (): void => { void this.reloadStats() }
                  })
                }
                .width('100%')
                .onClick((): void => { void this.reloadStats() })
              }
              .width('100%')
              .padding(Theme.space.s5)
              .alignItems(HorizontalAlign.Start)
              .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
              .borderRadius(Theme.radius.lg)
              .border({ width: 1, color: Theme.of(this.darkModeOn).strokeHairline })

              this.MenuRow('表达工作台', '润色 · 摘要 · 成稿 · 诊断', (): void => {
                AppStorage.setOrCreate('mainTabIndex', 1)
              })
              this.MenuRow('成长中心', '统计 · 成就 · 本周回顾', (): void => {
                AppStorage.setOrCreate('mainTabIndex', 3)
              })
              this.MenuRow('研究工作台', '笔记 / 专题 / 标签 / 灵感 / 时间线', (): void => {
                AppStorage.setOrCreate('mainTabIndex', 2)
              })
              this.MenuRow('稿本库', '润色与摘要成稿集中管理', (): void => {
                LanguageCraftNav.openManuscripts()
              })
              this.MenuRow('场景成稿', '邮件 / 纪要 / 致歉 / 汇报填空成稿', (): void => {
                LanguageCraftNav.openDraft()
              })
              this.MenuRow('润色与摘要历史', '本机最近 20 条润色与全部摘要', (): void => {
                LanguageCraftNav.openHistory()
              })
              this.MenuRow('收藏夹', '表达灵感 + 笔记星标', (): void => {
                LanguageCraftNav.openFavorites()
              })
              this.MenuRow('笔记星标', '研究笔记详情里可收藏', (): void => {
                ResearchNav.open('collections')
              })
              this.MenuRow('表达诊断', '问卷 + 模板报告 · 不含生成式对话', (): void => {
                LanguageCraftNav.openDiagnose()
              })
              this.MenuRow('设置与隐私', '协议 · 撤回同意 · 注销', (): void => {
                this.confirmDelete = false
                this.showSettings = true
              })

              Row({ space: Theme.space.s2 }) {
                AppIcon({ name: 'moon', iconSize: Theme.icon.sm })
                Text(this.darkModeOn ? '深色模式（开）' : '浅色模式')
                  .fontSize(Theme.type.subhead)
                  .fontColor(Theme.of(this.darkModeOn).textPrimary)
                  .layoutWeight(1)
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
              .borderRadius(Theme.radius.lg)
              .border({ width: 1, color: Theme.of(this.darkModeOn).strokeHairline })
              .onClick((): void => { this.toggleDark() })

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
                  onTap: (): void => { this.onOpenLogin() }
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
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .onVisibleAreaChange([0.0, 1.0], (visible: boolean) => {
            if (visible) {
              void this.reloadStats()
            }
          })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.of(this.darkModeOn).surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.of(this.darkModeOn).brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.of(this.darkModeOn).brandPrimary)
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
          .fontColor(Theme.of(this.darkModeOn).textPrimary)
        Text(subtitle)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.of(this.darkModeOn).textSecondary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.of(this.darkModeOn).strokeHairline })
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
          .fontColor(Theme.of(this.darkModeOn).textPrimary)
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
            .fontColor(Theme.of(this.darkModeOn).textSecondary)
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
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .onVisibleAreaChange([0.0, 1.0], (visible: boolean) => {
      if (visible) {
        void this.reloadStats()
      }
    })
  }
}
