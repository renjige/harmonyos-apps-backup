import { StickerDef } from '../models/DrawModels'

/** 魔法贴纸库 — Canvas 绘制，不依赖图片资源 */
export class StickerCatalog {
  static categories(): string[] {
    return ['cute', 'nature', 'space']
  }

  static categoryLabel(key: string): string {
    if (key === 'nature') {
      return '自然'
    }
    if (key === 'space') {
      return '太空'
    }
    return '可爱'
  }

  static stickers(): StickerDef[] {
    const list: StickerDef[] = []
    list.push(StickerCatalog.make('st_star', '星星', 'space', '#FFD54F'))
    list.push(StickerCatalog.make('st_moon', '月亮', 'space', '#FFF9C4'))
    list.push(StickerCatalog.make('st_rocket', '火箭', 'space', '#4FC3F7'))
    list.push(StickerCatalog.make('st_planet', '星球', 'space', '#BA68C8'))
    list.push(StickerCatalog.make('st_sun', '太阳', 'nature', '#FFD54F'))
    list.push(StickerCatalog.make('st_cloud', '云朵', 'nature', '#FFFFFF'))
    list.push(StickerCatalog.make('st_flower', '小花', 'nature', '#F06292'))
    list.push(StickerCatalog.make('st_leaf', '树叶', 'nature', '#81C784'))
    list.push(StickerCatalog.make('st_heart', '爱心', 'cute', '#F06292'))
    list.push(StickerCatalog.make('st_face', '笑脸', 'cute', '#FF8A65'))
    list.push(StickerCatalog.make('st_butterfly', '蝴蝶', 'cute', '#BA68C8'))
    list.push(StickerCatalog.make('st_fish', '小鱼', 'cute', '#4FC3F7'))
    return list
  }

  static byCategory(cat: string): StickerDef[] {
    const out: StickerDef[] = []
    for (const s of StickerCatalog.stickers()) {
      if (s.category === cat) {
        out.push(s)
      }
    }
    return out
  }

  static find(id: string): StickerDef | null {
    for (const s of StickerCatalog.stickers()) {
      if (s.id === id) {
        return s
      }
    }
    return null
  }

  static sizeRadius(key: string, base: number): number {
    if (key === 'small') {
      return base * 0.65
    }
    if (key === 'large') {
      return base * 1.35
    }
    return base
  }

  static drawSticker(
    ctx: CanvasRenderingContext2D, stickerId: string, cx: number, cy: number, radius: number, color: string
  ): void {
    ctx.save()
    ctx.lineCap = 'round'
    ctx.lineJoin = 'round'
    ctx.strokeStyle = '#3D3D3D'
    ctx.lineWidth = Math.max(2, radius * 0.08)
    if (stickerId === 'st_star') {
      StickerCatalog.drawStar(ctx, cx, cy, radius, color)
    } else if (stickerId === 'st_moon') {
      StickerCatalog.drawMoon(ctx, cx, cy, radius, color)
    } else if (stickerId === 'st_rocket') {
      StickerCatalog.drawRocket(ctx, cx, cy, radius, color)
    } else if (stickerId === 'st_planet') {
      StickerCatalog.drawPlanet(ctx, cx, cy, radius, color)
    } else if (stickerId === 'st_sun') {
      StickerCatalog.drawSun(ctx, cx, cy, radius, color)
    } else if (stickerId === 'st_cloud') {
      StickerCatalog.drawCloud(ctx, cx, cy, radius, color)
    } else if (stickerId === 'st_flower') {
      StickerCatalog.drawFlower(ctx, cx, cy, radius, color)
    } else if (stickerId === 'st_leaf') {
      StickerCatalog.drawLeaf(ctx, cx, cy, radius, color)
    } else if (stickerId === 'st_heart') {
      StickerCatalog.drawHeart(ctx, cx, cy, radius, color)
    } else if (stickerId === 'st_face') {
      StickerCatalog.drawFace(ctx, cx, cy, radius, color)
    } else if (stickerId === 'st_butterfly') {
      StickerCatalog.drawButterfly(ctx, cx, cy, radius, color)
    } else if (stickerId === 'st_fish') {
      StickerCatalog.drawFish(ctx, cx, cy, radius, color)
    }
    ctx.restore()
  }

  private static make(id: string, label: string, category: string, color: string): StickerDef {
    const s = new StickerDef()
    s.id = id
    s.label = label
    s.category = category
    s.defaultColor = color
    return s
  }

  private static fillStroke(ctx: CanvasRenderingContext2D, color: string): void {
    ctx.fillStyle = color
    ctx.fill()
    ctx.stroke()
  }

  private static drawStar(ctx: CanvasRenderingContext2D, cx: number, cy: number, r: number, color: string): void {
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
    StickerCatalog.fillStroke(ctx, color)
  }

