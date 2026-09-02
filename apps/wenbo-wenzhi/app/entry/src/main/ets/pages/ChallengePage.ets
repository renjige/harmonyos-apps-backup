import { Theme } from '../components/design-system/Theme'
import { AppNavBar } from '../components/design-system/AppNavBar'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { InsightItem } from '../models/AskModels'
import { AskBizService } from '../services/AskBizService'
import { AskNav } from '../services/AskNav'
import { LearnStore } from '../services/LearnStore'
import { GrowthStore } from '../services/GrowthStore'

class QuizOption {
  index: number = 0
  text: string = ''
}

@Component
export struct ChallengePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State pool: InsightItem[] = []
  @State current: InsightItem = new InsightItem()
  @State options: QuizOption[] = []
  @State index: number = 0
  @State picked: number = -1
  @State judged: boolean = false
  @State done: boolean = false
  @State score: number = 0
  @State total: number = 5
  @State empty: boolean = false

  aboutToAppear(): void {
    void this.start()
  }

  private async start(): Promise<void> {
    const want = AppStorage.get<number>('challengeTotal') ?? 5
    const total = want >= 10 ? 10 : (want >= 8 ? 8 : 5)
    const all = AskBizService.quizPool(await AskBizService.loadInsights())
    if (all.length === 0) {
      this.empty = true
      return
    }
    this.pool = ChallengePage.pick(all, total)
    this.total = this.pool.length
    this.index = 0
    this.score = 0
    this.done = false
    this.empty = false
    this.showAt(0)
  }

  private showAt(i: number): void {
    this.current = InsightItem.copy(this.pool[i])
    this.picked = -1
    this.judged = false
    const next: QuizOption[] = []
    const texts = this.current.choices()
    for (let n = 0; n < texts.length; n++) {
      const opt = new QuizOption()
      opt.index = n
      opt.text = texts[n]
      next.push(opt)
    }
    this.options = next
  }

  private async confirm(): Promise<void> {
    if (this.picked < 0 || this.judged) {
      return
    }
    this.judged = true
    const ok = this.picked === this.current.answerIndex
    if (ok) {
      this.score += 1
    } else {
      await LearnStore.addWrong(
        this.current,
        this.current.choiceAt(this.picked),
        this.current.choiceAt(this.current.answerIndex)
      )
    }
    await LearnStore.recordQuiz(ok)
    await GrowthStore.logActivity('quiz', this.current.title, this.current.id, this.current.category)
  }

  private next(): void {
    if (this.index + 1 >= this.total) {
      this.done = true
      AskNav.bumpRefresh()
      return
    }
    this.index += 1
    this.showAt(this.index)
  }

  private static pick(all: InsightItem[], n: number): InsightItem[] {
    const copy: InsightItem[] = []
    for (const row of all) {
      copy.push(row)
    }
    const out: InsightItem[] = []
    const seed = Date.now() % 97
    let i = 0
    while (copy.length > 0 && out.length < n) {
      const idx = (seed + i * 3) % copy.length
      out.push(copy[idx])
      const remain: InsightItem[] = []
      for (let k = 0; k < copy.length; k++) {
        if (k !== idx) {
          remain.push(copy[k])
        }
      }
      copy.length = 0
      for (const r of remain) {
        copy.push(r)
      }
      i += 1
    }
    return out
  }

  build() {
    Column() {
      AppNavBar({ title: '知识挑战', onBack: (): void => { AskNav.closeLearn() } })
      if (this.empty) {
        AppEmpty({
          title: '暂无挑战题目',
          description: '解答库加载后再试',
          actionLabel: '重试',
          onAction: (): void => { void this.start() }
        })
          .layoutWeight(1)
      } else if (this.done) {
        Column({ space: Theme.space.s4 }) {
          Text(`答对 ${this.score} / ${this.total}`)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text('可到错题本查看答错的题目，并再练一次。')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          AppButton({ label: '再挑战一次', onTap: (): void => { void this.start() } })
          AppButton({
            label: '查看错题本',
            variant: 'secondary',
            onTap: (): void => { AskNav.openLearn('wrong') }
          })
        }
        .padding(Theme.space.pageX)
        .width('100%')
        .layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            Text(`第 ${this.index + 1} / ${this.total} 题 · ${this.current.category}`)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Text(this.current.title)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.options, (opt: QuizOption) => {
              Text(`${opt.index + 1}. ${opt.text}`)
                .fontSize(Theme.type.body)
                .fontColor(this.optionColor())
                .width('100%')
                .padding(Theme.space.s4)
                .constraintSize({ minHeight: 48 })
                .backgroundColor(this.optionBg(opt.index))
                .borderRadius(Theme.radius.card)
                .onClick(() => {
                  if (!this.judged) {
                    this.picked = opt.index
                  }
                })
            }, (opt: QuizOption) => `${this.current.id}_${opt.index}`)
            if (this.judged) {
              Text(this.picked === this.current.answerIndex ?
                '答对了。下面是要点解析。' : '答错了。正确答案已标出，可看解析。')
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text(this.current.summary)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }
            if (!this.judged) {
              AppButton({
                label: this.picked < 0 ? '请先选一项' : '确认答案',
                disabled: this.picked < 0,
                onTap: (): void => { void this.confirm() }
              })
            } else {
              AppButton({
                label: this.index + 1 >= this.total ? '查看成绩' : '下一题',
                onTap: (): void => { this.next() }
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
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  private optionBg(i: number): string {
    if (this.judged && i === this.current.answerIndex) {
      return Theme.colors().successContainer
    }
    if (this.judged && i === this.picked && i !== this.current.answerIndex) {
      return Theme.colors().dangerContainer
    }
    if (this.picked === i) {
      return Theme.colors().brandPrimaryContainer
    }
    return Theme.colors().surfaceCard
  }

  private optionColor(): string {
    return this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary
  }
}
