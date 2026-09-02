import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { RecordsPage } from './RecordsPage'
import { AtlasTabPage } from './AtlasTabPage'
import { InsightPage } from './InsightPage'
import { MinePage } from './MinePage'
import { RecordDetailOverlay } from '../components/guanwu/RecordDetailOverlay'
import { RecordEditorOverlay } from '../components/guanwu/RecordEditorOverlay'
import { SubjectEditorOverlay } from '../components/guanwu/SubjectEditorOverlay'
import { SubjectDetailOverlay } from '../components/guanwu/SubjectDetailOverlay'
import { ShareCardOverlay } from '../components/guanwu/ShareCardOverlay'
import { ExploreHubOverlay } from '../components/guanwu/ExploreHubOverlay'
import { AchievementWallOverlay } from '../components/guanwu/AchievementWallOverlay'
import { GrowthTimelineOverlay } from '../components/guanwu/GrowthTimelineOverlay'
import { ReviewDetailOverlay } from '../components/guanwu/ReviewDetailOverlay'
import { ObserveRecord, SubtypeOption } from '../models/ObserveModels'
import { ObserveSubject, ObserveTemplate, ExploreTaskDef } from '../models/ObserveCatalog'
import { ObserveStore } from '../services/ObserveStore'
import { ObserveAtlasStore } from '../services/ObserveAtlasStore'
import { DateHelper } from '../services/DateHelper'
import { ObserveLifecycleService } from '../services/ObserveLifecycleService'
import { ActivityTimelineService } from '../services/ActivityTimelineService'
import { AchievementService } from '../services/AchievementService'
import { AchievementItem } from '../models/ActivityModels'
import { ActivityEvent } from '../models/ActivityModels'
import { InsightService } from '../services/InsightService'
import { MorningCardService, DailyChallenge } from '../services/MorningCardService'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const defs: string[][] = [
      ['0', 'home', '今日'],
      ['1', 'list', '记录'],
      ['2', 'book', '图鉴'],
      ['3', 'chart', '成长'],
      ['4', 'user', '我的']
    ]
    for (const d of defs) {
      const t = new TabItem()
      t.index = parseInt(d[0], 10)
      t.name = d[1] as AppIconName
      t.label = d[2]
      tabs.push(t)
    }
    return tabs
  }
}

