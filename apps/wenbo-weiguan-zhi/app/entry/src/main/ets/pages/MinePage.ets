import { common } from '@kit.AbilityKit'
import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AuthService } from '../services/AuthService'
import { PrivacyService } from '../services/PrivacyService'
import { ExportService } from '../services/ExportService'
import { GrowthStore } from '../services/GrowthStore'
import { EssayStatsService } from '../services/EssayStatsService'
import { EssayStore } from '../services/EssayStore'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { SessionStore } from '../services/SessionStore'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { WeekRecapPane } from '../components/essay/WeekRecapPane'
import { EssayDetailPane } from '../components/essay/EssayDetailPane'
import { EssayEditorSheet } from '../components/essay/EssayEditorSheet'
import { ContrastPane } from '../components/essay/ContrastPane'
import { SenseWeekCharts } from '../components/essay/SenseWeekCharts'
import { AlbumListPane } from '../components/essay/AlbumListPane'
import { ThemeListPane } from '../components/essay/ThemeListPane'
import { ThemeEditorSheet } from '../components/essay/ThemeEditorSheet'
import { BadgeWallPane } from '../components/essay/BadgeWallPane'
import { MonthRecapPane } from '../components/essay/MonthRecapPane'
import { YearRecapPane } from '../components/essay/YearRecapPane'
import { SenseCount, DayCount } from '../models/GrowthModels'
import { ObserveStatTile } from '../components/essay/ObserveStatTile'
import { MineSettingRow } from '../components/essay/MineSettingRow'

