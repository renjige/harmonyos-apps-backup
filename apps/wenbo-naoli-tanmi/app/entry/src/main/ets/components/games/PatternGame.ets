import { Theme } from '../design-system/Theme'

class PatQ {
  stem: string = ''
  options: string[] = []
  answer: string = ''
}

@Component
export struct PatternGame {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State idx: number = 0
  @State correct: number = 0
  @State q: PatQ = new PatQ()
  private bank: PatQ[] = []
  private started: number = 0
  onFinish: (score: number, durationSec: number) => void = (_s: number, _d: number) => {}

  aboutToAppear(): void {
    this.started = Date.now()
    this.bank = PatternGame.createBank()
    this.q = PatternGame.firstQuestion(this.bank)
  }

  private static firstQuestion(bank: PatQ[]): PatQ {
    return PatternGame.questionAt(bank, 0)
  }

  private static questionAt(bank: PatQ[], index: number): PatQ {
    let n = 0
    for (const item of bank) {
      if (n === index) {
        return item
      }
      n++
    }
    return new PatQ()
  }

  private static createBank(): PatQ[] {
    const items: PatQ[] = []
    const add = (stem: string, opts: string[], ans: string) => {
      const q = new PatQ()
      q.stem = stem
      q.options = opts
      q.answer = ans
      items.push(q)
    }
    add('● ○ ● ○ → ?', ['●', '○', '◎', '△'], '●')
    add('▲ ▶ ▼ ▶ → ?', ['▼', '▲', '◀', '●'], '▼')
    add('1 个、2 个、3 个 → ?', ['4 个', '2 个', '6 个', '1 个'], '4 个')
    add('金 → 紫 → 蓝 → ?', ['青', '金', '黑', '紫'], '青')
    add('2 4 8 16 → ?', ['18', '24', '32', '20'], '32')
    add('左上、右上、右下 → ?', ['左下', '中', '右上', '上'], '左下')
    add('奇 偶 奇 偶 → ?', ['奇', '偶', '全', '空'], '奇')
    add('小 中 大 小 → ?', ['中', '大', '小', '空'], '中')
    return items
  }

  private pick(opt: string): void {
    if (opt === this.q.answer) {
      this.correct = this.correct + 1
    }
    if (this.idx + 1 >= this.bank.length) {
      const sec = Math.max(1, Math.round((Date.now() - this.started) / 1000))
      this.onFinish(Math.round((this.correct / 8) * 100), sec)
      return
    }
    this.idx = this.idx + 1
    this.q = PatternGame.questionAt(this.bank, this.idx)
  }

  build() {
    Column({ space: 14 }) {
      Text(`第 ${this.idx + 1} / 8 · 先命名规律再选`)
        .fontSize(14)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Text(this.q.stem)
        .fontSize(22)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .padding({ top: 16, bottom: 16 })
      ForEach(this.q.options, (opt: string) => {
        Text(opt)
          .width('100%')
          .height(48)
          .textAlign(TextAlign.Center)
          .fontSize(16)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(12)
          .margin({ bottom: 8 })
          .onClick(() => this.pick(opt))
      }, (opt: string) => opt)
    }
    .width('100%')
  }
}
