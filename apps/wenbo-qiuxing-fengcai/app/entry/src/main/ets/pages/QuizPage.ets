import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AthleteItem, QuizChoice, QuizQuestion } from '../models/StarModels'
import { StarBizService } from '../services/StarBizService'
import { StarDetailNav } from '../services/StarDetailNav'
import { QuizBuilder } from '../services/QuizBuilder'
import { QuizRecordService } from '../services/QuizRecordService'
import { FanStatsService } from '../services/FanStatsService'
import { QuizStats } from '../models/FanGrowthModels'

@Component
export struct QuizPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State questions: QuizQuestion[] = []
  @State index: number = 0
  @State picked: string = ''
  @State score: number = 0
  @State finished: boolean = false
  @State loading: boolean = true
  @State promptText: string = ''
  @State choices: QuizChoice[] = []
  @State wrongIds: string[] = []
  @State lifetime: QuizStats = new QuizStats()
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.startRound()
  }

  private syncCurrent(): void {
    if (this.index >= this.questions.length) {
      this.promptText = ''
      this.choices = []
      return
    }
    const q = this.questions[this.index]
    this.promptText = q.prompt
    this.choices = q.choices
  }

  private async startRound(): Promise<void> {
    this.loading = true
    this.finished = false
    this.index = 0
    this.picked = ''
    this.score = 0
    this.wrongIds = []
    this.lifetime = QuizRecordService.statsSnapshot()
    const athletes: AthleteItem[] = await StarBizService.loadAthletes('', false)
    this.questions = QuizBuilder.build(athletes)
    this.syncCurrent()
    this.loading = false
  }

  private async finishRound(): Promise<void> {
    await QuizRecordService.saveRound(this.score, this.questions.length, this.wrongIds)
    this.lifetime = QuizRecordService.statsSnapshot()
    const ach = await FanStatsService.bumpAndEvaluate()
    if (ach.length > 0) {
      this.toastText = ach
      setTimeout((): void => { this.toastText = '' }, 2800)
    }
    this.finished = true
  }

  private pick(choice: QuizChoice): void {
    if (this.picked.length > 0 || this.finished) {
      return
    }
    this.picked = choice.id
    if (choice.correct) {
      this.score += 1
    } else {
      this.wrongIds.push(this.questions[this.index].id)
    }
  }

  private next(): void {
    if (this.index + 1 >= this.questions.length) {
      void this.finishRound()
      return
    }
    this.index += 1
    this.picked = ''
    this.syncCurrent()
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { StarDetailNav.close() })
        Text('球星知识挑战')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      if (this.loading) {
        AppLoading({ label: '出题中…' }).layoutWeight(1)
      } else if (this.questions.length === 0) {
        AppEmpty({
          title: '暂时无法出题',
          description: '球星资料不足 4 人时无法生成挑战',
          actionLabel: '返回',
          onAction: (): void => { StarDetailNav.close() }
        }).layoutWeight(1)
      } else if (this.finished) {
        Column({ space: Theme.space.s4 }) {
          Text(`本轮得分 ${this.score}/${this.questions.length}`)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text(`累计最佳 ${this.lifetime.bestScore}/${this.lifetime.bestTotal} · 正确率 ${this.lifetime.accuracyPercent()}%`)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          AppButton({
            label: '再来一轮',
            onTap: (): void => { void this.startRound() }
          })
          AppButton({
            label: '查看球星资料',
            variant: 'secondary',
            onTap: (): void => { StarDetailNav.close() }
          })
        }
        .padding(Theme.space.pageX)
        .layoutWeight(1)
        .width('100%')
      } else {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text(`第 ${this.index + 1} / ${this.questions.length} 题`)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .width('100%')
            Text(this.promptText)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.choices, (c: QuizChoice) => {
              Text(c.text)
                .fontSize(Theme.type.body)
                .fontColor(this.choiceColor(c))
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.xl)
                .border({
                  width: 1,
                  color: this.choiceBorder(c)
                })
                .onClick((): void => { this.pick(c) })
            }, (c: QuizChoice) => c.id)
            if (this.picked.length > 0) {
              AppButton({
                label: this.index + 1 >= this.questions.length ? '查看成绩' : '下一题',
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
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  private choiceColor(c: QuizChoice): string {
    if (this.picked.length === 0) {
      return Theme.colors().textPrimary
    }
    if (c.correct) {
      return Theme.colors().brandPrimary
    }
    if (c.id === this.picked) {
      return Theme.colors().danger
    }
    return Theme.colors().textSecondary
  }

  private choiceBorder(c: QuizChoice): string {
    if (this.picked.length === 0) {
      return Theme.colors().strokeHairline
    }
    if (c.correct || c.id === this.picked) {
      return Theme.colors().brandPrimary
    }
    return Theme.colors().strokeHairline
  }
}
