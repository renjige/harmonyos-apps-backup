import { Theme } from '../design-system/Theme'
import { DrawCanvasPane } from './DrawCanvasPane'
import { ColorPaletteBar } from './ColorPaletteBar'
import { DrawStroke, BrushDef, ArtworkItem, DrawPoint } from '../../models/DrawModels'
import { LineArtCatalog } from '../../services/LineArtCatalog'
import { GalleryStore } from '../../services/GalleryStore'
import { PrivacySaveDialog } from './PrivacySaveDialog'

/** 状态栏 + 顶部留白，避免按钮贴顶无法点击 */
const TOP_SAFE: number = 44

@Component
export struct FreeDrawOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop visible: boolean = false
  onClose: () => void = () => {}
  onSaved: () => void = () => {}

  @State strokes: DrawStroke[] = []
  @State undoStack: DrawStroke[][] = []
  @State redoStack: DrawStroke[][] = []
  @State canvasTick: number = 0
  @State color: string = '#FF8A65'
  @State brushId: string = 'crayon'
  @State sizeKey: string = 'mid'
  @State eraser: boolean = false
  @State showClearConfirm: boolean = false
  @State showPrivacy: boolean = false
  @State toast: string = ''
  /** 顶部：撤销/重做/清空 是否展开 */
  @State topToolsOpen: boolean = false
  /** 底部：笔刷/粗细/颜色 是否展开 */
  @State bottomToolsOpen: boolean = false

  private canvasW: number = 360
  private canvasH: number = 480

  private currentBrushLabel(): string {
    if (this.eraser) {
      return '橡皮'
    }
    for (const b of LineArtCatalog.brushes()) {
      if (b.id === this.brushId) {
        return b.label
      }
    }
    return '画笔'
  }

  private showToast(message: string): void {
    this.toast = message
    setTimeout(() => { this.toast = '' }, 2600)
  }

  private cloneStrokeList(src: DrawStroke[]): DrawStroke[] {
    const out: DrawStroke[] = []
    for (const s of src) {
      const copy = new DrawStroke()
      copy.id = s.id
      copy.color = s.color
      copy.width = s.width
      copy.tool = s.tool
      copy.eraser = s.eraser
      const pts: DrawPoint[] = []
      for (const p of s.points) {
        const dp = new DrawPoint()
        dp.x = p.x
        dp.y = p.y
        pts.push(dp)
      }
      copy.points = pts
      out.push(copy)
    }
    return out
  }

  private bumpCanvas(): void {
    this.canvasTick += 1
  }

  private handleStrokeFinished(stroke: DrawStroke): void {
    stroke.id = GalleryStore.newId('stroke')
    const snap = this.cloneStrokeList(this.strokes)
    const undoNext: DrawStroke[][] = []
    for (const u of this.undoStack) {
      undoNext.push(u)
    }
    undoNext.push(snap)
    if (undoNext.length > 20) {
      undoNext.shift()
    }
    this.undoStack = undoNext
    this.redoStack = []

    const next: DrawStroke[] = []
    for (const s of this.strokes) {
      next.push(s)
    }
    next.push(stroke)
    this.strokes = next
    this.bumpCanvas()
  }

  private handleUndo(): void {
    if (this.undoStack.length === 0) {
      this.showToast('没有可撤销的步骤')
      return
    }
    const redoSnap = this.cloneStrokeList(this.strokes)
    const redoNext: DrawStroke[][] = []
    for (const r of this.redoStack) {
      redoNext.push(r)
    }
    redoNext.push(redoSnap)
    this.redoStack = redoNext

    const prev = this.undoStack[this.undoStack.length - 1]
    this.strokes = this.cloneStrokeList(prev)
    const undoNext: DrawStroke[][] = []
    for (let i = 0; i < this.undoStack.length - 1; i++) {
      undoNext.push(this.undoStack[i])
    }
    this.undoStack = undoNext
    this.bumpCanvas()
    this.showToast('已撤销')
  }

  private handleRedo(): void {
    if (this.redoStack.length === 0) {
      this.showToast('没有可重做的步骤')
      return
    }
    const undoSnap = this.cloneStrokeList(this.strokes)
    const undoNext: DrawStroke[][] = []
    for (const u of this.undoStack) {
      undoNext.push(u)
    }
    undoNext.push(undoSnap)
    this.undoStack = undoNext

    const nextState = this.redoStack[this.redoStack.length - 1]
    this.strokes = this.cloneStrokeList(nextState)
    const redoNext: DrawStroke[][] = []
    for (let i = 0; i < this.redoStack.length - 1; i++) {
      redoNext.push(this.redoStack[i])
    }
    this.redoStack = redoNext
    this.bumpCanvas()
    this.showToast('已重做')
  }

  private handleClearRequest(): void {
    this.showClearConfirm = true
  }

  private handleClearConfirm(): void {
    if (this.strokes.length > 0) {
      const snap = this.cloneStrokeList(this.strokes)
      const undoNext: DrawStroke[][] = []
      for (const u of this.undoStack) {
        undoNext.push(u)
      }
      undoNext.push(snap)
      this.undoStack = undoNext
    }
    this.strokes = []
    this.redoStack = []
    this.showClearConfirm = false
    this.bumpCanvas()
    this.showToast('画布已清空')
  }

  private handleSave(): void {
    if (this.strokes.length === 0) {
      this.showToast('请先画点什么再保存')
      return
    }
    if (!GalleryStore.privacyAccepted()) {
      this.showPrivacy = true
      return
    }
    void this.persistWork()
  }

  private async persistWork(): Promise<void> {
    if (this.strokes.length === 0) {
      this.showToast('暂无内容可保存')
      return
    }
    const item = new ArtworkItem()
    item.id = GalleryStore.newId('art')
    item.title = `涂鸦 ${GalleryStore.todayLabel()}`
    item.kind = 'free'
    item.createdAt = GalleryStore.todayLabel()
    item.strokeData = JSON.stringify(this.strokes)
    item.accentColor = this.color
    await GalleryStore.addArtwork(item)
    this.showToast('已保存到画廊')
    this.onSaved()
    setTimeout(() => { this.onClose() }, 600)
  }

  build() {
    if (!this.visible) {
      Column()
        .width(0)
        .height(0)
        .hitTestBehavior(HitTestMode.None)
    } else {
      Stack({ alignContent: Alignment.Top }) {
        Column() {
          Column({ space: Theme.space.s2 }) {
            Row({ space: Theme.space.s2 }) {
              Button('返回')
                .height(36)
                .fontSize(14)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.onClose() })

              Button(this.topToolsOpen ? '收起编辑 ▲' : '编辑工具 ▼')
                .height(36)
                .fontSize(13)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .backgroundColor(Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .layoutWeight(1)
                .onClick((): void => { this.topToolsOpen = !this.topToolsOpen })

              Button('保存')
                .height(36)
                .fontSize(14)
                .fontColor(Theme.colors().brandOnPrimary)
                .backgroundColor(Theme.colors().brandPrimary)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.handleSave() })
            }
            .width('100%')

            if (this.topToolsOpen) {
              Row({ space: Theme.space.s2 }) {
                Button('撤销')
                  .height(36)
                  .fontSize(14)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.pill)
                  .layoutWeight(1)
                  .onClick((): void => { this.handleUndo() })

                Button('重做')
                  .height(36)
                  .fontSize(14)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.pill)
                  .layoutWeight(1)
                  .onClick((): void => { this.handleRedo() })

                Button('清空')
                  .height(36)
                  .fontSize(14)
                  .fontColor(Theme.colors().danger)
                  .backgroundColor(Theme.colors().dangerContainer)
                  .borderRadius(Theme.radius.pill)
                  .layoutWeight(1)
                  .onClick((): void => { this.handleClearRequest() })
              }
              .width('100%')
            }
          }
          .width('100%')
          .padding({
            left: Theme.space.s3,
            right: Theme.space.s3,
            top: TOP_SAFE,
            bottom: Theme.space.s2
          })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

          Column() {
            DrawCanvasPane({
              strokes: $strokes,
              reloadTick: this.canvasTick,
              currentColor: this.color,
              brushId: this.brushId,
              sizeKey: this.sizeKey,
              eraserOn: this.eraser,
              canvasW: this.canvasW,
              canvasH: this.canvasH,
              onStrokeFinished: (stroke: DrawStroke): void => { this.handleStrokeFinished(stroke) }
            })
          }
          .layoutWeight(1)
          .width('100%')
          .padding({ left: Theme.space.s2, right: Theme.space.s2, bottom: Theme.space.s2 })

          Column({ space: Theme.space.s2 }) {
            if (this.bottomToolsOpen) {
              Scroll() {
                Row({ space: Theme.space.s2 }) {
                  ForEach(LineArtCatalog.brushes(), (b: BrushDef) => {
                    Button(b.label)
                      .height(36)
                      .fontSize(13)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                      .backgroundColor(this.brushId === b.id && !this.eraser ?
                        Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
                      .borderRadius(Theme.radius.pill)
                      .onClick((): void => { this.brushId = b.id; this.eraser = false })
                  })
                  Button('橡皮')
                    .height(36)
                    .fontSize(13)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .backgroundColor(this.eraser ? Theme.colors().warningContainer : Theme.colors().surfaceSubtle)
                    .borderRadius(Theme.radius.pill)
                    .onClick((): void => { this.eraser = true })
                }
                .padding({ left: Theme.space.s3, right: Theme.space.s3 })
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              .height(44)

              Row({ space: Theme.space.s2 }) {
                ForEach(['thin', 'mid', 'thick'], (k: string) => {
                  Button(k === 'thin' ? '细' : (k === 'thick' ? '粗' : '中'))
                    .height(36)
                    .fontSize(13)
                    .fontColor(this.sizeKey === k ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                    .backgroundColor(this.sizeKey === k ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                    .borderRadius(Theme.radius.pill)
                    .layoutWeight(1)
                    .onClick((): void => { this.sizeKey = k })
                })
              }
              .padding({ left: Theme.space.s3, right: Theme.space.s3 })

              ColorPaletteBar({
                picked: this.color,
                onPick: (hex: string): void => { this.color = hex }
              })
            }

            Row({ space: Theme.space.s3 }) {
              Circle()
                .width(28)
                .height(28)
                .fill(this.color)
                .stroke(Theme.colors().strokeHairline)
                .strokeWidth(1)

              Text(this.currentBrushLabel())
                .fontSize(Theme.type.bodyM)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .layoutWeight(1)

              Button(this.bottomToolsOpen ? '收起画笔 ▲' : '画笔工具 ▼')
                .height(36)
                .fontSize(13)
                .fontColor(Theme.colors().brandOnPrimary)
                .backgroundColor(Theme.colors().brandPrimary)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.bottomToolsOpen = !this.bottomToolsOpen })
            }
            .width('100%')
            .padding({
              left: Theme.space.s3,
              right: Theme.space.s3,
              top: Theme.space.s2,
              bottom: Theme.space.s3
            })
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
          }
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

        if (this.showClearConfirm) {
          Stack() {
            Column()
              .width('100%')
              .height('100%')
              .backgroundColor(Theme.colors().overlayScrim)
              .onClick((): void => { this.showClearConfirm = false })

            Column({ space: Theme.space.s4 }) {
              Text('确定清空画布吗？')
                .fontSize(Theme.type.titleM)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Row({ space: Theme.space.s3 }) {
                Row() {
                  Text('取消').fontSize(15)
                }
                .height(44)
                .layoutWeight(1)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.showClearConfirm = false })

                Row() {
                  Text('清空').fontSize(15).fontColor('#FFFFFF')
                }
                .height(44)
                .layoutWeight(1)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(Theme.colors().danger)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.handleClearConfirm() })
              }
              .width('100%')
            }
            .width('82%')
            .padding(Theme.space.s6)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.xl)
          }
          .width('100%')
          .height('100%')
          .zIndex(50)
        }

        PrivacySaveDialog({
          visible: this.showPrivacy,
          onAccepted: (): void => { void this.persistWork(); this.showPrivacy = false },
          onCancel: (): void => { this.showPrivacy = false }
        })

        if (this.toast.length > 0) {
          Text(this.toast)
            .fontSize(14)
            .fontColor('#FFFFFF')
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandDeep)
            .borderRadius(Theme.radius.pill)
            .margin({ top: TOP_SAFE + 52 })
            .zIndex(80)
        }
      }
      .width('100%')
      .height('100%')
    }
  }
}
