import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { ChallengeQuestion } from '../data/ChallengeBank'
import { ElementService } from '../services/ElementService'
import { ElementNav } from '../services/ElementNav'
import { ProgressStore } from '../services/ProgressStore'
import { DetailShell } from '../components/detail/DetailShell'

@Component
export struct ChallengeQuizOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('elementNavTick') elementNavTick: number = 0
  @State quizType: string = ''
  @State questions: ChallengeQuestion[] = []
  @State index: number = 0
  @State selected: number = -1
  @State phase: string = 'answering'
  @State score: number = 0
  @State current: ChallengeQuestion = new ChallengeQuestion()

  aboutToAppear(): void {
    this.boot()
  }

  private boot(): void {
    this.quizType = ElementNav.quizType()
    this.questions = ElementService.quizSession(this.quizType)
    this.index = 0
    this.selected = -1
    this.phase = 'answering'
    this.score = 0
    if (this.questions.length > 0) {
      this.current = this.questions[0]
    }
  }

  private optionLabel(i: number): string {
    if (i === 0) {
      return 'A'
    }
    if (i === 1) {
      return 'B'
    }
    if (i === 2) {
      return 'C'
    }
    return 'D'
  }

  private optionTone(i: number): string {
    if (this.phase === 'result' && i === this.current.answerIndex) {
      return 'correct'
    }
    if (this.phase === 'result' && i === this.selected && i !== this.current.answerIndex) {
      return 'wrong'
    }
    if (this.selected === i) {
      return 'selected'
    }
    return 'idle'
  }

  private optionBg(i: number): string {
    const tone = this.optionTone(i)
    if (tone === 'correct') {
      return Theme.colors().successContainer
    }
    if (tone === 'wrong') {
      return Theme.colors().dangerContainer
    }
    if (tone === 'selected') {
      return Theme.colors().brandPrimaryContainer
    }
    return Theme.colors().surfaceCard
  }

  private pick(i: number): void {
    if (this.phase !== 'answering') {
      return
    }
    this.selected = i
  }

  private submit(): void {
    if (this.selected < 0) {
      return
    }
    if (this.selected === this.current.answerIndex) {
      this.score = this.score + 1
    }
    this.phase = 'result'
  }

  private next(): void {
    if (this.index + 1 >= this.questions.length) {
      const perfect = this.score === this.questions.length
      void ProgressStore.recordChallenge(this.score, this.questions.length, perfect)
      this.phase = 'finished'
      return
    }
    this.index = this.index + 1
    this.current = this.questions[this.index]
    this.selected = -1
    this.phase = 'answering'
  }

  private optionText(i: number): string {
    if (i >= 0 && i < this.current.options.length) {
      return this.current.options[i]
    }
    return ''
  }

  @Builder
  OptionRow(i: number) {
    Row({ space: Theme.space.s3 }) {
      Text(this.optionLabel(i))
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().brandPrimary)
      Text(this.optionText(i))
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textPrimary)
        .layoutWeight(1)
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.optionBg(i))
    .borderRadius(Theme.radius.md)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick((): void => { this.pick(i) })
  }

  build() {
    DetailShell({
      title: ElementService.challengeTypeLabel(this.quizType),
      onClose: (): void => { ElementNav.closeQuiz() }
    }) {
      if (this.questions.length === 0) {
        Column() {
          Text('暂无题目')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.phase === 'finished') {
        Column({ space: Theme.space.s4 }) {
          Text('挑战完成')
            .fontSize(Theme.type.title1)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text(`得分 ${this.score} / ${this.questions.length}`)
            .fontSize(Theme.type.title3)
            .fontColor(Theme.colors().brandAccent)
            .width('100%')
          Text(this.score >= 4 ? '表现优秀，继续保持！' : '再练几次会更熟练')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          Blank()
          AppButton({
            label: '返回挑战',
            onTap: (): void => { ElementNav.closeQuiz() }
          })
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10,
          top: Theme.space.s4
        })
        .width('100%')
        .height('100%')
      } else {
        Column({ space: Theme.space.s4 }) {
          Text(`第 ${this.index + 1} / ${this.questions.length} 题`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')

          Text(this.current.prompt)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .lineHeight(28)
            .width('100%')

          this.OptionRow(0)
          this.OptionRow(1)
          this.OptionRow(2)
          this.OptionRow(3)

          if (this.phase === 'result') {
            Column({ space: 6 }) {
              Text('解析')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              Text(this.current.explanation)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textSecondary)
                .lineHeight(22)
                .width('100%')
            }
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .width('100%')
          }

          Blank()

          if (this.phase === 'answering') {
            AppButton({
              label: '提交答案',
              disabled: this.selected < 0,
              onTap: (): void => { this.submit() }
            })
          } else {
            AppButton({
              label: this.index + 1 >= this.questions.length ? '查看成绩' : '下一题',
              onTap: (): void => { this.next() }
            })
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10,
          top: Theme.space.s2
        })
        .width('100%')
        .height('100%')
      }
    }
  }
}
