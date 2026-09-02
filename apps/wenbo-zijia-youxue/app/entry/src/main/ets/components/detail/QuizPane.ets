import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { QuizItem, QuizQuestion } from '../../models/RoadModels'
import { RoadBizService } from '../../services/RoadBizService'
import { RoadDetailNav } from '../../services/RoadDetailNav'

@Component
export struct QuizPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onQuizIdChange') quizId: string = ''
  @Prop @Watch('onQuizIdChange') refreshToken: number = 0
  @State item: QuizItem | undefined = undefined
  @State loading: boolean = true
  @State index: number = 0
  @State picked: number = -1
  @State showExplain: boolean = false
  @State correctCount: number = 0

  aboutToAppear(): void {
    void this.reload()
  }

  onQuizIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.item = await RoadBizService.findQuiz(this.quizId)
    this.index = 0
    this.picked = -1
    this.showExplain = false
    this.correctCount = 0
    this.loading = false
  }

  private current(): QuizQuestion | undefined {
    if (this.item === undefined) {
      return undefined
    }
    if (this.index < 0 || this.index >= this.item.questions.length) {
      return undefined
    }
    return this.item.questions[this.index]
  }

  private pick(i: number): void {
    if (this.showExplain) {
      return
    }
    this.picked = i
    const q = this.current()
    if (q !== undefined && i === q.correctIndex) {
      this.correctCount += 1
    }
    this.showExplain = true
  }

  private next(): void {
    this.index += 1
    this.picked = -1
    this.showExplain = false
  }

  build() {
    if (this.loading) {
      AppLoading({ label: '打开问答' })
    } else if (this.item === undefined) {
      DetailShell({ title: '问答', onClose: (): void => { RoadDetailNav.close() } }) {
        AppEmpty({ title: '暂无题目', description: '换一个景点再试' })
      }
    } else {
      this.Body(this.item as QuizItem)
    }
  }

  @Builder
  Body(item: QuizItem) {
    DetailShell({ title: item.title, contentKey: `${item.id}-${this.index}`, onClose: (): void => { RoadDetailNav.close() } }) {
      Column({ space: Theme.space.s4 }) {
        Text(`第 ${this.index + 1} / ${item.questions.length} 题`)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .padding({ left: Theme.space.pageX })
          .width('100%')

        if (this.current() === undefined) {
          Column({ space: 12 }) {
            Text(`完成啦，答对 ${this.correctCount} 题`)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text('把观察带回车上，下一站继续。')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            AppButton({ label: '返回景点', onTap: (): void => { RoadDetailNav.close() } })
          }
          .padding(Theme.space.pageX)
          .width('100%')
        } else {
          this.QuestionBlock(this.current() as QuizQuestion)
        }
      }
      .width('100%')
    }
  }

  @Builder
  QuestionBlock(q: QuizQuestion) {
    Column({ space: 12 }) {
      Text(q.prompt)
        .fontSize(Theme.type.subtitleL)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      this.OptionRow('A', q.optionA, 0)
      this.OptionRow('B', q.optionB, 1)
      this.OptionRow('C', q.optionC, 2)
      this.OptionRow('D', q.optionD, 3)
      if (this.showExplain) {
        Text(q.explain)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        AppButton({
          label: this.index + 1 >= (this.item !== undefined ? this.item.questions.length : 0) ? '看结果' : '下一题',
          onTap: (): void => { this.next() }
        })
      }
    }
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
    .width('100%')
  }

  @Builder
  OptionRow(mark: string, text: string, i: number) {
    Row({ space: 10 }) {
      Text(mark)
        .fontSize(Theme.type.subhead)
        .fontColor(this.picked === i ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
      Text(text)
        .fontSize(Theme.type.body)
        .fontColor(this.picked === i ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
        .layoutWeight(1)
    }
    .width('100%')
    .padding(14)
    .backgroundColor(this.picked === i ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick(() => { this.pick(i) })
  }
}
