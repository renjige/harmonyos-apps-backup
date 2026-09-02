import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppError } from '../components/design-system/AppError'
import { HuntOptionRow } from '../components/design-system/PoetryCards'
import { LevelItem, PoemItem, QuestionItem } from '../models/PoetryModels'
import { PoetryBizService } from '../services/PoetryBizService'
import { PoetryNav } from '../services/PoetryNav'
import { HuntProgressStore } from '../services/HuntProgressStore'
import { PoetryMedia } from '../services/PoetryMedia'

@Component
export struct HuntOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State questions: QuestionItem[] = []
  @State poems: PoemItem[] = []
  @State level: LevelItem = new LevelItem()
  @State current: QuestionItem = new QuestionItem()
  @State index: number = 0
  @State selected: number = -1
  @State phase: string = 'answering'
  @State fillText: string = ''
  @State loading: boolean = true
  @State failed: boolean = false
  @State chestOn: boolean = false
  @StorageLink('poetryTick') tick: number = 0

  aboutToAppear(): void {
    void this.boot()
  }

  async boot(): Promise<void> {
    this.loading = true
    this.failed = false
    const levelId = AppStorage.get<string>('huntLevelId') ?? ''
    const levels = await PoetryBizService.loadLevels()
    const found = PoetryBizService.findLevel(levels, levelId)
    if (found !== undefined) {
      this.level = found
    }
    this.poems = await PoetryBizService.loadPoems()
    this.questions = await PoetryBizService.loadQuestions(levelId)
    this.loading = false
    this.failed = this.questions.length === 0
    this.index = 0
    this.selected = -1
    this.phase = 'answering'
    this.syncCurrent()
  }

  private syncCurrent(): void {
    if (this.index >= 0 && this.index < this.questions.length) {
      this.current = this.questions[this.index]
    }
  }

  private tone(i: number): string {
    if (this.phase === 'correct' || this.phase === 'wrong') {
      if (i === this.current.answerIndex) {
        return 'correct'
      }
      if (i === this.selected && i !== this.current.answerIndex) {
        return 'wrong'
      }
    }
    if (this.selected === i) {
      return 'selected'
    }
    return 'idle'
  }

  private pick(i: number): void {
    if (this.phase !== 'answering') {
      return
    }
    this.selected = i
  }

  private isCorrect(): boolean {
    if (this.current.questionType === 'fill' && this.fillText.trim().length > 0) {
      return this.fillText.trim() === this.current.answerText.trim()
    }
    return this.selected === this.current.answerIndex
  }

  private submit(): void {
    if (this.phase !== 'answering') {
      return
    }
    if (this.selected < 0 && this.current.questionType !== 'fill') {
      return
    }
    if (this.current.questionType === 'fill' && this.fillText.trim().length === 0 && this.selected < 0) {
      return
    }
    if (this.isCorrect()) {
      this.phase = 'correct'
      this.chestOn = true
      setTimeout(() => { this.chestOn = false }, 700)
    } else {
      this.phase = 'wrong'
    }
  }

  private retry(): void {
    this.selected = -1
    this.fillText = ''
    this.phase = 'answering'
  }

  private async next(): Promise<void> {
    if (this.index + 1 >= this.questions.length) {
      const poem = PoetryBizService.findPoem(this.poems, this.current.poemId)
      const placeId = poem !== undefined ? poem.placeId : ''
      await HuntProgressStore.completeLevel(this.level.id, this.level.title, this.level.coins, placeId)
      this.phase = 'chest'
      return
    }
    this.index = this.index + 1
    this.selected = -1
    this.fillText = ''
    this.phase = 'answering'
    this.syncCurrent()
  }

  private promptExtra(): string {
    if (this.current.questionType === 'match' && this.current.matchLeft.length > 0) {
      return this.current.matchLeft
    }
    return ''
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row() {
          Text('返回')
            .fontSize(15)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .onClick(() => PoetryNav.close())
          Blank()
          Text(this.level.title)
            .fontSize(14)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 8 })

        if (this.failed && !this.loading) {
          AppError({
            title: '题目暂不可用',
            message: '请检查网络后重试。',
            retryLabel: '重试',
            onRetry: () => { void this.boot() }
          })
        } else if (this.phase === 'chest') {
          this.ChestPane()
        } else if (this.phase === 'correct') {
          this.CorrectPane()
        } else if (this.phase === 'wrong') {
          this.WrongPane()
        } else {
          this.AnswerPane()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.chestOn) {
        Text('宝箱已开启')
          .fontSize(16)
          .fontColor('#F5F0E8')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(192,57,43,0.92)')
          .borderRadius(12)
          .margin({ top: 64 })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  AnswerPane() {
    Column({ space: 14 }) {
      Text(`第 ${this.index + 1} / ${this.questions.length} 题 · ${PoetryBizService.typeLabel(this.current.questionType)}`)
        .fontSize(13)
        .fontColor(Theme.colors().brandAccent)
        .width('100%')
      Text(this.current.prompt)
        .fontSize(22)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .lineHeight(32)
        .width('100%')
      if (this.promptExtra().length > 0) {
        Text(this.promptExtra())
          .fontSize(16)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      if (this.current.questionType === 'fill') {
        TextInput({ text: this.fillText, placeholder: '填写空缺字句' })
          .onChange((v: string) => { this.fillText = v })
      }
      HuntOptionRow({ label: 'A', text: this.current.optionA, tone: this.tone(0), onPick: () => this.pick(0) })
      HuntOptionRow({ label: 'B', text: this.current.optionB, tone: this.tone(1), onPick: () => this.pick(1) })
      HuntOptionRow({ label: 'C', text: this.current.optionC, tone: this.tone(2), onPick: () => this.pick(2) })
      HuntOptionRow({ label: 'D', text: this.current.optionD, tone: this.tone(3), onPick: () => this.pick(3) })
      Blank()
      AppButton({
        label: '提交答案',
        disabled: this.selected < 0 && this.fillText.trim().length === 0,
        onTap: () => this.submit()
      })
    }
    .padding({ left: 20, right: 20, bottom: 28, top: 8 })
    .layoutWeight(1)
    .width('100%')
  }

  @Builder
  CorrectPane() {
    Column({ space: 14 }) {
      Text('宝箱开启')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text('回答正确，墨香入匣')
        .fontSize(16)
        .fontColor(Theme.colors().success)
        .width('100%')
      Text(this.current.explanation)
        .fontSize(15)
        .lineHeight(24)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Blank()
      AppButton({
        label: this.index + 1 >= this.questions.length ? '领取诗币' : '下一题',
        onTap: () => { void this.next() }
      })
    }
    .padding({ left: 20, right: 20, bottom: 28, top: 8 })
    .layoutWeight(1)
    .width('100%')
  }

  @Builder
  WrongPane() {
    Column({ space: 14 }) {
      Text('墨迹消散')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text('再想一想，可重答此题')
        .fontSize(16)
        .fontColor(Theme.colors().danger)
        .width('100%')
      Text(this.current.explanation)
        .fontSize(15)
        .lineHeight(24)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Blank()
      AppButton({ label: '重新作答', onTap: () => this.retry() })
    }
    .padding({ left: 20, right: 20, bottom: 28, top: 8 })
    .layoutWeight(1)
    .width('100%')
  }

  @Builder
  ChestPane() {
    Column({ space: 16 }) {
      Image(PoetryMedia.cover(this.level.coverKey))
        .width('100%')
        .height(160)
        .objectFit(ImageFit.Cover)
        .borderRadius(20)
      Text('卷轴展开')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(`通关「${this.level.title}」，获得 ${this.level.coins} 诗币。关联诗地已点亮。`)
        .fontSize(15)
        .lineHeight(24)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Blank()
      AppButton({ label: '返回寻宝', onTap: () => PoetryNav.close() })
    }
    .padding({ left: 20, right: 20, bottom: 28, top: 8 })
    .layoutWeight(1)
    .width('100%')
  }
}
