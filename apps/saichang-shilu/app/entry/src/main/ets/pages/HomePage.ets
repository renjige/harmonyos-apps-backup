import { Theme } from '../components/design-system/Theme'
import { HomeStatTile, HomeQuickChip } from '../components/sport/HomeWidgets'
import { AppRingChart } from '../components/design-system/AppChart'
import { ChallengeBar, TimelineRow } from '../components/sport/SportCards'
import { EditorialSwiper, ExploreTile, SectionHeader } from '../components/sport/SportVisual'
import { MemoryTimelinePage } from './MemoryTimelinePage'
import { GlobalSearchPage } from './GlobalSearchPage'
import { SeasonReportPage } from './SeasonReportPage'
import { DataInsightsPage } from './DataInsightsPage'
import { MatchWorkbenchPage } from './MatchWorkbenchPage'
import { MatchComparePage } from './MatchComparePage'
import { TagHubPage } from './TagHubPage'
import { MatchReportPage } from './MatchReportPage'
import { PlayerTrackerPage } from './PlayerTrackerPage'
import { TeamHubPage } from './TeamHubPage'
import { ActivityHeatmapPage } from './ActivityHeatmapPage'
import { PredictionLabPage } from './PredictionLabPage'
import { MvpLeaderboardPage } from './MvpLeaderboardPage'
import { WatchQueuePage } from './WatchQueuePage'
import { VenueJournalPage } from './VenueJournalPage'
import { WeeklyDigestPage } from './WeeklyDigestPage'
import { RecordCard } from '../components/sport/RecordCard'
import { SportRecordDetailPane } from '../components/sport/SportRecordDetailPane'
import { GoalSheet } from '../components/sport/GoalSheet'
import { RecordEditPage } from './RecordEditPage'
import { RecapQuizPage } from './RecapQuizPage'
import { RecapTimelinePage } from './RecapTimelinePage'
import { CollectEditPage } from './CollectEditPage'
import { SportRecord } from '../models/SportRecord'
import { SeasonGoal } from '../models/SportExtra'
import { DashStats, DailyPrompt, TimelineEntry } from '../models/CollectModels'
import { RecordStore } from '../services/RecordStore'
import { GoalStore } from '../services/GoalStore'
import { MemoryStats } from '../services/MemoryStats'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State recent: SportRecord[] = []
  @State dash: DashStats = new DashStats()
  @State goal: SeasonGoal = new SeasonGoal()
  @State prompt: string = DailyPrompt.today()
  @State pendingId: string = ''
  @State detailRecord: SportRecord | undefined = undefined
  @State showEdit: boolean = false
  @State showGoal: boolean = false
  @State showRecap: boolean = false
  @State showTimeline: boolean = false
  @State showCollect: boolean = false
  @State collectKind: string = 'team'
  @State recapSeedId: string = ''
  @State editMode: boolean = false
  @State editSeedId: string = ''
  @State timelinePreview: TimelineEntry[] = []
  @State showMemoryTimeline: boolean = false
  @State showSearch: boolean = false
  @State showSeasonReport: boolean = false
  @State showInsights: boolean = false
  @State showWorkbench: boolean = false
  @State workbenchId: string = ''
  @State showCompare: boolean = false
  @State showTagHub: boolean = false
  @State showReport: boolean = false
  @State showPlayerTracker: boolean = false
  @State showTeamHub: boolean = false
  @State showHeatmap: boolean = false
  @State showPrediction: boolean = false
  @State showMvpBoard: boolean = false
  @State showWatchQueue: boolean = false
  @State showVenue: boolean = false
  @State showWeeklyDigest: boolean = false
  @State reportSeedId: string = ''
  @State detailRefreshToken: number = 0
  @State pinned: SportRecord[] = []
  @Prop reloadToken: number = 0
  @State lastToken: number = -1

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const list = await RecordStore.loadAll()
    this.recent = list.length > 5 ? list.slice(0, 5) : list
    this.dash = await MemoryStats.dash()
    this.pinned = await MemoryStats.pinnedMatches()
    this.goal = await GoalStore.load()
    this.prompt = DailyPrompt.today()
    const groups = await MemoryStats.buildTimeline()
    this.timelinePreview = []
    if (groups.length > 0) {
      const first = groups[0]
      const max = first.entries.length > 3 ? 3 : first.entries.length
      for (let i = 0; i < max; i++) {
        this.timelinePreview.push(first.entries[i])
      }
    }
    this.pendingId = ''
    for (const it of list) {
      if (it.recapSummary.length === 0 && it.recapPhases.length === 0) {
        this.pendingId = it.id
        break
      }
    }
  }

  private goalPercent(): number {
    const target = this.goal.targetMatches > 0 ? this.goal.targetMatches : 20
    const p = this.dash.matches / target
    if (p > 1) {
      return 1
    }
    return p
  }

  private goTab(index: number): void {
    AppStorage.setOrCreate('mainTabIndex', index)
  }

  private async afterEditSaved(saved: SportRecord): Promise<void> {
    this.showEdit = false
    this.detailRecord = SportRecord.cloneFrom(saved)
    this.detailRefreshToken++
    await this.reload()
    const fresh = await RecordStore.findById(saved.id)
    if (fresh !== undefined) {
      this.detailRecord = fresh
      this.detailRefreshToken++
    }
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Row() {
            Column({ space: 4 }) {
              Text('赛场拾录')
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Text('记录 · 复盘 · 收藏 · 洞察')
                .fontSize(Theme.type.bodyS)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .alignItems(HorizontalAlign.Start)
            Blank()
            Text('记一场')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().brandOnPrimary)
              .padding({ left: 14, right: 14, top: 8, bottom: 8 })
              .backgroundColor(Theme.colors().brandPrimary)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => {
                this.editMode = false
                this.editSeedId = ''
                this.showEdit = true
              })
          }
          .width('100%')

          EditorialSwiper()
            .onClick((): void => { this.goTab(1) })

          if (this.dash.want > 0) {
            Stack({ alignContent: Alignment.Center }) {
              Image($r('app.media.ambient_empty'))
                .width('100%')
                .height(72)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.lg)
              Row() {
                Text(`还有 ${this.dash.want} 场待看赛事`)
                  .fontSize(Theme.type.bodyS)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#FFFFFF')
                Blank()
                Text('去整理 →')
                  .fontSize(Theme.type.caption)
                  .fontColor('#FFFFFF')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .linearGradient({
                angle: 90,
                colors: [['rgba(11,107,203,0.85)', 0], ['rgba(10,37,64,0.55)', 1]]
              })
            }
            .width('100%')
            .height(72)
            .onClick((): void => { this.goTab(1) })
          }

          Flex({ wrap: FlexWrap.Wrap }) {
            HomeStatTile({ value: `${this.dash.matches}`, label: '赛事记录', accent: '#0B6BCB' })
            HomeStatTile({ value: `${this.dash.moments}`, label: '精彩瞬间', accent: '#FF6B35' })
            HomeStatTile({ value: `${this.dash.recaps}`, label: '比赛复盘', accent: '#0F766E' })
            HomeStatTile({ value: `${this.dash.collections + this.dash.teams}`, label: '收藏档案', accent: '#7C3AED' })
          }
          .width('100%')

          Column({ space: Theme.space.s3 }) {
            SectionHeader({ title: '专业工具箱', action: '' })
            Flex({ wrap: FlexWrap.Wrap }) {
              ExploreTile({
                title: '比赛战报',
                subtitle: '一键生成完整战报',
                emoji: '📋',
                accent: '#0B6BCB',
                onTap: (): void => { this.reportSeedId = ''; this.showReport = true }
              })
              ExploreTile({
                title: '球员追踪',
                subtitle: 'MVP 与表现卡汇总',
                emoji: '⭐',
                accent: '#FF6B35',
                onTap: (): void => { this.showPlayerTracker = true }
              })
              ExploreTile({
                title: '球队中心',
                subtitle: '胜率与场均评价',
                emoji: '🏟️',
                accent: '#0F766E',
                onTap: (): void => { this.showTeamHub = true }
              })
              ExploreTile({
                title: '活跃热力图',
                subtitle: '90 天记录密度',
                emoji: '🔥',
                accent: '#7C3AED',
                onTap: (): void => { this.showHeatmap = true }
              })
              ExploreTile({
                title: '预测实验室',
                subtitle: '赛前预测命中率',
                emoji: '🎯',
                accent: '#B45309',
                onTap: (): void => { this.showPrediction = true }
              })
              ExploreTile({
                title: 'MVP 排行榜',
                subtitle: '提名次数排行',
                emoji: '🏆',
                accent: '#0B6BCB',
                onTap: (): void => { this.showMvpBoard = true }
              })
              ExploreTile({
                title: '待看清单',
                subtitle: '待看/重点赛事',
                emoji: '📺',
                accent: '#FF6B35',
                onTap: (): void => { this.showWatchQueue = true }
              })
              ExploreTile({
                title: '场馆志',
                subtitle: '地点观赛统计',
                emoji: '📍',
                accent: '#0F766E',
                onTap: (): void => { this.showVenue = true }
              })
              ExploreTile({
                title: '观赛周报',
                subtitle: '本周自动摘要',
                emoji: '📰',
                accent: '#6366F1',
                onTap: (): void => { this.showWeeklyDigest = true }
              })
            }
            .width('100%')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Column({ space: Theme.space.s3 }) {
            SectionHeader({ title: '探索我的记忆', action: '' })
            Flex({ wrap: FlexWrap.Wrap }) {
              ExploreTile({
                title: '全局搜索',
                subtitle: '跨赛事与收藏检索',
                emoji: '🔍',
                accent: '#0B6BCB',
                onTap: (): void => { this.showSearch = true }
              })
              ExploreTile({
                title: '记忆时间轴',
                subtitle: '按月回顾全部记录',
                emoji: '📅',
                accent: '#0F766E',
                onTap: (): void => { this.showMemoryTimeline = true }
              })
              ExploreTile({
                title: '赛季报告',
                subtitle: '年度统计与摘要',
                emoji: '📊',
                accent: '#FF6B35',
                onTap: (): void => { this.showSeasonReport = true }
              })
              ExploreTile({
                title: '数据洞察',
                subtitle: '日历·趋势·对手',
                emoji: '📈',
                accent: '#7C3AED',
                onTap: (): void => { this.showInsights = true }
              })
              ExploreTile({
                title: '比赛对比',
                subtitle: '两场对照分析',
                emoji: '⚖️',
                accent: '#0F766E',
                onTap: (): void => { this.showCompare = true }
              })
              ExploreTile({
                title: '标签分析',
                subtitle: '标签云与关联',
                emoji: '🏷️',
                accent: '#B45309',
                onTap: (): void => { this.showTagHub = true }
              })
            }
            .width('100%')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          if (this.pinned.length > 0) {
            Column({ space: Theme.space.s3 }) {
              SectionHeader({ title: '置顶赛事', action: '' })
              ForEach(this.pinned, (item: SportRecord) => {
                RecordCard({
                  record: item,
                  onTap: (): void => {
                    this.workbenchId = item.id
                    this.showWorkbench = true
                  }
                })
              }, (item: SportRecord) => item.id)
            }
            .width('100%')
          }

          Column({ space: Theme.space.s3 }) {
            SectionHeader({ title: '本周挑战', action: '记录中心 →', onAction: (): void => { this.goTab(2) } })
            ChallengeBar({ label: '记录 3 场比赛', current: this.dash.weekMatches, target: 3 })
            ChallengeBar({ label: '完成 2 次复盘', current: this.dash.weekRecaps, target: 2 })
            ChallengeBar({ label: '写下 5 条瞬间', current: this.dash.weekMoments, target: 5 })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .border({ width: 1, color: Theme.colors().strokeHairline })

          Row({ space: Theme.space.s3 }) {
            Column({ space: 6 }) {
              SectionHeader({ title: '我的赛季', action: '调整目标', onAction: (): void => { this.showGoal = true } })
              Text(`${this.goal.year} 赛季  ${this.dash.matches}/${this.goal.targetMatches > 0 ? this.goal.targetMatches : 20} 场`)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            AppRingChart({ title: '赛季进度', percent: this.goalPercent() })
              .layoutWeight(1)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          Column({ space: Theme.space.s3 }) {
            SectionHeader({ title: '快捷入口', action: '' })
            Flex({ wrap: FlexWrap.Wrap }) {
              HomeQuickChip({
                label: '赛事记录',
                filled: true,
                onTap: (): void => {
                  this.editMode = false
                  this.editSeedId = ''
                  this.showEdit = true
                }
              })
              HomeQuickChip({
                label: '比赛复盘',
                onTap: (): void => {
                  if (this.pendingId.length > 0) {
                    this.recapSeedId = this.pendingId
                    this.showRecap = true
                  } else {
                    this.goTab(2)
                  }
                }
              })
              HomeQuickChip({
                label: '球队档案',
                onTap: (): void => {
                  this.collectKind = 'team'
                  this.showCollect = true
                }
              })
              HomeQuickChip({
                label: '数据洞察',
                onTap: (): void => { this.showInsights = true }
              })
            }
            .width('100%')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          if (this.timelinePreview.length > 0) {
            Column({ space: Theme.space.s3 }) {
              Row() {
                Text('记忆时间轴')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                Blank()
                Text('查看全部 →')
                  .fontSize(Theme.type.bodyS)
                  .fontColor(Theme.colors().brandPrimary)
                  .onClick((): void => { this.showMemoryTimeline = true })
              }
              .width('100%')
              ForEach(this.timelinePreview, (e: TimelineEntry, idx: number) => {
                TimelineRow({
                  entry: e,
                  isLast: idx >= this.timelinePreview.length - 1,
                  onTap: (): void => { this.showMemoryTimeline = true }
                })
              }, (e: TimelineEntry) => e.id)
            }
            .width('100%')
          }

          Column({ space: 6 }) {
            SectionHeader({ title: '拾录灵感', action: '去记录 →', onAction: (): void => {
              this.editMode = false
              this.editSeedId = ''
              this.showEdit = true
            } })
            Text(this.prompt)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.lg)
          .alignItems(HorizontalAlign.Start)
          .border({ width: 1, color: 'rgba(11,107,203,0.15)' })

          Column({ space: Theme.space.s3 }) {
            SectionHeader({
              title: '最近拾录',
              action: this.recent.length > 0 ? '全部赛事 →' : '',
              onAction: (): void => { this.goTab(1) }
            })
            if (this.recent.length === 0) {
              Column({ space: Theme.space.s3 }) {
                Image($r('app.media.ambient_empty'))
                  .width('70%')
                  .aspectRatio(1.2)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(Theme.radius.lg)
                Text('从第一场开始，把比赛做成可复盘的记忆。')
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
              .width('100%')
              .alignItems(HorizontalAlign.Center)
            } else {
              ForEach(this.recent, (item: SportRecord) => {
                RecordCard({
                  record: item,
                  onTap: (): void => { this.detailRecord = item }
                })
              }, (item: SportRecord) => item.id)
            }
          }
          .width('100%')
        }
        .width('100%')
        .padding(Theme.space.pageX)
        .padding({ bottom: Theme.space.s10 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      .edgeEffect(EdgeEffect.Spring)

      if (this.detailRecord !== undefined) {
        SportRecordDetailPane({
          record: this.detailRecord,
          refreshToken: this.detailRefreshToken,
          onClose: (): void => { this.detailRecord = undefined },
          onDeleted: (): void => { this.detailRecord = undefined; void this.reload() },
          onEdit: (): void => {
            if (this.detailRecord === undefined) {
              return
            }
            this.editMode = true
            this.editSeedId = this.detailRecord.id
            this.showEdit = true
          },
          onRecap: (): void => {
            this.recapSeedId = (this.detailRecord as SportRecord).id
            this.detailRecord = undefined
            this.showRecap = true
          },
          onTimeline: (): void => {
            this.recapSeedId = (this.detailRecord as SportRecord).id
            this.detailRecord = undefined
            this.showTimeline = true
          },
          onWorkbench: (): void => {
            this.workbenchId = (this.detailRecord as SportRecord).id
            this.detailRecord = undefined
            this.showWorkbench = true
          },
          onReport: (): void => {
            this.reportSeedId = (this.detailRecord as SportRecord).id
            this.detailRecord = undefined
            this.showReport = true
          }
        })
      }
      if (this.showEdit) {
        RecordEditPage({
          editMode: this.editMode,
          seedId: this.editSeedId,
          onClose: (): void => { this.showEdit = false },
          onSaved: (saved: SportRecord): void => { void this.afterEditSaved(saved) }
        })
      }
      if (this.showGoal) {
        GoalSheet({
          goal: this.goal,
          onClose: (): void => { this.showGoal = false },
          onSaved: (): void => { void this.reload() }
        })
      }
      if (this.showRecap) {
        RecapQuizPage({
          seedId: this.recapSeedId,
          onClose: (): void => { this.showRecap = false },
          onSaved: (): void => { void this.reload() }
        })
      }
      if (this.showTimeline) {
        RecapTimelinePage({
          seedId: this.recapSeedId,
          onClose: (): void => { this.showTimeline = false },
          onSaved: (): void => { void this.reload() }
        })
      }
      if (this.showCollect) {
        CollectEditPage({
          editKind: this.collectKind,
          seedId: '',
          onClose: (): void => { this.showCollect = false },
          onSaved: (): void => { void this.reload() }
        })
      }
      if (this.showMemoryTimeline) {
        MemoryTimelinePage({ onClose: (): void => { this.showMemoryTimeline = false } })
      }
      if (this.showSearch) {
        GlobalSearchPage({ onClose: (): void => { this.showSearch = false } })
      }
      if (this.showSeasonReport) {
        SeasonReportPage({ onClose: (): void => { this.showSeasonReport = false } })
      }
      if (this.showInsights) {
        DataInsightsPage({
          reloadToken: this.reloadToken,
          onClose: (): void => { this.showInsights = false; void this.reload() }
        })
      }
      if (this.showWorkbench && this.workbenchId.length > 0) {
        MatchWorkbenchPage({
          seedId: this.workbenchId,
          onClose: (): void => { this.showWorkbench = false },
          onSaved: (): void => { void this.reload() }
        })
      }
      if (this.showCompare) {
        MatchComparePage({ onClose: (): void => { this.showCompare = false } })
      }
      if (this.showTagHub) {
        TagHubPage({ onClose: (): void => { this.showTagHub = false } })
      }
      if (this.showReport) {
        MatchReportPage({
          seedId: this.reportSeedId,
          onClose: (): void => { this.showReport = false }
        })
      }
      if (this.showPlayerTracker) {
        PlayerTrackerPage({ onClose: (): void => { this.showPlayerTracker = false } })
      }
      if (this.showTeamHub) {
        TeamHubPage({ onClose: (): void => { this.showTeamHub = false } })
      }
      if (this.showHeatmap) {
        ActivityHeatmapPage({ onClose: (): void => { this.showHeatmap = false } })
      }
      if (this.showPrediction) {
        PredictionLabPage({ onClose: (): void => { this.showPrediction = false } })
      }
      if (this.showMvpBoard) {
        MvpLeaderboardPage({ onClose: (): void => { this.showMvpBoard = false } })
      }
      if (this.showWatchQueue) {
        WatchQueuePage({ onClose: (): void => { this.showWatchQueue = false } })
      }
      if (this.showVenue) {
        VenueJournalPage({ onClose: (): void => { this.showVenue = false } })
      }
      if (this.showWeeklyDigest) {
        WeeklyDigestPage({ onClose: (): void => { this.showWeeklyDigest = false } })
      }
    }
    .width('100%')
    .height('100%')
    .onAppear((): void => {
      if (this.reloadToken !== this.lastToken) {
        this.lastToken = this.reloadToken
        void this.reload()
      }
    })
  }
}
