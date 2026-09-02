import { Theme } from '../design-system/Theme'

class StroopRound {
  word: string = ''
  ink: string = ''
  inkName: string = ''
}

@Component
export struct StroopGame {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State round: number = 0
  @State correct: number = 0
  @State current: StroopRound = new StroopRound()
  @State done: boolean = false
  private started: number = 0
  onFinish: (score: number, durationSec: number) => void = (_s: number, _d: number) => {}

  aboutToAppear(): void {
    this.started = Date.now()
    this.nextRound()
  }

  private nextRound(): void {
    if (this.round >= 15) {
      this.finish()
      return
    }
    const words: string[] = ['红', '蓝', '绿', '金']
    const inks: string[] = ['#E11D48', '#2563EB', '#059669', '#F5A623']
    const names: string[] = ['红', '蓝', '绿', '金']
    const w = Math.abs(Date.now() + this.round * 13) % 4
    let c = Math.abs(Date.now() + this.round * 29) % 4
    if (c === w) {
      c = (c + 1) % 4
    }
    const r = new StroopRound()
    r.word = words[w]
    r.ink = inks[c]
    r.inkName = names[c]
    this.current = r
    this.round = this.round + 1
  }

  private choose(name: string): void {
    if (this.done) {
      return
    }
    if (name === this.current.inkName) {
      this.correct = this.correct + 1
    }
    this.nextRound()
  }

  private finish(): void {
    this.done = true
    const sec = Math.max(1, Math.round((Date.now() - this.started) / 1000))
    const score = Math.round((this.correct / 15) * 100)
    this.onFinish(score, sec)
  }

  build() {
    Column({ space: 16 }) {
      Text(`第 ${this.round} / 15 题 · 选墨色不选字义`)
        .fontSize(14)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Text(this.current.word)
        .fontSize(48)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.current.ink)
        .width('100%')
        .textAlign(TextAlign.Center)
        .padding({ top: 24, bottom: 24 })
      Row({ space: 10 }) {
        this.ColorBtn('红', '#E11D48')
        this.ColorBtn('蓝', '#2563EB')
      }
      Row({ space: 10 }) {
        this.ColorBtn('绿', '#059669')
        this.ColorBtn('金', '#F5A623')
      }
    }
    .width('100%')
  }

  @Builder
  ColorBtn(name: string, color: string) {
    Text(name)
      .layoutWeight(1)
      .height(48)
      .textAlign(TextAlign.Center)
      .fontSize(16)
      .fontColor('#FFFFFF')
      .backgroundColor(color)
      .borderRadius(12)
      .onClick(() => this.choose(name))
  }
}
