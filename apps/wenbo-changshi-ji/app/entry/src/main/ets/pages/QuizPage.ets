import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { QuizOption, QuizQuestion } from '../models/CommonSenseToolModels'
import { CommonSenseBizService } from '../services/CommonSenseBizService'
import { CommonSenseDetailNav } from '../services/CommonSenseDetailNav'
import { CommonSenseLocalService } from '../services/CommonSenseLocalService'
import { LearningHubService } from '../services/LearningHubService'
import { QuizService } from '../services/QuizService'

@Component
export struct QuizPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State step: string = 'intro'
  @State questions: QuizQuestion[] = []
  @State index: number = 0
  @State picked: string = ''
  @State score: number = 0
  @State wrongIds: string[] = []
  @State paperSalt: number = 0
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.prepare(true)
  }

  private async prepare(fresh: boolean): Promise<void> {
    if (fresh) {
      this.paperSalt = Date.now()
    }
    const facts = await CommonSenseBizService.loadFacts()
    this.questions = QuizService.buildPaper(facts, 5, this.paperSalt)
  }

  private current(): QuizQuestion {
    if (this.index >= 0 && this.index < this.questions.length) {
      return this.questions[this.index]
    }
    return new QuizQuestion()
  }

  private select(opt: QuizOption): void {
    this.picked = opt.id
  }

  private goNext(): void {
    if (this.picked.length === 0) {
      this.toastText = '请先选择一项'
      setTimeout((): void => { this.toastText = '' }, 1600)
      return
    }
    const q = this.current()
    let ok = false
    for (const opt of q.options) {
      if (opt.id === this.picked && opt.correct) {
        ok = true
      }
    }
    const correctIds: string[] = []
    if (ok) {
      this.score = this.score + 1
      correctIds.push(q.factId)
    } else {
      const nextWrong: string[] = []
      for (const id of this.wrongIds) {
        nextWrong.push(id)
      }
      nextWrong.push(q.factId)
      this.wrongIds = nextWrong
    }
    void CommonSenseLocalService.recordQuiz(correctIds, ok ? [] : [q.factId])
    if (this.index + 1 >= this.questions.length) {
      void LearningHubService.onQuiz(this.score, this.questions.length)
      this.step = 'result'
      return
    }
    this.index = this.index + 1
    this.picked = ''
  }

  private restart(): void {
    this.step = 'intro'
    this.index = 0
    this.picked = ''
    this.score = 0
    this.wrongIds = []
    void this.prepare(true)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => { CommonSenseDetailNav.close() })
          Text('常识问答')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

        if (this.step === 'intro') {
          Column({ space: Theme.space.s4 }) {
            Text('每次随机抽取 5 道选择题，选项与题目一一对应；做完可看对错，错题可回看原文。')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            AppButton({
              label: this.questions.length > 0 ? '开始答题' : '内容加载中…',
              onTap: (): void => {
                if (this.questions.length > 0) {
                  this.step = 'quiz'
                }
              }
            })
          }
          .padding(Theme.space.pageX)
        } else if (this.step === 'quiz') {
          this.QuizBody()
        } else {
          this.ResultBody()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s6 })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  QuizBody() {
    Column({ space: Theme.space.s3 }) {
      Text(`${this.index + 1} / ${this.questions.length}`)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().brandPrimary)
        .width('100%')
      Text(this.current().prompt)
        .fontSize(Theme.type.subtitleM)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      ForEach(this.current().options, (opt: QuizOption) => {
        Text(opt.text)
          .fontSize(Theme.type.subhead)
          .fontColor(this.picked === opt.id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
          .padding(Theme.space.s4)
          .width('100%')
          .backgroundColor(this.picked === opt.id ?
            Theme.colors().brandPrimary : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.card)
          .onClick((): void => { this.select(opt) })
      }, (opt: QuizOption) => `${this.index}_${opt.id}`)
      AppButton({
        label: this.index + 1 >= this.questions.length ? '查看结果' : '下一题',
        onTap: (): void => { this.goNext() }
      })
    }
    .padding(Theme.space.pageX)
    .width('100%')
  }

  @Builder
  ResultBody() {
    Column({ space: Theme.space.s3 }) {
      Text(`答对 ${this.score} / ${this.questions.length}`)
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text('答对的条目已记入「已掌握」。错题点开可回看原文。')
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      if (this.wrongIds.length === 0) {
        AppEmpty({ title: '本题全对', description: '明天再来一组，保持手感。' })
      } else {
        Text('错题回顾')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        ForEach(this.wrongIds, (id: string) => {
          Text(this.wrongTitle(id))
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().brandPrimary)
            .padding(Theme.space.s4)
            .width('100%')
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.card)
            .onClick((): void => { CommonSenseDetailNav.openFact(id) })
        }, (id: string) => id)
      }
      AppButton({
        label: '再测一组',
        variant: 'secondary',
        onTap: (): void => { this.restart() }
      })
    }
    .padding(Theme.space.pageX)
    .width('100%')
  }

  private wrongTitle(id: string): string {
    for (const q of this.questions) {
      if (q.factId === id) {
        return q.title
      }
    }
    return '查看原文'
  }
}
