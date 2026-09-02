import { Theme } from '../design-system/Theme'
import { DotPoint, DrawStroke } from '../../models/DrawModels'
import { BrushRenderer } from '../../services/BrushRenderer'

/** 圆点半径 + 画布内边距，保证数字不被裁切 */
const DOT_RADIUS: number = 24
const CANVAS_MARGIN: number = 36

@Component
export struct WorkshopDotLinkPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onPaint') strokes: DrawStroke[] = []
  @Prop @Watch('onPaint') reloadTick: number = 0
  @Prop dots: DotPoint[] = []
  @Prop nextDotId: number = 1
  onDotTap: (dotId: number) => void = () => {}
  onWrongTap: () => void = () => {}
  onCanvasLayout: (width: number, height: number) => void = () => {}

  @State layoutW: number = 320
  @State layoutH: number = 360

  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  private ready: boolean = false

  onPaint(): void {
    if (this.ready) {
      this.redraw()
    }
  }

  private pxX(nx: number): number {
    const inner = this.layoutW - CANVAS_MARGIN * 2
    return CANVAS_MARGIN + nx * inner
  }

  private pxY(ny: number): number {
    const inner = this.layoutH - CANVAS_MARGIN * 2
    return CANVAS_MARGIN + ny * inner
  }

  private applyLayout(w: number, h: number): void {
    if (w <= 0 || h <= 0) {
      return
    }
    if (Math.abs(w - this.layoutW) < 1 && Math.abs(h - this.layoutH) < 1) {
      return
    }
    this.layoutW = w
    this.layoutH = h
    this.onCanvasLayout(w, h)
    if (this.ready) {
      this.redraw()
    }
  }

  private redraw(): void {
    const w = this.layoutW
    const h = this.layoutH
    this.context.clearRect(0, 0, w, h)
    this.context.fillStyle = '#FFF8F0'
    this.context.fillRect(0, 0, w, h)
    this.context.strokeStyle = '#FFE0B2'
    this.context.lineWidth = 2
    this.context.strokeRect(CANVAS_MARGIN, CANVAS_MARGIN, w - CANVAS_MARGIN * 2, h - CANVAS_MARGIN * 2)
    for (const s of this.strokes) {
      BrushRenderer.paint(this.context, s, w, h)
    }
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Canvas(this.context)
        .width('100%')
        .height('100%')
        .borderRadius(Theme.radius.lg)
        .onReady(() => {
          this.ready = true
          this.redraw()
        })

      ForEach(this.dots, (d: DotPoint) => {
        Column() {
          Text(`${d.id}`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(d.linked ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
        }
        .width(DOT_RADIUS * 2)
        .height(DOT_RADIUS * 2)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(d.linked ? Theme.colors().brandPrimary :
          (d.id === this.nextDotId ? Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle))
        .borderRadius(DOT_RADIUS)
        .border({
          width: d.id === this.nextDotId ? 2 : 1,
          color: d.id === this.nextDotId ? Theme.colors().brandPrimary : Theme.colors().strokeHairline
        })
        .position({
          x: this.pxX(d.nx) - DOT_RADIUS,
          y: this.pxY(d.ny) - DOT_RADIUS
        })
        .zIndex(10)
        .onClick((): void => {
          if (d.id === this.nextDotId) {
            this.onDotTap(d.id)
          } else if (!d.linked) {
            this.onWrongTap()
          }
        })
      }, (d: DotPoint) => `${d.id}_${this.layoutW}_${this.layoutH}`)
    }
    .width('100%')
    .height('100%')
    .clip(false)
    .onAreaChange((_old: Area, area: Area) => {
      this.applyLayout(area.width as number, area.height as number)
    })
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
