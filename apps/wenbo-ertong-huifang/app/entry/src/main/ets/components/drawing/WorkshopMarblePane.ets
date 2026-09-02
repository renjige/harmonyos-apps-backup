import { Theme } from '../design-system/Theme'
import { DrawStroke, DrawPoint } from '../../models/DrawModels'
import { BrushRenderer } from '../../services/BrushRenderer'

@Component
export struct WorkshopMarblePane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Link strokes: DrawStroke[]
  @Prop @Watch('onPaint') reloadTick: number = 0
  @Prop color: string = '#4FC3F7'
  @Prop canvasW: number = 360
  @Prop canvasH: number = 480

  @State ballX: number = 180
  @State ballY: number = 240
  private dragging: boolean = false
  private trail: DrawStroke = new DrawStroke()
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  private ready: boolean = false

  onPaint(): void {
    if (this.ready) {
      this.redraw()
    }
  }

  private redraw(): void {
    this.context.clearRect(0, 0, this.canvasW, this.canvasH)
    this.context.fillStyle = '#FFF8F0'
    this.context.fillRect(0, 0, this.canvasW, this.canvasH)
    for (const s of this.strokes) {
      BrushRenderer.paint(this.context, s, this.canvasW, this.canvasH)
    }
    if (this.dragging && this.trail.points.length > 0) {
      BrushRenderer.paint(this.context, this.trail, this.canvasW, this.canvasH)
    }
    this.context.beginPath()
    this.context.fillStyle = this.color
    this.context.globalAlpha = 0.95
    this.context.arc(this.ballX, this.ballY, 18, 0, Math.PI * 2)
    this.context.fill()
    this.context.globalAlpha = 1
    this.context.strokeStyle = '#FFFFFF'
    this.context.lineWidth = 2
    this.context.stroke()
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

  private finishTrail(): void {
    if (this.trail.points.length < 2) {
      this.trail = new DrawStroke()
      return
    }
    const finished = new DrawStroke()
    finished.tool = 'marble'
    finished.color = this.color
    finished.width = 10
    finished.points = this.clonePoints(this.trail.points)
    const next: DrawStroke[] = []
    for (const s of this.strokes) {
      next.push(s)
    }
    next.push(finished)
    this.strokes = next
    this.trail = new DrawStroke()
  }

  private handleTouch(event: TouchEvent): void {
    if (event.touches.length === 0) {
      return
    }
    const tx = event.touches[0].x
    const ty = event.touches[0].y
    if (event.type === TouchType.Down) {
      const dx = tx - this.ballX
      const dy = ty - this.ballY
      if (dx * dx + dy * dy <= 28 * 28) {
        this.dragging = true
        this.trail = new DrawStroke()
        this.trail.tool = 'marble'
        this.trail.color = this.color
        this.trail.width = 10
        const p = new DrawPoint()
        p.x = this.ballX
        p.y = this.ballY
        this.trail.points = [p]
      }
    } else if (event.type === TouchType.Move && this.dragging) {
      this.ballX = tx
      this.ballY = ty
      const pts = this.clonePoints(this.trail.points)
      const p = new DrawPoint()
      p.x = tx
      p.y = ty
      pts.push(p)
      this.trail.points = pts
      this.redraw()
    } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
      if (this.dragging) {
        this.finishTrail()
        this.dragging = false
        this.redraw()
      }
    }
  }

  build() {
    Column({ space: Theme.space.s2 }) {
      Text('按住小滚珠拖动，留下彩色轨迹')
        .fontSize(Theme.type.bodyM)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .padding({ left: Theme.space.s2 })

      Canvas(this.context)
        .width('100%')
        .layoutWeight(1)
        .backgroundColor('#FFF8F0')
        .borderRadius(Theme.radius.lg)
        .onReady(() => {
          this.ready = true
          this.ballX = this.canvasW * 0.5
          this.ballY = this.canvasH * 0.5
          this.redraw()
        })
        .onTouch((event: TouchEvent) => {
          this.handleTouch(event)
        })
    }
    .width('100%')
    .height('100%')
  }
}
