import { HomeHero } from '../components/essay/HomeHero'
import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { EssayListCard } from '../components/essay/EssayListCard'
import { EssayDetailPane } from '../components/essay/EssayDetailPane'
import { EssayEditorSheet } from '../components/essay/EssayEditorSheet'
import { PracticeStrip } from '../components/essay/PracticeStrip'
import { WeekRecapPane } from '../components/essay/WeekRecapPane'
import { ContrastPane } from '../components/essay/ContrastPane'
import { ThemeListPane } from '../components/essay/ThemeListPane'
import { AlbumListPane } from '../components/essay/AlbumListPane'
import { ThemeEditorSheet } from '../components/essay/ThemeEditorSheet'
import { MicroEssay } from '../models/EssayModels'
import { ObserveTheme } from '../models/GrowthModels'
import { EssayStore } from '../services/EssayStore'
import { GrowthStore } from '../services/GrowthStore'
import { PromptService } from '../services/PromptService'
import { DateHelper } from '../services/DateHelper'
import { ObserveStatTile } from '../components/essay/ObserveStatTile'
import { ObserveMethodCards } from '../components/essay/ObserveMethodCards'
import { ObserveProgressCard } from '../components/essay/ObserveProgressCard'
import { ObservePracticePath } from '../components/essay/ObservePracticePath'
import { ObserveDifferentiatorBanner } from '../components/essay/ObserveDifferentiatorBanner'
import { SenseWeekCharts } from '../components/essay/SenseWeekCharts'
import { EssayStatsService } from '../services/EssayStatsService'
import { SenseCount, DayCount } from '../models/GrowthModels'

@Component
export struct TodayPage {
  @Prop @Watch('onReloadToken') reloadToken: number = 0
  @StorageLink('essayFontScale') fontScale: number = 1
  @StorageLink('essayDataEpoch') @Watch('onEpoch') dataEpoch: number = 0
  @StorageLink('themeEpoch') @Watch('onThemeEpoch') themeEpoch: number = 0
  @StorageLink('growthToast') @Watch('onToast') growthToast: string = ''
  @StorageLink('openContrast') @Watch('onOpenContrast') openContrastFlag: number = 0
  @StorageLink('openObserveCard') @Watch('onOpenCardFlag') openObserveCard: number = 0
  @StorageLink('currentUsername') currentUsername: string = ''

  @State essays: MicroEssay[] = []
  @State recent: MicroEssay[] = []
  @State browsed: MicroEssay[] = []
  @State prompt: string = ''
  @State todayDone: boolean = false
  @State streak: number = 0
  @State essayCount: number = 0
  @State favCount: number = 0
  @State weekCount: number = 0
  @State statsStamp: number = 0
  @State themeTitle: string = ''
  @State themeLine: string = '还没有进行中的专题'
  @State themePct: number = 0
  @State contrastWeekDone: boolean = false
  @State toastText: string = ''
  @State detailId: string = ''
  @State showEditor: boolean = false
  @State editingId: string = ''
  @State showRecap: boolean = false
  @State showContrast: boolean = false
  @State showThemes: boolean = false
  @State showThemeEdit: boolean = false
  @State showAlbums: boolean = false
  @State senseRows: SenseCount[] = []
  @State weekRows: DayCount[] = []
  @State openAsCard: boolean = true

  aboutToAppear(): void {
    this.prompt = PromptService.todayPrompt(DateHelper.todayKey())
    void this.reload()
    this.consumeContrastFlag()
    this.onOpenCardFlag()
  }

  onEpoch(): void {
    void this.reload()
  }

  onReloadToken(): void {
    void this.reload()
  }

  onThemeEpoch(): void {
    void this.reload()
  }

  onOpenContrast(): void {
    this.consumeContrastFlag()
  }

  onOpenCardFlag(): void {
    if (this.openObserveCard > 0) {
      this.openNew(true)
      AppStorage.setOrCreate('openObserveCard', 0)
    }
  }

  private consumeContrastFlag(): void {
    if (this.openContrastFlag > 0) {
      this.showContrast = true
      AppStorage.setOrCreate('openContrast', 0)
    }
  }

  onToast(): void {
    if (this.growthToast.length > 0) {
      this.toastText = `点亮徽章：${this.growthToast}`
      AppStorage.setOrCreate('growthToast', '')
      setTimeout((): void => { this.toastText = '' }, 2800)
    }
  }

