import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppIcon } from '../components/design-system/AppIcon'
import { GrowthReviewCard } from '../components/life/GrowthReviewCard'
import { GrowthTrendStrip } from '../components/life/GrowthTrendStrip'
import { HomePlanStrip } from '../components/life/HomePlanStrip'
import { PeriodReview, AchievementBadge, ActivityEvent, PlanItem } from '../models/LifeGrowthModels'
import { DayCount } from '../models/LifeHubModels'
import { LifeGrowthService } from '../services/LifeGrowthService'
import { LifeHubNav } from '../services/LifeHubNav'
import { JournalDetailNav } from '../services/JournalDetailNav'
import { ReviewPage } from './ReviewPage'

class GrowLink {
  id: string = ''
  title: string = ''
  hint: string = ''

  constructor(id: string, title: string, hint: string) {
    this.id = id
    this.title = title
    this.hint = hint
  }
}

@Component
export struct GrowthPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('lifeHubVersion') @Watch('onVer') lifeHubVersion: number = 0
  @StorageLink('diaryDataVersion') @Watch('onVer') diaryDataVersion: number = 0
  @StorageLink('currentUsername') @Watch('onVer') currentUsername: string = ''
  @StorageLink('accessToken') @Watch('onVer') accessToken: string = ''
  @Prop @Watch('onVer') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  @State weekTitle: string = '本周回顾'
  @State weekSummary: string = ''
  @State weekDiary: number = 0
  @State weekMood: number = 0
  @State weekHabit: number = 0
  @State weekTodo: number = 0
  @State monthTitle: string = '本月回顾'
  @State monthSummary: string = ''
  @State monthDiary: number = 0
  @State monthMood: number = 0
  @State monthHabit: number = 0
  @State monthTodo: number = 0
  @State badges: AchievementBadge[] = []
  @State acts: ActivityEvent[] = []
  @State unlocked: number = 0
  @State showAnnual: boolean = false
  @State trend: DayCount[] = []
  @State plans: PlanItem[] = []
  @State planEpoch: number = 0
  private links: GrowLink[] = [
    new GrowLink('plans', '生活计划', '本周 / 本月任务与完成度'),
    new GrowLink('topics', '生活专题', '按标签收成自己的主题'),
    new GrowLink('search', '全文检索', '跨笺语、待办与收藏查找'),
    new GrowLink('achievements', '成就墙', '由真实记录点亮徽章'),
    new GrowLink('activity', '生活动态', '把日子串成时间轴')
  ]

  aboutToAppear(): void {
    void this.reload()
  }

  onVer(): void {
    void this.reload()
  }

  private applyPeriod(week: boolean, row: PeriodReview): void {
    if (week) {
      this.weekTitle = row.title
      this.weekSummary = row.summary
      this.weekDiary = row.diaryCount
      this.weekMood = row.moodCount
      this.weekHabit = row.habitHits
      this.weekTodo = row.todoDone
      return
    }
    this.monthTitle = row.title
    this.monthSummary = row.summary
    this.monthDiary = row.diaryCount
    this.monthMood = row.moodCount
    this.monthHabit = row.habitHits
    this.monthTodo = row.todoDone
  }

  private async reload(): Promise<void> {
    const uid = this.currentUsername
    const week = await LifeGrowthService.loadWeekReview(uid)
    this.applyPeriod(true, week)
    const month = await LifeGrowthService.loadMonthReview(uid)
    this.applyPeriod(false, month)
    this.badges = await LifeGrowthService.loadBadges(uid)
    const acts = await LifeGrowthService.loadActivities(uid)
    const recent: ActivityEvent[] = []
    for (const a of acts) {
      if (recent.length < 4) {
        recent.push(a)
      }
    }
    this.acts = recent
    let n = 0
    for (const b of this.badges) {
      if (b.unlocked) {
        n += 1
      }
    }
    this.unlocked = n
    this.trend = await LifeGrowthService.loadWeekTrend(uid)
    this.plans = await LifeGrowthService.loadActivePlans(uid, 3)
    this.planEpoch += 1
  }

  private openGrowthEntry(id: string): void {
    if (id === 'annual') {
      this.showAnnual = true
      AppStorage.setOrCreate('tabBarHidden', true)
      return
    }
    if (id === 'plans') {
      AppStorage.setOrCreate('pendingTab', 2)
      return
    }
    LifeHubNav.open(id, false)
  }

  build() {
    Stack() {
      Column() {
        AppHeader({ title: '成长', subtitle: '周月回顾 · 趋势 · 计划 · 成就 · 动态' })
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            GrowthReviewCard({
              cardTitle: this.weekTitle,
              summary: this.weekSummary,
              diaryCount: this.weekDiary,
              moodCount: this.weekMood,
              habitHits: this.weekHabit,
              todoDone: this.weekTodo
            })
            GrowthReviewCard({
              cardTitle: this.monthTitle,
              summary: this.monthSummary,
              diaryCount: this.monthDiary,
              moodCount: this.monthMood,
              habitHits: this.monthHabit,
              todoDone: this.monthTodo
            })

            GrowthTrendStrip({ trend: this.trend })

            HomePlanStrip({
              plans: this.plans,
              listEpoch: this.planEpoch
            })

            Column({ space: Theme.space.s3 }) {
              Row() {
                Text('成就')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                Blank()
                Text(`${this.unlocked} / ${this.badges.length}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandPrimary)
              }
              .width('100%')
              .onClick((): void => { LifeHubNav.open('achievements', false) })
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.badges, (b: AchievementBadge) => {
                  Text(b.title)
                    .fontSize(Theme.type.caption)
                    .fontColor(b.unlocked ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                    .backgroundColor(b.unlocked ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                    .borderRadius(Theme.radius.pill)
                    .margin({ right: 8, bottom: 8 })
                }, (b: AchievementBadge) => b.id)
              }
              .width('100%')
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.xl)

            Column({ space: Theme.space.s3 }) {
              Text('最近动态')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              if (this.acts.length === 0) {
                Text('写下第一页或完成一件待办，动态就会出现。')
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
              }
              ForEach(this.acts, (a: ActivityEvent) => {
                Text(`${a.date}  ${a.title}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
                  .onClick((): void => {
                    if (a.kind === 'diary') {
                      JournalDetailNav.openDiary(a.refId)
                    }
                  })
              }, (a: ActivityEvent) => a.id)
              Text('查看全部动态')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandPrimary)
                .onClick((): void => { LifeHubNav.open('activity', false) })
            }
            .width('100%')
            .padding(Theme.space.s4)
            .alignItems(HorizontalAlign.Start)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.xl)

            ForEach(this.links, (l: GrowLink) => {
              Row({ space: Theme.space.s3 }) {
                Column({ space: 2 }) {
                  Text(l.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                  Text(l.hint)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textTertiary)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .onClick((): void => { this.openGrowthEntry(l.id) })
            }, (l: GrowLink) => l.id)

            Row() {
              Text('年度笺历与智慧整理')
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().brandPrimary)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .onClick((): void => { this.openGrowthEntry('annual') })
          }
          .width('100%')
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.showAnnual) {
        Column() {
          Row({ space: Theme.space.s2 }) {
            Column() {
              AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
            }
            .width(44)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .rotate({ angle: 180 })
            .onClick((): void => {
              this.showAnnual = false
              AppStorage.setOrCreate('tabBarHidden', false)
            })
            Text('返回成长')
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().textPrimary)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX - 8, top: Theme.space.s2 })
          ReviewPage({
            onRequireAuth: (): void => this.onRequireAuth()
          })
            .layoutWeight(1)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().surfacePage)
        .zIndex(12)
      }
    }
    .width('100%')
    .height('100%')
  }
}
