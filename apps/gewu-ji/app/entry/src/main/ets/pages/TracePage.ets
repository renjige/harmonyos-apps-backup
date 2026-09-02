import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { GewuWeekStrip } from '../components/gewu/GewuWeekStrip'
import { TraceGrowthPane } from '../components/gewu/TraceGrowthPane'
import { TraceStats, UserProfile } from '../models/KnowledgeModels'
import { AtlasStat, DayCount, GewuBadge, GewuEvent, WeekMark } from '../models/FieldModels'
import { GewuStore } from '../services/GewuStore'
import { FieldStore } from '../services/FieldStore'
import { PrivacyService } from '../services/PrivacyService'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { AppContextService } from '../services/AppContextService'

@Component
export struct TracePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  onDataChanged: () => void = () => {}
  @StorageLink('themeRevision') themeRevision: number = 0
  @StorageLink('traceSettingsOpen') @Watch('onTraceSettingsFlag') traceSettingsOpen: boolean = false
  @State stats: TraceStats = new TraceStats()
  @State profile: UserProfile = new UserProfile()
  @State themeMode: string = 'system'
  @State showSettings: boolean = false
  @StorageLink('gewuLegalKind') gewuLegalKind: string = ''
  @State weekMarks: WeekMark[] = []
  @State atlasRows: AtlasStat[] = []
  @State confirmRevoke: boolean = false
  @State toastText: string = ''
  @State badges: GewuBadge[] = []
  @State events: GewuEvent[] = []
  @State weekBars: DayCount[] = []
  @State weekLine: string = ''
  @State monthLine: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.stats = await GewuStore.stats()
    this.profile = await GewuStore.loadProfile()
    this.weekMarks = await FieldStore.weekMarks()
    this.atlasRows = await GewuStore.atlasStats()
    this.badges = await FieldStore.loadBadges()
    this.events = await FieldStore.loadEvents()
    this.weekBars = await FieldStore.weekBars()
    const dash = await FieldStore.loadDash(this.stats.favoriteCount)
    this.weekLine = dash.weekLine
    this.monthLine = dash.monthLine
    const mode = this.profile.themeMode.length > 0 ? this.profile.themeMode : 'system'
    this.themeMode = mode
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2600)
  }

  private ringProgress(): number {
    if (this.stats.totalPool <= 0) {
      return 0
    }
    const pct = (this.stats.readDays / 365) * 100
    if (pct > 100) {
      return 100
    }
    return pct
  }

  private async persistTheme(mode: string): Promise<void> {
    this.themeMode = mode
    this.profile.themeMode = mode
    const ctx = AppContextService.getContext()
    if (ctx !== null) {
      ThemeAppearance.apply(mode, ctx)
    } else {
      ThemeAppearance.apply(mode)
    }
    await GewuStore.saveProfile(this.profile)
    this.onDataChanged()
    this.showToast('主题已切换')
  }

  private closeSettings(): void {
    this.showSettings = false
    this.confirmRevoke = false
    AppStorage.setOrCreate('traceSettingsOpen', false)
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  onTraceSettingsFlag(): void {
    if (!this.traceSettingsOpen) {
      this.showSettings = false
      this.confirmRevoke = false
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  onBackPress(): boolean {
    if (this.gewuLegalKind.length > 0) {
      AppStorage.setOrCreate('gewuLegalKind', '')
      return true
    }
    if (this.showSettings) {
      this.closeSettings()
      return true
    }
    return false
  }

  private async handleRevokePrivacy(): Promise<void> {
    await PrivacyService.revoke()
    this.closeSettings()
    this.showToast('已撤回本地隐私记录')
  }

  private async clearCache(): Promise<void> {
    await GewuStore.clearCache()
    this.showToast('界面缓存已清理（阅读数据未删除）')
  }

  private openLegal(kind: string): void {
    AppStorage.setOrCreate('gewuLegalKind', kind)
  }

  private closeLegal(): void {
    AppStorage.setOrCreate('gewuLegalKind', '')
  }

  private legalKind(): LegalDocKind {
    if (this.gewuLegalKind === 'agreement') {
      return 'agreement'
    }
    if (this.gewuLegalKind === 'collect') {
      return 'collect'
    }
    if (this.gewuLegalKind === 'third') {
      return 'third'
    }
    return 'privacy'
  }

  private openWeekDay(key: string): void {
    AppStorage.setOrCreate('recordDateFilter', key)
    AppStorage.setOrCreate('switchTabIndex', 2)
  }

  @Builder
  ThemeChip(label: string, mode: string) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.themeMode === mode ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .margin({ right: 8, bottom: 8 })
      .backgroundColor(this.themeMode === mode ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { void this.persistTheme(mode) })
  }

  @Builder
  SettingsPanel() {
    Column({ space: Theme.space.s4 }) {
      Row() {
        Text('设置与隐私')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.closeSettings() })
      }
      .width('100%')

      Text('主题模式')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        this.ThemeChip('跟随系统', 'system')
        this.ThemeChip('浅色', 'light')
        this.ThemeChip('深色', 'dark')
      }
      .width('100%')

      Row() {
        AppButton({
          label: '查看《用户协议》全文',
          variant: 'secondary',
          onTap: (): void => { this.openLegal('agreement') }
        })
      }
      .width('100%')
      .onClick((): void => { this.openLegal('agreement') })
      Row() {
        AppButton({
          label: '查看《隐私政策》全文',
          variant: 'secondary',
          onTap: (): void => { this.openLegal('privacy') }
        })
      }
      .width('100%')
      .onClick((): void => { this.openLegal('privacy') })
      Row() {
        AppButton({
          label: '个人信息收集清单',
          variant: 'ghost',
          onTap: (): void => { this.openLegal('collect') }
        })
      }
      .width('100%')
      .onClick((): void => { this.openLegal('collect') })
      Row() {
        AppButton({
          label: '第三方共享清单',
          variant: 'ghost',
          onTap: (): void => { this.openLegal('third') }
        })
      }
      .width('100%')
      .onClick((): void => { this.openLegal('third') })
      AppButton({
        label: '清除缓存',
        variant: 'ghost',
        onTap: (): void => { void this.clearCache() }
      })

      if (!this.confirmRevoke) {
        AppButton({
          label: '撤回隐私同意',
          variant: 'danger',
          onTap: (): void => { this.confirmRevoke = true }
        })
      } else {
        Text('撤回后仅清除本机记录，系统托管的隐私声明仍由华为平台管理。确认撤回？')
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Row({ space: Theme.space.s3 }) {
          Column() {
            AppButton({
              label: '取消',
              variant: 'ghost',
              onTap: (): void => { this.confirmRevoke = false }
            })
          }
          .layoutWeight(1)
          Column() {
            AppButton({
              label: '确认撤回',
              variant: 'danger',
              onTap: (): void => { void this.handleRevokePrivacy() }
            })
          }
          .layoutWeight(1)
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding(Theme.space.s6)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Row() {
            Column({ space: Theme.space.s1 }) {
              Text('智慧足迹')
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Text(this.stats.streakHint)
                .fontSize(Theme.type.subhead)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            Column() {
              AppIcon({ name: 'gear', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
            }
            .width(44)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .onClick((): void => {
              this.showSettings = true
              AppStorage.setOrCreate('traceSettingsOpen', true)
              AppStorage.setOrCreate('tabBarHidden', true)
            })
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)

          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.Center }) {
              Progress({ value: this.ringProgress(), total: 100, type: ProgressType.Ring })
                .width(160)
                .height(160)
                .color(Theme.colors().brandPrimary)
                .backgroundColor(Theme.colors().brandPrimaryContainer)
              Column({ space: Theme.space.s1 }) {
                Text(`${this.stats.readDays}`)
                  .fontSize(Theme.type.display)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                Text('阅读天数')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
            }
            .width('100%')
            .height(180)
          }
          .alignItems(HorizontalAlign.Center)
          .width('100%')
          .padding(Theme.space.s6)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          Row({ space: Theme.space.s3 }) {
            Column() {
              AppStatCard({
                label: '收藏',
                value: `${this.stats.favoriteCount}`,
                trend: '',
                positive: true
              })
            }
            .layoutWeight(1)
            Column() {
              AppStatCard({
                label: '想深究',
                value: `${this.stats.deepenCount}`,
                trend: '',
                positive: true
              })
            }
            .layoutWeight(1)
          }
          .width('100%')

          Column() {
            AppStatCard({
              label: '知识库总量',
              value: `${this.stats.totalPool}`,
              trend: `札记 ${this.stats.noteCount} 则 · 可检索全部条目`,
              positive: true
            })
          }
          .width('100%')

          Row({ space: Theme.space.s3 }) {
            Column() {
              AppStatCard({
                label: '观察记录',
                value: `${this.stats.recordCount}`,
                trend: `连续 ${this.stats.exploreStreak} 天`,
                positive: true
              })
            }
            .layoutWeight(1)
            Column() {
              AppStatCard({
                label: '收藏夹 / 任务',
                value: `${this.stats.albumCount}`,
                trend: `今日任务 ${this.stats.questDone}/5`,
                positive: true
              })
            }
            .layoutWeight(1)
          }
          .width('100%')

          GewuWeekStrip({
            marks: this.weekMarks,
            onPick: (key: string): void => { this.openWeekDay(key) }
          })

          Column({ space: Theme.space.s2 }) {
            Text('图鉴收集进度')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text('收藏或写过观察的条目会计入进度，鼓励持续探索。')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            ForEach(this.atlasRows, (row: AtlasStat) => {
              Row() {
                Text(row.kind)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .layoutWeight(1)
                Text(`${row.saved}/${row.total}`)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              }
              .width('100%')
            }, (row: AtlasStat) => row.kind)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          TraceGrowthPane({
            weekLine: this.weekLine,
            monthLine: this.monthLine,
            bars: this.weekBars,
            badges: this.badges,
            events: this.events
          })

          Row().height(this.bottomInset)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      if (this.gewuLegalKind.length > 0) {
        Column() {
          LegalDocOverlay({
            kind: this.legalKind(),
            onClose: (): void => { this.closeLegal() }
          })
        }
        .width('100%')
        .height('100%')
        .zIndex(90)
      } else if (this.showSettings) {
        Column() {
          Column()
            .width('100%')
            .layoutWeight(1)
            .backgroundColor(Theme.colors().overlayScrim)
            .onClick((): void => { this.closeSettings() })
          this.SettingsPanel()
        }
        .width('100%')
        .height('100%')
        .zIndex(30)
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .position({ x: '50%', y: 48 })
          .translate({ x: '-50%' })
          .zIndex(40)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.pageBg())
  }

  private pageBg(): string {
    if (this.themeRevision < 0) {
      return Theme.colors().surfacePage
    }
    return Theme.colors().surfacePage
  }
}
