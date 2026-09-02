import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { OptionItem, QuestMap, QuestQuestion } from '../models/QuestModels'
import { QuestBizService } from '../services/QuestBizService'
import { QuestNav } from '../services/QuestNav'
import { ProgressStore } from '../services/ProgressStore'

@Component
export struct QuizOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State map: QuestMap = new QuestMap()
  @State questions: QuestQuestion[] = []
  @State options: OptionItem[] = []
  @State index: number = 0
  @State selected: number = -1
  @State revealed: boolean = false
  @State retriesLeft: number = 3
  @State wrongCount: number = 0
  @State finished: boolean = false
  @State success: boolean = false
  @State toast: string = ''
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.load()
  }

  async load(): Promise<void> {
    this.loading = true
    const id = QuestNav.quizMapId()
    const found = await QuestBizService.loadMap(id)
    if (found !== undefined) {
      this.map = found
      this.retriesLeft = found.retryLimit > 0 ? found.retryLimit : 3
    }
    this.questions = await QuestBizService.loadQuestions(id)
    this.index = 0
    this.finished = false
    this.success = false
    this.wrongCount = 0
    this.applyQuestion()
    this.loading = false
  }

  private currentQ(): QuestQuestion {
    const n = this.index
    let i = 0
    for (const q of this.questions) {
      if (i === n) {
        return q
      }
      i = i + 1
    }
    return new QuestQuestion()
  }

  private applyQuestion(): void {
    this.selected = -1
    this.revealed = false
    if (this.index < this.questions.length) {
      this.options = QuestBizService.optionsOf(this.currentQ())
    }
  }

  private showToast(msg: string): void {
    this.toast = msg
    setTimeout(() => { this.toast = '' }, 2400)
  }

  private currentTitle(): string {
    if (this.index < this.questions.length) {
      return this.currentQ().title
    }
    return ''
  }

  private currentExplain(): string {
    if (this.index < this.questions.length) {
      return this.currentQ().explanation
    }
    return ''
  }

  private isCorrect(): boolean {
    if (this.index >= this.questions.length) {
      return false
    }
    return this.selected === this.currentQ().answerIndex
  }

  private async confirm(): Promise<void> {
    if (this.selected < 0 || this.revealed) {
      return
    }
    const ok = this.isCorrect()
    await ProgressStore.recordAnswer(ok)
    this.revealed = true
    if (!ok) {
      this.wrongCount = this.wrongCount + 1
      this.retriesLeft = this.retriesLeft - 1
      if (this.retriesLeft <= 0) {
        this.finished = true
        this.success = false
        this.showToast('本关重试次数已用尽，可返回后重新开始')
      }
    }
  }

  private async next(): Promise<void> {
    if (!this.revealed) {
      return
    }
    if (!this.isCorrect()) {
      if (this.retriesLeft <= 0) {
        return
      }
      this.applyQuestion()
      return
    }
    if (this.index + 1 >= this.questions.length) {
      this.finished = true
      this.success = true
      const treasureId = `tr_${this.map.id}`
      await ProgressStore.completeMap(this.map.id, treasureId, this.map.wisdomReward, this.wrongCount === 0)
      this.showToast('宝藏已解锁，智慧值已入账')
      return
    }
    this.index = this.index + 1
    this.applyQuestion()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row() {
          Text('退出')
            .fontSize(15)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .onClick(() => QuestNav.close())
          Blank()
          Text(this.finished ? '闯关结果' : `第 ${this.index + 1} / ${this.questions.length} 题`)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Text(`重试 ${this.retriesLeft}`)
            .fontSize(12)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 8 })
        .constraintSize({ minHeight: 48 })

        if (this.loading) {
          Text('正在展开地图…')
            .fontSize(14)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .margin(24)
        } else if (this.finished) {
          this.ResultPane()
        } else {
          Scroll() {
            Column({ space: 14 }) {
              Text(this.map.title)
                .fontSize(13)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                .width('100%')
              Text(this.currentTitle())
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')

              ForEach(this.options, (opt: OptionItem) => {
                this.OptionRow(opt)
              }, (opt: OptionItem) => `${opt.index}`)

              if (this.revealed) {
                Column({ space: 6 }) {
                  Text(this.isCorrect() ? '回答正确' : '再想一想')
                    .fontSize(15)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.isCorrect() ? Theme.colors().success : Theme.colors().danger)
                    .width('100%')
                  Text(this.currentExplain())
                    .fontSize(14)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                }
                .width('100%')
                .padding(14)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.md)
              }

              if (!this.revealed) {
                AppButton({
                  label: '确认答案',
                  disabled: this.selected < 0,
                  onTap: () => { void this.confirm() }
                })
              } else {
                AppButton({
                  label: this.isCorrect() ?
                    (this.index + 1 >= this.questions.length ? '领取宝藏' : '下一题') :
                    '再试一次',
                  onTap: () => { void this.next() }
                })
              }
            }
            .padding({ left: 20, right: 20, bottom: Theme.space.s10 })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(14)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(45,27,105,0.92)')
          .borderRadius(Theme.radius.pill)
          .margin({ top: 56 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  OptionRow(opt: OptionItem) {
    Row() {
      Text(opt.text)
        .fontSize(15)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
    }
    .width('100%')
    .padding(14)
    .constraintSize({ minHeight: 48 })
    .backgroundColor(this.optionBg(opt.index))
    .borderRadius(Theme.radius.md)
    .border({
      width: 1,
      color: this.selected === opt.index ? Theme.colors().brandPrimary : Theme.colors().strokeHairline
    })
    .onClick(() => {
      if (!this.revealed) {
        this.selected = opt.index
      }
    })
  }

  private optionBg(i: number): string {
    if (this.revealed && i === this.currentQ().answerIndex) {
      return Theme.colors().successContainer
    }
    if (this.revealed && i === this.selected && i !== this.currentQ().answerIndex) {
      return Theme.colors().dangerContainer
    }
    if (this.selected === i) {
      return Theme.colors().brandPrimaryContainer
    }
    return Theme.colors().surfaceCard
  }

  @Builder
  ResultPane() {
    Column({ space: 16 }) {
      Text(this.success ? '知识宝藏已点亮' : '再整装出发')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(this.success ?
        `通关「${this.map.title}」，智慧值 +${this.map.wisdomReward}` :
        '三次重试已用完。解析仍可在下次闯关中查看。')
        .fontSize(15)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      AppButton({
        label: this.success ? '查看我的宝藏' : '返回地图',
        onTap: () => {
          if (this.success) {
            QuestNav.close()
            AppStorage.setOrCreate('mainTab', 3)
          } else {
            QuestNav.openMap(this.map.id)
          }
        }
      })
      AppButton({
        label: '关闭',
        variant: 'secondary',
        onTap: () => QuestNav.close()
      })
    }
    .padding({ left: 20, right: 20, top: 24 })
    .width('100%')
    .layoutWeight(1)
  }
}
