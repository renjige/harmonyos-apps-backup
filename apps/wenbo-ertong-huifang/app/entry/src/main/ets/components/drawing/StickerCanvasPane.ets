import { Theme } from '../design-system/Theme'
import { StickerPlacement } from '../../models/DrawModels'
import { StickerCatalog } from '../../services/StickerCatalog'

const BASE_RADIUS: number = 36

@Component
export struct StickerCanvasPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onDataChange') items: StickerPlacement[] = []
  @Prop @Watch('onDataChange') reloadTick: number = 0
  onTapCanvas: (nx: number, ny: number) => void = () => {}

  @State layoutW: number = 320
  @State layoutH: number = 400

  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  private ready: boolean = false

  onDataChange(): void {
    if (this.ready) {
      this.redraw()
    }
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
    this.context.fillStyle = '#FFFFFF'
    this.context.fillRect(12, 12, w - 24, h - 24)
    this.context.strokeStyle = '#FFE0B2'
    this.context.lineWidth = 2
    this.context.strokeRect(12, 12, w - 24, h - 24)

    for (const item of this.items) {
      const cx = item.nx * w
      const cy = item.ny * h
      const r = StickerCatalog.sizeRadius(item.sizeKey, BASE_RADIUS * (w / 360))
      StickerCatalog.drawSticker(this.context, item.stickerId, cx, cy, r, item.color)
    }
  }

  build() {
    Canvas(this.context)
      .width('100%')
      .height('100%')
      .borderRadius(Theme.radius.lg)
      .border({ width: 2, color: Theme.colors().strokeHairline })
      .onReady(() => {
        this.ready = true
        this.redraw()
      })
      .onTouch((event: TouchEvent) => {
        if (event.type === TouchType.Down && event.touches.length > 0) {
          const tx = event.touches[0].x
          const ty = event.touches[0].y
          if (this.layoutW > 0 && this.layoutH > 0) {
            const nx = tx / this.layoutW
            const ny = ty / this.layoutH
            this.onTapCanvas(nx, ny)
          }
        }
      })
      .onAreaChange((_old: Area, area: Area) => {
        this.applyLayout(area.width as number, area.height as number)
      })
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
