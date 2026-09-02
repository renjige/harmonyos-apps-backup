import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { AuthService } from '../services/AuthService'
import {
  ActivityRow,
  HomeStatCard,
  QuickActionCard,
  SectionTitle,
  TemplateCard,
  TipCard,
  TripCard,
  WorkbenchProgressCard
} from '../components/travel/TravelCards'
import { CountdownCard } from '../components/travel/CountdownCard'
import {
  ChecklistItem,
  ChecklistPreset,
  ItineraryItem,
  NoteItem,
  ReminderItem,
  TravelTemplate,
  TravelTip,
  TripItem
} from '../models/TravelModels'
import { ActivityEvent, TravelStatsSnapshot } from '../models/TravelGrowthModels'
import { TravelGrowthService } from '../services/TravelGrowthService'
import { TravelService } from '../services/TravelService'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('currentUsername') currentUsername: string = ''
  @State trips: TripItem[] = []
  @State templates: TravelTemplate[] = []
  @State checklist: ChecklistItem[] = []
  @State presets: ChecklistPreset[] = []
  @State notes: NoteItem[] = []
  @State tips: TravelTip[] = []
  @State reminders: ReminderItem[] = []
  @State todayAgenda: ItineraryItem[] = []
  @State nearestTrip: TripItem = new TripItem()
  @State activities: ActivityEvent[] = []
  @State stats: TravelStatsSnapshot = new TravelStatsSnapshot()
  @State prepChecked: boolean = false
  @State loading: boolean = false
  @Prop @Watch('onEpochChange') dataEpoch: number = 0
  onOpenTrip: (trip: TripItem) => void = () => {}
  onCreateTrip: () => void = () => {}
  onOpenTrips: () => void = () => {}
  onOpenPrepare: () => void = () => {}
  onOpenGuide: () => void = () => {}
  onOpenSearch: () => void = () => {}
  onOpenGrowth: (segment: string) => void = () => {}
  onOpenTemplate: (item: TravelTemplate) => void = () => {}
  onOpenTip: (item: TravelTip) => void = () => {}
  onRequireAuth: () => void = () => {}
  onToast: (message: string) => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  onEpochChange(): void {
    void this.load(true)
  }

  private async load(silent: boolean = false): Promise<void> {
    if (!silent) {
      this.loading = true
    }
    try {
      const tripRows = await TravelService.trips()
      this.templates = await TravelService.templates()
      this.checklist = await TravelService.checklistItems()
      this.presets = await TravelService.presets()
      this.notes = await TravelService.notes()
      this.tips = await TravelService.tips()
      this.reminders = await TravelService.reminders()
      this.todayAgenda = await TravelService.todayAgenda()
      this.trips = TravelService.attachProgress(tripRows, this.checklist)
      this.nearestTrip = TravelService.nearestUpcomingTrip(this.trips)
      const favorites = await TravelGrowthService.listFavorites()
      const streak = AuthService.isLoggedIn() ? await TravelGrowthService.prepStreakDays() : 0
      this.stats = TravelGrowthService.computeStats(
        this.trips, this.checklist, favorites, streak, this.notes, this.reminders
      )
      this.activities = TravelGrowthService.buildActivities(this.trips, this.checklist, this.notes, favorites)
      this.prepChecked = AuthService.isLoggedIn() ? await TravelGrowthService.prepCheckedToday() : false
    } catch {
      this.trips = []
      this.templates = []
      this.checklist = []
      this.presets = []
      this.notes = []
      this.tips = []
      this.reminders = []
      this.todayAgenda = []
      this.nearestTrip = new TripItem()
      this.activities = []
      this.stats = new TravelStatsSnapshot()
    }
    this.loading = false
  }

  private completedCount(): number {
    let count = 0
    for (const item of this.checklist) {
      if (item.completed) {
        count += 1
      }
    }
    return count
  }

  private checklistTotal(): number {
    if (this.checklist.length > 0) {
      return this.checklist.length
    }
    return this.presets.length
  }

  private previewTrips(): TripItem[] {
    const out: TripItem[] = []
    for (const trip of this.trips) {
      if (out.length >= 2) {
        break
      }
      out.push(trip)
    }
    return out
  }

  private previewTemplates(): TravelTemplate[] {
    const out: TravelTemplate[] = []
    for (const item of this.templates) {
      if (out.length >= 2) {
        break
      }
      out.push(item)
    }
    return out
  }

  private previewTips(): TravelTip[] {
    const out: TravelTip[] = []
    for (const item of this.tips) {
      if (out.length >= 2) {
        break
      }
      out.push(item)
    }
    return out
  }

  private previewActivities(): ActivityEvent[] {
    const out: ActivityEvent[] = []
    for (const item of this.activities) {
      if (out.length >= 5) {
        break
      }
      out.push(item)
    }
    return out
  }

  private upcomingReminders(): ReminderItem[] {
    return TravelService.upcomingReminders(this.reminders, 3)
  }

  private daysLeft(): number {
    if (this.nearestTrip.startDate.length === 0) {
      return -1
    }
    return TravelService.daysUntil(this.nearestTrip.startDate)
  }

  private async handleCheckIn(): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      this.onRequireAuth()
      return
    }
    if (this.prepChecked) {
      this.onToast('今日已完成准备打卡')
      return
    }
    const ok = await TravelGrowthService.checkInPrep()
    if (ok) {
      this.prepChecked = true
      this.onToast('准备打卡成功，连续天数已更新')
      void this.load(true)
    } else {
      this.onToast('打卡失败，请稍后重试')
    }
  }

  private greeting(): string {
    if (this.currentUsername.length > 0) {
      return `你好，${this.currentUsername}`
    }
    return '出行备忘 · 出行工作台'
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Row() {
          Column({ space: 4 }) {
            Text(this.greeting())
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textPrimary)
            Text('规划 · 准备 · 出发 · 回顾')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          Row() {
            AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.lg)
          .onClick(() => this.onOpenSearch())
        }
        .width('100%')

        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.travel_hero'))
            .width('100%')
            .height(180)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.sheet)
          Column()
            .width('100%')
            .height(180)
            .linearGradient({
              angle: 180,
              colors: [['rgba(11,39,86,0.05)', 0], ['rgba(7,32,74,0.75)', 1]]
            })
            .borderRadius(Theme.radius.sheet)
          Text('从规划到回顾，每一次出行有迹可循')
            .fontSize(Theme.type.subhead)
            .fontColor('#FFFFFF')
            .padding(Theme.space.s4)
        }
        .width('100%')

        WorkbenchProgressCard({
          tripTitle: this.nearestTrip.title,
          destination: this.nearestTrip.destination,
          daysLeft: this.daysLeft(),
          done: this.completedCount(),
          total: this.checklistTotal(),
          progress: this.nearestTrip.progress,
          onContinue: () => {
            if (this.nearestTrip.id.length > 0) {
              this.onOpenTrip(this.nearestTrip)
            } else {
              this.onOpenPrepare()
            }
          }
        })

        Row({ space: Theme.space.s3 }) {
          HomeStatCard({ label: '行程', value: `${this.stats.tripCount}` })
          HomeStatCard({ label: '清单完成', value: `${this.stats.checklistDone}` })
        }
        Row({ space: Theme.space.s3 }) {
          HomeStatCard({ label: '收藏', value: `${this.stats.favoriteCount}` })
          HomeStatCard({ label: '连续准备', value: `${this.stats.prepStreakDays}天` })
        }

        Row({ space: Theme.space.s3 }) {
          QuickActionCard({
            title: '新建行程',
            subtitle: '规划目的地',
            icon: 'add',
            onTap: () => this.onCreateTrip()
          })
          QuickActionCard({
            title: '准备打卡',
            subtitle: this.prepChecked ? '今日已打卡' : '出发前每日确认',
            icon: 'check',
            onTap: (): void => { void this.handleCheckIn() }
          })
          QuickActionCard({
            title: '出行成长',
            subtitle: '统计·成就·回顾',
            icon: 'chart',
            onTap: () => this.onOpenGrowth('stats')
          })
        }

        if (this.nearestTrip.id.length > 0) {
          CountdownCard({ trip: this.nearestTrip })
            .onClick(() => this.onOpenTrip(this.nearestTrip))
        }

        if (this.todayAgenda.length > 0) {
          SectionTitle({ title: '今日安排' })
          ForEach(this.todayAgenda, (item: ItineraryItem) => {
            Row({ space: Theme.space.s3 }) {
              Text(item.startTime.length > 0 ? item.startTime : '全天')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandPrimary)
                .width(52)
              Column({ space: 4 }) {
                Text(item.title)
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Text(item.location.length > 0 ? item.location : item.note)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.xl)
          }, (item: ItineraryItem) => item.id)
        }

        if (this.upcomingReminders().length > 0) {
          SectionTitle({ title: '临近提醒', action: '去准备中心', onAction: () => this.onOpenPrepare() })
          ForEach(this.upcomingReminders(), (item: ReminderItem) => {
            Row({ space: Theme.space.s2 }) {
              Text(item.reminderType)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandPrimary)
              Text(`${item.remindAt} · ${item.title}`)
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textPrimary)
                .layoutWeight(1)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
          }, (item: ReminderItem) => item.id)
        }

        if (this.previewActivities().length > 0) {
          SectionTitle({ title: '最近动态', action: '全部', onAction: () => this.onOpenGrowth('activity') })
          ForEach(this.previewActivities(), (item: ActivityEvent) => {
            ActivityRow({ title: item.title, subtitle: item.subtitle })
          }, (item: ActivityEvent) => item.id)
        }

        if (this.loading) {
          LoadingProgress()
            .width(32)
            .height(32)
            .color(Theme.colors().brandPrimary)
        }

        SectionTitle({ title: '最近行程', action: '查看全部', onAction: () => this.onOpenTrips() })
        if (this.trips.length === 0 && !this.loading) {
          AppEmpty({
            title: '还没有行程',
            description: '创建行程或在攻略页使用模板一键生成',
            actionLabel: '去攻略',
            onAction: () => this.onOpenGuide()
          })
        } else {
          ForEach(this.previewTrips(), (trip: TripItem) => {
            TripCard({ trip: trip, onTap: () => this.onOpenTrip(trip) })
          }, (trip: TripItem) => trip.id)
        }

        SectionTitle({ title: '旅行模板', action: '全部攻略', onAction: () => this.onOpenGuide() })
        if (this.templates.length === 0 && !this.loading) {
          Text('暂无公开模板，可稍后重试')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.xl)
        } else {
          ForEach(this.previewTemplates(), (item: TravelTemplate) => {
            TemplateCard({ item: item, onTap: () => this.onOpenTemplate(item) })
          }, (item: TravelTemplate) => item.id)
        }

        if (this.tips.length > 0) {
          SectionTitle({ title: '出行贴士', action: '查看更多', onAction: () => this.onOpenGuide() })
          Image($r('app.media.travel_checklist'))
            .width('100%')
            .height(120)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.xl)
          ForEach(this.previewTips(), (item: TravelTip) => {
            TipCard({ item: item, onTap: () => this.onOpenTip(item) })
          }, (item: TravelTip) => item.id)
        }
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s4,
        bottom: Theme.space.s10
      })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .backgroundColor(Theme.colors().surfacePage)
  }
}
