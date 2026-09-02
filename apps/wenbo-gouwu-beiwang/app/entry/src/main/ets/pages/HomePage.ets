import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { ItemRow, ListMiniCard, ProgressTrack, SectionTitle } from '../components/shop/ShoppingCards'
import { SceneCard, SceneWorkbench } from '../components/shop/SceneWorkbench'
import { FrequentItem, RemainingRow, RestockRow, ShoppingItem, ShoppingList, WeekStats,
  ActivityEvent, GrowthSnapshot, ProcurementPlan, ProcurementTopic } from '../models/ShoppingModels'
import { ShoppingService } from '../services/ShoppingService'
import { ShoppingLocalStore } from '../services/ShoppingLocalStore'
import { ShoppingInsight, ShoppingStatsService, WeekDayStat } from '../services/ShoppingStatsService'
import { GrowthService } from '../services/GrowthService'
import { GrowthWorkbench } from '../components/shop/GrowthWorkbench'
import { BrandIdentity } from '../config/BrandIdentity'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State lists: ShoppingList[] = []
  @State todayItems: ShoppingItem[] = []
  @State today: ShoppingList = new ShoppingList()
  @State hasToday: boolean = false
  @State stats: WeekStats = new WeekStats()
  @State insight: ShoppingInsight = new ShoppingInsight()
  @State frequent: FrequentItem[] = []
  @State remaining: RemainingRow[] = []
  @State restock: RestockRow[] = []
  @State doneNum: number = 0
  @State totalNum: number = 0
  @State remainNum: number = 0
  @State estNum: number = 0
  @State paidNum: number = 0
  @State insightEpoch: number = 0
  @State activeSceneId: string = ''
  @State growth: GrowthSnapshot = new GrowthSnapshot()
  @State growthPlan: ProcurementPlan = new ProcurementPlan()
  @State hasGrowthPlan: boolean = false
  @State recentEvents: ActivityEvent[] = []
  @State topics: ProcurementTopic[] = []
  @StorageLink('insetTop') insetTop: number = 44
  @Prop @Watch('onTick') refreshToken: number = 0
  onAddItem: () => void = () => {}
  onOpenList: (id: string) => void = () => {}
  onCreateList: () => void = () => {}
  onOpenLists: () => void = () => {}
  onAddFrequent: (item: FrequentItem) => void = () => {}
  onOpenVerify: () => void = () => {}
  onOpenHabit: () => void = () => {}
  onOpenAisle: () => void = () => {}
  onOpenLibrary: () => void = () => {}
  onOpenHistory: () => void = () => {}
  onOpenSpend: () => void = () => {}
  onOpenTemplates: () => void = () => {}
  onQuickScene: (card: SceneCard) => void = () => {}
  onOpenSearch: () => void = () => {}
  onOpenGrowth: () => void = () => {}
  onOpenFavorites: () => void = () => {}
  onOpenTopics: () => void = () => {}
  onOpenPlanEditor: () => void = () => {}
  onOpenCategoryInsight: () => void = () => {}
  onOpenCalendar: () => void = () => {}
  onOpenMonthlyReview: () => void = () => {}
  onOpenAssigneeBoard: () => void = () => {}
  onOpenItem: (itemId: string, listId: string) => void = () => {}
  onOpenTopic: (id: string) => void = () => {}
  onDataChange: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onTick(): void {
    void this.reload()
  }

  async reload(): Promise<void> {
    this.lists = await ShoppingService.lists()
    this.stats = ShoppingService.weekStats()
    this.insight = ShoppingStatsService.insight()
    this.frequent = ShoppingService.frequentItems()
    this.remaining = ShoppingService.remainingRows()
    this.restock = ShoppingService.restockRows()
    this.growth = GrowthService.snapshot()
    this.recentEvents = GrowthService.recentEvents(3)
    this.topics = GrowthService.topics()
    const plan = GrowthService.activePlan()
    if (plan !== undefined) {
      this.growthPlan = plan
      this.hasGrowthPlan = true
    } else {
      this.hasGrowthPlan = false
      this.growthPlan = new ProcurementPlan()
    }
    const t = await ShoppingService.todayList()
    if (t === undefined) {
      this.hasToday = false
      this.todayItems = []
      this.syncMetrics()
      return
    }
    this.hasToday = true
    this.today = t
    this.todayItems = await ShoppingService.items(t.id)
    this.syncMetrics()
  }

  private syncMetrics(): void {
    this.totalNum = this.todayItems.length
    this.doneNum = ShoppingService.doneCount(this.todayItems)
    this.remainNum = this.totalNum - this.doneNum
    this.estNum = ShoppingService.pendingPriceSum(this.todayItems)
    this.paidNum = ShoppingService.paidPriceSum(this.todayItems)
  }

  private mergedItemsForInsight(): ShoppingItem[] {
    const all = ShoppingLocalStore.items()
    const out: ShoppingItem[] = []
    for (const it of all) {
      let hit = false
      for (const local of this.todayItems) {
        if (local.id === it.id) {
          out.push(ShoppingLocalStore.cloneItem(local))
          hit = true
          break
        }
      }
      if (!hit) {
        out.push(ShoppingLocalStore.cloneItem(it))
      }
    }
    return out
  }

  private syncDashboardOptimistic(): void {
    this.syncMetrics()
    this.insight = ShoppingStatsService.insightForItems(this.mergedItemsForInsight(), ShoppingLocalStore.lists())
    this.stats = ShoppingService.weekStats()
    this.growth = GrowthService.snapshot()
    this.recentEvents = GrowthService.recentEvents(3)
    this.topics = GrowthService.topics()
    this.insightEpoch += 1
  }

  private pullDashboardFromStore(): void {
    this.stats = ShoppingService.weekStats()
    this.insight = ShoppingStatsService.insight()
    this.remaining = ShoppingService.remainingRows()
    this.restock = ShoppingService.restockRows()
    this.frequent = ShoppingService.frequentItems()
    const lists = ShoppingLocalStore.lists()
    for (const row of lists) {
      if (row.dueDate === ShoppingLocalStore.today()) {
        this.today = ShoppingLocalStore.cloneList(row)
        this.hasToday = true
        const items: ShoppingItem[] = []
        for (const it of ShoppingLocalStore.itemsOf(row.id)) {
          items.push(ShoppingLocalStore.cloneItem(it))
        }
        this.todayItems = items
        break
      }
    }
    this.syncMetrics()
    this.growth = GrowthService.snapshot()
    this.recentEvents = GrowthService.recentEvents(3)
    this.topics = GrowthService.topics()
    const plan = GrowthService.activePlan()
    if (plan !== undefined) {
      this.growthPlan = plan
      this.hasGrowthPlan = true
    }
    this.insightEpoch += 1
  }

  private previewItems(): ShoppingItem[] {
    const out: ShoppingItem[] = []
    for (const it of this.todayItems) {
      if (out.length >= 6) {
        break
      }
      out.push(it)
    }
    return out
  }

  private recentLists(): ShoppingList[] {
    const out: ShoppingList[] = []
    for (const row of this.lists) {
      if (out.length >= 4) {
        break
      }
      out.push(row)
    }
    return out
  }

  private topPad(): number {
    return this.insetTop + 8
  }

  private flipToday(id: string): void {
    const next: ShoppingItem[] = []
    let nowCompleted = false
    for (const it of this.todayItems) {
      const copy = ShoppingLocalStore.cloneItem(it)
      if (copy.id === id) {
        copy.completed = !copy.completed
        nowCompleted = copy.completed
      }
      next.push(copy)
    }
    this.todayItems = next
    this.syncDashboardOptimistic()
    if (nowCompleted) {
      const rows: RemainingRow[] = []
      for (const row of this.remaining) {
        if (row.itemId !== id) {
          rows.push(row)
        }
      }
      this.remaining = rows
    }
  }

  private weekdayLabel(): string {
    const labels: string[] = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']
    const d = new Date()
    return labels[d.getDay()]
  }

  private progressDone(): number {
    if (this.hasGrowthPlan && this.growthPlan.targetItemCount > 0) {
      return this.growth.planDone
    }
    return this.doneNum
  }

  private progressTotal(): number {
    if (this.hasGrowthPlan && this.growthPlan.targetItemCount > 0) {
      return this.growthPlan.targetItemCount
    }
    return this.totalNum > 0 ? this.totalNum : 1
  }

  private progressPercent(): number {
    const total = this.progressTotal()
    if (total <= 0) {
      return 0
    }
    return Math.min(100, Math.round((this.progressDone() / total) * 100))
  }

  private progressCaption(): string {
    if (this.hasGrowthPlan && this.growthPlan.targetItemCount > 0) {
      return `计划「${this.growthPlan.title}」· 待购预估 ¥${this.estNum}`
    }
    if (this.hasToday) {
      return `今日清单 · 待购预估 ¥${this.estNum}`
    }
    return '创建清单或计划，开始今日采购'
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        this.WelcomeHeader()
        this.ProgressHero()
        this.KpiGrid()
        this.QuickActions()
        this.VisualStrip()
        SceneWorkbench({
          activeId: this.activeSceneId,
          onPick: (card: SceneCard): void => {
            this.activeSceneId = card.templateId
            this.onQuickScene(card)
          }
        })
        this.TopicsBlock()
        this.InsightBlock()
        GrowthWorkbench({
          growth: this.growth,
          plan: this.growthPlan,
          hasPlan: this.hasGrowthPlan,
          events: this.recentEvents,
          onOpenGrowth: () => this.onOpenGrowth(),
          onOpenSearch: () => this.onOpenSearch(),
          onOpenFavorites: () => this.onOpenFavorites(),
          onOpenPlanEditor: () => this.onOpenPlanEditor(),
          onOpenTopics: () => this.onOpenTopics()
        })
        this.TodayBlock()
        this.RemainBlock()
        this.RestockBlock()
        this.RecentBlock()
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: this.topPad(),
        bottom: Theme.space.s8
      })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.paint(this.themeEpoch).surfacePage)
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }

  @Builder
  WelcomeHeader() {
    Row() {
      Column({ space: 4 }) {
        Text(BrandIdentity.appName())
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.paint(this.themeEpoch).textPrimary)
        Text(`${this.weekdayLabel()} · 个人与家庭采购工作台`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.paint(this.themeEpoch).textSecondary)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
  }

  @Builder
  ProgressHero() {
    Column({ space: 12 }) {
      Text('今日采购进度')
        .fontSize(Theme.type.subtitleM)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.paint(this.themeEpoch).textPrimary)
        .width('100%')
      Row() {
        Text(`${this.progressDone()}/${this.progressTotal()}`)
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().brandPrimary)
        Blank()
        Text(`${this.progressPercent()}%`)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().brandPrimary)
      }
      .width('100%')
      ProgressTrack({
        done: this.progressDone(),
        total: this.progressTotal()
      })
      Text(this.progressCaption())
        .fontSize(Theme.type.caption)
        .fontColor(Theme.paint(this.themeEpoch).textSecondary)
        .width('100%')
      Text('继续完成 →')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().brandPrimary)
        .width('100%')
        .onClick((): void => {
          if (this.hasToday) {
            this.onOpenList(this.today.id)
            return
          }
          if (this.hasGrowthPlan) {
            this.onOpenPlanEditor()
            return
          }
          this.onCreateList()
        })
    }
    .width('100%')
    .padding(18)
    .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
    .borderRadius(Theme.radius.xl)
  }

  @Builder
  KpiGrid() {
    Row({ space: 8 }) {
      this.KpiChip('已购', `${this.doneNum}`, () => {
        if (this.hasToday) {
          this.onOpenList(this.today.id)
        } else {
          this.onOpenLists()
        }
      })
      this.KpiChip('待购', `${this.remainNum}`, () => this.onOpenVerify())
      this.KpiChip('收藏', `${this.growth.favoriteCount}`, () => this.onOpenFavorites())
      this.KpiChip('连续', `${this.growth.checkInStreak}天`, () => this.onOpenGrowth())
    }
    .width('100%')
  }

  @Builder
  KpiChip(label: string, value: string, action: () => void) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().brandPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.paint(this.themeEpoch).textSecondary)
    }
    .layoutWeight(1)
    .padding({ top: 12, bottom: 12 })
    .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
    .borderRadius(Theme.radius.lg)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => action())
  }

  @Builder
  QuickActions() {
    Column({ space: 10 }) {
      SectionTitle({ title: '快捷操作' })
      Flex({ wrap: FlexWrap.Wrap }) {
        this.HubChip('添加', () => this.onAddItem())
        this.HubChip('情景', () => this.onOpenLists())
        this.HubChip('核对', () => this.onOpenVerify())
        this.HubChip('搜索', () => this.onOpenSearch())
        this.HubChip('计划', () => this.onOpenPlanEditor())
        this.HubChip('日历', () => this.onOpenCalendar())
        this.HubChip('月报', () => this.onOpenMonthlyReview())
        this.HubChip('分工', () => this.onOpenAssigneeBoard())
        this.HubChip('洞察', () => this.onOpenCategoryInsight())
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  VisualStrip() {
    Row({ space: 10 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image($r('app.media.home_hero'))
          .width('100%')
          .height(88)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.lg)
        Column()
          .width('100%')
          .height(88)
          .linearGradient({
            angle: 180,
            colors: [['rgba(8,42,90,0.05)', 0], ['rgba(8,42,90,0.65)', 1]]
          })
          .borderRadius(Theme.radius.lg)
        Text('采购工作台')
          .fontSize(Theme.type.footnote)
          .fontColor('#FFFFFF')
          .padding(10)
      }
      .layoutWeight(1)
      .height(88)

      Image($r('app.media.tpl_family'))
        .layoutWeight(1)
        .height(88)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.lg)
    }
    .width('100%')
  }

  private insightBarMax(): number {
    let max = 1
    for (const bar of this.insight.weekBars) {
      if (bar.done > max) {
        max = bar.done
      }
    }
    return max
  }

  private insightBarHeight(done: number): number {
    const max = this.insightBarMax()
    if (max <= 0) {
      return 4
    }
    return Math.max(4, Math.round((done / max) * 44))
  }

  @Builder
  InsightBlock() {
    Column({ space: 12 }) {
      SectionTitle({ title: '本周采购看板', action: '习惯诊断', onAction: () => this.onOpenHabit() })
      Row({ space: 8 }) {
        this.InsightChip('完成率', `${Math.round(this.insight.completionRate * 100)}%`)
        this.InsightChip('本周勾选', `${this.insight.weekChecked}`)
        this.InsightChip('连续完成', `${this.insight.streakDays}天`)
      }
      .width('100%')
      .height(76)
      .alignItems(VerticalAlign.Center)
      if (this.insight.weekBars.length > 0) {
        Text(`常买分类：${this.insight.topCategory}`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.paint(this.themeEpoch).textSecondary)
          .width('100%')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Row({ space: 4 }) {
          ForEach(this.insight.weekBars, (bar: WeekDayStat, idx: number) => {
            Column({ space: 6 }) {
              Column() {
                Row()
                  .width(14)
                  .height(this.insightBarHeight(bar.done))
                  .backgroundColor(Theme.colors().brandPrimary)
                  .borderRadius(4)
              }
              .width('100%')
              .height(48)
              .justifyContent(FlexAlign.End)
              .alignItems(HorizontalAlign.Center)
              Text(bar.label)
                .fontSize(Theme.type.overline)
                .fontColor(Theme.paint(this.themeEpoch).textSecondary)
                .maxLines(1)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
          }, (bar: WeekDayStat, idx: number) => `${bar.label}_${bar.done}_${this.insightEpoch}`)
        }
        .width('100%')
        .height(68)
        .alignItems(VerticalAlign.Bottom)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
    .borderRadius(Theme.radius.xl)
  }

  @Builder
  InsightChip(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.paint(this.themeEpoch).brandPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.paint(this.themeEpoch).textSecondary)
    }
    .layoutWeight(1)
    .height(64)
    .padding({ top: 8, bottom: 8, left: 4, right: 4 })
    .backgroundColor(Theme.colors().surfaceSubtle)
    .borderRadius(Theme.radius.lg)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  HubChip(label: string, action: () => void) {
    Text(label)
      .fontSize(Theme.type.footnote)
      .fontColor(Theme.paint(this.themeEpoch).brandPrimary)
      .padding({ left: 14, right: 14, top: 10, bottom: 10 })
      .margin({ right: 8, bottom: 8 })
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.pill)
      .onClick(() => action())
  }

  @Builder
  TodayBlock() {
    Column({ space: 12 }) {
      SectionTitle({ title: '今日购物清单', action: '查看全部', onAction: () => this.onOpenLists() })
      if (!this.hasToday || this.todayItems.length === 0) {
        AppEmpty({
          title: '还没有购物清单',
          description: '从记录第一件物品开始',
          actionLabel: '创建清单',
          onAction: () => this.onCreateList()
        })
      } else {
        Column({ space: 10 }) {
          Text(this.today.title)
            .fontSize(Theme.type.subtitleM)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.paint(this.themeEpoch).textPrimary)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
            .onClick(() => this.onOpenList(this.today.id))
          ProgressTrack({
            done: this.doneNum,
            total: this.totalNum
          })
          if (this.remaining.length > 0) {
            Text('卖场路线')
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.paint(this.themeEpoch).brandPrimary)
              .onClick(() => this.onOpenAisle())
          }
          ForEach(this.previewItems(), (it: ShoppingItem) => {
            ItemRow({
              title: it.title,
              extra: ShoppingService.extraLine(it),
              done: it.completed,
              detailEnabled: true,
              onOpen: (): void => { this.onOpenItem(it.id, this.today.id) },
              onToggle: (): void => {
                this.flipToday(it.id)
                void ShoppingService.toggleItemById(it.id).then((ok: boolean) => {
                  if (ok) {
                    this.pullDashboardFromStore()
                    this.onDataChange()
                    return
                  }
                  void this.reload()
                })
              }
            })
          }, (it: ShoppingItem) => `${it.id}_${it.completed ? '1' : '0'}`)
        }
        .width('100%')
        .padding(16)
        .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
        .borderRadius(Theme.radius.xl)
      }
    }
    .width('100%')
  }

  @Builder
  RemainBlock() {
    if (this.remaining.length === 0) {
      Column().width('100%').height(0)
    } else {
      Column({ space: 10 }) {
        SectionTitle({ title: '出门前核对', action: '全屏核对', onAction: () => this.onOpenVerify() })
        Column({ space: 8 }) {
          ForEach(this.remaining, (row: RemainingRow) => {
            Row() {
              Text(row.title)
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.paint(this.themeEpoch).textPrimary)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .layoutWeight(1)
              Text(row.listTitle)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.paint(this.themeEpoch).textSecondary)
                .maxLines(1)
                .margin({ left: 8 })
            }
            .width('100%')
            .onClick(() => this.onOpenList(row.listId))
          }, (row: RemainingRow) => row.itemId)
        }
        .width('100%')
        .padding(16)
        .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
        .borderRadius(Theme.radius.xl)
      }
      .width('100%')
    }
  }

  @Builder
  RestockBlock() {
    if (this.restock.length === 0) {
      Column().width('100%').height(0)
    } else {
      Column({ space: 10 }) {
        SectionTitle({ title: '该补货了' })
        Text('上次购买已超过 7 天，点标签加入今日清单')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.paint(this.themeEpoch).textSecondary)
          .width('100%')
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.restock, (it: RestockRow) => {
            Text(it.title)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.paint(this.themeEpoch).brandPrimary)
              .maxLines(1)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .margin({ right: 8, bottom: 8 })
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => {
                const row = new FrequentItem()
                row.title = it.title
                row.category = it.category
                row.qty = it.qty
                this.onAddFrequent(row)
              })
          }, (it: RestockRow) => `${it.title}_${it.lastBoughtAt}`)
        }
        .width('100%')
      }
      .width('100%')
    }
  }

  private previewTopics(): ProcurementTopic[] {
    const out: ProcurementTopic[] = []
    for (const row of this.topics) {
      if (out.length >= 2) {
        break
      }
      out.push(row)
    }
    return out
  }

  @Builder
  TopicsBlock() {
    if (this.topics.length === 0) {
      Column().width('100%').height(0)
    } else {
      Column({ space: 10 }) {
        SectionTitle({ title: '采购主题', action: '全部', onAction: () => this.onOpenTopics() })
        Grid() {
          ForEach(this.previewTopics(), (row: ProcurementTopic) => {
            GridItem() {
              ListMiniCard({
                title: row.title,
                meta: `${row.listIds.length} 份清单`,
                coverKey: row.coverKey,
                onTap: (): void => { this.onOpenTopic(row.id) }
              })
            }
          }, (row: ProcurementTopic) => row.id)
        }
        .columnsTemplate('1fr 1fr')
        .columnsGap(12)
        .rowsGap(12)
        .width('100%')
      }
      .width('100%')
    }
  }

  @Builder
  RecentBlock() {
    Column({ space: 12 }) {
      SectionTitle({ title: '最近清单', action: '全部', onAction: () => this.onOpenLists() })
      if (this.lists.length === 0) {
        Text('创建清单后，会显示在这里')
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.paint(this.themeEpoch).textSecondary)
          .width('100%')
      } else {
        Grid() {
          ForEach(this.recentLists(), (row: ShoppingList) => {
            GridItem() {
              ListMiniCard({
                title: row.title,
                meta: row.status === 'done' ? '已完成' : '进行中',
                coverKey: row.coverKey,
                onTap: () => this.onOpenList(row.id)
              })
            }
          }, (row: ShoppingList) => `${row.id}_${row.status}`)
        }
        .columnsTemplate('1fr 1fr')
        .columnsGap(12)
        .rowsGap(12)
        .width('100%')
      }
    }
    .width('100%')
  }
}
