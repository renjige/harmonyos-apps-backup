import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { QuizOptionRow } from '../components/design-system/PuzzleCards'
import { PuzzleItem } from '../models/PuzzleModels'
import { QuizBizService } from '../services/QuizBizService'
import { QuizNav } from '../services/QuizNav'
import { ProgressStore } from '../services/ProgressStore'

@Component
export struct FamilyPlayOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State puzzles: PuzzleItem[] = []
  @State current: PuzzleItem = new PuzzleItem()
  @State index: number = 0
  @State total: number = 0
  @State selected: number = -1
  @State step: string = 'parent'
  @State match: number = 0
  @StorageLink('quizTick') tick: number = 0

  aboutToAppear(): void {
    void this.boot()
  }

  async boot(): Promise<void> {
    this.puzzles = await QuizBizService.loadPuzzles()
    this.sync()
  }

  private sync(): void {
    const ids = QuizNav.queue()
    this.total = ids.length
    this.index = QuizNav.index()
    this.selected = QuizNav.selected()
    this.step = AppStorage.get<string>('familyStep') ?? 'parent'
    if (this.index >= 0 && this.index < ids.length) {
      const found = QuizBizService.find(this.puzzles, ids[this.index])
      if (found !== undefined) {
        this.current = found
      }
    }
  }

  private roleTitle(): string {
    if (this.step === 'parent') {
      return '家长先答'
    }
    if (this.step === 'child') {
      return '轮到孩子啦'
    }
    return '今日亲子默契'
  }

  private pick(i: number): void {
    if (this.step === 'result') {
      return
    }
    QuizNav.setSelected(i)
    this.selected = i
  }

  private tone(i: number): string {
    if (this.step === 'result') {
      if (i === this.current.answerIndex) {
        return 'correct'
      }
    }
    if (this.selected === i) {
      return 'selected'
    }
    return 'idle'
  }

  private append(key: string, value: number): void {
    const raw = AppStorage.get<string>(key) ?? ''
    const next = raw.length === 0 ? `${value}` : `${raw},${value}`
    AppStorage.setOrCreate(key, next)
  }

  private async next(): Promise<void> {
    if (this.selected < 0 && this.step !== 'result') {
      return
    }
    if (this.step === 'parent') {
      this.append('familyParent', this.selected)
      if (this.index + 1 >= this.total) {
        AppStorage.setOrCreate('familyStep', 'child')
        QuizNav.setIndex(0)
        this.step = 'child'
        this.sync()
        return
      }
      QuizNav.setIndex(this.index + 1)
      this.sync()
      return
    }
    if (this.step === 'child') {
      this.append('familyChild', this.selected)
      if (this.index + 1 >= this.total) {
        await this.finish()
        return
      }
      QuizNav.setIndex(this.index + 1)
      this.sync()
    }
  }

  private async finish(): Promise<void> {
    const parent = (AppStorage.get<string>('familyParent') ?? '').split(',')
    const child = (AppStorage.get<string>('familyChild') ?? '').split(',')
    let same = 0
    const n = Math.min(parent.length, child.length)
    for (let i = 0; i < n; i++) {
      if (parent[i] === child[i]) {
        same++
      }
    }
    const pct = n === 0 ? 0 : Math.round((same * 100) / n)
    this.match = pct
    await ProgressStore.recordFamily(pct)
    AppStorage.setOrCreate('familyStep', 'result')
    this.step = 'result'
    QuizNav.bump()
  }

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(15)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick(() => QuizNav.close())
        Blank()
        Text(this.roleTitle())
          .fontSize(14)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 8 })

      if (this.step === 'result') {
        this.ResultPane()
      } else {
        this.PlayPane()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  PlayPane() {
    Column({ space: 16 }) {
      Text(`第 ${this.index + 1} 题`)
        .fontSize(13)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Text(this.current.question)
        .fontSize(24)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .lineHeight(34)
        .width('100%')
      QuizOptionRow({ label: 'A', text: this.current.optionA, tone: this.tone(0), onPick: () => this.pick(0) })
      QuizOptionRow({ label: 'B', text: this.current.optionB, tone: this.tone(1), onPick: () => this.pick(1) })
      QuizOptionRow({ label: 'C', text: this.current.optionC, tone: this.tone(2), onPick: () => this.pick(2) })
      QuizOptionRow({ label: 'D', text: this.current.optionD, tone: this.tone(3), onPick: () => this.pick(3) })
      Blank()
      AppButton({
        label: this.step === 'parent' && this.index + 1 >= this.total ? '交给孩子' : '下一题',
        disabled: this.selected < 0,
        onTap: () => { void this.next() }
      })
    }
    .padding({ left: 20, right: 20, bottom: 28 })
    .layoutWeight(1)
    .width('100%')
  }

  @Builder
  ResultPane() {
    Column({ space: 14 }) {
      Text('今日亲子默契')
        .fontSize(16)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Text(`${this.match}%`)
        .fontSize(48)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        .width('100%')
      Text(this.match >= 60 ? '你们今天很有默契！' : '一起想过，就已经很棒。')
        .fontSize(18)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text('默契只是今天的小纪念，不是比较，也不是评分。')
        .fontSize(14)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Blank()
      AppButton({
        label: '回到亲子时光',
        onTap: () => QuizNav.close()
      })
    }
    .padding({ left: 24, right: 24, bottom: 28, top: 24 })
    .layoutWeight(1)
    .width('100%')
  }
}