  private async reload(): Promise<void> {
    let list = await EssayStore.loadAll()
    const repaired = await GrowthStore.repairAndRelink(list)
    if (repaired) {
      await EssayStore.persistAll(list)
      list = await EssayStore.loadAll()
    }
    this.essays = list
    let fav = 0
    let weekN = 0
    for (const it of list) {
      if (it.favorite) {
        fav++
      }
      if (EssayStore.isInWeek(it)) {
        weekN++
      }
    }
    this.essayCount = list.length
    this.favCount = fav
    this.weekCount = weekN
    this.streak = GrowthStore.streakOf(list)
    this.todayDone = GrowthStore.todayWritten(list)
    this.contrastWeekDone = this.hasContrastInWeek(list)
    this.recent = await EssayStore.loadRecentUpdated(2)
    this.browsed = await EssayStore.loadRecentBrowsed(2)
    this.senseRows = EssayStatsService.senseCountsOf(list)
    this.weekRows = EssayStatsService.weekDayCountsOf(list)
    const theme = await GrowthStore.activeTheme()
    this.applyTheme(theme, list)
    this.statsStamp = this.statsStamp + 1
  }

  private applyTheme(theme: ObserveTheme | undefined, list: MicroEssay[]): void {
    if (theme === undefined) {
      this.themeTitle = ''
      this.themeLine = '还没有进行中的专题'
      this.themePct = 0
      return
    }
    const n = GrowthStore.themeProgress(theme, list)
    const pct = theme.targetCount > 0 ? Math.round(n * 100 / theme.targetCount) : 0
    this.themeTitle = theme.title
    this.themeLine = `${n} / ${theme.targetCount} 篇`
    this.themePct = pct > 100 ? 100 : pct
  }

  private hasContrastInWeek(list: MicroEssay[]): boolean {
    for (const it of list) {
      if (!EssayStore.isInWeek(it)) {
        continue
      }
      if (it.kind === 'contrast' || it.tagsCsv.indexOf('对照') >= 0) {
        return true
      }
    }
    return false
  }

  private greet(): string {
    if (this.currentUsername.length > 0) {
      return this.currentUsername
    }
    return '观察者'
  }

  private openNew(card: boolean): void {
    this.editingId = ''
    this.openAsCard = card
    this.showEditor = true
  }

  private openFromPrompt(): void {
    AppStorage.setOrCreate('essayCardHint', this.prompt)
    this.openNew(true)
  }

  private openFromHint(hint: string): void {
    AppStorage.setOrCreate('essayPracticeHint', hint)
    this.openNew(true)
  }

  private async openCapsule(): Promise<void> {
    const it = await EssayStore.findRandom()
    if (it === undefined) {
      this.openNew(true)
      return
    }
    this.detailId = it.id
  }

  private openEdit(id: string): void {
    this.editingId = id
    this.showEditor = true
    this.detailId = ''
  }

  private openThemeEntry(): void {
    if (this.themeTitle.length > 0) {
      this.showThemes = true
    } else {
      this.showThemeEdit = true
    }
  }

  private openPracticeArchive(): void {
    AppStorage.setOrCreate('openObserveListKind', '')
    AppStorage.setOrCreate('openObserveList', Date.now())
    AppStorage.setOrCreate('essayTabIndex', 1)
  }

