import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { YdBadgeItem, YdChapterItem, YdReviewStats, YdTimelineEvent, YdWeekDayStat } from '../models/YdModels'
import { YdWeekHeatmap } from '../components/yuedong/YdWeekHeatmap'
import { YdMetricTile } from '../components/yuedong/YdMetricTile'
import { YdLocalStore } from '../services/YdLocalStore'
import { YdDetailNav } from '../services/YdDetailNav'
import { YdClipboard } from '../services/YdClipboard'

enum ReviewRange {
  Day = 0,
  Week = 1,
  Month = 2,
  Year = 3
}

@Component
export struct GrowthPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('ydDataRefresh') @Watch('onGlobalRefresh') globalRefresh: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State range: ReviewRange = ReviewRange.Day
  @State stats: YdReviewStats = new YdReviewStats()
  @State mainMetricText: string = '0%'
  @State mainLabelText: string = '今日完成率'
  @State streakText: string = '0'
  @State leapText: string = '0'
  @State badges: YdBadgeItem[] = []
  @State chapters: YdChapterItem[] = []
  @State trendValues: number[] = [0, 0, 0, 0, 0, 0, 0]
  @State weekDays: YdWeekDayStat[] = []
  @State timelineEvents: YdTimelineEvent[] = []
  @State toast: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  onGlobalRefresh(): void {
    void this.reload()
  }

  private weeklyInsight(): string {
    const totalMin = this.stats.workMin + this.stats.studyMin + this.stats.lifeMin
    if (this.stats.weekDone === 0 && totalMin === 0) {
      return '本周尚未记入完成步数。在今日章勾选完成并补记分钟，时间账会自动更新。'
    }
    let top = '工作'
    let topMin = this.stats.workMin
    if (this.stats.studyMin > topMin) {
      top = '学习'
      topMin = this.stats.studyMin
    }
    if (this.stats.lifeMin > topMin) {
      top = '生活'
    }
    return `本周已完成 ${this.stats.weekDone} 步，投入 ${totalMin} 分钟；${top} 占比最高。连续 ${this.stats.streakDays} 天有记录，跃动指数 ${this.stats.leapIndex}。`
  }

  private syncMetricTexts(): void {
    this.mainMetricText = this.mainMetric()
    this.mainLabelText = this.mainLabel()
    this.streakText = `${this.stats.streakDays}`
    this.leapText = `${this.stats.leapIndex}`
  }

  private async reload(): Promise<void> {
    this.stats = await YdLocalStore.computeReviewStats()
    this.syncMetricTexts()
    this.badges = await YdLocalStore.loadBadges()
    this.chapters = await YdLocalStore.loadAllChapters()
    this.weekDays = await YdLocalStore.computeWeekDayStats()
    this.timelineEvents = await YdLocalStore.buildTimeline(30)
    await this.loadTrend()
  }

  private showToast(msg: string): void {
    this.toast = msg
    setTimeout((): void => { this.toast = '' }, 2400)
  }

  private async exportWeekly(): Promise<void> {
    const text = await YdLocalStore.buildWeeklyReportText()
    const ok = await YdClipboard.copyText(text)
    this.showToast(ok ? '本周摘要已复制到剪贴板' : '复制失败，请稍后重试')
  }

  private async exportChapters(): Promise<void> {
    const text = await YdLocalStore.exportAllChaptersText()
    const ok = await YdClipboard.copyText(text)
    this.showToast(ok ? '篇章档案已复制到剪贴板' : '复制失败，请稍后重试')
  }

  private async exportMonthly(): Promise<void> {
    const text = await YdLocalStore.buildMonthlyReviewText()
    const ok = await YdClipboard.copyText(text)
    this.showToast(ok ? '本月回顾已复制' : '复制失败')
  }

  private async exportYearly(): Promise<void> {
    const text = await YdLocalStore.buildYearlyReviewText()
    const ok = await YdClipboard.copyText(text)
    this.showToast(ok ? '年度摘要已复制' : '复制失败')
  }

  private async loadTrend(): Promise<void> {
    const tasks = await YdLocalStore.loadAllTasks()
    const vals: number[] = [0, 0, 0, 0, 0, 0, 0]
    const today = new Date()
    for (let i = 6; i >= 0; i--) {
      const d = new Date(today)
      d.setDate(d.getDate() - i)
      const y = d.getFullYear()
      const m = d.getMonth() + 1
      const ds = d.getDate()
      const ms = m < 10 ? `0${m}` : `${m}`
      const dd = ds < 10 ? `0${ds}` : `${ds}`
      const key = `${y}-${ms}-${dd}`
      let n = 0
      for (const t of tasks) {
        if (t.dateKey === key && t.done) {
          n++
        }
      }
      vals[6 - i] = n
    }
    this.trendValues = vals
  }

  private mainMetric(): string {
    if (this.range === ReviewRange.Week) {
      return `${this.stats.weekDone}`
    }
    if (this.range === ReviewRange.Month) {
      return `${this.stats.monthDone}`
    }
    if (this.range === ReviewRange.Year) {
      return `${this.stats.chapterClosed}`
    }
    return `${this.stats.completionRate}%`
  }

  private mainLabel(): string {
    if (this.range === ReviewRange.Week) {
      return '本周完成'
    }
    if (this.range === ReviewRange.Month) {
      return '本月完成'
    }
    if (this.range === ReviewRange.Year) {
      return '收官篇章'
    }
    return '今日完成率'
  }

  build() {
    Stack() {
      Scroll() {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.banner_growth'))
            .width('100%')
            .height(100)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.lg)
          Column()
            .width('100%')
            .height(100)
            .borderRadius(Theme.radius.lg)
            .linearGradient({
              angle: 180,
              colors: [['rgba(10,37,64,0.05)', 0], ['rgba(10,37,64,0.78)', 1]]
            })
          Text('成长中心')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .padding({ left: Theme.space.s4, bottom: Theme.space.s3 })
        }
        .width('100%')

        Row({ space: Theme.space.s2 }) {
          this.RangeChip('日', ReviewRange.Day)
          this.RangeChip('周', ReviewRange.Week)
          this.RangeChip('月', ReviewRange.Month)
          this.RangeChip('年', ReviewRange.Year)
        }
        .width('100%')

        Row({ space: Theme.space.s3 }) {
          YdMetricTile({ value: this.mainMetricText, label: this.mainLabelText })
          YdMetricTile({ value: this.streakText, label: '连续天数' })
          YdMetricTile({ value: this.leapText, label: '跃动指数' })
        }
        .width('100%')

        Column({ space: Theme.space.s2 }) {
          Text('产品能力概览')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
          Text('篇章周期 · 今日执行 · 目标里程碑 · 成长复盘 · 时间轴 · 热力图 · 12 枚徽章 · 多格式导出')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textPrimary)
            .lineHeight(20)
          Text('非简单备忘录：以「人生篇章」为框架，串联计划、执行、复盘与长期目标。')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
            .lineHeight(20)
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .alignItems(HorizontalAlign.Start)

        Column({ space: Theme.space.s2 }) {
          Text('本周洞察')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text(this.weeklyInsight())
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textPrimary)
            .lineHeight(20)
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().brandPrimaryContainer)
        .borderRadius(Theme.radius.lg)
        .alignItems(HorizontalAlign.Start)

        Row({ space: Theme.space.s2 }) {
          Column() {
            AppButton({
              label: '导出本周摘要',
              variant: 'secondary',
              onTap: (): void => { void this.exportWeekly() }
            })
          }
          .layoutWeight(1)
          Column() {
            AppButton({
              label: '导出全部篇章',
              variant: 'secondary',
              onTap: (): void => { void this.exportChapters() }
            })
          }
          .layoutWeight(1)
        }
        .width('100%')

        YdWeekHeatmap({ days: this.weekDays })

        Column({ space: Theme.space.s3 }) {
          Text('成长时间轴')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
          if (this.timelineEvents.length === 0) {
            Image($r('app.media.empty_timeline'))
              .width('100%')
              .height(120)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.md)
            Text('完成任务、打卡、收官后会出现在这里')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textTertiary)
          } else {
            ForEach(this.timelineEvents.slice(0, 12), (e: YdTimelineEvent) => {
              Row({ space: Theme.space.s3 }) {
                Column()
                  .width(3)
                  .height(36)
                  .backgroundColor(Theme.colors().brandPrimary)
                  .borderRadius(2)
                Column({ space: 2 }) {
                  Text(e.title)
                    .fontSize(Theme.type.bodyS)
                    .fontColor(Theme.colors().textPrimary)
                    .maxLines(2)
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
                } else if (e.refType === 'goal') {
                  YdDetailNav.openGoalDetail(e.refId)
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

        Row({ space: Theme.space.s2 }) {
          Column() {
            AppButton({ label: '导出本月', variant: 'secondary', onTap: (): void => { void this.exportMonthly() } })
          }
          .layoutWeight(1)
          Column() {
            AppButton({ label: '导出年度', variant: 'secondary', onTap: (): void => { void this.exportYearly() } })
          }
          .layoutWeight(1)
        }
        .width('100%')

        Column({ space: Theme.space.s3 }) {
          Text('本周时间账（工作 / 学习 / 生活）')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          this.AllocRow('工作', this.stats.workMin, '#007DFF')
          this.AllocRow('学习', this.stats.studyMin, '#6366F1')
          this.AllocRow('生活', this.stats.lifeMin, '#0F766E')
          Text('完成任务时补记投入分钟，才会进入时间账。系统日历没有这项账本。')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textTertiary)
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)

        Row() {
          Text('篇章档案')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Text('开启新章')
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .onClick(() => YdDetailNav.openChapterCreate())
        }
        .width('100%')

        if (this.chapters.length === 0) {
          Text('还没有篇章。先在首页开启一章，到期写复盘收官。')
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        } else {
          ForEach(this.chapters, (c: YdChapterItem) => {
            Column({ space: 4 }) {
              Text(c.title)
                .fontSize(Theme.type.body)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Text(`${c.themeLabel()} · ${c.closed ? '已收官' : '进行中'} · ${c.startKey}`)
                .fontSize(Theme.type.bodyS)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              if (c.closed && c.recap.length > 0) {
                Text(c.recap.length > 48 ? `${c.recap.substring(0, 48)}…` : c.recap)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .maxLines(2)
              }
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick(() => YdDetailNav.openChapterDetail(c.id))
          }, (c: YdChapterItem) => c.id)
        }

        Column({ space: Theme.space.s3 }) {
          Text('近7日完成趋势')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          Row({ space: 6 }) {
            ForEach(this.trendValues, (v: number, idx: number) => {
              Column({ space: 4 }) {
                Column()
                  .width(28)
                  .height(Math.max(8, v * 12))
                  .backgroundColor(Theme.colors().brandPrimary)
                  .borderRadius(4)
                Text(`${idx + 1}`)
                  .fontSize(10)
                  .fontColor(Theme.colors().textTertiary)
              }
              .height(80)
              .justifyContent(FlexAlign.End)
            }, (v: number, idx: number) => `t${idx}`)
          }
          .width('100%')
          .alignItems(VerticalAlign.Bottom)
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)

        Text('成就徽章')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')

        Column({ space: Theme.space.s2 }) {
          ForEach(this.badges, (b: YdBadgeItem) => {
            Row({ space: Theme.space.s3 }) {
              Column() {
                Text(b.unlocked ? '🏅' : '🔒')
                  .fontSize(22)
              }
              .width(44)
              .height(44)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(b.unlocked ? Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
              Column({ space: 2 }) {
                Text(b.title)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                Text(b.desc)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .width('100%')
            .padding(Theme.space.s3)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
          }, (b: YdBadgeItem) => b.id)
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
  RangeChip(label: string, value: ReviewRange) {
    Text(label)
      .fontSize(Theme.type.subhead)
      .fontColor(this.range === value ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor(this.range === value ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.range = value; this.syncMetricTexts() })
  }

  @Builder
  AllocRow(label: string, minutes: number, color: string) {
    Column({ space: 4 }) {
      Row() {
        Text(label)
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        Blank()
        Text(`${minutes} 分钟`)
          .fontSize(Theme.type.bodyS)
          .fontColor(color)
      }
      .width('100%')
      Progress({ value: minutes, total: this.allocTotal(), type: ProgressType.Linear })
        .width('100%')
        .color(color)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .style({ strokeWidth: 6 })
    }
    .width('100%')
  }

  private allocTotal(): number {
    const n = this.stats.workMin + this.stats.studyMin + this.stats.lifeMin
    return n > 0 ? n : 1
  }
}
