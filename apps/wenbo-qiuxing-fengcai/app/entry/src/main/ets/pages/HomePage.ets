import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppCard } from '../components/design-system/AppCard'
import { AppIcon } from '../components/design-system/AppIcon'
import { AthleteListCard } from '../components/sports/AthleteListCard'
import { EventListCard } from '../components/sports/EventListCard'
import { SportCategoryOption } from '../components/sports/SportCategoryBar'
import { AthleteItem, EventItem, KpiItem, FavoriteItem } from '../models/StarModels'
import { FanDashboardSnapshot, TimelineEntry } from '../models/FanGrowthModels'
import { StarBizService } from '../services/StarBizService'
import { StarDetailNav } from '../services/StarDetailNav'
import { ReminderService } from '../services/ReminderService'
import { BrowseHistoryService } from '../services/BrowseHistoryService'
import { FanStatsService } from '../services/FanStatsService'
import { TimelineService } from '../services/TimelineService'

class QuickTool {
  label: string = ''
  caption: string = ''
  action: string = ''

  static rowA(): QuickTool[] {
    const out: QuickTool[] = []
    const t0 = new QuickTool()
    t0.label = '对比'
    t0.caption = '双星研究'
    t0.action = 'compare'
    out.push(t0)
    const t1 = new QuickTool()
    t1.label = '笔记'
    t1.caption = '球探观察'
    t1.action = 'scout'
    out.push(t1)
    const t2 = new QuickTool()
    t2.label = '挑战'
    t2.caption = '知识测验'
    t2.action = 'quiz'
    out.push(t2)
    const t3 = new QuickTool()
    t3.label = '成长'
    t3.caption = '数据回顾'
    t3.action = 'growth'
    out.push(t3)
    return out
  }

