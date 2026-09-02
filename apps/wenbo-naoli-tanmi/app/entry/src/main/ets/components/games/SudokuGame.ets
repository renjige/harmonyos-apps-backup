import { Theme } from '../design-system/Theme'

class SudokuCell {
  idx: number = 0
  value: number = 0
  given: boolean = false
}

@Component
export struct SudokuGame {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State cells: SudokuCell[] = []
  @State pick: number = -1
  @State hint: string = ''
  private started: number = 0
  onFinish: (score: number, durationSec: number) => void = (_s: number, _d: number) => {}

  aboutToAppear(): void {
    this.started = Date.now()
    this.cells = SudokuGame.createBoard()
  }

  private static createBoard(): SudokuCell[] {
    const src: number[] = [
      1, 0, 3, 0, 5, 6,
      0, 5, 6, 1, 0, 3,
      2, 3, 0, 5, 6, 0,
      5, 0, 4, 2, 0, 1,
      3, 1, 0, 6, 4, 0,
      0, 4, 5, 0, 1, 2
    ]
    const list: SudokuCell[] = []
    let idx = 0
    for (const v of src) {
      const c = new SudokuCell()
      c.idx = idx
      c.value = v
      c.given = v > 0
      list.push(c)
      idx++
    }
    return list
  }

  private static answers(): number[] {
    return [
      1, 2, 3, 4, 5, 6,
      4, 5, 6, 1, 2, 3,
      2, 3, 1, 5, 6, 4,
      5, 6, 4, 2, 3, 1,
      3, 1, 2, 6, 4, 5,
      6, 4, 5, 3, 1, 2
    ]
  }

  private selectedGiven(): boolean {
    for (const c of this.cells) {
      if (c.idx === this.pick) {
        return c.given
      }
    }
    return true
  }

  private put(n: number): void {
    if (this.pick < 0) {
      this.hint = '请先点选一个空格，再点下方数字'
      return
    }
    if (this.selectedGiven()) {
      this.hint = '这是题目给定格，请换一个空格'
      return
    }
    const next: SudokuCell[] = []
    for (const src of this.cells) {
      const c = new SudokuCell()
      c.idx = src.idx
      c.value = src.value
      c.given = src.given
      if (c.idx === this.pick && !c.given) {
        c.value = n
      }
      next.push(c)
    }
    this.cells = next
    this.hint = ''
  }

  private clearPick(): void {
    this.put(0)
  }

  private check(): void {
    const ans = SudokuGame.answers()
    let ok = 0
    let pos = 0
    for (const expect of ans) {
      let got = 0
      for (const c of this.cells) {
        if (c.idx === pos) {
          got = c.value
        }
      }
      if (got === expect) {
        ok++
      }
      pos++
    }
    if (ok < 36) {
      this.hint = `还有 ${36 - ok} 格未对齐，再检查行列与宫`
      return
    }
    const sec = Math.max(1, Math.round((Date.now() - this.started) / 1000))
    this.onFinish(Math.max(50, 100 - Math.floor(sec / 12)), sec)
  }

  build() {
    Column({ space: 10 }) {
      Text('先点空格（会亮紫），再点 1–6 填入。每行、每列、每宫不重复。')
        .fontSize(13)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.cells, (c: SudokuCell) => {
          Text(c.value > 0 ? `${c.value}` : '')
            .width('15.5%')
            .height(44)
            .margin({ bottom: 4, right: '1%' })
            .textAlign(TextAlign.Center)
            .fontSize(18)
            .fontWeight(c.given ? FontWeight.Medium : FontWeight.Regular)
            .fontColor(c.given ? Theme.colors().textSecondary : Theme.colors().textPrimary)
            .backgroundColor(this.pick === c.idx ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
            .borderRadius(6)
            .onClick(() => {
              if (!c.given) {
                this.pick = c.idx
                this.hint = ''
              }
            })
        }, (c: SudokuCell) => `s${c.idx}-${c.value}-${this.pick}`)
      }
      .width('100%')
      Row({ space: 8 }) {
        this.PadBtn(1)
        this.PadBtn(2)
        this.PadBtn(3)
        this.PadBtn(4)
        this.PadBtn(5)
        this.PadBtn(6)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      Text('清除此格')
        .fontSize(14)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .padding({ left: 14, right: 14, top: 10, bottom: 10 })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(10)
        .onClick(() => this.clearPick())
      if (this.hint.length > 0) {
        Text(this.hint).fontSize(13).fontColor(Theme.colors().brandAccent).width('100%')
      }
      Text('核验通关')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().brandOnPrimary)
        .backgroundColor(Theme.colors().brandPrimary)
        .borderRadius(12)
        .padding({ left: 20, right: 20, top: 12, bottom: 12 })
        .onClick(() => this.check())
    }
    .width('100%')
  }

  @Builder
  PadBtn(n: number) {
    Column() {
      Text(`${n}`)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
    }
    .width(48)
    .height(48)
    .justifyContent(FlexAlign.Center)
    .borderRadius(24)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .border({ width: 1, color: Theme.colors().brandPrimary })
    .onClick(() => this.put(n))
  }
}