  private static drawMoon(ctx: CanvasRenderingContext2D, cx: number, cy: number, r: number, color: string): void {
    ctx.beginPath()
    ctx.arc(cx, cy, r, 0, Math.PI * 2)
    ctx.fillStyle = color
    ctx.fill()
    ctx.stroke()
    ctx.fillStyle = '#FFFDF8'
    ctx.beginPath()
    ctx.arc(cx + r * 0.35, cy - r * 0.1, r * 0.72, 0, Math.PI * 2)
    ctx.fill()
  }

  private static drawRocket(ctx: CanvasRenderingContext2D, cx: number, cy: number, r: number, color: string): void {
    ctx.beginPath()
    ctx.moveTo(cx, cy - r)
    ctx.lineTo(cx + r * 0.45, cy + r * 0.2)
    ctx.lineTo(cx + r * 0.45, cy + r * 0.85)
    ctx.lineTo(cx - r * 0.45, cy + r * 0.85)
    ctx.lineTo(cx - r * 0.45, cy + r * 0.2)
    ctx.closePath()
    StickerCatalog.fillStroke(ctx, color)
    ctx.beginPath()
    ctx.moveTo(cx - r * 0.45, cy + r * 0.55)
    ctx.lineTo(cx - r * 0.75, cy + r * 0.85)
    ctx.lineTo(cx - r * 0.45, cy + r * 0.85)
    ctx.fillStyle = '#EF5350'
    ctx.fill()
    ctx.stroke()
    ctx.beginPath()
    ctx.moveTo(cx + r * 0.45, cy + r * 0.55)
    ctx.lineTo(cx + r * 0.75, cy + r * 0.85)
    ctx.lineTo(cx + r * 0.45, cy + r * 0.85)
    ctx.fillStyle = '#EF5350'
    ctx.fill()
    ctx.stroke()
    ctx.beginPath()
    ctx.arc(cx, cy - r * 0.15, r * 0.18, 0, Math.PI * 2)
    ctx.fillStyle = '#FFFFFF'
    ctx.fill()
    ctx.stroke()
  }

  private static drawPlanet(ctx: CanvasRenderingContext2D, cx: number, cy: number, r: number, color: string): void {
    ctx.beginPath()
    ctx.arc(cx, cy, r * 0.75, 0, Math.PI * 2)
    StickerCatalog.fillStroke(ctx, color)
    ctx.beginPath()
    ctx.ellipse(cx, cy, r * 1.1, r * 0.35, 0.3, 0, Math.PI * 2)
    ctx.stroke()
  }

  private static drawSun(ctx: CanvasRenderingContext2D, cx: number, cy: number, r: number, color: string): void {
    ctx.beginPath()
    ctx.arc(cx, cy, r * 0.55, 0, Math.PI * 2)
    StickerCatalog.fillStroke(ctx, color)
    for (let i = 0; i < 8; i++) {
      const a = (Math.PI * 2 * i) / 8
      ctx.beginPath()
      ctx.moveTo(cx + Math.cos(a) * r * 0.65, cy + Math.sin(a) * r * 0.65)
      ctx.lineTo(cx + Math.cos(a) * r, cy + Math.sin(a) * r)
      ctx.stroke()
    }
    ctx.fillStyle = '#3D3D3D'
    ctx.beginPath()
    ctx.arc(cx - r * 0.2, cy - r * 0.08, r * 0.07, 0, Math.PI * 2)
    ctx.arc(cx + r * 0.2, cy - r * 0.08, r * 0.07, 0, Math.PI * 2)
    ctx.fill()
    ctx.beginPath()
    ctx.arc(cx, cy + r * 0.15, r * 0.22, 0.2 * Math.PI, 0.8 * Math.PI)
    ctx.stroke()
  }

  private static drawCloud(ctx: CanvasRenderingContext2D, cx: number, cy: number, r: number, color: string): void {
    ctx.beginPath()
    ctx.arc(cx - r * 0.45, cy, r * 0.45, 0, Math.PI * 2)
    ctx.arc(cx, cy - r * 0.25, r * 0.55, 0, Math.PI * 2)
    ctx.arc(cx + r * 0.5, cy, r * 0.48, 0, Math.PI * 2)
    ctx.arc(cx + r * 0.1, cy + r * 0.15, r * 0.42, 0, Math.PI * 2)
    StickerCatalog.fillStroke(ctx, color)
  }

