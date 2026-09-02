import { Theme } from '../design-system/Theme'
import { FillRegion } from '../../models/DrawModels'
import { LineArtOutline } from '../../services/LineArtOutline'

const CANVAS_MARGIN: number = 8

@Component
export struct FillCanvasPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onDataChange') regions: FillRegion[] = []
  @Prop @Watch('onDataChange') lineArtId: string = ''
  @Prop @Watch('onDataChange') reloadTick: number = 0
  @Prop pickedColor: string = '#FF8A65'
  onRegionsChange: (next: FillRegion[]) => void = () => {}
  onColorHint: (zh: string, en: string) => void = () => {}

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

  private regionRect(r: FillRegion): RegionRect {
    const out = new RegionRect()
    out.x = r.x * this.layoutW
    out.y = r.y * this.layoutH
    out.w = r.w * this.layoutW
    out.h = r.h * this.layoutH
    return out
  }

  private fillRegion(ctx: CanvasRenderingContext2D, r: FillRegion): void {
    const box = this.regionRect(r)
    const color = r.fillColor.length > 0 ? r.fillColor : '#FFFFFF'
    ctx.fillStyle = color
    if (r.shape === 'ellipse') {
      ctx.beginPath()
      ctx.ellipse(box.x + box.w / 2, box.y + box.h / 2, box.w / 2, box.h / 2, 0, 0, Math.PI * 2)
      ctx.fill()
    } else {
      ctx.fillRect(box.x, box.y, box.w, box.h)
    }
  }

  private redraw(): void {
    const w = this.layoutW
    const h = this.layoutH
    this.context.clearRect(0, 0, w, h)
    this.context.fillStyle = '#FFFDF8'
    this.context.fillRect(0, 0, w, h)
    this.context.fillStyle = '#F5F0E8'
    this.context.fillRect(CANVAS_MARGIN, CANVAS_MARGIN, w - CANVAS_MARGIN * 2, h - CANVAS_MARGIN * 2)
    for (const r of this.regions) {
      this.fillRegion(this.context, r)
    }
    LineArtOutline.drawOutline(this.context, this.lineArtId, w, h)
  }

  private hitRegion(tx: number, ty: number): FillRegion | null {
    for (let i = this.regions.length - 1; i >= 0; i--) {
      const r = this.regions[i]
      const box = this.regionRect(r)
      if (r.shape === 'ellipse') {
        const cx = box.x + box.w / 2
        const cy = box.y + box.h / 2
        const nx = (tx - cx) / (box.w / 2)
        const ny = (ty - cy) / (box.h / 2)
        if (nx * nx + ny * ny <= 1) {
          return r
        }
      } else if (tx >= box.x && tx <= box.x + box.w && ty >= box.y && ty <= box.y + box.h) {
        return r
      }
    }
    return null
  }

  private fillAt(tx: number, ty: number): void {
    const hit = this.hitRegion(tx, ty)
    if (hit === null) {
      return
    }
    const next: FillRegion[] = []
    for (const r of this.regions) {
      const copy = new FillRegion()
      copy.id = r.id
      copy.x = r.x
      copy.y = r.y
      copy.w = r.w
      copy.h = r.h
      copy.shape = r.shape
      copy.colorHintZh = r.colorHintZh
      copy.colorHintEn = r.colorHintEn
      copy.fillColor = r.id === hit.id ? this.pickedColor : r.fillColor
      next.push(copy)
    }
    this.onRegionsChange(next)
    this.onColorHint(hit.colorHintZh, hit.colorHintEn)
  }

  build() {
    Stack() {
      Canvas(this.context)
        .width('100%')
        .height('100%')
        .backgroundColor('#FFFDF8')
        .borderRadius(Theme.radius.lg)
        .border({ width: 2, color: Theme.colors().strokeHairline })
        .onReady(() => {
          this.ready = true
          this.redraw()
        })
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down && event.touches.length > 0) {
            this.fillAt(event.touches[0].x, event.touches[0].y)
          }
        })
    }
    .width('100%')
    .height('100%')
    .onAreaChange((_old: Area, area: Area) => {
      this.applyLayout(area.width as number, area.height as number)
    })
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}

class RegionRect {
  x: number = 0
  y: number = 0
  w: number = 0
  h: number = 0
}
