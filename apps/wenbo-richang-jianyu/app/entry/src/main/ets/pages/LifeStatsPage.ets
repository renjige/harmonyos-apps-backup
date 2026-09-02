import { Theme } from '../components/design-system/Theme'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { LifePageShell } from '../components/life/LifePageShell'
import { DayCount, LifeDates } from '../models/LifeHubModels'
import { JournalItem } from '../models/JournalModels'
import { JournalBizService } from '../services/JournalBizService'
import { LifeHubNav } from '../services/LifeHubNav'
import { LifeHubStore } from '../services/LifeHubStore'
import { AuthService } from '../services/AuthService'

@Component
export struct LifeStatsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('currentUsername') currentUsername: string = ''
  @State diaryCount: number = 0
  @State moodCount: number = 0
  @State todoDone: number = 0
  @State habitBest: number = 0
  @State goalDone: number = 0
  @State summary: string = ''
  @State trend: DayCount[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    let diaries = 0
    if (AuthService.isLoggedIn()) {
      const list = await JournalBizService.cachedDiaries(this.currentUsername)
      diaries = list.length
      this.trend = this.buildTrend(list)
    } else {
      this.trend = this.emptyTrend()
    }
    this.diaryCount = diaries
    const moods = await LifeHubStore.loadMoods()
    this.moodCount = moods.length
    const todos = await LifeHubStore.loadTodos()
    let done = 0
    for (const t of todos) {
      if (t.done) {
        done += 1
      }
    }
    this.todoDone = done
    const habits = await LifeHubStore.loadHabits()
    let best = 0
    for (const h of habits) {
      const s = h.streak()
      if (s > best) {
        best = s
      }
    }
    this.habitBest = best
    const goals = await LifeHubStore.loadGoals()
    let gDone = 0
    for (const g of goals) {
      if (g.status === 'done') {
        gDone += 1
      }
    }
    this.goalDone = gDone
    this.summary = this.buildSummary()
  }

  private emptyTrend(): DayCount[] {
    const out: DayCount[] = []
    let i = 6
    while (i >= 0) {
      const row = new DayCount()
      row.iso = LifeDates.shiftIso(LifeDates.todayIso(), -i)
      row.count = 0
      out.push(row)
      i -= 1
    }
    return out
  }

  private buildTrend(list: JournalItem[]): DayCount[] {
    const out = this.emptyTrend()
    for (const d of list) {
      const iso = d.recordDate.length >= 10 ? d.recordDate.substring(0, 10) : ''
      for (const row of out) {
        if (row.iso === iso) {
          row.count += 1
        }
      }
    }
    return out
  }

  private buildSummary(): string {
    const now = new Date()
    const month = `${now.getMonth() + 1}月`
    if (this.diaryCount === 0 && this.moodCount === 0) {
      return `${month}还刚开始。写下一页笺语、记下今日心情，生活轨迹就会慢慢清晰。`
    }
    return `${month}生活小结：已写下 ${this.diaryCount} 篇笺语，记录 ${this.moodCount} 天心情，完成 ${this.todoDone} 项待办，最长连续打卡 ${this.habitBest} 天，达成 ${this.goalDone} 个目标。继续把日常轻轻收进笺页。`
  }

  private barHeight(count: number): number {
    const h = 12 + count * 18
    if (h > 72) {
      return 72
    }
    return h
  }

  private dayLabel(iso: string): string {
    if (iso.length < 10) {
      return ''
    }
    return iso.substring(8, 10)
  }

  build() {
    LifePageShell({
      title: '数据回顾',
      subtitle: '记录数量 · 月度总结 · 七日趋势',
      onClose: (): void => { LifeHubNav.backOrClose() },
      body: () => { this.Body() }
    })
  }

  @Builder
  Body() {
    Column({ space: Theme.space.s4 }) {
      Row({ space: Theme.space.s3 }) {
        AppStatCard({
          label: '笺语',
          value: `${this.diaryCount}`,
          trend: '篇',
          positive: true
        }).layoutWeight(1)
        AppStatCard({
          label: '心情',
          value: `${this.moodCount}`,
          trend: '天',
          positive: true
        }).layoutWeight(1)
      }
      .width('100%')
      Row({ space: Theme.space.s3 }) {
        AppStatCard({
          label: '待办完成',
          value: `${this.todoDone}`,
          trend: '项',
          positive: true
        }).layoutWeight(1)
        AppStatCard({
          label: '目标达成',
          value: `${this.goalDone}`,
          trend: '个',
          positive: true
        }).layoutWeight(1)
      }
      .width('100%')
      Text(`最长连续打卡 ${this.habitBest} 天`)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().brandPrimaryContainer)
        .borderRadius(Theme.radius.lg)

      Text('月度生活总结')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text(this.summary)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textPrimary)
        .lineHeight(24)
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .border({ width: 1, color: Theme.colors().strokeHairline })

      Text('近七日记录趋势')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Row({ space: 8 }) {
        ForEach(this.trend, (row: DayCount) => {
          Column({ space: 4 }) {
            Column()
              .width(18)
              .height(this.barHeight(row.count))
              .backgroundColor(row.count > 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.sm)
            Text(this.dayLabel(row.iso))
              .fontSize(Theme.type.overline)
              .fontColor(Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.End)
          .height(96)
        }, (row: DayCount) => row.iso)
      }
      .width('100%')
      .alignItems(VerticalAlign.Bottom)
    }
    .width('100%')
  }
}
