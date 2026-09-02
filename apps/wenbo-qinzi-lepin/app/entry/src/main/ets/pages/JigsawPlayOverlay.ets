import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { BoardSlot, JigsawItem, TrayPiece } from '../models/JigsawModels'
import { JigsawBizService } from '../services/JigsawBizService'
import { JigsawMedia } from '../services/JigsawMedia'
import { JigsawNav } from '../services/JigsawNav'
import { ProgressStore } from '../services/ProgressStore'

@Component
export struct JigsawPlayOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State item: JigsawItem = new JigsawItem()
  @State side: number = 2
  @State cell: number = 72
  @State slots: BoardSlot[] = []
  @State tray: TrayPiece[] = []
  @State selected: number = -1
  @State hintSlot: number = -1
  @State childTurn: boolean = true
  @State collab: boolean = false
  @State done: boolean = false
  @State stars: number = 0
  @State praise: string = ''
  @State toastText: string = ''
  @State hintsUsed: number = 0
  @State placed: number = 0
  private startAt: number = 0
  @StorageLink('jigTick') tick: number = 0

  aboutToAppear(): void {
    this.collab = JigsawNav.collab()
    const pieces = JigsawNav.pieces()
    if (pieces === 16) {
      this.side = 4
    } else if (pieces === 9) {
      this.side = 3
    } else {
      this.side = 2
    }
    this.cell = this.side === 4 ? 52 : (this.side === 3 ? 72 : 100)
    this.startAt = Date.now()
    this.buildBoard()
    void this.reload()
  }

  async reload(): Promise<void> {
    const list = await JigsawBizService.loadJigsaws()
    const found = JigsawBizService.findJigsaw(list, JigsawNav.jigId())
    if (found !== undefined) {
      this.item = found
    }
  }

  private total(): number {
    return this.side * this.side
  }

  private boardPx(): number {
    return this.cell * this.side
  }

  private colOf(index: number): number {
    return index % this.side
  }

  private rowOf(index: number): number {
    return Math.floor(index / this.side)
  }

  private gridTemplate(): string {
    if (this.side === 2) {
      return '1fr 1fr'
    }
    if (this.side === 3) {
      return '1fr 1fr 1fr'
    }
    return '1fr 1fr 1fr 1fr'
  }

  private buildBoard(): void {
    const n = this.total()
    const slots: BoardSlot[] = []
    const tray: TrayPiece[] = []
    const order: number[] = []
    for (let i = 0; i < n; i++) {
      const s = new BoardSlot()
      s.index = i
      s.occupant = -1
      slots.push(s)
      order.push(i)
    }
    for (let i = n - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1))
      const tmp = order[i]
      order[i] = order[j]
      order[j] = tmp
    }
    for (let k = 0; k < n; k++) {
      const p = new TrayPiece()
      p.correctIndex = order[k]
      tray.push(p)
    }
    this.slots = slots
    this.tray = tray
    this.selected = -1
    this.hintSlot = -1
    this.done = false
    this.placed = 0
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 1800)
  }

  private firstEmpty(): number {
    for (const s of this.slots) {
      if (s.occupant < 0) {
        return s.index
      }
    }
    return -1
  }

  private useHint(): void {
    const empty = this.firstEmpty()
    if (empty < 0) {
      return
    }
    this.hintSlot = empty
    this.hintsUsed = this.hintsUsed + 1
    this.showToast('亮起来的格子，就是下一块的家')
  }

  private pickTray(correct: number): void {
    this.selected = correct
  }

  private tryPlace(slotIndex: number): void {
    if (this.done) {
      return
    }
    if (this.selected < 0) {
      this.showToast('先点下面的小块，再点棋盘')
      return
    }
    const slots: BoardSlot[] = []
    let target: BoardSlot = new BoardSlot()
    for (const s of this.slots) {
      const copy = new BoardSlot()
      copy.index = s.index
      copy.occupant = s.occupant
      slots.push(copy)
      if (s.index === slotIndex) {
        target = copy
      }
    }
    if (target.occupant >= 0) {
      this.showToast('这里已经有一块啦')
      return
    }
    if (this.selected !== slotIndex) {
      this.showToast('这块还没到这儿，再看看轮廓')
      this.selected = -1
      return
    }
    target.occupant = this.selected
    const nextTray: TrayPiece[] = []
    for (const p of this.tray) {
      if (p.correctIndex !== this.selected) {
        nextTray.push(p)
      }
    }
    this.slots = slots
    this.tray = nextTray
    this.selected = -1
    this.hintSlot = -1
    this.placed = this.placed + 1
    if (this.collab) {
      this.childTurn = !this.childTurn
    }
    if (this.placed >= this.total()) {
      this.finish()
    } else if (ProgressStore.soundOn()) {
      this.showToast('咔嗒，对上了')
    }
  }

  private finish(): void {
    const duration = Date.now() - this.startAt
    let stars = 1
    if (this.hintsUsed === 0 && duration < this.total() * 8000) {
      stars = 3
    } else if (this.hintsUsed <= 1) {
      stars = 2
    }
    this.stars = stars
    if (stars >= 3) {
      this.praise = '太棒了！'
    } else if (stars === 2) {
      this.praise = '拼得真认真！'
    } else {
      this.praise = '完成啦，真好！'
    }
    this.done = true
    void ProgressStore.recordComplete(
      this.item.id,
      this.item.title,
      this.item.themeLabel,
      this.total(),
      stars,
      duration,
      this.hintsUsed,
      this.collab,
      this.item.coverKey
    )
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column({ space: 6 }) {
        Row() {
          Text('返回')
            .fontSize(16)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .onClick(() => { JigsawNav.close() })
          Text(this.item.title)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .maxLines(1)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
          Text(`${this.placed}/${this.total()}`)
            .fontSize(14)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8 })

        if (this.collab) {
          Text(this.childTurn ? '孩子回合 · 橙色' : '家长回合 · 蓝色')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.childTurn ? Theme.colors().brandPrimary : Theme.colors().brandAccent)
        }

        Grid() {
          ForEach(this.slots, (s: BoardSlot) => {
            GridItem() {
              this.SlotCell(s)
            }
          }, (s: BoardSlot) => `s-${s.index}-${s.occupant}`)
        }
        .columnsTemplate(this.gridTemplate())
        .rowsGap(3)
        .columnsGap(3)
        .width(this.boardPx() + 8)
        .height(this.boardPx() + 8)

        Text('点小块，再点棋盘上的家 · 块多时请上下滑')
          .fontSize(13)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)

        Scroll() {
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Center }) {
            ForEach(this.tray, (p: TrayPiece) => {
              this.TrayCell(p)
            }, (p: TrayPiece) => `t-${p.correctIndex}`)
          }
          .width('100%')
          .padding({ left: 8, right: 8, bottom: 16 })
        }
        .layoutWeight(1)
        .width('100%')
        .align(Alignment.Top)
        .scrollBar(BarState.Auto)
        .edgeEffect(EdgeEffect.Spring)
        .constraintSize({ minHeight: 120 })

        Row({ space: 10 }) {
          AppButton({
            label: '智慧提示',
            variant: 'secondary',
            onTap: (): void => { this.useHint() }
          })
          AppButton({
            label: '重开',
            variant: 'secondary',
            onTap: (): void => {
              this.hintsUsed = 0
              this.startAt = Date.now()
              this.childTurn = true
              this.buildBoard()
            }
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 4, bottom: 12 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.done) {
        Column({ space: 14 }) {
          Text(this.praise)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Text(`${this.stars} 颗星`)
            .fontSize(28)
            .fontColor('#FFD56A')
          AppButton({
            label: '再拼一幅',
            onTap: (): void => { JigsawNav.setRoute(JigsawNav.THEME) }
          })
          AppButton({
            label: '返回详情',
            variant: 'secondary',
            onTap: (): void => { JigsawNav.setRoute(JigsawNav.DETAIL) }
          })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('rgba(42,36,28,0.78)')
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(14)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(999)
          .margin({ top: 56 })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  SlotCell(s: BoardSlot) {
    Stack() {
      if (s.occupant >= 0) {
        this.PieceThumb(s.occupant)
      } else {
        Column()
          .width(this.cell)
          .height(this.cell)
          .backgroundColor(s.index === this.hintSlot ?
            Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
      }
    }
    .width(this.cell)
    .height(this.cell)
    .borderRadius(8)
    .border({
      width: s.index === this.hintSlot ? 3 : 1,
      color: s.index === this.hintSlot ? Theme.colors().brandPrimary : Theme.colors().strokeStrong
    })
    .clip(true)
    .onClick(() => { this.tryPlace(s.index) })
  }

  @Builder
  TrayCell(p: TrayPiece) {
    Stack() {
      this.PieceThumb(p.correctIndex)
    }
    .width(this.cell)
    .height(this.cell)
    .margin(4)
    .borderRadius(8)
    .border({
      width: 3,
      color: (this.selected === p.correctIndex || this.hintSlot === p.correctIndex) ?
        Theme.colors().brandPrimary : 'transparent'
    })
    .scale({ x: this.selected === p.correctIndex ? 1.04 : 1, y: this.selected === p.correctIndex ? 1.04 : 1 })
    .clip(true)
    .onClick(() => { this.pickTray(p.correctIndex) })
  }

  @Builder
  PieceThumb(correctIndex: number) {
    Stack() {
      Image(JigsawMedia.cover(this.item.coverKey))
        .width(this.boardPx())
        .height(this.boardPx())
        .objectFit(ImageFit.Cover)
        .position({
          x: -this.colOf(correctIndex) * this.cell,
          y: -this.rowOf(correctIndex) * this.cell
        })
    }
    .width(this.cell)
    .height(this.cell)
    .clip(true)
  }
}
