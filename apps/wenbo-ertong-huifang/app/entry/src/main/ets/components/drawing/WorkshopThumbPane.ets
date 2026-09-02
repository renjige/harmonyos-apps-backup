import { Theme } from '../design-system/Theme'
import { DrawStroke, DrawPoint } from '../../models/DrawModels'
import { BrushRenderer } from '../../services/BrushRenderer'

@Component
export struct WorkshopThumbPane {
  @Link strokes: DrawStroke[]
  @Prop @Watch('onPaint') reloadTick: number = 0
  @Prop color: string = '#FF8A65'
  @Prop canvasW: number = 360
  @Prop canvasH: number = 480
  onStamp: () => void = () => {}

  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  private ready: boolean = false

  onPaint(): void {
    if (this.ready) {
      this.redraw(null)
    }
  }

  private redraw(active: DrawStroke | null): void {
    this.context.clearRect(0, 0, this.canvasW, this.canvasH)
    this.context.fillStyle = '#FFFFFF'
    this.context.fillRect(0, 0, this.canvasW, this.canvasH)
    for (const s of this.strokes) {
      BrushRenderer.paint(this.context, s, this.canvasW, this.canvasH)
    }
    if (active !== null) {
      BrushRenderer.paint(this.context, active, this.canvasW, this.canvasH)
    }
  }

  private addThumb(tx: number, ty: number): void {
    const s = new DrawStroke()
    s.tool = 'thumb'
    s.color = this.color
    s.width = 32
    const p = new DrawPoint()
    p.x = tx
    p.y = ty
    s.points = [p]
    const next: DrawStroke[] = []
    for (const st of this.strokes) {
      next.push(st)
    }
    next.push(s)
    this.strokes = next
    this.onStamp()
    this.redraw(null)
  }

  build() {
    Canvas(this.context)
      .width('100%')
      .height('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius(Theme.radius.lg)
      .onReady(() => {
        this.ready = true
        this.redraw(null)
      })
      .onTouch((event: TouchEvent) => {
        if (event.touches.length === 0) {
          return
        }
        if (event.type === TouchType.Down) {
          this.addThumb(event.touches[0].x, event.touches[0].y)
        }
      })
  }
}
