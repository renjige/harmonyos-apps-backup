import { DrawPoint, DrawStroke } from '../models/DrawModels'

/** 各笔刷视觉参数 — 宽度倍率 / 透明度 / 叠层 */
export class BrushStyle {
  tool: string = 'crayon'
  widthMul: number = 1
  alpha: number = 1
  layers: number = 1
  jitter: number = 0
  dotGrain: boolean = false
  squareCap: boolean = false
  softEdge: boolean = false
}

export class BrushRenderer {
  static styleFor(tool: string): BrushStyle {
    const s = new BrushStyle()
    s.tool = tool
    if (tool === 'water') {
      s.widthMul = 2.4
      s.alpha = 0.22
      s.layers = 3
      s.softEdge = true
      return s
    }
    if (tool === 'marker') {
      s.widthMul = 1.5
      s.alpha = 1
      s.layers = 1
      return s
    }
    if (tool === 'chalk') {
      s.widthMul = 1.3
      s.alpha = 0.42
      s.layers = 1
      s.dotGrain = true
      return s
    }
    if (tool === 'brush') {
      s.widthMul = 1.8
      s.alpha = 0.38
      s.layers = 4
      s.softEdge = true
      return s
    }
    s.widthMul = 1.1
    s.alpha = 0.88
    s.layers = 2
    s.jitter = 1.2
    return s
  }

  static paint(
    ctx: CanvasRenderingContext2D,
    stroke: DrawStroke,
    canvasW: number,
    canvasH: number
  ): void {
    if (stroke.points.length === 0) {
      return
    }
    if (stroke.eraser) {
      BrushRenderer.paintEraser(ctx, stroke)
      return
    }
    if (stroke.tool === 'thumb') {
      BrushRenderer.paintThumb(ctx, stroke)
      return
    }
    if (stroke.tool.startsWith('stamp_')) {
      BrushRenderer.paintStamp(ctx, stroke)
      return
    }
    if (stroke.tool === 'marble') {
      BrushRenderer.paintMarble(ctx, stroke)
      return
    }
    const style = BrushRenderer.styleFor(stroke.tool)
    const baseW = stroke.width * style.widthMul

    if (style.dotGrain) {
      BrushRenderer.paintChalk(ctx, stroke, baseW, style.alpha)
      return
    }

    for (let layer = 0; layer < style.layers; layer++) {
      const layerAlpha = style.softEdge ?
        style.alpha * (1 - layer * 0.22) :
        style.alpha * (layer === 0 ? 1 : 0.45)
      const layerW = style.softEdge ? baseW * (1 + layer * 0.15) : baseW
      const offset = style.jitter > 0 && layer > 0 ?
        (layer % 2 === 0 ? style.jitter : -style.jitter) : 0

      ctx.beginPath()
      ctx.lineCap = 'round'
      ctx.lineJoin = 'round'
      ctx.lineWidth = layerW
      ctx.globalCompositeOperation = 'source-over'
      ctx.strokeStyle = stroke.color
      ctx.globalAlpha = layerAlpha

      let isFirst = true
      for (const p of stroke.points) {
        if (isFirst) {
          ctx.moveTo(p.x + offset, p.y - offset * 0.5)
          isFirst = false
        } else {
          ctx.lineTo(p.x + offset, p.y - offset * 0.5)
        }
      }
      ctx.stroke()
    }

    ctx.globalAlpha = 1
    ctx.globalCompositeOperation = 'source-over'
  }

  private static paintThumb(ctx: CanvasRenderingContext2D, stroke: DrawStroke): void {
    ctx.fillStyle = stroke.color
    ctx.globalAlpha = 0.75
    for (const p of stroke.points) {
      ctx.beginPath()
      ctx.arc(p.x, p.y, stroke.width * 0.5, 0, Math.PI * 2)
      ctx.fill()
      ctx.beginPath()
      ctx.arc(p.x - 4, p.y - 4, stroke.width * 0.28, 0, Math.PI * 2)
      ctx.globalAlpha = 0.35
      ctx.fill()
      ctx.globalAlpha = 0.75
    }
    ctx.globalAlpha = 1
  }

