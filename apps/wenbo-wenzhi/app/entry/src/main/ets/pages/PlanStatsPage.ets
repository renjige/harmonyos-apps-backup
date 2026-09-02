import { Theme } from '../components/design-system/Theme'
import { AppNavBar } from '../components/design-system/AppNavBar'
import { AppButton } from '../components/design-system/AppButton'
import { AppBarChart, AppRingChart, BarChartItem } from '../components/design-system/AppChart'
import { StudyTask, DayCountItem } from '../models/GrowthModels'
import { LearnCatalog } from '../models/LearnModels'
import { AskNav } from '../services/AskNav'
import { GrowthStore } from '../services/GrowthStore'
import { LearnStore } from '../services/LearnStore'
import { VaultStore } from '../services/VaultStore'

@Component
export struct PlanStatsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('vaultRefresh') @Watch('onRefresh') vaultRefresh: number = 0
  @Prop mode: string = 'plan'
  @State toastText: string = ''
  @State dailyGoal: number = 3
  @State todayProgress: number = 0
  @State streakDays: number = 0
  @State askCount: number = 0
  @State readCount: number = 0
  @State quizCount: number = 0
  @State quizHits: number = 0
  @State collectCount: number = 0
  @State cardCount: number = 0
  @State checkedIn: boolean = false
  @State taskDraft: string = ''
  @State tasks: StudyTask[] = []
  @State weekBars: BarChartItem[] = []
  @State catBars: BarChartItem[] = []
  @State progressPct: number = 0
  private goals: number[] = LearnCatalog.goalOptions()

  aboutToAppear(): void {
    this.syncFromStore()
  }

  onRefresh(): void {
    this.syncFromStore()
  }

  private toBarItems(src: DayCountItem[]): BarChartItem[] {
    const out: BarChartItem[] = []
    for (const d of src) {
      const item = new BarChartItem()
      item.label = d.label
      item.value = d.count
      out.push(item)
    }
    return out
  }

  private syncFromStore(): void {
    this.dailyGoal = LearnStore.goal()
    this.todayProgress = LearnStore.todayCount()
    this.streakDays = VaultStore.streakDays()
    this.askCount = VaultStore.asks()
    this.readCount = LearnStore.reads()
    this.quizCount = LearnStore.quizTimes()
    this.quizHits = LearnStore.quizHits()
    this.collectCount = VaultStore.count()
    this.cardCount = LearnStore.cardAll().length
    this.checkedIn = GrowthStore.hasCheckinToday()
    this.tasks = GrowthStore.weekTasks()
    this.weekBars = this.toBarItems(GrowthStore.weekDayCounts())
    this.catBars = this.toBarItems(GrowthStore.categoryCollectCounts())
    this.progressPct = GrowthStore.todayProgressPercent()
  }

  private async pickGoal(n: number): Promise<void> {
    await LearnStore.setGoal(n)
    this.dailyGoal = n
    AskNav.bumpRefresh()
    this.toastText = `每日目标已设为 ${n} 次`
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async addTask(): Promise<void> {
    await GrowthStore.addTask(this.taskDraft)
    this.taskDraft = ''
    this.tasks = GrowthStore.weekTasks()
    AskNav.bumpRefresh()
    this.showToast('已添加本周学习任务')
  }

  private async toggleTask(id: string): Promise<void> {
    await GrowthStore.toggleTask(id)
    this.tasks = GrowthStore.weekTasks()
    AskNav.bumpRefresh()
    this.syncFromStore()
  }

  private async checkin(): Promise<void> {
    const ok = await GrowthStore.checkinToday('')
    if (ok) {
      AskNav.bumpRefresh()
      this.syncFromStore()
      this.showToast('打卡成功')
      return
    }
    this.showToast('今日已打卡')
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        AppNavBar({
          title: this.mode === 'stats' ? '知识成长统计' :
            (this.mode === 'timeline' ? '学习动态' : '学习计划'),
          onBack: (): void => { AskNav.closeLearn() }
        })
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            if (this.mode === 'stats') {
              AppRingChart({ title: '今日目标完成率', percent: this.progressPct })
              AppBarChart({ title: '近 7 日学习次数', items: this.weekBars })
              if (this.catBars.length > 0) {
                AppBarChart({ title: '收藏分类分布', items: this.catBars })
              }
              this.StatBlock('提问次数', `${this.askCount}`)
              this.StatBlock('阅读条数', `${this.readCount}`)
              this.StatBlock('答题次数', `${this.quizCount}`)
              this.StatBlock('答对次数', `${this.quizHits}`)
              this.StatBlock('收藏数量', `${this.collectCount}`)
              this.StatBlock('连续学习', `${this.streakDays} 天`)
              this.StatBlock('知识卡片', `${this.cardCount}`)
            } else {
              Text('每日学习目标')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Row({ space: Theme.space.s2 }) {
                ForEach(this.goals, (g: number) => {
                  Text(`${g} 次`)
                    .fontSize(Theme.type.footnote)
                    .fontColor(this.dailyGoal === g ?
                      Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                    .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                    .constraintSize({ minHeight: 40 })
                    .backgroundColor(this.dailyGoal === g ?
                      Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                    .borderRadius(Theme.radius.pill)
                    .onClick(() => { void this.pickGoal(g) })
                }, (g: number) => `${g}_${this.dailyGoal}`)
              }
              .width('100%')
              Column({ space: 8 }) {
                Text(`今日进度  ${this.todayProgress} / ${this.dailyGoal}`)
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  .width('100%')
                Text(`连续学习 ${this.streakDays} 天 · ${this.checkedIn ? '已打卡' : '未打卡'}`)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.card)
              AppButton({
                label: this.checkedIn ? '今日已打卡' : '今日学习打卡',
                variant: 'secondary',
                disabled: this.checkedIn,
                onTap: (): void => { void this.checkin() }
              })
              Text('本周待学清单')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              TextInput({ text: this.taskDraft, placeholder: '添加一条本周想完成的学习任务' })
                .height(44)
                .fontSize(Theme.type.body)
                .onChange((v: string) => { this.taskDraft = v })
              AppButton({ label: '添加任务', variant: 'secondary', onTap: (): void => { void this.addTask() } })
              ForEach(this.tasks, (t: StudyTask) => {
                Row({ space: Theme.space.s2 }) {
                  Column() {
                    Text(t.done ? '完成' : '待做')
                      .fontSize(Theme.type.caption)
                      .fontColor(t.done ? Theme.colors().brandPrimary : Theme.colors().textTertiary)
                  }
                  .width(40)
                  Text(t.title)
                    .fontSize(Theme.type.body)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .layoutWeight(1)
                    .decoration({ type: t.done ? TextDecorationType.LineThrough : TextDecorationType.None })
                }
                .width('100%')
                .padding(Theme.space.s3)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.sm)
                .onClick(() => { void this.toggleTask(t.id) })
              }, (t: StudyTask) => `${t.id}_${t.done}`)
              AppButton({
                label: '去做今日问答',
                onTap: (): void => {
                  AskNav.closeLearn()
                  AskNav.switchTab(0)
                }
              })
            }
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s8 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  StatBlock(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      Blank()
      Text(value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
  }
}