@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State refreshToken: number = 0
  @State showEditor: boolean = false
  @State showDetail: boolean = false
  @State showSubjectEditor: boolean = false
  @State showSubjectDetail: boolean = false
  @State showShare: boolean = false
  @State showExploreHub: boolean = false
  @State showAchievementWall: boolean = false
  @State showGrowthTimeline: boolean = false
  @State showReviewDetail: boolean = false
  @State achievementItems: AchievementItem[] = []
  @State timelineEvents: ActivityEvent[] = []
  @State reviewTitle: string = ''
  @State reviewLines: string[] = []
  @State exploreChallenge: DailyChallenge = new DailyChallenge()
  @State globalToast: string = ''
  @State editMode: boolean = false
  @State detailRecord: ObserveRecord = new ObserveRecord()
  @State editorRecord: ObserveRecord = new ObserveRecord()
  @State subjectDraft: ObserveSubject = new ObserveSubject()
  @State subjectWasNew: boolean = false
  @State activeSubjectId: string = ''
  @State detailRefreshKey: number = 0
  @Prop appName: string = '观物'
  onPrivacyRevoked: () => void = () => {}
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  private tabs: TabItem[] = TabItem.all()
  private readonly tabBarHeight: number = 60
  private readonly tabSafeBottom: number = 16

  private bumpRefresh(): void {
    this.refreshToken++
  }

  private hideTab(): void {
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private showGlobalToast(msg: string): void {
    this.globalToast = msg
    setTimeout((): void => { this.globalToast = '' }, 2800)
  }

  private restoreTab(): void {
    AppStorage.setOrCreate('tabBarHidden',
      this.showEditor || this.showDetail || this.showSubjectEditor || this.showSubjectDetail ||
      this.showShare || this.showExploreHub || this.showAchievementWall ||
      this.showGrowthTimeline || this.showReviewDetail)
  }

  private async openExploreHub(): Promise<void> {
    this.exploreChallenge = MorningCardService.todayChallenge()
    this.showExploreHub = true
    this.hideTab()
  }

  private closeExploreHub(): void {
    this.showExploreHub = false
    this.restoreTab()
  }

  private async openAchievementWall(): Promise<void> {
    this.achievementItems = await AchievementService.listAll()
    this.showAchievementWall = true
    this.hideTab()
  }

  private closeAchievementWall(): void {
    this.showAchievementWall = false
    this.restoreTab()
  }

  private async openGrowthTimeline(): Promise<void> {
    this.timelineEvents = await ActivityTimelineService.loadRecent(50)
    this.showGrowthTimeline = true
    this.hideTab()
  }

  private closeGrowthTimeline(): void {
    this.showGrowthTimeline = false
    this.restoreTab()
  }

  private async openReview(mode: string): Promise<void> {
    if (mode === 'today') {
      this.reviewTitle = '今日回顾'
      this.reviewLines = await InsightService.buildTodayReview()
    } else if (mode === 'month') {
      this.reviewTitle = '本月回顾'
      this.reviewLines = await InsightService.buildMonthlyReview()
    } else if (mode === 'year') {
      this.reviewTitle = '年度回顾'
      this.reviewLines = await InsightService.buildYearReview()
    } else {
      this.reviewTitle = '本周回顾'
      this.reviewLines = await InsightService.buildWeeklyReview()
    }
    this.showReviewDetail = true
    this.hideTab()
  }

  private closeReviewDetail(): void {
    this.showReviewDetail = false
    this.restoreTab()
  }

  private openTemplatePrefill(tpl: ObserveTemplate): void {
    const record = ObserveRecord.createNew(DateHelper.todayKey())
    record.kind = tpl.kind
    record.content = tpl.prompt
    record.categoryKey = tpl.categoryKey
    record.tags = tpl.tags
    this.closeExploreHub()
    this.openEditor(false, record)
  }

  private openExplorePrefill(task: ExploreTaskDef): void {
    const record = ObserveRecord.createNew(DateHelper.todayKey())
    record.kind = task.kind
    record.content = task.prompt
    record.categoryKey = task.categoryKey
    record.tags = task.tags
    this.closeExploreHub()
    this.openEditor(false, record)
  }

  private openEditor(edit: boolean, record: ObserveRecord): void {
    this.editMode = edit
    this.editorRecord = ObserveRecord.cloneFrom(record)
    this.showEditor = true
    this.hideTab()
  }

  private openChallenge(kind: string, hint: string): void {
    const record = ObserveRecord.createNew(DateHelper.todayKey())
    record.kind = kind
    record.content = hint
    const subs = SubtypeOption.forKind(kind)
    if (subs.length > 0) {
      record.subtypeKey = subs[0].key
    }
    this.openEditor(false, record)
  }

  private closeEditor(): void {
    this.showEditor = false
    this.restoreTab()
  }

  private async openDetail(id: string): Promise<void> {
    const found = await ObserveStore.findById(id)
    if (found === undefined) {
      return
    }
    this.detailRecord = found
    this.showDetail = true
    this.hideTab()
  }

  private closeDetail(): void {
    this.showDetail = false
    this.restoreTab()
  }

  private openAtlasTab(): void {
    this.current = 2
    this.bumpRefresh()
  }

  private openRecordsTab(): void {
    this.current = 1
    this.bumpRefresh()
  }

  private openInsightTab(): void {
    this.current = 3
    this.bumpRefresh()
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            refreshToken: this.refreshToken,
            bottomInset: this.tabBarHeight + this.tabSafeBottom,
            onOpenEditor: (): void => this.openEditor(false, new ObserveRecord()),
            onOpenChallenge: (kind: string, hint: string): void => this.openChallenge(kind, hint),
            onOpenPrefill: (record: ObserveRecord): void => this.openEditor(false, record),
            onOpenAtlas: (): void => this.openAtlasTab(),
            onOpenRecords: (): void => this.openRecordsTab(),
            onOpenInsight: (): void => this.openInsightTab(),
            onOpenExplore: (): void => { void this.openExploreHub() },
            onOpenRecord: (id: string): void => { void this.openDetail(id) },
            onAchievementToast: (msg: string): void => this.showGlobalToast(msg)
          }).layoutWeight(1)
        } else if (this.current === 1) {
          RecordsPage({
            refreshToken: this.refreshToken,
            bottomInset: this.tabBarHeight + this.tabSafeBottom,
            onOpenEditor: (): void => this.openEditor(false, new ObserveRecord()),
            onOpenAtlas: (): void => this.openAtlasTab(),
            onOpenRecord: (id: string): void => { void this.openDetail(id) }
          }).layoutWeight(1)
        } else if (this.current === 2) {
          AtlasTabPage({
            refreshToken: this.refreshToken,
            bottomInset: this.tabBarHeight + this.tabSafeBottom,
            onCreateSubject: (): void => {
              this.subjectDraft = new ObserveSubject()
              this.subjectWasNew = true
              this.showSubjectEditor = true
              this.hideTab()
            },
            onOpenSubject: (id: string): void => {
              this.activeSubjectId = id
              this.showSubjectDetail = true
              this.hideTab()
            }
          }).layoutWeight(1)
        } else if (this.current === 3) {
          InsightPage({
            refreshToken: this.refreshToken,
            bottomInset: this.tabBarHeight + this.tabSafeBottom,
            onOpenAchievements: (): void => { void this.openAchievementWall() },
            onOpenTimeline: (): void => { void this.openGrowthTimeline() },
            onOpenReview: (mode: string): void => { void this.openReview(mode) }
          }).layoutWeight(1)
        } else {
          MinePage({
            refreshToken: this.refreshToken,
            bottomInset: this.tabBarHeight + this.tabSafeBottom,
            appName: this.appName,
            onPrivacyRevoked: (): void => this.onPrivacyRevoked(),
            onDataCleared: (): void => this.bumpRefresh(),
            onOpenLogin: (): void => this.onOpenLogin(),
            onLogout: (): void => this.onLogout()
          }).layoutWeight(1)
        }

        if (!this.tabBarHidden) {
          Row() {
            ForEach(this.tabs, (t: TabItem) => {
              this.TabBarItem(t)
            }, (t: TabItem) => `${t.index}`)
          }
          .width('100%')
          .height(this.tabBarHeight)
          .padding({ left: Theme.space.s3, right: Theme.space.s3, bottom: this.tabSafeBottom })
          .margin({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s2 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          .shadow({ radius: 16, color: 'rgba(26,26,46,0.08)', offsetY: 4 })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.showDetail) {
        RecordDetailOverlay({
          record: this.detailRecord,
          onClose: (): void => this.closeDetail(),
          onEdit: (): void => this.openEditor(true, this.detailRecord),
          onShare: (): void => { this.showShare = true },
          onOpenSubject: (): void => {
            if (this.detailRecord.subjectId.length > 0) {
              this.activeSubjectId = this.detailRecord.subjectId
              this.showSubjectDetail = true
              this.hideTab()
            }
          },
          onToggleFavorite: (): void => {
            void ObserveStore.toggleFavorite(this.detailRecord.id).then(async () => {
              const unlocked = await ObserveLifecycleService.afterFavoriteToggle(this.detailRecord.id)
              if (unlocked.length > 0) {
                this.showGlobalToast(`解锁成就：${unlocked[0]}`)
              }
              void this.openDetail(this.detailRecord.id)
              this.bumpRefresh()
            })
          },
          onDelete: (): void => {
            void ObserveStore.deleteRecord(this.detailRecord.id).then(() => {
              this.closeDetail()
              this.bumpRefresh()
            })
          }
        })
      }

      if (this.showEditor) {
        RecordEditorOverlay({
          editingRecord: this.editorRecord,
          isEdit: this.editMode,
          onClose: (): void => this.closeEditor(),
          onSaved: (recordId: string): void => {
            this.closeEditor()
            void ObserveStore.findById(recordId).then(async (found) => {
              if (found !== undefined) {
                const unlocked = this.editMode ?
                  await ObserveLifecycleService.afterRecordUpdated(found) :
                  await ObserveLifecycleService.afterRecordCreated(found)
                if (unlocked.length > 0) {
                  this.showGlobalToast(`解锁成就：${unlocked[0]}`)
                }
                this.detailRecord = found
                this.detailRefreshKey++
                this.showDetail = true
                this.hideTab()
              }
            })
            this.bumpRefresh()
          }
        })
      }

      if (this.showSubjectEditor) {
        SubjectEditorOverlay({
          editing: this.subjectDraft,
          onClose: (): void => {
            this.showSubjectEditor = false
            this.restoreTab()
          },
          onSaved: (id: string): void => {
            this.showSubjectEditor = false
            this.activeSubjectId = id
            void ObserveAtlasStore.findById(id).then(async (found) => {
              if (found !== undefined && this.subjectWasNew) {
                const unlocked = await ObserveLifecycleService.afterSubjectCreated(found)
                if (unlocked.length > 0) {
                  this.showGlobalToast(`解锁成就：${unlocked[0]}`)
                }
              }
              this.subjectWasNew = false
            })
            this.showSubjectDetail = true
            this.bumpRefresh()
            this.hideTab()
          }
        })
      }

      if (this.showSubjectDetail) {
        SubjectDetailOverlay({
          subjectId: this.activeSubjectId,
          refreshToken: this.refreshToken,
          onClose: (): void => {
            this.showSubjectDetail = false
            this.restoreTab()
          },
          onEdit: (): void => {
            void ObserveAtlasStore.findById(this.activeSubjectId).then((found) => {
              if (found !== undefined) {
                this.subjectDraft = found
                this.subjectWasNew = false
                this.showSubjectEditor = true
              }
            })
          },
          onAddRecord: (): void => {
            void ObserveAtlasStore.findById(this.activeSubjectId).then((found) => {
              const record = ObserveRecord.createNew(DateHelper.todayKey())
              if (found !== undefined) {
                record.subjectId = found.id
                record.itemName = found.name
                record.categoryKey = found.categoryKey
                record.content = `继续观察「${found.name}」：`
              }
              this.openEditor(false, record)
            })
          },
          onOpenRecord: (id: string): void => { void this.openDetail(id) },
          onDeleted: (): void => {
            this.showSubjectDetail = false
            this.bumpRefresh()
            this.restoreTab()
          }
        })
      }

      if (this.showShare) {
        ShareCardOverlay({
          record: this.detailRecord,
          onClose: (): void => { this.showShare = false }
        })
      }

      if (this.showExploreHub) {
        ExploreHubOverlay({
          challenge: this.exploreChallenge,
          onClose: (): void => this.closeExploreHub(),
          onPickTemplate: (tpl: ObserveTemplate): void => this.openTemplatePrefill(tpl),
          onPickExplore: (task: ExploreTaskDef): void => this.openExplorePrefill(task),
          onAcceptChallenge: (): void => {
            this.closeExploreHub()
            this.openChallenge(this.exploreChallenge.kind, this.exploreChallenge.prompt)
          }
        })
      }

      if (this.showAchievementWall) {
        AchievementWallOverlay({
          items: this.achievementItems,
          onClose: (): void => this.closeAchievementWall()
        })
      }

      if (this.showGrowthTimeline) {
        GrowthTimelineOverlay({
          events: this.timelineEvents,
          onClose: (): void => this.closeGrowthTimeline(),
          onOpenRecord: (id: string): void => {
            this.closeGrowthTimeline()
            void this.openDetail(id)
          },
          onOpenSubject: (id: string): void => {
            this.closeGrowthTimeline()
            this.activeSubjectId = id
            this.showSubjectDetail = true
            this.hideTab()
          }
        })
      }

      if (this.showReviewDetail) {
        ReviewDetailOverlay({
          title: this.reviewTitle,
          lines: this.reviewLines,
          onClose: (): void => this.closeReviewDetail()
        })
      }

      if (this.globalToast.length > 0) {
        Text(this.globalToast)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(26,26,46,0.92)')
          .borderRadius(Theme.radius.pill)
          .position({ x: '8%', y: 48 })
          .zIndex(40)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  TabBarItem(t: TabItem) {
    Column({ space: 4 }) {
      Column() {
        AppIcon({
          name: t.name,
          iconSize: Theme.icon.md,
          color: this.current === t.index ?
            Theme.colors().brandPrimary : Theme.colors().textSecondary
        })
      }
      .width(44)
      .height(26)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.current === t.index ?
        Theme.colors().brandPrimaryContainer : 'transparent')
      .borderRadius(Theme.radius.pill)
      Text(t.label)
        .fontSize(Theme.type.caption)
        .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.current === t.index ?
          Theme.colors().brandPrimary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .padding({ top: 6 })
    .onClick((): void => {
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = t.index
      this.bumpRefresh()
    })
  }
}