  private static paintStamp(ctx: CanvasRenderingContext2D, stroke: DrawStroke): void {
    const shape = stroke.tool.replace('stamp_', '')
    const size = stroke.width
    ctx.fillStyle = stroke.color
    ctx.globalAlpha = 0.88
    for (const p of stroke.points) {
      if (shape === 'square') {
        ctx.fillRect(p.x - size * 0.5, p.y - size * 0.5, size, size)
      } else if (shape === 'triangle') {
        ctx.beginPath()
        ctx.moveTo(p.x, p.y - size * 0.5)
        ctx.lineTo(p.x + size * 0.5, p.y + size * 0.4)
        ctx.lineTo(p.x - size * 0.5, p.y + size * 0.4)
        ctx.closePath()
        ctx.fill()
      } else if (shape === 'star') {
        BrushRenderer.fillStar(ctx, p.x, p.y, size * 0.5)
      } else {
        ctx.beginPath()
        ctx.arc(p.x, p.y, size * 0.5, 0, Math.PI * 2)
        ctx.fill()
      }
    }
    ctx.globalAlpha = 1
  }

  private static fillStar(ctx: CanvasRenderingContext2D, cx: number, cy: number, r: number): void {
    ctx.beginPath()
    for (let i = 0; i < 5; i++) {
      const a = (Math.PI * 2 * i) / 5 - Math.PI / 2
      const x = cx + Math.cos(a) * r
      const y = cy + Math.sin(a) * r
      if (i === 0) {
        ctx.moveTo(x, y)
      } else {
        ctx.lineTo(x, y)
      }
      const a2 = a + Math.PI / 5
      ctx.lineTo(cx + Math.cos(a2) * r * 0.45, cy + Math.sin(a2) * r * 0.45)
    }
    ctx.closePath()
    ctx.fill()
  }

  private static paintMarble(ctx: CanvasRenderingContext2D, stroke: DrawStroke): void {
    ctx.beginPath()
    ctx.lineCap = 'round'
    ctx.lineJoin = 'round'
    ctx.lineWidth = stroke.width
    ctx.strokeStyle = stroke.color
    ctx.globalAlpha = 0.65
    let isFirst = true
    for (const p of stroke.points) {
      if (isFirst) {
        ctx.moveTo(p.x, p.y)
        isFirst = false
      } else {
        ctx.lineTo(p.x, p.y)
      }
    }
    ctx.stroke()
    ctx.globalAlpha = 1
  }

  private static paintChalk(
    ctx: CanvasRenderingContext2D,
    stroke: DrawStroke,
    dotR: number,
    alpha: number
  ): void {
    ctx.fillStyle = stroke.color
    ctx.globalAlpha = alpha
    const step = Math.max(3, dotR * 0.55)
    let idx = 0
    let prev: DrawPoint | null = null
    for (const p of stroke.points) {
      const seed = (idx * 17 + Math.floor(p.x) * 3) % 7
      const jx = (seed - 3) * 0.9
      const jy = ((seed * 2) % 5 - 2) * 0.9
      const r = dotR * (0.35 + (seed % 3) * 0.12)
      ctx.beginPath()
      ctx.arc(p.x + jx, p.y + jy, r, 0, Math.PI * 2)
      ctx.fill()
      if (prev !== null) {
        const dx = p.x - prev.x
        const dy = p.y - prev.y
        const dist = Math.sqrt(dx * dx + dy * dy)
        const n = Math.floor(dist / step)
        for (let k = 1; k < n; k++) {
          const t = k / n
          const sx = prev.x + dx * t + jx
          const sy = prev.y + dy * t + jy
          ctx.beginPath()
          ctx.arc(sx, sy, r * 0.85, 0, Math.PI * 2)
          ctx.fill()
        }
      }
      prev = p
      idx += 1
    }
    ctx.globalAlpha = 1
  }

  private static paintEraser(ctx: CanvasRenderingContext2D, stroke: DrawStroke): void {
    if (stroke.points.length < 2) {
      return
    }
    ctx.beginPath()
    ctx.lineCap = 'round'
    ctx.lineJoin = 'round'
    ctx.lineWidth = stroke.width * 2.2
    ctx.globalCompositeOperation = 'destination-out'
    ctx.strokeStyle = 'rgba(0,0,0,1)'
    ctx.globalAlpha = 1
    let isFirst = true
    for (const p of stroke.points) {
      if (isFirst) {
        ctx.moveTo(p.x, p.y)
        isFirst = false
      } else {
        ctx.lineTo(p.x, p.y)
      }
    }
    ctx.stroke()
    ctx.globalCompositeOperation = 'source-over'
  }
}
