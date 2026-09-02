import { Theme } from '../design-system/Theme'

class MemCard {
  idx: number = 0
  pairId: number = 0
  label: string = ''
  open: boolean = false
  done: boolean = false
}

@Component
export struct MemoryGame {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State cards: MemCard[] = []
  @State first: number = -1
  @State lock: boolean = false
  @State moves: number = 0
  @State remain: number = 6
  private started: number = 0
  onFinish: (score: number, durationSec: number) => void = (_s: number, _d: number) => {}

  aboutToAppear(): void {
    this.started = Date.now()
    this.cards = MemoryGame.createDeck()
  }

  private static makeCard(idx: number, pairId: number, label: string): MemCard {
    const c = new MemCard()
    c.idx = idx
    c.pairId = pairId
    c.label = label
    return c
  }

  private static cloneCard(src: MemCard): MemCard {
    const c = new MemCard()
    c.idx = src.idx
    c.pairId = src.pairId
    c.label = src.label
    c.open = src.open
    c.done = src.done
    return c
  }

  /** 固定打乱顺序，避免 ArkTS 下标取数导致牌面文字丢失 */
  private static createDeck(): MemCard[] {
    const out: MemCard[] = []
    out.push(MemoryGame.makeCard(0, 0, '星'))
    out.push(MemoryGame.makeCard(1, 2, '川'))
    out.push(MemoryGame.makeCard(2, 1, '月'))
    out.push(MemoryGame.makeCard(3, 4, '火'))
    out.push(MemoryGame.makeCard(4, 3, '石'))
    out.push(MemoryGame.makeCard(5, 5, '云'))
    out.push(MemoryGame.makeCard(6, 1, '月'))
    out.push(MemoryGame.makeCard(7, 0, '星'))
    out.push(MemoryGame.makeCard(8, 5, '云'))
    out.push(MemoryGame.makeCard(9, 3, '石'))
    out.push(MemoryGame.makeCard(10, 4, '火'))
    out.push(MemoryGame.makeCard(11, 2, '川'))
    return out
  }

  private cardAt(index: number): MemCard {
    for (const c of this.cards) {
      if (c.idx === index) {
        return c
      }
    }
    return new MemCard()
  }

  private patch(idA: number, openA: boolean, doneA: boolean, idB: number, openB: boolean, doneB: boolean): void {
    const next: MemCard[] = []
    for (const src of this.cards) {
      const copy = MemoryGame.cloneCard(src)
      if (copy.idx === idA) {
        copy.open = openA
        copy.done = doneA
      } else if (idB >= 0 && copy.idx === idB) {
        copy.open = openB
        copy.done = doneB
      }
      next.push(copy)
    }
    this.cards = next
  }

  private tap(card: MemCard): void {
    if (this.lock || card.done || card.open) {
      return
    }
    const id = card.idx
    this.patch(id, true, false, -1, false, false)
    if (this.first < 0) {
      this.first = id
      return
    }
    this.moves = this.moves + 1
    const prev = this.cardAt(this.first)
    const cur = this.cardAt(id)
    if (prev.pairId === cur.pairId && prev.label === cur.label && prev.label.length > 0) {
      this.patch(this.first, true, true, id, true, true)
      this.remain = this.remain - 1
      this.first = -1
      if (this.remain <= 0) {
        const sec = Math.max(1, Math.round((Date.now() - this.started) / 1000))
        this.onFinish(Math.max(40, 100 - this.moves * 3 - Math.floor(sec / 8)), sec)
      }
      return
    }
    this.lock = true
    const firstId = this.first
    setTimeout(() => {
      this.patch(firstId, false, false, id, false, false)
      this.first = -1
      this.lock = false
    }, 800)
  }

  private face(c: MemCard): string {
    if (c.open || c.done) {
      return c.label
    }
    return '探'
  }

  private faceColor(c: MemCard): string {
    if (c.done || c.open) {
      return Theme.colors().brandAccent
    }
    return Theme.colors().brandPrimary
  }

  private tileBg(c: MemCard): string {
    if (c.done) {
      return Theme.colors().brandPrimaryContainer
    }
    if (c.open) {
      return '#1E2A4A'
    }
    return '#243056'
  }

  build() {
    Column({ space: 12 }) {
      Text('点按两张牌：相同汉字即锁定。背面「探」是牌背，翻开才见星象字。')
        .fontSize(13)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Text(`剩余 ${this.remain} 对 · 尝试 ${this.moves} 次`)
        .fontSize(14)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.cards, (c: MemCard) => {
          Column() {
            Text(this.face(c))
              .fontSize(c.open || c.done ? 28 : 20)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.faceColor(c))
          }
          .width('30%')
          .height(88)
          .margin({ bottom: 10, right: '3%' })
          .justifyContent(FlexAlign.Center)
          .borderRadius(14)
          .backgroundColor(this.tileBg(c))
          .border({
            width: 1,
            color: c.open || c.done ? Theme.colors().brandAccent : Theme.colors().brandPrimary
          })
          .onClick(() => this.tap(c))
        }, (c: MemCard) => `m${c.idx}-${c.open}-${c.done}`)
      }
      .width('100%')
    }
    .width('100%')
  }
}