  static rowB(): QuickTool[] {
    return QuickTool.rowA()
  }
}

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop company: string = '魏文波'
  @Prop appName: string = '球星风采'
  @Prop tagline: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onOpenMessages: () => void = () => {}
  onSwitchTab: (index: number) => void = () => {}
  @StorageLink('historyTick') historyTick: number = 0
  @StorageLink('growthTick') growthTick: number = 0
  @StorageLink('planTick') planTick: number = 0
  @State featured: AthleteItem[] = []
  @State upcomingEvents: EventItem[] = []
  @State kpis: KpiItem[] = []
  @State timeline: TimelineEntry[] = []
  @State dash: FanDashboardSnapshot = new FanDashboardSnapshot()
  @State followCount: number = 0
  @State loading: boolean = true
  @State dueEventId: string = ''
  @State dueTitle: string = ''
  @State dueContent: string = ''
  private quickTools: QuickTool[] = QuickTool.rowA()
  private sportHubs: SportCategoryOption[] = SportCategoryOption.all().slice(1)

  aboutToAppear(): void {
    this.refreshDue()
    void this.reload()
  }

  onRefreshTokenChange(): void {
    this.refreshDue()
    void this.reload()
  }

  private refreshDue(): void {
    const due = ReminderService.peekDue()
    this.dueEventId = due.eventId
    this.dueTitle = due.title
    this.dueContent = due.content
  }

  private dismissDue(): void {
    void ReminderService.markShown(this.dueEventId)
    this.dueEventId = ''
    this.dueTitle = ''
    this.dueContent = ''
  }

  private greeting(): string {
    const hour = new Date().getHours()
    if (hour < 11) {
      return '早安，发现今日球星'
    }
    if (hour < 17) {
      return '午安，浏览体育人物'
    }
    return '晚安，关注喜爱运动员'
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.dash = FanStatsService.dashboard()
    this.timeline = TimelineService.list(3)
    this.featured = await StarBizService.loadAthletes('', true)
    this.upcomingEvents = await StarBizService.loadEvents('', '', 'upcoming')
    this.kpis = await StarBizService.loadKpis()
    const favs: FavoriteItem[] = await StarBizService.loadFavorites('')
    this.followCount = favs.length
    this.loading = false
  }

  private progressPercent(): number {
    return Math.round(this.dash.planProgress * 100)
  }

  private openTimelineEntry(entry: TimelineEntry): void {
    if (entry.refKind === 'event') {
      StarDetailNav.openEvent(entry.refId)
      return
    }
    if (entry.refKind === 'athlete') {
      StarDetailNav.openAthlete(entry.refId)
    }
  }

  private handleQuickTool(action: string): void {
    if (action === 'compare') {
      StarDetailNav.openCompare()
      return
    }
    if (action === 'watchplan') {
      StarDetailNav.openWatchPlan()
      return
    }
    if (action === 'scout') {
      StarDetailNav.openScoutNotes('')
      return
    }
    if (action === 'quiz') {
      StarDetailNav.openQuiz()
      return
    }
    if (action === 'growth') {
      this.onSwitchTab(3)
      return
    }
    if (action === 'plan') {
      this.onSwitchTab(2)
      return
    }
    if (action === 'discover') {
      this.onSwitchTab(1)
    }
  }

  private hubCoverResource(key: string): Resource {
    if (key === 'football') {
      return $r('app.media.athlete_football_1')
    }
    if (key === 'basketball') {
      return $r('app.media.athlete_basketball_1')
    }
    if (key === 'tennis') {
      return $r('app.media.athlete_tennis_1')
    }
    if (key === 'racing') {
      return $r('app.media.athlete_racing_1')
    }
    return $r('app.media.athlete_other_1')
  }

  @Builder
  StatMini(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().textPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s3)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Row() {
          Column({ space: 6 }) {
            Text(this.greeting())
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(this.appName)
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          Column() {
            AppIcon({ name: 'message', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onOpenMessages() })
        }
        .width('100%')

        Column({ space: Theme.space.s3 }) {
          Text('今日观赛')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Progress({ value: this.dash.watchedCount, total: this.dash.planTotal > 0 ? this.dash.planTotal : 1 })
            .width('100%')
            .color(Theme.colors().brandPrimary)
          Text(`已完成 ${this.dash.watchedCount} / ${this.dash.planTotal} 场 · ${this.progressPercent()}%`)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          if (this.dash.nextPlanTitle.length > 0) {
            Text(`下一场：${this.dash.nextPlanTitle} · ${this.dash.nextPlanCountdown}`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
              .width('100%')
          }
          Row({ space: Theme.space.s2 }) {
            Text('去计划')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { this.onSwitchTab(2) })
            Text('发现赛程')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.pill)
              .border({ width: 1, color: Theme.colors().strokeHairline })
              .onClick((): void => { this.onSwitchTab(1) })
          }
          .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .border({ width: 1, color: Theme.colors().strokeHairline })

        Row({ space: Theme.space.s2 }) {
          this.StatMini('已看', `${this.dash.watchedCount}`)
          this.StatMini('笔记', `${this.dash.noteCount}`)
          this.StatMini('关注', `${this.followCount}`)
          this.StatMini('连续', `${this.dash.streakDays}天`)
        }
        .width('100%')

        Row({ space: Theme.space.s2 }) {
          ForEach(this.quickTools, (tool: QuickTool) => {
            Column({ space: 4 }) {
              Text(tool.label)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
              Text(tool.caption)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .padding(Theme.space.s3)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .border({ width: 1, color: Theme.colors().strokeHairline })
            .onClick((): void => { this.handleQuickTool(tool.action) })
          }, (tool: QuickTool) => tool.action)
        }
        .width('100%')

        Column({ space: Theme.space.s3 }) {
          Row() {
            Text('最近活动')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .layoutWeight(1)
            Text('成长')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
              .onClick((): void => { this.onSwitchTab(3) })
          }
          .width('100%')
          if (this.timeline.length === 0) {
            AppEmpty({
              title: '还没有球迷动态',
              description: '浏览球星或加入观赛计划后会出现在这里',
              actionLabel: '去发现',
              onAction: (): void => { this.onSwitchTab(1) }
            })
          } else {
            ForEach(this.timeline, (entry: TimelineEntry) => {
              Row({ space: Theme.space.s2 }) {
                Text(entry.kindLabel())
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandPrimary)
                  .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                  .backgroundColor(Theme.colors().brandPrimaryContainer)
                  .borderRadius(Theme.radius.pill)
                Column({ space: 2 }) {
                  Text(entry.title)
                    .fontSize(Theme.type.callout)
                    .fontColor(Theme.colors().textPrimary)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .width('100%')
                  Text(entry.timeLabel())
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .width('100%')
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .border({ width: 1, color: Theme.colors().strokeHairline })
              .onClick((): void => { this.openTimelineEntry(entry) })
            }, (entry: TimelineEntry) => entry.id)
          }
        }
        .width('100%')

        Column({ space: Theme.space.s3 }) {
          Text('项目专区')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Scroll() {
            Row({ space: Theme.space.s3 }) {
              ForEach(this.sportHubs, (hub: SportCategoryOption) => {
                Stack({ alignContent: Alignment.BottomStart }) {
                  Image(this.hubCoverResource(hub.key))
                    .width(120)
                    .height(88)
                    .objectFit(ImageFit.Cover)
                    .borderRadius(Theme.radius.lg)
                  Column()
                    .width(120)
                    .height(88)
                    .linearGradient({
                      angle: 180,
                      colors: [['rgba(15,23,42,0)', 0], ['rgba(15,23,42,0.75)', 1]]
                    })
                    .borderRadius(Theme.radius.lg)
                  Text(hub.label)
                    .fontSize(Theme.type.callout)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textOnInverse)
                    .padding(Theme.space.s3)
                }
                .onClick((): void => { StarDetailNav.openSportHub(hub.key) })
              }, (hub: SportCategoryOption) => hub.key)
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')
        }
        .width('100%')

        if (this.dueEventId.length > 0) {
          AppCard({ title: this.dueTitle, variant: 'outlined' }) {
            Column({ space: Theme.space.s2 }) {
              Text(this.dueContent)
                .fontSize(Theme.type.callout)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
              Text('知道了')
                .fontSize(Theme.type.footnote)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                .onClick((): void => { this.dismissDue() })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }
        }

        AppCard({
          title: '消息中心',
          variant: 'outlined',
          onTap: (): void => { this.onOpenMessages() }
        }) {
          Row({ space: Theme.space.s2 }) {
            AppIcon({ name: 'message', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
            Text('赛事开放与提醒通知')
              .fontSize(Theme.type.callout)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
        }

        Column({ space: Theme.space.s3 }) {
          Row() {
            Text('近期赛程')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .layoutWeight(1)
            Text('全部')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .onClick((): void => { this.onSwitchTab(1) })
          }
          .width('100%')
          if (this.loading) {
            AppLoading({ variant: 'skeleton' })
          } else if (this.upcomingEvents.length === 0) {
            AppEmpty({ title: '暂无赛程', description: '可在发现 Tab 浏览全部赛程' })
          } else {
            ForEach(this.upcomingEvents.slice(0, 4), (ev: EventItem) => {
              EventListCard({
                item: ev,
                compact: true,
                onTap: (): void => { StarDetailNav.openEvent(ev.id) }
              })
            }, (ev: EventItem) => ev.id)
          }
        }
        .width('100%')

        if (this.loading) {
          AppLoading({ variant: 'skeleton' })
        } else if (this.featured.length === 0) {
          AppEmpty({
            title: '暂无热门球星',
            description: '请检查网络后下拉刷新',
            actionLabel: '重试',
            onAction: (): void => { void this.reload() }
          })
        } else {
          Column({ space: Theme.space.s3 }) {
            Row() {
              Text('热门球星')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .layoutWeight(1)
              Text('全部')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                .onClick((): void => { this.onSwitchTab(1) })
            }
            .width('100%')
            ForEach(this.featured.slice(0, 6), (item: AthleteItem) => {
              AthleteListCard({
                item: item,
                compact: true,
                onTap: (): void => { StarDetailNav.openAthlete(item.id) }
              })
            }, (item: AthleteItem) => item.id)
          }
          .width('100%')
        }
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s10
      })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }
}
