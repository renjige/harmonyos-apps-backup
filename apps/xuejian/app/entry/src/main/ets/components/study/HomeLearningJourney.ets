import { Theme } from '../design-system/Theme'
import { StudyStore } from '../../services/StudyStore'

class JourneyStep {
  title: string = ''
  hint: string = ''
  done: boolean = false

  static of(title: string, hint: string, done: boolean): JourneyStep {
    const s = new JourneyStep()
    s.title = title
    s.hint = hint
    s.done = done
    return s
  }
}

/** 首页五步学习闭环 — 让审核看见完整路径而非单一计时 */
@Component
export struct HomeLearningJourney {
  @StorageLink('studyDataEpoch') @Watch('onDataEpoch') studyDataEpoch: number = 0
  @State steps: JourneyStep[] = []
  onOpenFocus: () => void = () => {}
  onOpenNote: () => void = () => {}
  onOpenReview: () => void = () => {}
  onOpenInsight: () => void = () => {}
  onOpenWeekly: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  onDataEpoch(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const sessions = await StudyStore.loadSessions()
    const notes = await StudyStore.loadNotes()
    const cards = await StudyStore.loadCards()
    let mastered = 0
    for (const c of cards) {
      if (c.isMastered()) {
        mastered++
      }
    }
    const plan = await StudyStore.loadWeeklyPlan()
    let planDone = 0
    for (const p of plan.items) {
      if (p.done) {
        planDone++
      }
    }
    const list: JourneyStep[] = []
    list.push(JourneyStep.of('① 专注计时', '记录真实投入', sessions.length > 0))
    list.push(JourneyStep.of('② 学习笔记', '沉淀要点', notes.length > 0))
    list.push(JourneyStep.of('③ 知识卡片', '术语一张一卡', cards.length > 0))
    list.push(JourneyStep.of('④ 随机复习', '标记掌握状态', mastered > 0))
    list.push(JourneyStep.of('⑤ 洞察周报', '看见节奏与趋势', planDone > 0 || sessions.length >= 3))
    this.steps = list
  }

  private tapStep(index: number): void {
    if (index === 0) {
      this.onOpenFocus()
      return
    }
    if (index === 1) {
      this.onOpenNote()
      return
    }
    if (index === 2) {
      this.onOpenNote()
      return
    }
    if (index === 3) {
      this.onOpenReview()
      return
    }
    if (index === 4) {
      this.onOpenInsight()
      return
    }
    this.onOpenWeekly()
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text('学习闭环')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.isDark() ? '#F8FAFC' : '#0F172A')
          .layoutWeight(1)
        Text('本周计划')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
          .constraintSize({ minHeight: 44 })
          .onClick((): void => { this.onOpenWeekly() })
      }
      .width('100%')

      ForEach(this.steps, (s: JourneyStep, idx: number) => {
        Row({ space: 10 }) {
          Text(s.done ? '✓' : `${idx + 1}`)
            .fontSize(Theme.type.bodyS)
            .fontColor(s.done ? '#FFFFFF' : Theme.colors().textPrimary)
            .textAlign(TextAlign.Center)
            .width(28)
            .height(28)
            .borderRadius(14)
            .backgroundColor(s.done ? '#0F766E' : Theme.colors().surfaceSubtle)
          Column({ space: 2 }) {
            Text(s.title)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Text(s.hint)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.bodyMuted())
              .width('100%')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding(10)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(12)
        .onClick((): void => { this.tapStep(idx) })
      }, (s: JourneyStep, idx: number) => `j-${idx}-${s.title}`)
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.isDark() ? '#2C2C2E' : '#FFFFFF')
    .borderRadius(16)
  }
}
