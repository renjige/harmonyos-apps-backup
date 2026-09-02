import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { KnowledgeObject } from '../../models/KnowledgeModels'
import { QuizItem, QuizOption } from '../../models/FieldModels'
import { KnowledgeCatalog } from '../../services/KnowledgeCatalog'
import { FieldStore } from '../../services/FieldStore'

@Component
export struct GewuQuizPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onItemTick') item: KnowledgeObject = new KnowledgeObject()
  @Prop @Watch('onItemTick') refreshToken: number = 0
  onFinished: () => void = () => {}
  @State questions: QuizItem[] = []
  @State options: QuizOption[] = []
  @State prompt: string = ''
  @State index: number = 0
  @State picked: string = ''
  @State score: number = 0
  @State done: boolean = false
  @State summary: string = ''

  aboutToAppear(): void {
    void this.reset()
  }

  onItemTick(): void {
    void this.reset()
  }

  private async reset(): Promise<void> {
    this.questions = KnowledgeCatalog.buildQuiz(this.item)
    this.index = 0
    this.picked = ''
    this.score = 0
    this.done = false
    this.syncCurrent()
    const raw = await FieldStore.todayQuizScore()
    if (raw.length > 0) {
      this.done = true
      this.summary = '今日小测已完成，可在足迹查看任务进度'
    }
  }

  private syncCurrent(): void {
    const q = this.current()
    this.prompt = q.prompt
    this.options = q.options
  }

  private current(): QuizItem {
    let i = 0
    for (const q of this.questions) {
      if (i === this.index) {
        return q
      }
      i++
    }
    return new QuizItem()
  }

  private pick(opt: QuizOption): void {
    if (this.picked.length > 0 || this.done) {
      return
    }
    this.picked = opt.text
    if (opt.ok) {
      this.score++
    }
  }

  private async next(): Promise<void> {
    if (this.picked.length === 0) {
      return
    }
    if (this.index + 1 >= this.questions.length) {
      this.done = true
      this.summary = `答对 ${this.score} / ${this.questions.length} 题`
      await FieldStore.saveQuizScore(this.score, this.questions.length)
      this.onFinished()
      return
    }
    this.index++
    this.picked = ''
    this.syncCurrent()
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('格物小测')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text('根据今日知识物要点作答，加深记忆，不是浏览题库。')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')

      if (this.questions.length === 0) {
        Text('本日条目要点较少，请先阅读详情再回来。')
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      } else if (this.done) {
        Text(this.summary)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .width('100%')
      } else {
        Text(`第 ${this.index + 1} / ${this.questions.length} 题`)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Text(this.prompt)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .lineHeight(22)
          .width('100%')
        ForEach(this.options, (opt: QuizOption) => {
          Text(opt.text)
            .fontSize(Theme.type.bodyS)
            .fontColor(this.picked === opt.text ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
            .width('100%')
            .padding(12)
            .margin({ bottom: 8 })
            .backgroundColor(this.picked === opt.text ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
            .borderRadius(12)
            .onClick((): void => { this.pick(opt) })
        }, (opt: QuizOption) => opt.text)
        if (this.picked.length > 0) {
          AppButton({
            label: this.index + 1 >= this.questions.length ? '提交成绩' : '下一题',
            onTap: (): void => { void this.next() }
          })
        }
      }
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
  }
}