@Component
export struct MinePage {
  @Prop appName: string = '微观志'
  @Prop @Watch('onReloadToken') reloadToken: number = 0
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('essayFontScale') fontScale: number = 1
  @StorageLink('essayDataEpoch') @Watch('onDataEpoch') dataEpoch: number = 0
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('colorMode') colorMode: string = 'system'
  @State showSettings: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  @State confirmDelete: boolean = false
  @State darkMode: boolean = false
  @State exportText: string = ''
  @State exportTitle: string = ''
  @State essayCount: number = 0
  @State totalWords: number = 0
  @State streakDays: number = 0
  @State favoriteCount: number = 0
  @State weekCount: number = 0
  @State weekWords: number = 0
  @State topTag: string = ''
  @State uiFontScale: number = 1
  @State showRecap: boolean = false
  @State detailId: string = ''
  @State editingId: string = ''
  @State showEditor: boolean = false
  @State showContrast: boolean = false
  @State statsStamp: number = 0
  @State senseRows: SenseCount[] = []
  @State weekRows: DayCount[] = []
  @State showAlbums: boolean = false
  @State showThemes: boolean = false
  @State showThemeEdit: boolean = false
  @State showBadges: boolean = false
  @State showMonth: boolean = false
  @State showYear: boolean = false
  @State monthYear: number = 2026
  @State monthIndex: number = 1
  @State monthEssayCount: number = 0
  @State yearEssayCount: number = 0
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}

  private uiContext: common.UIAbilityContext | null = null

  aboutToAppear(): void {
    this.uiFontScale = this.fontScale
    this.syncDarkFromMode()
    void this.loadStats()
  }

  onReloadToken(): void {
    this.uiFontScale = this.fontScale
    void this.loadStats()
  }

  onDataEpoch(): void {
    void this.loadStats()
  }

  private syncDarkFromMode(): void {
    this.darkMode = Theme.isDark()
  }

  private async loadStats(): Promise<void> {
    const list = await EssayStore.loadAll()
    this.essayCount = list.length
    let words = 0
    let fav = 0
    let weekN = 0
    let weekW = 0
    for (const it of list) {
      words += it.wordCount
      if (it.favorite) {
        fav++
      }
      if (EssayStore.isInWeek(it)) {
        weekN++
        weekW += it.wordCount
      }
    }
    this.totalWords = words
    this.favoriteCount = fav
    this.weekCount = weekN
    this.weekWords = weekW
    this.streakDays = EssayStatsService.computeStreak(list)
    this.topTag = EssayStatsService.topTagOf(list)
    this.senseRows = EssayStatsService.senseCountsOf(list)
    this.weekRows = EssayStatsService.weekDayCountsOf(list)
    const now = new Date()
    this.monthYear = now.getFullYear()
    this.monthIndex = now.getMonth() + 1
    this.monthEssayCount = GrowthStore.loadMonthEssays(list, this.monthYear, this.monthIndex).length
    this.yearEssayCount = GrowthStore.loadYearEssays(list, this.monthYear).length
    this.statsStamp++
  }

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2800)
  }

  private hideTab(hidden: boolean): void {
    AppStorage.setOrCreate('tabBarHidden', hidden)
  }

  private applyFont(scale: number): void {
    this.uiFontScale = scale
    AppStorage.setOrCreate('essayFontScale', scale)
    void SessionStore.saveFontScale(scale)
    this.showToast(`本页与时间线已改为 ${Math.round(scale * 100)}%`)
  }

  private async openCapsule(): Promise<void> {
    const it = await EssayStore.findRandom()
    if (it === undefined) {
      this.showToast('还没有观察，先写一篇再抽时光胶囊')
      this.showEditor = true
      this.hideTab(true)
      return
    }
    this.detailId = it.id
    this.hideTab(true)
  }

  private openEditFromDetail(): void {
    this.editingId = this.detailId
    this.detailId = ''
    this.showEditor = true
    this.hideTab(true)
  }

  private openWrite(hint: string): void {
    if (hint.length > 0) {
      AppStorage.setOrCreate('essayPracticeHint', hint)
    }
    this.showRecap = false
    this.detailId = ''
    this.editingId = ''
    this.showEditor = true
    this.hideTab(true)
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

  private host(): common.UIAbilityContext | null {
    if (this.uiContext !== null) {
      return this.uiContext
    }
    const h = this.getUIContext().getHostContext()
    if (h !== undefined) {
      this.uiContext = h as common.UIAbilityContext
    }
    return this.uiContext
  }

  private async exportTxt(): Promise<void> {
    const ctx = this.host()
    if (ctx === null) {
      this.showToast('导出失败，请重试')
      return
    }
    const r = await ExportService.exportPlainText(ctx)
    this.exportTitle = 'TXT 导出预览'
    this.exportText = r.text
    this.showToast(r.message)
  }

  private async exportMd(): Promise<void> {
    const ctx = this.host()
    if (ctx === null) {
      this.showToast('导出失败，请重试')
      return
    }
    const r = await ExportService.exportMarkdown(ctx)
    this.exportTitle = 'Markdown 导出预览'
    this.exportText = r.text
    this.showToast(r.message)
  }

  private applyDark(on: boolean): void {
    this.darkMode = on
    const mode = on ? 'dark' : 'light'
    const ctx = this.host()
    if (ctx !== null) {
      ThemeAppearance.apply(mode, ctx)
    } else {
      ThemeAppearance.apply(mode)
    }
    void SessionStore.saveColorMode(mode)
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
              Row({ space: Theme.space.s3 }) {
                Column() {
                  AppIcon({ name: 'user', iconSize: Theme.icon.xl, color: Theme.colors().brandAccent })
                }
                .width(56)
                .height(56)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
                Column({ space: 4 }) {
                  Text(this.isLoggedIn() ? this.currentUsername : '观察者')
                    .fontSize(Theme.type.title3 * this.uiFontScale)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Theme.colors().textPrimary)
                  Text(this.isLoggedIn() ? '已登录 · 可选同步账号' : '游客模式 · 数据保存在本机')
                    .fontSize(Theme.type.footnote * this.uiFontScale)
                    .fontColor(Theme.colors().textSecondary)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)

              Row({ space: Theme.space.s3 }) {
                ObserveStatTile({ value: this.essayCount, label: '观察数', fontScale: this.uiFontScale })
                ObserveStatTile({ value: this.totalWords, label: '总字数', fontScale: this.uiFontScale })
                ObserveStatTile({ value: this.streakDays, label: '连续天数', fontScale: this.uiFontScale })
              }
              .width('100%')
              Row({ space: Theme.space.s3 }) {
                ObserveStatTile({ value: this.favoriteCount, label: '珍藏', fontScale: this.uiFontScale })
                ObserveStatTile({ value: this.weekCount, label: '本周篇数', fontScale: this.uiFontScale })
                ObserveStatTile({ value: this.weekWords, label: '本周字数', fontScale: this.uiFontScale })
              }
              .width('100%')

              if (this.topTag.length > 0) {
                Text(`本周高频标签：${this.topTag}`)
                  .fontSize(Theme.type.bodyS * this.uiFontScale)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
              }

              SenseWeekCharts({
                senseRows: this.senseRows,
                weekRows: this.weekRows
              })

              Column({ space: Theme.space.s2 }) {
                Text('阅读字号')
                  .fontSize(Theme.type.subhead * this.uiFontScale)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Text(`当前 ${Math.round(this.uiFontScale * 100)}% · 预览：窗边的光慢慢移到桌面`)
                  .fontSize(Theme.type.body * this.uiFontScale)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Row({ space: Theme.space.s2 }) {
                  this.FontChip('小', 1)
                  this.FontChip('中', 1.1)
                  this.FontChip('大', 1.2)
                }
                .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)

              MineSettingRow({
                title: '观察方法说明',
                subtitle: '五感卡 · 对照 · 专题（审核/新用户可重看）',
                fontScale: this.uiFontScale,
                onTap: (): void => {
                  AppStorage.setOrCreate('forceObserveIntro', Date.now())
                }
              })
              MineSettingRow({
                title: '观察专辑',
                subtitle: '把自己的珍藏放进集合',
                fontScale: this.uiFontScale,
                onTap: (): void => {
                  this.showAlbums = true
                  this.hideTab(true)
                }
              })
              MineSettingRow({
                title: '观察专题',
                subtitle: '给一种感官定目标篇数',
                fontScale: this.uiFontScale,
                onTap: (): void => {
                  this.showThemes = true
                  this.hideTab(true)
                }
              })
              MineSettingRow({
                title: '观察徽章',
                subtitle: '点亮来自真实写作的徽章',
                fontScale: this.uiFontScale,
                onTap: (): void => {
                  this.showBadges = true
                  this.hideTab(true)
                }
              })
              MineSettingRow({
                title: '本周观察回顾',
                subtitle: `${this.weekCount} 篇 · 回看这 7 天`,
                fontScale: this.uiFontScale,
                onTap: (): void => {
                  this.showRecap = true
                  this.hideTab(true)
                }
              })
              MineSettingRow({
                title: '本月观察回顾',
                subtitle: `${this.monthIndex} 月 · ${this.monthEssayCount} 篇`,
                fontScale: this.uiFontScale,
                onTap: (): void => {
                  this.showMonth = true
                  this.hideTab(true)
                }
              })
              MineSettingRow({
                title: `${this.monthYear} 年观察回顾`,
                subtitle: `${this.yearEssayCount} 篇 · 年度总览`,
                fontScale: this.uiFontScale,
                onTap: (): void => {
                  this.showYear = true
                  this.hideTab(true)
                }
              })
              MineSettingRow({
                title: '时光胶囊',
                subtitle: '随机抽一条旧观察重读',
                fontScale: this.uiFontScale,
                onTap: (): void => { void this.openCapsule() }
              })
              MineSettingRow({
                title: '对照观察',
                subtitle: '并排两篇旧观察，写下这次不同',
                fontScale: this.uiFontScale,
                onTap: (): void => {
                  this.showContrast = true
                  this.hideTab(true)
                }
              })

              Row({ space: Theme.space.s3 }) {
                Text('深色模式')
                  .fontSize(Theme.type.body * this.uiFontScale)
                  .fontColor(Theme.colors().textPrimary)
                Blank()
                Toggle({ type: ToggleType.Switch, isOn: this.darkMode })
                  .selectedColor(Theme.colors().brandAccent)
                  .onChange((v: boolean) => { this.applyDark(v) })
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)

              MineSettingRow({
                title: '导出 TXT',
                subtitle: '复制到剪贴板并预览',
                fontScale: this.uiFontScale,
                onTap: (): void => { void this.exportTxt() }
              })
              MineSettingRow({
                title: '导出 Markdown',
                subtitle: '复制到剪贴板并预览',
                fontScale: this.uiFontScale,
                onTap: (): void => { void this.exportMd() }
              })

              Row({ space: Theme.space.s3 }) {
                Column({ space: 2 }) {
                  Text('设置与隐私')
                    .fontSize(Theme.type.subhead * this.uiFontScale)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                  Text('协议 · 撤回 · 注销')
                    .fontSize(Theme.type.caption * this.uiFontScale)
                    .fontColor(Theme.colors().textSecondary)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .onClick(() => {
                this.confirmDelete = false
                this.showSettings = true
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
                  label: '登录 / 注册',
                  onTap: (): void => { this.onOpenLogin() }
                })
              }

              Text('微观志 v1.0.5 · 数据默认仅保存在本机')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textTertiary)
                .width('100%')
                .textAlign(TextAlign.Center)
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          }
          .layoutWeight(1)
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.body)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor('#1A2A3A')
            .border({ width: 1, color: '#C9A96E' })
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }

      if (this.showLegal) {
        LegalDocOverlay({
          kind: this.legalKind,
          onClose: () => { this.showLegal = false }
        })
      }

      if (this.exportText.length > 0) {
        this.ExportPreview()
      }

      if (this.showRecap) {
        WeekRecapPane({
          onClose: (): void => {
            this.showRecap = false
            this.hideTab(false)
          },
          onWrite: (): void => { this.openWrite('') },
          onOpen: (id: string): void => {
            this.showRecap = false
            this.detailId = id
            this.hideTab(true)
          }
        })
      }

      if (this.detailId.length > 0) {
        EssayDetailPane({
          essayId: this.detailId,
          fontScale: this.uiFontScale,
          onClose: (): void => {
            this.detailId = ''
            this.hideTab(false)
          },
          onEdit: (): void => { this.openEditFromDetail() },
          onDeleted: (): void => {
            this.detailId = ''
            this.hideTab(false)
            void this.loadStats()
          },
          onChanged: (): void => { void this.loadStats() },
          onOpenRelated: (id: string): void => { this.detailId = id }
        })
      }

      if (this.showContrast) {
        ContrastPane({
          onClose: (): void => {
            this.showContrast = false
            this.hideTab(false)
          },
          onSaved: (): void => {
            this.showContrast = false
            this.hideTab(false)
            void this.loadStats()
          }
        })
      }

      if (this.showAlbums) {
        AlbumListPane({
          onClose: (): void => {
            this.showAlbums = false
            this.hideTab(false)
          },
          onOpenEssay: (id: string): void => {
            this.showAlbums = false
            this.detailId = id
            this.hideTab(true)
          }
        })
      }

      if (this.showThemes) {
        ThemeListPane({
          onClose: (): void => {
            this.showThemes = false
            this.hideTab(false)
          },
          onCreate: (): void => {
            this.showThemeEdit = true
          },
          onOpenEssay: (id: string): void => {
            this.showThemes = false
            this.detailId = id
            this.hideTab(true)
          }
        })
      }

      if (this.showThemeEdit) {
        ThemeEditorSheet({
          themeId: '',
          onClose: (): void => {
            this.showThemeEdit = false
            this.hideTab(false)
          },
          onSaved: (): void => {
            this.showThemeEdit = false
            this.showThemes = false
            this.hideTab(false)
            void this.loadStats()
          }
        })
      }

      if (this.showBadges) {
        BadgeWallPane({
          onClose: (): void => {
            this.showBadges = false
            this.hideTab(false)
          }
        })
      }

      if (this.showMonth) {
        MonthRecapPane({
          year: this.monthYear,
          month: this.monthIndex,
          onClose: (): void => {
            this.showMonth = false
            this.hideTab(false)
          },
          onWrite: (): void => {
            this.showMonth = false
            this.openWrite('')
          },
          onOpen: (id: string): void => {
            this.showMonth = false
            this.detailId = id
            this.hideTab(true)
          }
        })
      }

      if (this.showYear) {
        YearRecapPane({
          year: this.monthYear,
          onClose: (): void => {
            this.showYear = false
            this.hideTab(false)
          },
          onWrite: (): void => {
            this.showYear = false
            this.openWrite('')
          },
          onOpen: (id: string): void => {
            this.showYear = false
            this.detailId = id
            this.hideTab(true)
          }
        })
      }

      if (this.showEditor) {
        EssayEditorSheet({
          essayId: this.editingId,
          fontScale: this.uiFontScale,
          openAsCard: this.editingId.length === 0,
          onClose: (): void => {
            this.showEditor = false
            this.editingId = ''
            this.hideTab(this.detailId.length > 0)
            void this.loadStats()
          },
          onSaved: (): void => {
            this.showEditor = false
            this.editingId = ''
            this.hideTab(false)
            void this.loadStats()
          }
        })
      }
    }
    .width('100%')
    .height('100%')
    .onAppear((): void => {
      const host = this.getUIContext().getHostContext()
      if (host !== undefined) {
        this.uiContext = host as common.UIAbilityContext
      }
      this.uiFontScale = this.fontScale
      this.syncDarkFromMode()
      void this.loadStats()
    })
  }

  @Builder
  FontChip(label: string, scale: number) {
    Text(label)
      .fontSize(Theme.type.body)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.uiFontScale === scale ? '#FFFFFF' : Theme.colors().textPrimary)
      .textAlign(TextAlign.Center)
      .layoutWeight(1)
      .padding({ top: 10, bottom: 10 })
      .backgroundColor(this.uiFontScale === scale ? '#1A2A3A' : Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.sm)
      .onClick((): void => { this.applyFont(scale) })
  }

  @Builder
  ExportPreview() {
    Column() {
      Row() {
        Text(this.exportTitle)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Blank()
        Text('关闭')
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { this.exportText = '' })
      }
      .width('100%')
      .padding(Theme.space.pageX)
      Scroll() {
        Text(this.exportText)
          .fontSize(Theme.type.bodyS * this.uiFontScale)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
      }
      .layoutWeight(1)
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s8 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
    .zIndex(30)
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
          AppButton({
            label: '清除缓存',
            variant: 'secondary',
            onTap: (): void => { this.handleClearCache() }
          })
          AppButton({
            label: this.confirmDelete ? '再点一次确认注销' : '注销账号',
            variant: 'secondary',
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
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }
}
