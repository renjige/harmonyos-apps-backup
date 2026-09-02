import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { CwGoal, CwGoalCategory, CwPlan, CwPlanTemplate } from '../models/ChenwuModels'
import { ChenwuStore } from '../services/ChenwuStore'
import { ChenwuDetailNav } from '../services/ChenwuDetailNav'
import { ChenwuMedia } from '../services/ChenwuMedia'
import { GoalListCard } from '../components/chenwu/GoalListCard'
import { PlanListCard } from '../components/chenwu/PlanListCard'

@Component
export struct PlanPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('cwDataRev') @Watch('onDataRev') dataRev: number = 0
  @StorageLink('tabBarHidden') @Watch('onTabBarChange') tabBarHidden: boolean = false
  @Prop @Watch('onRefresh') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State filter: string = 'all'
  @State goals: CwGoal[] = []
  @State plans: CwPlan[] = []
  @State cats: CwGoalCategory[] = []
  @State templates: CwPlanTemplate[] = CwPlanTemplate.defaults()
  @State goalMap: Map<string, string> = new Map()
  @State planPctMap: Map<string, number> = new Map()
  @State listEpoch: number = 0

  aboutToAppear(): void {
    void this.reload()
  }

  onRefresh(): void {
    void this.reload()
  }

  onDataRev(): void {
    void this.reload()
  }

  onTabBarChange(): void {
    if (!this.tabBarHidden) {
      void this.reload()
    }
  }

  private async reload(): Promise<void> {
    this.cats = await ChenwuStore.loadCategories()
    const allGoals = await ChenwuStore.loadGoals()
    for (const g of allGoals) {
      await ChenwuStore.syncGoalProgress(g.id)
    }
    this.goals = await ChenwuStore.loadGoals()
    const allPlans = await ChenwuStore.loadPlans()
    const next: CwPlan[] = []
    const pctMap = new Map<string, number>()
    for (const p of allPlans) {
      if (this.filter === 'all' || p.horizonType === this.filter) {
        next.push(p)
      }
      pctMap.set(p.id, await ChenwuStore.planCompletionPct(p.id))
    }
    this.plans = next
    this.planPctMap = pctMap
    const gm = new Map<string, string>()
    for (const g of this.goals) {
      gm.set(g.id, g.title)
    }
    this.goalMap = gm
    this.listEpoch = this.listEpoch + 1
  }

  private catLabel(key: string): string {
    return ChenwuStore.categoryLabel(key, this.cats)
  }

  private coverForGoal(g: CwGoal): string {
    for (const c of this.cats) {
      if (c.key === g.categoryKey) {
        return c.coverKey
      }
    }
    return 'cover_goal_learn'
  }

  private goalTitle(plan: CwPlan): string {
    const t = this.goalMap.get(plan.goalId)
    return t !== undefined ? t : ''
  }

  private async applyTemplate(key: string): Promise<void> {
    let goalId = ''
    if (this.goals.length > 0) {
      goalId = this.goals[0].id
    } else {
      const g = CwGoal.createNew('我的成长目标', 'learn')
      await ChenwuStore.saveGoal(g)
      goalId = g.id
    }
    const planId = await ChenwuStore.applyTemplate(key, goalId)
    if (planId.length > 0) {
      ChenwuDetailNav.openPlan(planId)
    }
    await this.reload()
  }

  build() {
    Scroll() {
    Column() {
      Row() {
        Text('计划中心')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
        Column() {
          AppIcon({ name: 'add', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { ChenwuDetailNav.openPlanEditor('') })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s6 })

      Scroll() {
        Row({ space: 8 }) {
          this.chip('all', '全部')
          this.chip('long', '长期')
          this.chip('phase', '阶段')
          this.chip('short', '短期')
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
      .width('100%')

      Text('目标分类')
        .fontSize(Theme.type.subtitleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
        .padding({ left: Theme.space.pageX, top: Theme.space.s3 })
      Scroll() {
        Row({ space: Theme.space.s3 }) {
          ForEach(this.cats, (c: CwGoalCategory) => {
            Column({ space: 4 }) {
              Image(ChenwuMedia.coverOf(c.coverKey))
                .width(72)
                .height(72)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.sm)
              Text(c.label)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textPrimary)
            }
            .onClick((): void => {
              const g = CwGoal.createNew(c.label, c.key)
              void ChenwuStore.saveGoal(g).then(() => {
                ChenwuDetailNav.openGoalEditor(g.id)
              })
            })
          }, (c: CwGoalCategory) => c.key)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')

      Text('我的目标')
        .fontSize(Theme.type.subtitleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
        .padding({ left: Theme.space.pageX, top: Theme.space.s4 })
      if (this.goals.length === 0) {
        AppEmpty({
          title: '还没有目标',
          description: '先添加一个成长目标，再拆解计划',
          actionLabel: '添加目标',
          onAction: (): void => { ChenwuDetailNav.openGoalEditor('') }
        })
      } else {
        Column({ space: Theme.space.s3 }) {
          ForEach(this.goals.slice(0, 3), (g: CwGoal) => {
            GoalListCard({
              goal: g,
              categoryLabel: this.catLabel(g.categoryKey),
              coverKey: this.coverForGoal(g),
              onOpen: (): void => { ChenwuDetailNav.openGoal(g.id) }
            })
          }, (g: CwGoal) => `${g.id}_${g.progress}_${this.listEpoch}`)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }

      Text('计划列表')
        .fontSize(Theme.type.subtitleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
        .padding({ left: Theme.space.pageX, top: Theme.space.s4 })
      if (this.plans.length === 0) {
        AppEmpty({
          title: '还没有计划',
          description: '从模板快速创建，或手动新建',
          actionLabel: '创建计划',
          onAction: (): void => { ChenwuDetailNav.openPlanEditor('') }
        })
      } else {
        Column({ space: Theme.space.s3 }) {
          ForEach(this.plans, (p: CwPlan) => {
            PlanListCard({
              plan: p,
              goalTitle: this.goalTitle(p),
              progressPct: this.planPctMap.get(p.id) ?? 0,
              onOpen: (): void => { ChenwuDetailNav.openPlan(p.id) }
            })
          }, (p: CwPlan) => `${p.id}_${p.status}_${this.planPctMap.get(p.id) ?? 0}`)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }

      Text('计划模板')
        .fontSize(Theme.type.subtitleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
        .padding({ left: Theme.space.pageX, top: Theme.space.s4 })
      Column({ space: Theme.space.s3 }) {
        ForEach(this.templates, (t: CwPlanTemplate) => {
          Column({ space: 6 }) {
            Text(t.title)
              .fontSize(Theme.type.body)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Text(t.description)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Text('使用模板')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
              .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .onClick((): void => { void this.applyTemplate(t.key) })
        }, (t: CwPlanTemplate) => t.key)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: this.bottomInset })
    }
    .width('100%')
    }
    .width('100%')
    .height('100%')
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .backgroundColor(Theme.colors().surfacePage)
    .onAppear((): void => { void this.reload() })
  }

  @Builder
  chip(key: string, label: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.filter === key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .backgroundColor(this.filter === key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => {
        this.filter = key
        void this.reload()
      })
  }
}