  build() {
    Stack() {
      Scroll() {
        Column() {
          HomeHero({
            title: '微观志',
            subtitle: `${this.greet()} · 五感观察练习本 · 连续 ${this.streak} 天`
          })

          Column({ space: Theme.space.s3 }) {
            ObserveDifferentiatorBanner()
            ObservePracticePath({
              todayCardDone: this.todayDone,
              contrastWeekDone: this.contrastWeekDone,
              themeActive: this.themeTitle.length > 0,
              themeLine: this.themeLine,
              themePct: this.themePct,
              onCard: (): void => { this.openNew(true) },
              onContrast: (): void => { this.showContrast = true },
              onTheme: (): void => { this.openThemeEntry() }
            })
            ObserveMethodCards({
              onCard: (): void => { this.openNew(true) },
              onContrast: (): void => { this.showContrast = true },
              onTheme: (): void => { this.openThemeEntry() },
              onAlbum: (): void => { this.showAlbums = true }
            })
            ObserveProgressCard({
              todayDone: this.todayDone,
              themeTitle: this.themeTitle,
              themeLine: this.themeLine,
              themePct: this.themePct,
              onWrite: (): void => { this.openNew(true) }
            })
            Row({ space: Theme.space.s2 }) {
              ObserveStatTile({ value: this.essayCount, label: '篇数', compact: true })
              ObserveStatTile({ value: this.favCount, label: '珍藏', compact: true })
              ObserveStatTile({ value: this.streak, label: '连续', compact: true })
              ObserveStatTile({ value: this.weekCount, label: '本周', compact: true })
            }
            .width('100%')
            if (this.essayCount > 0) {
              Column({ space: Theme.space.s3 }) {
                Text('我的观察档案')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                SenseWeekCharts({
                  senseRows: this.senseRows,
                  weekRows: this.weekRows
                })
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
            }
            Row({ space: Theme.space.s2 }) {
              Text('时光胶囊')
                .fontSize(Theme.type.bodyS)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
                .layoutWeight(1)
                .textAlign(TextAlign.Center)
                .padding({ top: 10, bottom: 10 })
                .backgroundColor('#2D4A5E')
                .borderRadius(Theme.radius.sm)
                .onClick((): void => { void this.openCapsule() })
              Text('本周回顾')
                .fontSize(Theme.type.bodyS)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .layoutWeight(1)
                .textAlign(TextAlign.Center)
                .padding({ top: 10, bottom: 10 })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.sm)
                .onClick((): void => { this.showRecap = true })
            }
            .width('100%')
            this.PromptCard()
            PracticeStrip({
              fontScale: this.fontScale,
              onWrite: (hint: string): void => { this.openFromHint(hint) }
            })
            if (this.browsed.length > 0) {
              Text('继续阅读')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              ForEach(this.browsed, (item: MicroEssay) => {
                EssayListCard({
                  essay: item,
                  fontScale: this.fontScale,
                  onTap: (): void => { this.detailId = item.id }
                })
              }, (item: MicroEssay) => `b_${item.id}_${item.lastOpenedAt}`)
            }
            if (this.recent.length > 0 || this.browsed.length > 0) {
              Row() {
                Text('最近练习')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                Blank().layoutWeight(1)
                Text('练习 Tab 查看全部 →')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandPrimary)
                  .onClick((): void => { this.openPracticeArchive() })
              }
              .width('100%')
            }
            if (this.recent.length === 0 && this.browsed.length === 0) {
              Column({ space: Theme.space.s3 }) {
                Image($r('app.media.empty_quiet'))
                  .width('72%')
                  .aspectRatio(1)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(Theme.radius.lg)
                AppEmpty({
                  title: '还没有观察练习',
                  description: '从第一张五感卡开始，完成今日练习路径',
                  actionLabel: '写五感卡',
                  onAction: (): void => { this.openNew(true) }
                })
              }
              .width('100%')
            } else {
              ForEach(this.recent, (item: MicroEssay) => {
                EssayListCard({
                  essay: item,
                  fontScale: this.fontScale,
                  onTap: (): void => { this.detailId = item.id }
                })
              }, (item: MicroEssay) => item.id)
            }
            Blank().height(Theme.space.s10)
          }
          .width('100%')
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            top: Theme.space.s3
          })
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.body)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('#1A2A3A')
          .border({ width: 1, color: '#C9A96E' })
          .borderRadius(Theme.radius.pill)
          .position({ x: '12%', y: 44 })
          .zIndex(30)
      }

      if (this.detailId.length > 0) {
        EssayDetailPane({
          essayId: this.detailId,
          fontScale: this.fontScale,
          onClose: (): void => { this.detailId = '' },
          onEdit: (): void => { this.openEdit(this.detailId) },
          onDeleted: (): void => {
            this.detailId = ''
            void this.reload()
          },
          onChanged: (): void => { void this.reload() },
          onOpenRelated: (id: string): void => { this.detailId = id }
        })
      }
      if (this.showRecap) {
        WeekRecapPane({
          onClose: (): void => { this.showRecap = false },
          onWrite: (): void => {
            this.showRecap = false
            this.openNew(true)
          },
          onOpen: (id: string): void => {
            this.showRecap = false
            this.detailId = id
          }
        })
      }
      if (this.showContrast) {
        ContrastPane({
          onClose: (): void => { this.showContrast = false },
          onSaved: (): void => {
            this.showContrast = false
            void this.reload()
          }
        })
      }
      if (this.showThemes) {
        ThemeListPane({
          onClose: (): void => { this.showThemes = false },
          onCreate: (): void => {
            this.showThemeEdit = true
          },
          onOpenEssay: (id: string): void => {
            this.showThemes = false
            this.detailId = id
          }
        })
      }
      if (this.showAlbums) {
        AlbumListPane({
          onClose: (): void => { this.showAlbums = false },
          onOpenEssay: (id: string): void => {
            this.showAlbums = false
            this.detailId = id
          }
        })
      }
      if (this.showThemeEdit) {
        ThemeEditorSheet({
          themeId: '',
          onClose: (): void => { this.showThemeEdit = false },
          onSaved: (): void => {
            this.showThemeEdit = false
            this.showThemes = false
            void this.reload()
          }
        })
      }
      if (this.showEditor) {
        EssayEditorSheet({
          essayId: this.editingId,
          fontScale: this.fontScale,
          openAsCard: this.openAsCard,
          onClose: (): void => {
            this.showEditor = false
            void this.reload()
          },
          onSaved: (): void => {
            this.showEditor = false
            void this.reload()
          }
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  PromptCard() {
    Column({ space: 6 }) {
      Text('今日微题')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().brandAccent)
        .width('100%')
      Text(this.prompt)
        .fontSize(Theme.type.body * this.fontScale)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text('用这条观察题写一篇 →')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().brandPrimary)
        .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick((): void => { this.openFromPrompt() })
  }
}
