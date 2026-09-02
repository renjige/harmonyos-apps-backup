import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppBarChart, BarChartItem } from '../components/design-system/AppChart'
import { ArchiveCard } from '../components/archive/ArchiveCard'
import { Archive, TimelineNode } from '../models/ArchiveModels'
import { DashboardSummary } from '../models/LifeModels'
import { ArchiveStore } from '../services/ArchiveStore'
import { ArchiveStatsService } from '../services/ArchiveStatsService'
import { ArchiveDetailNav } from '../services/ArchiveDetailNav'
import { DateHelper } from '../services/DateHelper'
import { AchievementService } from '../services/AchievementService'

class QuickActionItem {
  label: string = ''
  emoji: string = ''
  action: string = ''

  static make(label: string, emoji: string, action: string): QuickActionItem {
    const q = new QuickActionItem()
    q.label = label
    q.emoji = emoji
    q.action = action
    return q
  }
}

/** 时光首页 — 商业级仪表盘 */
@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('dataEpoch') @Watch('onDataEpochChange') dataEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  onSwitchTab: (index: number) => void = () => {}
  @State totalArchives: number = 0
  @State dash: DashboardSummary = new DashboardSummary()
  @State recentArchives: Archive[] = []
  @State onThisDayNodes: TimelineNode[] = []
  @State catLabelKeys: string[] = []
  @State catLabelValues: string[] = []
  @State archiveIds: string[] = []
  @State archiveNodeCounts: number[] = []
  @State planDoneCount: number = 0
  @State weeklyBarItems: BarChartItem[] = []
  private quickActions: QuickActionItem[] = [
    QuickActionItem.make('写下时光', '✍️', 'create'),
    QuickActionItem.make('新建计划', '📋', 'plan'),
    QuickActionItem.make('记录灵感', '💡', 'inspiration'),
    QuickActionItem.make('重要时刻', '⭐', 'moment')
  ]

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  onDataEpochChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    await AchievementService.checkAndUnlock()
    this.dash = await ArchiveStatsService.buildDashboardSummary()
    const stats = await ArchiveStatsService.computeStats()
    this.totalArchives = stats.totalArchives
    this.recentArchives = await ArchiveStore.recentArchives(5)
    this.planDoneCount = this.dash.todayPlanDone
    const today = new Date()
    this.onThisDayNodes = await ArchiveStore.nodesOnDayMonth(today.getDate(), today.getMonth() + 1)
    const cats = await ArchiveStore.loadCategories()
    const keys: string[] = []
    const values: string[] = []
    for (const c of cats) {
      keys.push(c.key)
      values.push(c.label)
    }
    this.catLabelKeys = keys
    this.catLabelValues = values
    const allNodes = await ArchiveStore.loadNodes()
    const ids: string[] = []
    const counts: number[] = []
    for (const a of this.recentArchives) {
      ids.push(a.id)
      let cnt = 0
      for (const n of allNodes) {
        if (n.archiveId === a.id) {
          cnt++
        }
      }
      counts.push(cnt)
    }
    this.archiveIds = ids
    this.archiveNodeCounts = counts
    const weekly = await ArchiveStatsService.buildWeeklyActivityBars()
    const items: BarChartItem[] = []
    for (const w of weekly) {
      const item = new BarChartItem()
      item.label = w.label
      item.value = w.count
      items.push(item)
    }
    this.weeklyBarItems = items
  }

  private labelFor(key: string): string {
    for (let i = 0; i < this.catLabelKeys.length; i++) {
      if (this.catLabelKeys[i] === key) {
        return this.catLabelValues[i]
      }
    }
    return key
  }

  private nodeCountFor(id: string): number {
    for (let i = 0; i < this.archiveIds.length; i++) {
      if (this.archiveIds[i] === id) {
        return this.archiveNodeCounts[i]
      }
    }
    return 0
  }

  private handleQuickAction(action: string): void {
    if (action === 'create') {
      ArchiveDetailNav.openCreateArchive()
    } else if (action === 'plan') {
      this.onSwitchTab(2)
    } else if (action === 'inspiration') {
      AppStorage.setOrCreate('inspirationEditorOpen', true)
      AppStorage.setOrCreate('tabBarHidden', true)
    } else if (action === 'moment') {
      AppStorage.setOrCreate('momentEditorOpen', true)
      AppStorage.setOrCreate('tabBarHidden', true)
    }
  }

  private planProgressPercent(): number {
    if (this.dash.todayPlanTotal <= 0) {
      return 0
    }
    return Math.round((this.dash.todayPlanDone / this.dash.todayPlanTotal) * 100)
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        this.HomeSectionHero()
        this.HomeSectionTodayStrip()
        this.HomeSectionPlanProgress()
        this.HomeSectionWeeklyOverview()
        this.HomeSectionQuickActions()
        this.HomeSectionDataSummary()
        this.HomeSectionOnThisDay()
        this.HomeSectionRecentArchives()
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: this.bottomInset + Theme.space.s6
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  HomeSectionHero() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image($r('app.media.hero_ambient'))
        .width('100%')
        .height(160)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.lg)
      Column()
        .width('100%')
        .height(160)
        .linearGradient({
          angle: 180,
          colors: [['rgba(24,35,51,0.08)', 0], ['rgba(24,35,51,0.75)', 1]]
        })
        .borderRadius(Theme.radius.lg)
      Column({ space: Theme.space.s1 }) {
        Text('时光档案')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
        Text('把值得记住的时光，整理成自己的故事')
          .fontSize(Theme.type.caption)
          .fontColor('#F7F6F2')
      }
      .padding(Theme.space.s4)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
  }

  @Builder
  HomeSectionTodayStrip() {
    Row() {
      Column({ space: 4 }) {
        Text(DateHelper.displayDate(DateHelper.todayKey()))
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Text(`${DateHelper.formatWeekday(new Date())} · 今天想留下什么`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      Column() {
        AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
      }
      .width(44)
      .height(44)
      .justifyContent(FlexAlign.Center)
      .onClick((): void => {
        AppStorage.setOrCreate('searchOpen', true)
        AppStorage.setOrCreate('tabBarHidden', true)
      })
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
  }

  @Builder
  HomeSectionPlanProgress() {
    Column({ space: Theme.space.s2 }) {
      Row() {
        Text('今日计划')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Blank()
        if (this.dash.todayPlanTotal > 0) {
          Text(`${this.dash.todayPlanDone}/${this.dash.todayPlanTotal}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
      }
      .width('100%')
      if (this.dash.todayPlanTotal <= 0) {
        Text('还没有计划任务，去计划页创建并添加任务')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        Row() {
          Text('去创建计划')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandPrimary)
        }
        .width('100%')
        .onClick((): void => { this.onSwitchTab(2) })
      } else {
        Row() {
          Column()
            .layoutWeight(this.planProgressPercent())
            .height(6)
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
          Column()
            .layoutWeight(100 - this.planProgressPercent() > 0 ? 100 - this.planProgressPercent() : 1)
            .height(6)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        Text(`已完成 ${this.planProgressPercent()}%`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
          .width('100%')
      }
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
  }

  @Builder
  HomeSectionWeeklyOverview() {
    Column({ space: Theme.space.s2 }) {
      Row() {
        Text('本周概览')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Blank()
        Text('近7日')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
      }
      .width('100%')
      AppBarChart({
        title: '',
        items: this.weeklyBarItems,
        emptyHint: '近 7 日暂无记录，写下第一段时光或完成一次打卡'
      })
      Text('档案节点 · 新建档案 · 习惯打卡 · 计划完成')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textTertiary)
        .width('100%')
    }
    .width('100%')
  }

  @Builder
  HomeSectionQuickActions() {
    Row({ space: Theme.space.s2 }) {
      ForEach(this.quickActions, (q: QuickActionItem) => {
        Column({ space: 6 }) {
          Text(q.emoji)
            .fontSize(22)
          Text(q.label)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textPrimary)
        }
        .layoutWeight(1)
        .padding({ top: 12, bottom: 12 })
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
        .onClick((): void => { this.handleQuickAction(q.action) })
      }, (q: QuickActionItem) => q.action)
    }
    .width('100%')
  }

  @Builder
  HomeSectionDataSummary() {
    Row({ space: Theme.space.s2 }) {
      AppStatCard({ label: '连续', value: `${this.dash.streakDays}天` }).layoutWeight(1)
      AppStatCard({ label: '档案', value: `${this.totalArchives}` }).layoutWeight(1)
    }
    Row({ space: Theme.space.s2 }) {
      AppStatCard({ label: '计划完成', value: `${this.planDoneCount}` }).layoutWeight(1)
      AppStatCard({ label: '收藏', value: `${this.dash.favoriteCount}` }).layoutWeight(1)
    }
  }

  @Builder
  HomeSectionOnThisDay() {
    Column({ space: Theme.space.s2 }) {
      Text(this.dash.onThisDayTitle)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text(this.dash.onThisDayBody)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(Theme.colors().brandPrimaryContainer)
    .borderRadius(Theme.radius.lg)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  HomeSectionRecentArchives() {
    Column({ space: Theme.space.s3 }) {
      Text('最近档案')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      if (this.recentArchives.length === 0) {
        AppEmpty({
          title: '还没有档案',
          description: '创建第一份人生档案，开始整理你的重要时刻',
          actionLabel: '立即创建',
          onAction: (): void => { ArchiveDetailNav.openCreateArchive() }
        })
        Image($r('app.media.empty_archive'))
          .width('100%')
          .height(100)
          .objectFit(ImageFit.Contain)
          .opacity(0.85)
      } else {
        ForEach(this.recentArchives, (a: Archive) => {
          ArchiveCard({
            archive: a,
            categoryLabel: this.labelFor(a.categoryKey),
            nodeCount: this.nodeCountFor(a.id),
            completion: ArchiveStore.completionPercent(a, this.nodeCountFor(a.id)),
            onTap: (): void => { ArchiveDetailNav.openArchiveDetail(a.id) }
          })
        }, (a: Archive) => a.id)
      }
    }
  }
}
