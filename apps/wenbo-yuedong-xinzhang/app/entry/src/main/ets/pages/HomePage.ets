import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { YdChapterProgressCard } from '../components/yuedong/YdChapterProgressCard'
import { YdDailyNoteCard } from '../components/yuedong/YdDailyNoteCard'
import { YdWeekHeatmap } from '../components/yuedong/YdWeekHeatmap'
import { YdTaskRow } from '../components/yuedong/YdTaskRow'
import { YdTodayProgressCard } from '../components/yuedong/YdTodayProgressCard'
import { YdChapterItem, YdGoalItem, YdHomeSummary, YdHourSlot, YdTaskItem, YdTimelineEvent, YdWeekDayStat } from '../models/YdModels'
import { YdLocalStore } from '../services/YdLocalStore'
import { YdDetailNav } from '../services/YdDetailNav'

enum HomeMiniStatKind {
  Task = 0,
  Done = 1,
  Favorite = 2,
  Streak = 3
}

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('ydDataRefresh') @Watch('onGlobalRefresh') globalRefresh: number = 0
  @Prop appName: string = '跃动新章'
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  onDataChanged: () => void = () => {}
  @State tasks: YdTaskItem[] = []
  @State hours: YdHourSlot[] = []
  @State chapter: YdChapterItem = new YdChapterItem()
  @State hasChapter: boolean = false
  @State progressEpoch: number = 0
  @State todayDoneCount: number = 0
  @State todayTotal: number = 0
  @State dateLabel: string = ''
  @State timeline: boolean = false
  @State toast: string = ''
  @State weekDays: YdWeekDayStat[] = []
  @State summary: YdHomeSummary = new YdHomeSummary()
  @State activities: YdTimelineEvent[] = []
  @State nickname: string = '跃动用户'
  @State activeGoals: YdGoalItem[] = []
  private scrollCtrl: Scroller = new Scroller()
  @State tasksSectionY: number = 0

  aboutToAppear(): void {
    this.dateLabel = this.formatToday()
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  onGlobalRefresh(): void {
    void this.reload()
  }

  private miniStatValue(kind: HomeMiniStatKind): string {
    if (kind === HomeMiniStatKind.Task) {
      return `${this.summary.taskTotal}`
    }
    if (kind === HomeMiniStatKind.Done) {
      return `${this.summary.taskDoneAll}`
    }
    if (kind === HomeMiniStatKind.Favorite) {
      return `${this.summary.favoriteCount}`
    }
    return `${this.summary.streakDays}天`
  }

  private miniStatLabel(kind: HomeMiniStatKind): string {
    if (kind === HomeMiniStatKind.Task) {
      return '任务'
    }
    if (kind === HomeMiniStatKind.Done) {
      return '完成'
    }
    if (kind === HomeMiniStatKind.Favorite) {
      return '收藏'
    }
    return '连续'
  }

  private formatToday(): string {
    const d = new Date()
    const w = ['日', '一', '二', '三', '四', '五', '六'][d.getDay()]
    return `${d.getMonth() + 1}月${d.getDate()}日 · 周${w}`
  }

  private async reload(): Promise<void> {
    this.dateLabel = this.formatToday()
    const key = YdTaskItem.todayKey()
    const loaded = await YdLocalStore.loadTasksForDate(key)
    const copy: YdTaskItem[] = []
    for (const t of loaded) {
      copy.push(YdLocalStore.cloneTask(t))
    }
    this.tasks = copy
    this.hours = YdLocalStore.buildHourSlots(this.tasks)
    this.syncTodayStats()
    this.bumpProgress()
    const ch = await YdLocalStore.findActiveChapter()
    if (ch !== undefined) {
      this.chapter = ch
      this.hasChapter = true
    } else {
      this.chapter = new YdChapterItem()
      this.hasChapter = false
    }
    this.weekDays = await YdLocalStore.computeWeekDayStats()
    this.summary = await YdLocalStore.computeHomeSummary()
    this.activities = await YdLocalStore.buildRecentActivity(5)
    const profile = await YdLocalStore.loadProfile()
    this.nickname = profile.nickname
    const goals = await YdLocalStore.loadActiveGoals()
    const top: YdGoalItem[] = []
    for (let i = 0; i < goals.length && i < 2; i++) {
      top.push(goals[i])
    }
    this.activeGoals = top
  }

  private syncTodayStats(): void {
    let done = 0
    for (const t of this.tasks) {
      if (t.done) {
        done++
      }
    }
    this.todayDoneCount = done
    this.todayTotal = this.tasks.length
  }

  private countTodayDone(): number {
    return this.todayDoneCount
  }

  private todayTotalCount(): number {
    return this.todayTotal
  }

  private progressPercent(): number {
    if (this.todayTotal <= 0) {
      return 0
    }
    return Math.floor((this.todayDoneCount * 100) / this.todayTotal)
  }

  private bumpProgress(): void {
    this.progressEpoch++
  }

  private async handleTaskToggle(taskId: string, done: boolean): Promise<void> {
    const next: YdTaskItem[] = []
    for (const t of this.tasks) {
      const item = YdLocalStore.cloneTask(t)
      if (item.id === taskId) {
        item.done = done
      }
      next.push(item)
    }
    this.tasks = next
    this.hours = YdLocalStore.buildHourSlots(this.tasks)
    this.syncTodayStats()
    this.bumpProgress()
    await YdLocalStore.setTaskDone(taskId, done)
    this.summary = await YdLocalStore.computeHomeSummary()
    this.onDataChanged()
  }

  private showToast(message: string): void {
    this.toast = message
    setTimeout((): void => { this.toast = '' }, 2600)
  }

  private handleContinueTap(): void {
    if (this.todayTotal === 0) {
      YdDetailNav.openTaskAdd()
      return
    }
    if (this.todayDoneCount >= this.todayTotal) {
      this.showToast('今日任务已全部完成，可在成长页查看统计')
      return
    }
    let firstUndoneId = ''
    for (const t of this.tasks) {
      if (!t.done) {
        firstUndoneId = t.id
        break
      }
    }
    if (this.tasksSectionY > 0) {
      this.scrollCtrl.scrollTo({
        xOffset: 0,
        yOffset: this.tasksSectionY,
        animation: { duration: 300, curve: Curve.EaseOut }
      })
    }
    if (firstUndoneId.length > 0) {
      this.showToast('请在下方勾选 Checkbox，或点进任务详情完成')
    } else {
      this.showToast('请在下方今日安排中完成任务')
    }
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Scroll(this.scrollCtrl) {
        Column({ space: Theme.space.s5 }) {
          this.WorkbenchHeader()
          YdTodayProgressCard({
            doneCount: this.todayDoneCount,
            totalCount: this.todayTotal,
            leapIndex: this.summary.leapIndex,
            checkInToday: this.summary.checkInToday,
            onContinueTap: (): void => { this.handleContinueTap() }
          })
          this.StatGrid()
          this.QuickActions()
          this.RecentActivity()
          this.ActiveGoalsStrip()
          this.ChapterBanner()
          if (this.hasChapter) {
            YdChapterProgressCard({ chapter: this.chapter })
          }
          YdWeekHeatmap({ days: this.weekDays })
          YdDailyNoteCard({
            refreshToken: this.refreshToken,
            onSaved: (): void => { this.onDataChanged() }
          })

          Column({ space: Theme.space.s3 }) {
            Row() {
              Text('今日安排')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Blank()
              this.ViewModePills()
            }
            .width('100%')
            .margin({ top: Theme.space.s2 })

            if (this.tasks.length === 0) {
              this.EmptyGuide()
            } else if (this.timeline) {
              ForEach(this.hours, (h: YdHourSlot) => {
                this.HourRow(h)
              }, (h: YdHourSlot) => `${h.hour}`)
            } else {
            ForEach(this.tasks, (t: YdTaskItem) => {
              YdTaskRow({
                task: t,
                onToggle: (taskId: string, done: boolean): void => {
                  void this.handleTaskToggle(taskId, done)
                },
                onOpen: (taskId: string): void => {
                  YdDetailNav.openTaskDetail(taskId)
                }
              })
            }, (t: YdTaskItem) => `${t.id}_${t.done ? '1' : '0'}`)
            }
          }
          .width('100%')
          .onAreaChange((_old: Area, area: Area): void => {
            this.tasksSectionY = area.position.y as number
          })
        }
        .width('100%')
        .padding(Theme.space.pageX)
        .padding({ top: Theme.space.s3, bottom: 112 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      .edgeEffect(EdgeEffect.Spring)

      Column() {
        AppIcon({ name: 'add', iconSize: 26, color: Theme.colors().brandOnPrimary })
      }
      .width(56)
      .height(56)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimary)
      .borderRadius(28)
      .margin({ right: Theme.space.pageX, bottom: Theme.space.s8 })
      .shadow({ radius: 20, color: 'rgba(0,125,255,0.28)', offsetX: 0, offsetY: 6 })
      .onClick(() => YdDetailNav.openTaskAdd())

      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '8%', y: 48 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  WorkbenchHeader() {
    Row() {
      Column({ space: 4 }) {
        Text(this.appName)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .letterSpacing(1)
        Text(`你好，${this.nickname}`)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Text(this.dateLabel)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textSecondary)
      }
      .alignItems(HorizontalAlign.Start)
      Blank()
      Column() {
        AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
      }
      .width(44)
      .height(44)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(22)
      .onClick(() => YdDetailNav.openSearch())
    }
    .width('100%')
  }

  @Builder
  StatGrid() {
    Row({ space: Theme.space.s2 }) {
      this.MiniStat(HomeMiniStatKind.Task)
      this.MiniStat(HomeMiniStatKind.Done)
      this.MiniStat(HomeMiniStatKind.Favorite)
      this.MiniStat(HomeMiniStatKind.Streak)
    }
    .width('100%')
  }

  @Builder
  MiniStat(kind: HomeMiniStatKind) {
    Column({ space: 4 }) {
      Text(this.miniStatValue(kind))
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().brandPrimary)
      Text(this.miniStatLabel(kind))
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s3)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  QuickActions() {
    Row({ space: Theme.space.s2 }) {
      this.ActionPill('任务', (): void => { YdDetailNav.openTaskAdd() })
      this.ActionPill('篇章', (): void => {
        if (this.hasChapter) {
          YdDetailNav.openChapterDetail(this.chapter.id)
        } else {
          YdDetailNav.openChapterCreate()
        }
      })
      this.ActionPill('打卡', (): void => { YdDetailNav.openCheckIn() })
      this.ActionPill('收藏', (): void => { YdDetailNav.openFavorites() })
    }
    .width('100%')
  }

  @Builder
  ActionPill(label: string, onTap: () => void) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(Theme.colors().textPrimary)
      .textAlign(TextAlign.Center)
      .layoutWeight(1)
      .padding({ top: 10, bottom: 10 })
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .border({ width: 1, color: Theme.colors().strokeStrong })
      .onClick(onTap)
  }

  @Builder
  RecentActivity() {
    Column({ space: Theme.space.s2 }) {
      Text('最近动态')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
      if (this.activities.length === 0) {
        Text('完成任务或打卡后，这里会留下你的跃动轨迹')
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textTertiary)
      } else {
        ForEach(this.activities, (e: YdTimelineEvent) => {
          Row({ space: Theme.space.s2 }) {
            Text('·')
              .fontColor(Theme.colors().brandPrimary)
            Column({ space: 2 }) {
              Text(e.title)
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textPrimary)
                .maxLines(1)
              Text(`${e.dateKey} · ${e.kindLabel()}`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textTertiary)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
          .onClick((): void => {
            if (e.refType === 'task') {
              YdDetailNav.openTaskDetail(e.refId)
            } else if (e.refType === 'chapter') {
              YdDetailNav.openChapterDetail(e.refId)
            }
          })
        }, (e: YdTimelineEvent) => e.id)
      }
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  ActiveGoalsStrip() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text('进行中目标')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Blank()
        Text('全部')
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => {
            AppStorage.setOrCreate('ydSwitchTab', 2)
          })
      }
      .width('100%')

      if (this.activeGoals.length === 0) {
        Row({ space: Theme.space.s3 }) {
          Text('还没有长期目标，拆解里程碑让跃升可衡量')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textTertiary)
            .layoutWeight(1)
          Text('新建')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().brandPrimary)
            .onClick((): void => { YdDetailNav.openGoalCreate() })
        }
        .width('100%')
      } else {
        ForEach(this.activeGoals, (g: YdGoalItem) => {
          Column({ space: Theme.space.s2 }) {
            Row() {
              Text(g.title)
                .fontSize(Theme.type.body)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .layoutWeight(1)
                .maxLines(1)
              Text(`${g.progressPercent()}%`)
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().brandPrimary)
            }
            .width('100%')
            Progress({ value: g.progressPercent(), total: 100, type: ProgressType.Linear })
              .width('100%')
              .color(Theme.colors().brandPrimary)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .style({ strokeWidth: 5 })
            Text(`${g.doneCount()} / ${g.milestones.length} 里程碑`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .width('100%')
          .padding(Theme.space.s3)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.md)
          .onClick((): void => { YdDetailNav.openGoalDetail(g.id) })
        }, (g: YdGoalItem) => g.id)
      }
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  HeroBlock() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image($r('app.media.hero_ambient'))
        .width('100%')
        .height(188)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.xl)
      Column()
        .width('100%')
        .height(188)
        .borderRadius(Theme.radius.xl)
        .linearGradient({
          angle: 180,
          colors: [['rgba(10,37,64,0.08)', 0], ['rgba(10,37,64,0.72)', 0.55], ['rgba(10,37,64,0.88)', 1]]
        })
      Column({ space: Theme.space.s2 }) {
        Text(this.appName)
          .fontSize(Theme.type.caption)
          .fontColor('rgba(255,255,255,0.82)')
          .letterSpacing(1)
        Text(this.dateLabel)
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
        Text('把今日写成可执行的一步')
          .fontSize(Theme.type.bodyS)
          .fontColor('rgba(255,255,255,0.88)')
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .padding({ left: Theme.space.s5, right: Theme.space.s5, bottom: Theme.space.s5 })
    }
    .width('100%')
    .height(188)
    .shadow({ radius: 24, color: 'rgba(10,37,64,0.12)', offsetX: 0, offsetY: 8 })
  }

  @Builder
  ProgressBlock() {
    Row({ space: Theme.space.s5 }) {
      Stack() {
        Progress({ value: this.progressPercent(), total: 100, type: ProgressType.Ring })
          .width(88)
          .height(88)
          .color(Theme.colors().brandPrimary)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .style({ strokeWidth: 7 })
        Column({ space: 2 }) {
          Text(`${this.progressPercent()}%`)
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text('完成')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
      }
      Column({ space: Theme.space.s2 }) {
        Text('今日执行')
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        Text(`${this.countTodayDone()} / ${this.todayTotalCount()}`)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Text(this.todayTotalCount() === 0 ? '写下第一步，进度从这里开始' : '点卡片查看详情 · 可勾选完成')
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding(Theme.space.s5)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .shadow({ radius: 16, color: 'rgba(10,37,64,0.06)', offsetX: 0, offsetY: 4 })
  }

  @Builder
  ChapterBanner() {
    Row({ space: Theme.space.s4 }) {
      Column() {
        AppIcon({
          name: this.hasChapter ? 'chart' : 'biz',
          iconSize: Theme.icon.lg,
          color: Theme.colors().brandPrimary
        })
      }
      .width(48)
      .height(48)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.md)
      Column({ space: Theme.space.s1 }) {
        if (!this.hasChapter) {
          Text('开启人生篇章')
            .fontSize(Theme.type.body)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text('命名主题与周期 · 到期须写复盘方可收官')
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .maxLines(2)
        } else {
          Text(this.chapter.title)
            .fontSize(Theme.type.body)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(`${this.chapter.themeLabel()} · 剩余 ${this.chapter.remainDays()} 天`)
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick(() => {
      if (this.hasChapter) {
        YdDetailNav.openChapterDetail(this.chapter.id)
      } else {
        YdDetailNav.openChapterCreate()
      }
    })
  }

  @Builder
  ViewModePills() {
    Row({ space: Theme.space.s1 }) {
      this.ModePill('清单', !this.timeline)
      this.ModePill('时间轴', this.timeline)
    }
    .padding(3)
    .backgroundColor(Theme.colors().surfaceSubtle)
    .borderRadius(Theme.radius.pill)
  }

  @Builder
  ModePill(label: string, active: boolean) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontWeight(active ? FontWeight.Medium : FontWeight.Regular)
      .fontColor(active ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .backgroundColor(active ? Theme.colors().surfaceCard : Color.Transparent)
      .borderRadius(Theme.radius.pill)
      .shadow(active ? { radius: 8, color: 'rgba(10,37,64,0.08)', offsetY: 2 } : { radius: 0, color: Color.Transparent, offsetY: 0 })
      .onClick(() => {
        this.timeline = label === '时间轴'
      })
  }

  @Builder
  EmptyGuide() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image($r('app.media.empty_guide'))
        .width('100%')
        .height(140)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.lg)
      Column()
        .width('100%')
        .height(140)
        .borderRadius(Theme.radius.lg)
        .linearGradient({
          angle: 180,
          colors: [['rgba(10,37,64,0.05)', 0], ['rgba(10,37,64,0.78)', 1]]
        })
      Column({ space: Theme.space.s3 }) {
        Text('今日还没有安排')
          .fontSize(Theme.type.body)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
        Text('先开启篇章，或点右下角添加今日第一步')
          .fontSize(Theme.type.bodyS)
          .fontColor('rgba(255,255,255,0.88)')
        AppButton({
          label: this.hasChapter ? '添加今日任务' : '开启篇章',
          variant: 'primary',
          onTap: (): void => {
            if (this.hasChapter) {
              YdDetailNav.openTaskAdd()
            } else {
              YdDetailNav.openChapterCreate()
            }
          }
        })
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .padding(Theme.space.s5)
    }
    .width('100%')
    .height(140)
  }

  @Builder
  HourRow(h: YdHourSlot) {
    Row({ space: Theme.space.s3 }) {
      Column({ space: 4 }) {
        Text(h.label)
          .fontSize(Theme.type.bodyS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        Column()
          .width(2)
          .height(h.items.length > 0 ? 32 : 12)
          .backgroundColor(Theme.colors().strokeStrong)
          .borderRadius(1)
      }
      .width(44)
      Column({ space: Theme.space.s2 }) {
        if (h.items.length === 0) {
          Text('空档')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textTertiary)
            .padding({ top: 4, bottom: 4 })
        } else {
          ForEach(h.items, (t: YdTaskItem) => {
            YdTaskRow({
              task: t,
              onToggle: (taskId: string, done: boolean): void => {
                void this.handleTaskToggle(taskId, done)
              },
              onOpen: (taskId: string): void => {
                YdDetailNav.openTaskDetail(taskId)
              }
            })
          }, (t: YdTaskItem) => `${t.id}_${t.done ? '1' : '0'}`)
        }
      }
      .layoutWeight(1)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }
}
