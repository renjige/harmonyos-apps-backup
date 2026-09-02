import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { ShapeMark } from './ShapeMark'
import { QuizQuestion } from '../../models/KingdomModels'
import { KingdomBizService } from '../../services/KingdomBizService'
import { KingdomLocalStore } from '../../services/KingdomLocalStore'

class OptSlot {
  index: number = 0

  static four(): OptSlot[] {
    const out: OptSlot[] = []
    for (let i = 0; i < 4; i++) {
      const s = new OptSlot()
      s.index = i
      out.push(s)
    }
    return out
  }
}

@Component
export struct QuizOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop question: QuizQuestion = new QuizQuestion()
  @Prop @Watch('onQuestionChange') questionId: string = ''
  @Prop index: number = 0
  @Prop total: number = 4
  onAnswer: (ok: boolean) => void = (_ok: boolean) => {}
  onClose: () => void = () => {}
  @State picked: number = -1
  @State locked: boolean = false
  @State seqHits: number = 0
  @State toast: string = ''
  @State missed: boolean = false
  @State fontScale: number = 1
  private slots: OptSlot[] = OptSlot.four()

  onQuestionChange(): void {
    this.resetLocal()
  }

  aboutToAppear(): void {
    this.resetLocal()
  }

  private resetLocal(): void {
    this.picked = -1
    this.locked = false
    this.seqHits = 0
    this.toast = ''
    this.missed = false
    this.fontScale = KingdomLocalStore.settings().fontScale
  }

  private isSeq(): boolean {
    return this.question.sequence.length > 0
  }

  private seqParts(): string[] {
    return this.question.sequence.split(',')
  }

  private choose(index: number): void {
    if (this.locked) {
      return
    }
    if (this.isSeq()) {
      const parts = this.seqParts()
      if (this.seqHits >= parts.length) {
        return
      }
      const expect = parts[this.seqHits]
      const label = KingdomBizService.optionLabel(this.question, index)
      if (label === expect) {
        this.seqHits = this.seqHits + 1
        this.picked = index
        if (this.seqHits >= parts.length) {
          this.locked = true
          this.toast = '走对啦'
          this.onAnswer(!this.missed)
        }
        return
      }
      this.missed = true
      this.picked = index
      this.toast = this.question.hint.length > 0 ? this.question.hint : '再试试这条路'
      return
    }
    this.picked = index
    const ok = index === this.question.answerIndex
    if (!ok) {
      this.missed = true
      this.toast = this.question.hint.length > 0 ? this.question.hint : '再想一想也可以'
      return
    }
    this.locked = true
    this.toast = '答对了'
    this.onAnswer(!this.missed)
  }

  private tone(index: number): string {
    if (this.picked !== index) {
      return Theme.colors().surfaceCard
    }
    if (index === this.question.answerIndex) {
      return Theme.colors().successContainer
    }
    return Theme.colors().dangerContainer
  }

  build() {
    Column() {
      Row() {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(48)
        .height(48)
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.onClose())
        Text(`第 ${this.index + 1} / ${this.total} 题`)
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.s2, right: Theme.space.pageX, top: Theme.space.s4 })

      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Stack({ alignContent: Alignment.Start }) {
            Row()
              .width('100%')
              .height(6)
              .borderRadius(99)
              .backgroundColor(Theme.colors().surfaceSubtle)
            Row()
              .width(`${this.total > 0 ? Math.floor(((this.index + 1) / this.total) * 100) : 0}%`)
              .height(6)
              .borderRadius(99)
              .backgroundColor(Theme.colors().brandAccent)
          }
          .width('100%')
          .height(6)

          Text(this.question.prompt)
            .fontSize(Math.floor(22 * this.fontScale))
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
            .lineHeight(32)

          if (this.toast.length > 0) {
            Text(this.toast)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .width('100%')
          }

          ForEach(this.slots, (slot: OptSlot) => {
            Row({ space: Theme.space.s3 }) {
              if (this.question.visualA.length > 0) {
                ShapeMark({
                  visualKey: KingdomBizService.optionVisual(this.question, slot.index),
                  fillColor: this.question.kind === 'color' ?
                    KingdomBizService.visualColor(KingdomBizService.optionVisual(this.question, slot.index)) :
                    Theme.colors().brandPrimary
                })
              }
              Text(KingdomBizService.optionLabel(this.question, slot.index))
                .fontSize(18)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .layoutWeight(1)
            }
            .width('100%')
            .constraintSize({ minHeight: 56 })
            .padding(Theme.space.s4)
            .borderRadius(20)
            .backgroundColor(this.tone(slot.index))
            .onClick(() => this.choose(slot.index))
          }, (slot: OptSlot) => `opt-${this.question.id}-${slot.index}`)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