  private static drawFlower(ctx: CanvasRenderingContext2D, cx: number, cy: number, r: number, color: string): void {
    for (let i = 0; i < 5; i++) {
      const a = (Math.PI * 2 * i) / 5
      ctx.beginPath()
      ctx.arc(cx + Math.cos(a) * r * 0.45, cy + Math.sin(a) * r * 0.45, r * 0.32, 0, Math.PI * 2)
      ctx.fillStyle = color
      ctx.fill()
      ctx.stroke()
    }
    ctx.beginPath()
    ctx.arc(cx, cy, r * 0.22, 0, Math.PI * 2)
    ctx.fillStyle = '#FFD54F'
    ctx.fill()
    ctx.stroke()
  }

  private static drawLeaf(ctx: CanvasRenderingContext2D, cx: number, cy: number, r: number, color: string): void {
    ctx.beginPath()
    ctx.moveTo(cx, cy - r)
    ctx.quadraticCurveTo(cx + r * 1.1, cy, cx, cy + r)
    ctx.quadraticCurveTo(cx - r * 1.1, cy, cx, cy - r)
    StickerCatalog.fillStroke(ctx, color)
    ctx.beginPath()
    ctx.moveTo(cx, cy - r * 0.8)
    ctx.lineTo(cx, cy + r * 0.8)
    ctx.stroke()
  }

  private static drawHeart(ctx: CanvasRenderingContext2D, cx: number, cy: number, r: number, color: string): void {
    ctx.beginPath()
    ctx.moveTo(cx, cy + r * 0.85)
    ctx.bezierCurveTo(cx - r * 1.2, cy + r * 0.1, cx - r * 0.6, cy - r * 0.7, cx, cy - r * 0.2)
    ctx.bezierCurveTo(cx + r * 0.6, cy - r * 0.7, cx + r * 1.2, cy + r * 0.1, cx, cy + r * 0.85)
    StickerCatalog.fillStroke(ctx, color)
  }

  private static drawFace(ctx: CanvasRenderingContext2D, cx: number, cy: number, r: number, color: string): void {
    ctx.beginPath()
    ctx.arc(cx, cy, r * 0.85, 0, Math.PI * 2)
    StickerCatalog.fillStroke(ctx, color)
    ctx.fillStyle = '#3D3D3D'
    ctx.beginPath()
    ctx.arc(cx - r * 0.28, cy - r * 0.12, r * 0.1, 0, Math.PI * 2)
    ctx.arc(cx + r * 0.28, cy - r * 0.12, r * 0.1, 0, Math.PI * 2)
    ctx.fill()
    ctx.beginPath()
    ctx.arc(cx, cy + r * 0.2, r * 0.28, 0.15 * Math.PI, 0.85 * Math.PI)
    ctx.stroke()
  }

  private static drawButterfly(ctx: CanvasRenderingContext2D, cx: number, cy: number, r: number, color: string): void {
    ctx.beginPath()
    ctx.ellipse(cx - r * 0.55, cy - r * 0.15, r * 0.45, r * 0.55, -0.3, 0, Math.PI * 2)
    ctx.ellipse(cx + r * 0.55, cy - r * 0.15, r * 0.45, r * 0.55, 0.3, 0, Math.PI * 2)
    ctx.ellipse(cx - r * 0.45, cy + r * 0.35, r * 0.32, r * 0.38, -0.2, 0, Math.PI * 2)
    ctx.ellipse(cx + r * 0.45, cy + r * 0.35, r * 0.32, r * 0.38, 0.2, 0, Math.PI * 2)
    StickerCatalog.fillStroke(ctx, color)
    ctx.beginPath()
    ctx.ellipse(cx, cy, r * 0.12, r * 0.55, 0, 0, Math.PI * 2)
    ctx.fillStyle = '#4A4A4A'
    ctx.fill()
    ctx.stroke()
  }

  private static drawFish(ctx: CanvasRenderingContext2D, cx: number, cy: number, r: number, color: string): void {
    ctx.beginPath()
    ctx.ellipse(cx - r * 0.1, cy, r * 0.65, r * 0.45, 0, 0, Math.PI * 2)
    StickerCatalog.fillStroke(ctx, color)
    ctx.beginPath()
    ctx.moveTo(cx + r * 0.45, cy)
    ctx.lineTo(cx + r * 0.95, cy - r * 0.45)
    ctx.lineTo(cx + r * 0.95, cy + r * 0.45)
    ctx.closePath()
    StickerCatalog.fillStroke(ctx, color)
    ctx.fillStyle = '#FFFFFF'
    ctx.beginPath()
    ctx.arc(cx - r * 0.25, cy - r * 0.12, r * 0.14, 0, Math.PI * 2)
    ctx.fill()
    ctx.stroke()
    ctx.fillStyle = '#3D3D3D'
    ctx.beginPath()
    ctx.arc(cx - r * 0.22, cy - r * 0.12, r * 0.06, 0, Math.PI * 2)
    ctx.fill()
  }
}
