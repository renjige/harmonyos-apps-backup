import { Theme } from '../design-system/Theme'

class MathQ {
  text: string = ''
  options: string[] = []
  answer: string = ''
}

@Component
export struct MathGame {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State idx: number = 0
  @State correct: number = 0
  @State q: MathQ = new MathQ()
  @State remain: number = 8
  private bank: MathQ[] = []
  private started: number = 0
  private timer: number = -1
  onFinish: (score: number, durationSec: number) => void = (_s: number, _d: number) => {}

  aboutToAppear(): void {
    this.started = Date.now()
    this.bank = MathGame.buildBank()
    this.show(0)
    this.tick()
  }

  aboutToDisappear(): void {
    if (this.timer >= 0) {
      clearInterval(this.timer)
      this.timer = -1
    }
  }

  private static buildBank(): MathQ[] {
    const out: MathQ[] = []
    const pairs: number[][] = [
      [17, 8, 1], [12, 9, 1], [23, 6, 0], [15, 7, 0], [6, 7, 2],
      [8, 8, 2], [19, 4, 0], [14, 5, 1], [9, 6, 2], [21, 8, 0],
      [11, 9, 1], [7, 8, 2]
    ]
    for (const p of pairs) {
      const q = new MathQ()
      if (p[2] === 0) {
        q.text = `${p[0]} − ${p[1]}`
        q.answer = `${p[0] - p[1]}`
      } else if (p[2] === 1) {
        q.text = `${p[0]} + ${p[1]}`
        q.answer = `${p[0] + p[1]}`
      } else {
        q.text = `${p[0]} × ${p[1]}`
        q.answer = `${p[0] * p[1]}`
      }
      const ans = Number(q.answer)
      q.options = [`${ans}`, `${ans + 2}`, `${ans - 3}`, `${ans + 5}`]
      out.push(q)
    }
    return out
  }

  private tick(): void {
    this.timer = setInterval(() => {
      if (this.remain <= 1) {
        this.pick('__timeout')
        return
      }
      this.remain = this.remain - 1
    }, 1000)
  }

  private show(i: number): void {
    if (i >= this.bank.length) {
      this.end()
      return
    }
    this.idx = i
    this.q = this.bank[i]
    this.remain = 8
  }

  private pick(opt: string): void {
    if (opt === this.q.answer) {
      this.correct = this.correct + 1
    }
    this.show(this.idx + 1)
  }

  private end(): void {
    if (this.timer >= 0) {
      clearInterval(this.timer)
      this.timer = -1
    }
    const sec = Math.max(1, Math.round((Date.now() - this.started) / 1000))
    this.onFinish(Math.round((this.correct / 12) * 100), sec)
  }

  build() {
    Column({ space: 14 }) {
      Text(`第 ${this.idx + 1} / 12 · 剩余 ${this.remain} 秒`)
        .fontSize(14)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Text(this.q.text)
        .fontSize(40)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .textAlign(TextAlign.Center)
        .padding({ top: 12, bottom: 12 })
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.q.options, (opt: string) => {
          Text(opt)
            .width('47%')
            .height(48)
            .margin({ bottom: 10, right: '3%' })
            .textAlign(TextAlign.Center)
            .fontSize(18)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(12)
            .onClick(() => this.pick(opt))
        }, (opt: string) => opt)
      }
      .width('100%')
    }
    .width('100%')
  }
}
