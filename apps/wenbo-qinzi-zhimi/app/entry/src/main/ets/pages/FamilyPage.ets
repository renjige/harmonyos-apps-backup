import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { ProgressStore } from '../services/ProgressStore'
import { GrowthService } from '../services/GrowthService'
import { QuizMedia } from '../services/QuizMedia'
import { QuizNav } from '../services/QuizNav'
import { QuizBizService } from '../services/QuizBizService'
import { PuzzleItem, GuideItem } from '../models/PuzzleModels'

@Component
export struct FamilyPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State puzzles: PuzzleItem[] = []
  @State tips: GuideItem[] = []
  @State familyRounds: number = 0
  @State weekDone: boolean = false
  @State dailyGoal: number = 3
  @State weekCorrectTarget: number = 15
  @State weekFamilyTarget: number = 1
  @State weekCorrect: number = 0
  @State weekFamily: number = 0
  @StorageLink('familyMatch') familyMatch: number = 0
  @StorageLink('todayCount') todayCount: number = 0
  @StorageLink('quizTick') @Watch('onQuizTick') tick: number = 0
  @StorageLink('accountEpoch') @Watch('onAccount') accountEpoch: number = 0
  @StorageLink('windowIsWide') isWide: boolean = false

  aboutToAppear(): void {
    this.refreshTask()
    void this.reload()
  }

  onQuizTick(): void {
    this.refreshTask()
  }

  onAccount(): void {
    this.refreshTask()
  }

  private refreshTask(): void {
    ProgressStore.sync()
    this.familyRounds = ProgressStore.snapshot().familyRounds
    this.weekDone = ProgressStore.weekFamilyDone()
    this.dailyGoal = ProgressStore.dailyGoal()
    const plan = GrowthService.planGoal()
    this.weekCorrectTarget = plan.targetCorrect
    this.weekFamilyTarget = plan.targetFamily
    this.weekCorrect = GrowthService.weekCorrectCount()
    this.weekFamily = GrowthService.weekFamilyCount()
  }

  private async saveWeekPlan(correct: number, family: number): Promise<void> {
    await ProgressStore.savePlan(correct, family, '')
    this.refreshTask()
  }

  async reload(): Promise<void> {
    this.puzzles = await QuizBizService.loadPuzzles()
    const guides = await QuizBizService.loadGuides()
    const out: GuideItem[] = []
    let n = 0
    for (const g of guides) {
      if (n >= 2) {
        break
      }
      out.push(g)
      n++
    }
    this.tips = out
  }

  private start(): void {
    const ids = QuizBizService.familyIds(this.puzzles, 5)
    if (ids.length === 0) {
      return
    }
    QuizNav.openFamily(ids)
  }

  private async setGoal(n: number): Promise<void> {
    await ProgressStore.setDailyGoal(n)
    this.refreshTask()
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Text('亲子时光')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')

        Stack({ alignContent: Alignment.BottomStart }) {
          Image(QuizMedia.cover('hero_desk'))
            .width('100%')
            .height(180)
            .objectFit(ImageFit.Cover)
            .borderRadius(24)
          Column()
            .width('100%')
            .height(180)
            .borderRadius(24)
            .linearGradient({
              angle: 180,
              colors: [['rgba(30,42,58,0.08)', 0], ['rgba(30,42,58,0.70)', 1]]
            })
          Column({ space: 6 }) {
            Text('家庭对答')
              .fontSize(13)
              .fontColor('#FFFFFF')
            Text('家长先想，孩子再想，一起揭晓。')
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
          }
          .padding({ left: 20, right: 20, bottom: 20 })
        }
        .clip(true)

        Row({ space: 10 }) {
          this.Stat('今日默契', this.familyMatch > 0 ? `${this.familyMatch}%` : '未开始')
          this.Stat('累计轮次', `${this.familyRounds} 次`)
        }
        .width('100%')

        Column({ space: 10 }) {
          Text('怎么玩')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text('1. 家长独立选择答案\n2. 把手机交给孩子，孩子再选一次\n3. 揭晓答案，看看今天的默契')
            .fontSize(15)
            .lineHeight(24)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .padding(20)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(24)
        .width('100%')

        if (this.tips.length > 0) {
          Column({ space: 10 }) {
            Text('亲子小贴士')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.tips, (g: GuideItem) => {
              Column({ space: 6 }) {
                Text(g.title)
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(g.summary.length > 0 ? g.summary : g.body)
                  .fontSize(14)
                  .lineHeight(22)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
                  .maxLines(3)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .padding(14)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(18)
              .width('100%')
            }, (g: GuideItem) => g.id)
          }
          .padding(20)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(24)
          .width('100%')
        }

        AppButton({
          label: '开始对答',
          onTap: () => this.start()
        })
        this.TaskCard()
        AppButton({
          label: '创建家庭谜题',
          variant: 'secondary',
          onTap: () => QuizNav.openCustom()
        })
      }
      .padding({
        left: this.isWide ? 36 : Theme.space.pageX,
        right: this.isWide ? 36 : Theme.space.pageX,
        top: Theme.space.s4,
        bottom: Theme.space.s10
      })
      .constraintSize({ maxWidth: 840 })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .align(Alignment.Top)
  }

  @Builder
  TaskCard() {
    Column({ space: 10 }) {
      Text('本周亲子任务')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(`本周目标：答对 ${this.weekCorrectTarget} 题 · 亲子 ${this.weekFamilyTarget} 次`)
        .fontSize(14)
        .lineHeight(22)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Text(`当前进度：答对 ${this.weekCorrect}/${this.weekCorrectTarget} · 亲子 ${this.weekFamily}/${this.weekFamilyTarget}`)
        .fontSize(14)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text(`每天答对 ${this.dailyGoal} 题 · 本周完成一次家庭对答`)
        .fontSize(14)
        .lineHeight(22)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Text(this.todayCount >= this.dailyGoal ? '今日题目任务已完成' : `今日还差 ${this.dailyGoal - this.todayCount} 题`)
        .fontSize(14)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text(this.weekDone ? '本周亲子挑战已完成' : '本周还差一次家庭对答')
        .fontSize(14)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Row({ space: 8 }) {
        Text('每日 3 题')
          .fontSize(13)
          .fontColor(this.dailyGoal === 3 ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor(this.dailyGoal === 3 ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
          .onClick(() => { void this.setGoal(3) })
        Text('每日 5 题')
          .fontSize(13)
          .fontColor(this.dailyGoal === 5 ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor(this.dailyGoal === 5 ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
          .onClick(() => { void this.setGoal(5) })
      }
      .width('100%')
      Row({ space: 8 }) {
        Text('周目标 15 题')
          .fontSize(13)
          .fontColor(this.weekCorrectTarget === 15 ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor(this.weekCorrectTarget === 15 ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
          .onClick(() => { void this.saveWeekPlan(15, this.weekFamilyTarget) })
        Text('周目标 20 题')
          .fontSize(13)
          .fontColor(this.weekCorrectTarget === 20 ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor(this.weekCorrectTarget === 20 ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
          .onClick(() => { void this.saveWeekPlan(20, this.weekFamilyTarget) })
      }
      .width('100%')
    }
    .padding(20)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(24)
    .width('100%')
  }

  @Builder
  Stat(label: string, value: string) {
    Column({ space: 6 }) {
      Text(label)
        .fontSize(12)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      Text(value)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
    }
    .layoutWeight(1)
    .padding(16)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(20)
    .alignItems(HorizontalAlign.Start)
  }
}
