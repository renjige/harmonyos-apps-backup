import { Theme } from '../design-system/Theme'
import { ArtworkItem, DrawStroke, DrawPoint, FillRegion, StickerPlacement } from '../../models/DrawModels'
import { BrushRenderer } from '../../services/BrushRenderer'
import { LineArtOutline } from '../../services/LineArtOutline'
import { StickerCatalog } from '../../services/StickerCatalog'

@Component
export struct ArtworkPreview {
  @Prop item: ArtworkItem = new ArtworkItem()
  @Prop @Watch('onPaint') reloadTick: number = 0
  @Prop previewW: number = 120
  @Prop previewH: number = 120

  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  private ready: boolean = false

  onPaint(): void {
    if (this.ready) {
      this.redraw()
    }
  }

  private parseStrokes(raw: string): DrawStroke[] {
    const out: DrawStroke[] = []
    if (raw.length === 0) {
      return out
    }
    try {
      const arr = JSON.parse(raw) as DrawStroke[]
      for (const s of arr) {
        const stroke = new DrawStroke()
        stroke.id = s.id !== undefined && s.id.length > 0 ? s.id : ''
        stroke.tool = s.tool !== undefined ? s.tool : 'crayon'
        stroke.color = s.color !== undefined ? s.color : '#FF8A65'
        stroke.width = s.width !== undefined ? s.width : 8
        stroke.eraser = s.eraser === true
        const pts: DrawPoint[] = []
        if (s.points !== undefined) {
          for (const p of s.points) {
            const dp = new DrawPoint()
            dp.x = p.x
            dp.y = p.y
            pts.push(dp)
          }
        }
        stroke.points = pts
        out.push(stroke)
      }
    } catch {
      return out
    }
    return out
  }

  private parseRegions(raw: string): FillRegion[] {
    const out: FillRegion[] = []
    if (raw.length === 0) {
      return out
    }
    try {
      const arr = JSON.parse(raw) as FillRegion[]
      for (const r of arr) {
        const copy = new FillRegion()
        copy.id = r.id !== undefined ? r.id : ''
        copy.x = r.x
        copy.y = r.y
        copy.w = r.w
        copy.h = r.h
        copy.shape = r.shape !== undefined ? r.shape : 'rect'
        copy.fillColor = r.fillColor !== undefined ? r.fillColor : '#FFFFFF'
        out.push(copy)
      }
    } catch {
      return out
    }
    return out
  }

  private parseStickers(raw: string): StickerPlacement[] {
    const out: StickerPlacement[] = []
    if (raw.length === 0) {
      return out
    }
    try {
      const arr = JSON.parse(raw) as StickerPlacement[]
      for (const s of arr) {
        const copy = new StickerPlacement()
        copy.id = s.id !== undefined ? s.id : ''
        copy.stickerId = s.stickerId !== undefined ? s.stickerId : 'st_star'
        copy.nx = s.nx
        copy.ny = s.ny
        copy.color = s.color !== undefined ? s.color : '#FFD54F'
        copy.sizeKey = s.sizeKey !== undefined ? s.sizeKey : 'mid'
        out.push(copy)
      }
    } catch {
      return out
    }
    return out
  }

  private redraw(): void {
    this.context.clearRect(0, 0, this.previewW, this.previewH)
    this.context.fillStyle = '#FFFFFF'
    this.context.fillRect(0, 0, this.previewW, this.previewH)

    if (this.item.kind === 'sticker') {
      const stickers = this.parseStickers(this.item.strokeData)
      for (const s of stickers) {
        const cx = s.nx * this.previewW
        const cy = s.ny * this.previewH
        const r = StickerCatalog.sizeRadius(s.sizeKey, 36 * (this.previewW / 360))
        StickerCatalog.drawSticker(this.context, s.stickerId, cx, cy, r, s.color)
      }
    } else if (this.item.kind === 'fill') {
      const regions = this.parseRegions(this.item.fillData)
      for (const r of regions) {
        const x = r.x * this.previewW
        const y = r.y * this.previewH
        const rw = r.w * this.previewW
        const rh = r.h * this.previewH
        this.context.fillStyle = r.fillColor
        if (r.shape === 'ellipse') {
          this.context.beginPath()
          this.context.ellipse(x + rw / 2, y + rh / 2, rw / 2, rh / 2, 0, 0, Math.PI * 2)
          this.context.fill()
        } else {
          this.context.fillRect(x, y, rw, rh)
        }
      }
      LineArtOutline.drawOutline(this.context, this.item.lineArtId, this.previewW, this.previewH)
    } else {
      const strokes = this.parseStrokes(this.item.strokeData)
      const scaleX = this.previewW / 360
      const scaleY = this.previewH / 480
      for (const s of strokes) {
        const scaled = new DrawStroke()
        scaled.tool = s.tool
        scaled.color = s.color
        scaled.width = s.width * Math.min(scaleX, scaleY)
        scaled.eraser = s.eraser
        const pts: DrawPoint[] = []
        for (const p of s.points) {
          const dp = new DrawPoint()
          dp.x = p.x * scaleX
          dp.y = p.y * scaleY
          pts.push(dp)
        }
        scaled.points = pts
        BrushRenderer.paint(this.context, scaled, this.previewW, this.previewH)
      }
    }
  }

  build() {
    Canvas(this.context)
      .width(this.previewW)
      .height(this.previewH)
      .borderRadius(Theme.radius.md)
      .backgroundColor('#FFFFFF')
      .onReady(() => {
        this.ready = true
        this.redraw()
      })
  }
}
