import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import {
  AppointmentCardUtil,
  AppointmentRow,
  SectionTitle,
  TemplateMiniCard
} from '../components/appointment/AppointmentCards'
import {
  ActivityFeedRow,
  DataQuadCard,
  ProgressHeroCard,
  PlanSummaryCard,
  QuickActionChip,
  ToolGrid
} from '../components/appointment/WorkbenchCards'
import {
  AppointmentItem,
  AppointmentTemplate,
  NextHint
} from '../models/AppointmentModels'
import { ActivityLogItem, CommitmentPlan, GrowthSnapshot } from '../models/GrowthModels'
import { AppointmentService } from '../services/AppointmentService'
import { AppointmentTools } from '../services/AppointmentTools'
import { GrowthService } from '../services/GrowthService'
import { ScheduleEngine } from '../services/ScheduleEngine'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('accessToken') accessToken: string = ''
  @State todayItems: AppointmentItem[] = []
  @State templates: AppointmentTemplate[] = []
  @State hint: NextHint = new NextHint()
  @State missedCount: number = 0
  @State doneToday: number = 0
  @State totalToday: number = 0
  @State snap: GrowthSnapshot = new GrowthSnapshot()
  @State activePlans: CommitmentPlan[] = []
  @State recentLogs: ActivityLogItem[] = []
  @State loading: boolean = true
  @Prop @Watch('onTick') refreshToken: number = 0
  @Prop appName: string = '约定提醒'
  @Prop tagline: string = ''
  onCreate: () => void = () => {}
  onOpenItem: (id: string) => void = () => {}
  onOpenList: () => void = () => {}
  onOpenCalendar: () => void = () => {}
  onOpenTemplate: (tpl: AppointmentTemplate) => void = () => {}
  onOpenSceneHub: (scene: string) => void = () => {}
  onOpenBrief: () => void = () => {}
  onOpenSlots: () => void = () => {}
  onOpenOverdue: () => void = () => {}
  onOpenImport: () => void = () => {}
  onOpenPlans: () => void = () => {}
  onOpenGrowth: () => void = () => {}
  onOpenSearch: () => void = () => {}
  onOpenPlan: (id: string) => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onTick(): void {
    void this.reload()
  }

  private userLabel(): string {
    if (this.accessToken.length > 0) {
      const name = AppStorage.get<string>('currentUsername') ?? ''
      return name.length > 0 ? name : '已登录'
    }
    return '游客'
  }

  private logTime(iso: string): string {
    if (iso.length < 16) {
      return iso
    }
    return iso.slice(5, 16).replace('T', ' ')
  }

  private previewPlans(): CommitmentPlan[] {
    const out: CommitmentPlan[] = []
    let count = 0
    for (const row of this.activePlans) {
      if (count >= 2) {
        break
      }
      out.push(row)
      count += 1
    }
    return out
  }

  private previewTemplates(): AppointmentTemplate[] {
    const out: AppointmentTemplate[] = []
    let count = 0
    for (const row of this.templates) {
      if (count >= 2) {
        break
      }
      out.push(row)
      count += 1
    }
    return out
  }

  private async reload(): Promise<void> {
    this.loading = true
    try {
      const all = await AppointmentService.listAll()
      const todayAll = await AppointmentService.listTodayAll()
      this.todayItems = await AppointmentService.listToday()
      this.hint = ScheduleEngine.nextHint(all)
      this.missedCount = AppointmentTools.missed(all).length
      this.totalToday = todayAll.length
      let done = 0
      for (const row of todayAll) {
        if (row.isDone()) {
          done += 1
        }
      }
      this.doneToday = done
      this.snap = await GrowthService.snapshot()
      this.activePlans = await GrowthService.activePlans()
      this.recentLogs = GrowthService.recentLogs(3)
      this.templates = await AppointmentService.templates()
    } catch {
      this.todayItems = []
      this.templates = []
      this.activePlans = []
      this.recentLogs = []
    }
    this.loading = false
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        this.HeroBlock()
        if (this.loading) {
          AppLoading({ label: '加载工作台…' })
        } else {
          ProgressHeroCard({
            doneCount: this.doneToday,
            totalCount: this.totalToday,
            nextTitle: this.hint.hasNext ? this.hint.title : '',
            nextTime: this.hint.timeLabel,
            onContinue: (): void => {
              if (this.hint.hasNext) {
                this.onOpenItem(this.hint.id)
              } else {
                this.onCreate()
              }
            }
          })
          Image($r('app.media.banner_schedule'))
            .width('100%')
            .height(96)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.xl)
            .onClick((): void => { this.onOpenGrowth() })
          Row({ space: 8 }) {
            DataQuadCard({
              label: '待办',
              value: `${this.todayItems.length}`,
              onTap: (): void => { this.onOpenList() }
            })
            DataQuadCard({
              label: '完成',
              value: `${this.snap.totalDone}`,
              onTap: (): void => { this.onOpenGrowth() }
            })
            DataQuadCard({
              label: '收藏',
              value: `${this.snap.favoriteCount}`,
              onTap: (): void => { this.onOpenList() }
            })
            DataQuadCard({
              label: '连续',
              value: `${this.snap.streakDays}天`,
              onTap: (): void => { this.onOpenGrowth() }
            })
          }
          .width('100%')
          Scroll() {
            Row({ space: 8 }) {
              QuickActionChip({ label: '新建', onTap: (): void => { this.onCreate() } })
              QuickActionChip({ label: '导入', onTap: (): void => { this.onOpenImport() } })
              QuickActionChip({ label: '找空档', onTap: (): void => { this.onOpenSlots() } })
              QuickActionChip({ label: '简报', onTap: (): void => { this.onOpenBrief() } })
              QuickActionChip({ label: '搜索', onTap: (): void => { this.onOpenSearch() } })
              QuickActionChip({ label: '日历', onTap: (): void => { this.onOpenCalendar() } })
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')
          this.TodayBlock()
          if (this.recentLogs.length > 0) {
            Column({ space: 8 }) {
              SectionTitle({ title: '最近动态', action: '成长', onAction: (): void => { this.onOpenGrowth() } })
              ForEach(this.recentLogs, (log: ActivityLogItem) => {
                ActivityFeedRow({
                  action: GrowthService.activityLabel(log.type),
                  title: log.title,
                  timeLabel: this.logTime(log.occurredAt),
                  onTap: (): void => {
                    if (log.refId.length > 0) {
                      this.onOpenItem(log.refId)
                    }
                  }
                })
              }, (log: ActivityLogItem) => log.id)
            }
            .width('100%')
          }
          if (this.previewPlans().length > 0) {
            Column({ space: 8 }) {
              SectionTitle({ title: '进行中的计划', action: '全部', onAction: (): void => { this.onOpenPlans() } })
              ForEach(this.previewPlans(), (plan: CommitmentPlan) => {
                PlanSummaryCard({
                  title: plan.title,
                  progressText: `${plan.doneCount}/${plan.targetCount}`,
                  percent: plan.progressPercent(),
                  onTap: (): void => { this.onOpenPlan(plan.id) }
                })
              }, (plan: CommitmentPlan) => plan.id)
            }
            .width('100%')
          }
          ToolGrid({
            missedCount: this.missedCount,
            onBrief: (): void => { this.onOpenBrief() },
            onSlots: (): void => { this.onOpenSlots() },
            onOverdue: (): void => { this.onOpenOverdue() },
            onImport: (): void => { this.onOpenImport() }
          })
          this.SceneHubRow()
          this.TemplateBlock()
        }
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s4,
        bottom: Theme.space.s10
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
    .align(Alignment.Top)
  }

  @Builder
  HeroBlock() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image($r('app.media.hero_appointment'))
        .width('100%')
        .height(160)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.sheet)
      Column()
        .width('100%')
        .height(160)
        .linearGradient({
          angle: 180,
          colors: [['rgba(17,24,39,0.12)', 0], ['rgba(17,24,39,0.82)', 1]]
        })
        .borderRadius(Theme.radius.sheet)
      Column({ space: 6 }) {
        Row() {
          Text(this.appName)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Blank()
          Text(this.userLabel())
            .fontSize(Theme.type.caption)
            .fontColor('#FFFFFF')
        }
        .width('100%')
        Text(ScheduleEngine.todayLongLabel())
          .fontSize(Theme.type.subhead)
          .fontColor('#FFFFFF')
        Text('守约成长工作台')
          .fontSize(Theme.type.caption)
          .fontColor('#FFFFFF')
      }
      .padding(18)
    }
    .width('100%')
  }

  @Builder
  SceneHubRow() {
    Column({ space: 10 }) {
      SectionTitle({ title: '场景中心', action: '全部', onAction: (): void => { this.onOpenSceneHub('work') } })
      Row({ space: 8 }) {
        ForEach(['work', 'life', 'study', 'health'], (key: string) => {
          Text(key === 'work' ? '工作' : key === 'life' ? '生活' : key === 'study' ? '学习' : '健康')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandPrimary)
            .padding({ left: 14, right: 14, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .onClick((): void => { this.onOpenSceneHub(key) })
        }, (key: string) => key)
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  TodayBlock() {
    Column({ space: 12 }) {
      SectionTitle({ title: '今日时间线', action: '全部', onAction: (): void => { this.onOpenList() } })
      if (this.todayItems.length === 0) {
        AppEmpty({
          title: '今天还没有约定',
          description: '从第一条记录开始，建立你的守约空间',
          actionLabel: '创建第一条',
          onAction: (): void => { this.onCreate() }
        })
      } else {
        Column({ space: 4 }) {
          ForEach(this.todayItems, (row: AppointmentItem) => {
            AppointmentRow({
              title: row.title,
              timeLabel: row.timeRangeLabel(),
              meta: AppointmentCardUtil.rowMeta(row),
              done: row.isDone(),
              onTap: (): void => { this.onOpenItem(row.id) }
            })
          }, (row: AppointmentItem) => row.id)
        }
        .width('100%')
        .padding(12)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
      }
    }
    .width('100%')
  }

  @Builder
  TemplateBlock() {
    Column({ space: 12 }) {
      SectionTitle({ title: '场景模板', action: '更多', onAction: (): void => { this.onOpenSceneHub('work') } })
      if (this.templates.length === 0) {
        Text('模板加载中或暂无数据')
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
      } else {
        Grid() {
          ForEach(this.previewTemplates(), (tpl: AppointmentTemplate) => {
            GridItem() {
              TemplateMiniCard({
                template: tpl,
                onTap: (): void => { this.onOpenTemplate(tpl) }
              })
            }
          }, (tpl: AppointmentTemplate) => tpl.id)
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
