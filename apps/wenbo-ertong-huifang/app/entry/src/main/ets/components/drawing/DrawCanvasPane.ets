import { Theme } from '../design-system/Theme'
import { DrawStroke, DrawPoint } from '../../models/DrawModels'
import { LineArtCatalog } from '../../services/LineArtCatalog'
import { BrushRenderer } from '../../services/BrushRenderer'

@Component
export struct DrawCanvasPane {
  @Link @Watch('onStrokesLinked') strokes: DrawStroke[]
  @Prop @Watch('onReloadTickChange') reloadTick: number = 0
  @Prop currentColor: string = '#FF8A65'
  @Prop brushId: string = 'crayon'
  @Prop sizeKey: string = 'mid'
  @Prop eraserOn: boolean = false
  @Prop regionMode: boolean = false
  @Prop canvasW: number = 360
  @Prop canvasH: number = 480
  onStrokeFinished: (stroke: DrawStroke) => void = () => {}

  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  private drawing: boolean = false
  private active: DrawStroke = new DrawStroke()
  private canvasReady: boolean = false

  onStrokesLinked(): void {
    if (this.canvasReady) {
      this.redrawAll(this.drawing ? this.active : null)
    }
  }

  onReloadTickChange(): void {
    if (this.canvasReady) {
      this.redrawAll(this.drawing ? this.active : null)
    }
  }

  private widthPx(): number {
    return LineArtCatalog.brushWidth(this.sizeKey)
  }

  private redrawAll(activeStroke: DrawStroke | null): void {
    this.context.clearRect(0, 0, this.canvasW, this.canvasH)
    this.context.fillStyle = '#FFFFFF'
    this.context.fillRect(0, 0, this.canvasW, this.canvasH)
    if (this.regionMode) {
      this.context.strokeStyle = '#4A4A4A'
      this.context.lineWidth = 3
      this.context.strokeRect(24, 24, this.canvasW - 48, this.canvasH - 48)
      this.context.beginPath()
      this.context.arc(this.canvasW * 0.35, this.canvasH * 0.38, 48, 0, Math.PI * 2)
      this.context.stroke()
      this.context.strokeRect(this.canvasW * 0.55, this.canvasH * 0.25, 80, 100)
    }
    for (const s of this.strokes) {
      BrushRenderer.paint(this.context, s, this.canvasW, this.canvasH)
    }
    if (activeStroke !== null && activeStroke.points.length > 0) {
      BrushRenderer.paint(this.context, activeStroke, this.canvasW, this.canvasH)
    }
  }

  private cloneStroke(src: DrawStroke): DrawStroke {
    const s = new DrawStroke()
    s.id = src.id
    s.color = src.color
    s.width = src.width
    s.tool = src.tool
    s.eraser = src.eraser
    const pts: DrawPoint[] = []
    for (const p of src.points) {
      const c = new DrawPoint()
      c.x = p.x
      c.y = p.y
      pts.push(c)
    }
    s.points = pts
    return s
  }

  private clonePoints(src: DrawPoint[]): DrawPoint[] {
    const out: DrawPoint[] = []
    for (const p of src) {
      const c = new DrawPoint()
      c.x = p.x
      c.y = p.y
      out.push(c)
    }
    return out
  }

  private handleTouch(event: TouchEvent): void {
    if (event.touches.length === 0) {
      return
    }
    const tx = event.touches[0].x
    const ty = event.touches[0].y
    if (event.type === TouchType.Down) {
      this.drawing = true
      this.active = new DrawStroke()
      this.active.color = this.currentColor
      this.active.width = this.widthPx()
      this.active.eraser = this.eraserOn
      this.active.tool = this.brushId
      const p = new DrawPoint()
      p.x = tx
      p.y = ty
      this.active.points = [p]
      this.redrawAll(this.active)
    } else if (event.type === TouchType.Move && this.drawing) {
      const p = new DrawPoint()
      p.x = tx
      p.y = ty
      const pts = this.clonePoints(this.active.points)
      pts.push(p)
      this.active.points = pts
      this.redrawAll(this.active)
    } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
      if (this.drawing && this.active.points.length > 0) {
        const finished = this.cloneStroke(this.active)
        this.onStrokeFinished(finished)
      }
      this.drawing = false
      this.active = new DrawStroke()
      this.redrawAll(null)
    }
  }

  build() {
    Canvas(this.context)
      .width('100%')
      .height('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius(Theme.radius.lg)
      .onReady(() => {
        this.canvasReady = true
        this.redrawAll(null)
      })
      .onTouch((event: TouchEvent) => {
        this.handleTouch(event)
      })
  }
}
