import { FillRegion } from '../models/DrawModels'

class RegionSpec {
  key: string = ''
  x: number = 0
  y: number = 0
  w: number = 0
  h: number = 0
  hintZh: string = ''
  hintEn: string = ''
  shape: string = 'rect'
}

/** 各线稿的填色分区与 Canvas 轮廓绘制 */
export class LineArtOutline {
  static regionsFor(artId: string): FillRegion[] {
    if (artId === 'la_cat') {
      return LineArtOutline.pack('la_cat', [
        LineArtOutline.region('bg', 0.04, 0.04, 0.92, 0.92, '天蓝', 'Sky Blue', 'rect'),
        LineArtOutline.region('body', 0.20, 0.48, 0.58, 0.34, '樱花粉', 'Pink', 'ellipse'),
        LineArtOutline.region('head', 0.26, 0.14, 0.48, 0.32, '暖橙', 'Orange', 'ellipse'),
        LineArtOutline.region('ear_l', 0.18, 0.06, 0.18, 0.16, '柠檬黄', 'Yellow', 'ellipse'),
        LineArtOutline.region('ear_r', 0.64, 0.06, 0.18, 0.16, '柠檬黄', 'Yellow', 'ellipse'),
        LineArtOutline.region('tail', 0.66, 0.52, 0.22, 0.28, '葡萄紫', 'Purple', 'ellipse'),
        LineArtOutline.region('belly', 0.32, 0.56, 0.36, 0.20, '雪白', 'White', 'ellipse'),
      ])
    }
    if (artId === 'la_dog') {
      return LineArtOutline.pack('la_dog', [
        LineArtOutline.region('bg', 0.04, 0.04, 0.92, 0.92, '草绿', 'Green', 'rect'),
        LineArtOutline.region('body', 0.18, 0.46, 0.64, 0.32, '暖橙', 'Orange', 'ellipse'),
        LineArtOutline.region('head', 0.28, 0.16, 0.44, 0.30, '可可', 'Brown', 'ellipse'),
        LineArtOutline.region('ear_l', 0.16, 0.08, 0.20, 0.18, '可可', 'Brown', 'ellipse'),
        LineArtOutline.region('ear_r', 0.64, 0.08, 0.20, 0.18, '可可', 'Brown', 'ellipse'),
        LineArtOutline.region('spot', 0.38, 0.52, 0.24, 0.16, '雪白', 'White', 'ellipse'),
      ])
    }
    if (artId === 'la_bird') {
      return LineArtOutline.pack('la_bird', [
        LineArtOutline.region('bg', 0.04, 0.04, 0.92, 0.92, '天蓝', 'Sky Blue', 'rect'),
        LineArtOutline.region('wing', 0.14, 0.30, 0.30, 0.24, '草绿', 'Green', 'ellipse'),
        LineArtOutline.region('body', 0.28, 0.36, 0.42, 0.30, '柠檬黄', 'Yellow', 'ellipse'),
        LineArtOutline.region('head', 0.50, 0.18, 0.30, 0.26, '暖橙', 'Orange', 'ellipse'),
        LineArtOutline.region('beak', 0.72, 0.28, 0.14, 0.10, '朱红', 'Red', 'ellipse'),
      ])
    }
    if (artId === 'la_fish') {
      return LineArtOutline.pack('la_fish', [
        LineArtOutline.region('bg', 0.04, 0.04, 0.92, 0.92, '天蓝', 'Sky Blue', 'rect'),
        LineArtOutline.region('body', 0.16, 0.34, 0.46, 0.34, '天蓝', 'Sky Blue', 'ellipse'),
        LineArtOutline.region('tail', 0.58, 0.28, 0.24, 0.38, '草绿', 'Green', 'ellipse'),
        LineArtOutline.region('fin', 0.32, 0.50, 0.16, 0.14, '樱花粉', 'Pink', 'ellipse'),
        LineArtOutline.region('stripe', 0.28, 0.40, 0.22, 0.08, '雪白', 'White', 'ellipse'),
        LineArtOutline.region('bubble1', 0.08, 0.12, 0.10, 0.10, '雪白', 'White', 'ellipse'),
        LineArtOutline.region('bubble2', 0.18, 0.22, 0.08, 0.08, '雪白', 'White', 'ellipse'),
      ])
    }
    if (artId === 'la_tree') {
      return LineArtOutline.pack('la_tree', [
        LineArtOutline.region('bg', 0.04, 0.04, 0.92, 0.92, '天蓝', 'Sky Blue', 'rect'),
        LineArtOutline.region('grass', 0.04, 0.72, 0.92, 0.24, '草绿', 'Green', 'rect'),
        LineArtOutline.region('crown', 0.18, 0.08, 0.64, 0.48, '草绿', 'Green', 'ellipse'),
        LineArtOutline.region('crown2', 0.28, 0.14, 0.44, 0.36, '青绿', 'Teal', 'ellipse'),
        LineArtOutline.region('trunk', 0.40, 0.50, 0.20, 0.34, '可可', 'Brown', 'rect'),
      ])
    }
    if (artId === 'la_flower') {
      return LineArtOutline.pack('la_flower', [
        LineArtOutline.region('bg', 0.04, 0.04, 0.92, 0.92, '天蓝', 'Sky Blue', 'rect'),
        LineArtOutline.region('petal1', 0.38, 0.10, 0.24, 0.18, '樱花粉', 'Pink', 'ellipse'),
        LineArtOutline.region('petal2', 0.58, 0.22, 0.20, 0.18, '樱花粉', 'Pink', 'ellipse'),
        LineArtOutline.region('petal3', 0.58, 0.42, 0.20, 0.18, '樱花粉', 'Pink', 'ellipse'),
        LineArtOutline.region('petal4', 0.38, 0.52, 0.24, 0.18, '樱花粉', 'Pink', 'ellipse'),
        LineArtOutline.region('petal5', 0.18, 0.42, 0.20, 0.18, '樱花粉', 'Pink', 'ellipse'),
        LineArtOutline.region('petal6', 0.18, 0.22, 0.20, 0.18, '樱花粉', 'Pink', 'ellipse'),
        LineArtOutline.region('center', 0.36, 0.30, 0.28, 0.24, '柠檬黄', 'Yellow', 'ellipse'),
        LineArtOutline.region('stem', 0.46, 0.58, 0.08, 0.30, '草绿', 'Green', 'rect'),
        LineArtOutline.region('leaf', 0.52, 0.62, 0.18, 0.12, '草绿', 'Green', 'ellipse'),
      ])
    }
    if (artId === 'la_sun') {
      return LineArtOutline.pack('la_sun', [
        LineArtOutline.region('bg', 0.04, 0.04, 0.92, 0.92, '天蓝', 'Sky Blue', 'rect'),
        LineArtOutline.region('ray_n', 0.40, 0.06, 0.20, 0.16, '暖橙', 'Orange', 'ellipse'),
        LineArtOutline.region('ray_s', 0.40, 0.78, 0.20, 0.16, '暖橙', 'Orange', 'ellipse'),
        LineArtOutline.region('ray_w', 0.06, 0.40, 0.16, 0.20, '暖橙', 'Orange', 'ellipse'),
        LineArtOutline.region('ray_e', 0.78, 0.40, 0.16, 0.20, '暖橙', 'Orange', 'ellipse'),
        LineArtOutline.region('core', 0.28, 0.26, 0.44, 0.44, '柠檬黄', 'Yellow', 'ellipse'),
      ])
    }
    if (artId === 'la_car') {
      return LineArtOutline.pack('la_car', [
        LineArtOutline.region('bg', 0.04, 0.04, 0.92, 0.92, '天蓝', 'Sky Blue', 'rect'),
        LineArtOutline.region('road', 0.04, 0.72, 0.92, 0.22, '深灰', 'Gray', 'rect'),
        LineArtOutline.region('body', 0.10, 0.40, 0.80, 0.28, '朱红', 'Red', 'rect'),
        LineArtOutline.region('cabin', 0.26, 0.22, 0.48, 0.24, '天蓝', 'Sky Blue', 'rect'),
        LineArtOutline.region('wheel_l', 0.18, 0.62, 0.20, 0.20, '深灰', 'Gray', 'ellipse'),
        LineArtOutline.region('wheel_r', 0.62, 0.62, 0.20, 0.20, '深灰', 'Gray', 'ellipse'),
        LineArtOutline.region('window', 0.32, 0.26, 0.36, 0.14, '雪白', 'White', 'rect'),
      ])
    }
    if (artId === 'la_train') {
      return LineArtOutline.pack('la_train', [
        LineArtOutline.region('bg', 0.04, 0.04, 0.92, 0.92, '天蓝', 'Sky Blue', 'rect'),
        LineArtOutline.region('track', 0.06, 0.70, 0.88, 0.14, '深灰', 'Gray', 'rect'),
        LineArtOutline.region('engine', 0.08, 0.28, 0.38, 0.38, '朱红', 'Red', 'rect'),
        LineArtOutline.region('car1', 0.44, 0.32, 0.26, 0.30, '天蓝', 'Sky Blue', 'rect'),
        LineArtOutline.region('car2', 0.68, 0.32, 0.26, 0.30, '草绿', 'Green', 'rect'),
        LineArtOutline.region('smoke', 0.16, 0.10, 0.20, 0.16, '雪白', 'White', 'ellipse'),
      ])
    }
    if (artId === 'la_boat') {
      return LineArtOutline.pack('la_boat', [
        LineArtOutline.region('sea', 0.04, 0.52, 0.92, 0.44, '天蓝', 'Sky Blue', 'rect'),
        LineArtOutline.region('sky', 0.04, 0.04, 0.92, 0.50, '草绿', 'Green', 'rect'),
        LineArtOutline.region('hull', 0.20, 0.38, 0.60, 0.22, '暖橙', 'Orange', 'ellipse'),
        LineArtOutline.region('sail', 0.36, 0.12, 0.32, 0.34, '雪白', 'White', 'ellipse'),
        LineArtOutline.region('flag', 0.58, 0.14, 0.10, 0.08, '朱红', 'Red', 'rect'),
      ])
    }
    if (artId === 'la_star') {
      return LineArtOutline.pack('la_star', [
        LineArtOutline.region('sky', 0.04, 0.04, 0.92, 0.92, '葡萄紫', 'Purple', 'rect'),
        LineArtOutline.region('star', 0.24, 0.18, 0.52, 0.52, '柠檬黄', 'Yellow', 'ellipse'),
        LineArtOutline.region('spark1', 0.12, 0.20, 0.10, 0.10, '雪白', 'White', 'ellipse'),
        LineArtOutline.region('spark2', 0.76, 0.28, 0.08, 0.08, '雪白', 'White', 'ellipse'),
      ])
    }
    if (artId === 'la_rocket') {
      return LineArtOutline.pack('la_rocket', [
        LineArtOutline.region('sky', 0.04, 0.04, 0.92, 0.92, '葡萄紫', 'Purple', 'rect'),
        LineArtOutline.region('body', 0.36, 0.16, 0.28, 0.54, '天蓝', 'Sky Blue', 'rect'),
        LineArtOutline.region('nose', 0.38, 0.04, 0.24, 0.16, '朱红', 'Red', 'ellipse'),
        LineArtOutline.region('window', 0.42, 0.28, 0.16, 0.16, '雪白', 'White', 'ellipse'),
        LineArtOutline.region('fin_l', 0.30, 0.58, 0.12, 0.16, '草绿', 'Green', 'ellipse'),
        LineArtOutline.region('fin_r', 0.58, 0.58, 0.12, 0.16, '草绿', 'Green', 'ellipse'),
        LineArtOutline.region('flame', 0.34, 0.68, 0.32, 0.22, '暖橙', 'Orange', 'ellipse'),
      ])
    }
    return LineArtOutline.pack('generic', [
      LineArtOutline.region('bg', 0.04, 0.04, 0.92, 0.92, '天蓝', 'Sky Blue', 'rect'),
      LineArtOutline.region('a', 0.15, 0.20, 0.35, 0.35, '草绿', 'Green', 'ellipse'),
      LineArtOutline.region('b', 0.50, 0.20, 0.35, 0.35, '暖橙', 'Orange', 'ellipse'),
      LineArtOutline.region('c', 0.15, 0.58, 0.70, 0.28, '樱花粉', 'Pink', 'rect'),
    ])
  }

  static drawOutline(ctx: CanvasRenderingContext2D, artId: string, w: number, h: number): void {
    ctx.lineCap = 'round'
    ctx.lineJoin = 'round'
    ctx.strokeStyle = '#3D3D3D'
    ctx.lineWidth = 3
    if (artId === 'la_cat') {
      LineArtOutline.drawCat(ctx, w, h)
    } else if (artId === 'la_dog') {
      LineArtOutline.drawDog(ctx, w, h)
    } else if (artId === 'la_bird') {
      LineArtOutline.drawBird(ctx, w, h)
    } else if (artId === 'la_fish') {
      LineArtOutline.drawFish(ctx, w, h)
    } else if (artId === 'la_tree') {
      LineArtOutline.drawTree(ctx, w, h)
    } else if (artId === 'la_flower') {
      LineArtOutline.drawFlower(ctx, w, h)
    } else if (artId === 'la_sun') {
      LineArtOutline.drawSun(ctx, w, h)
    } else if (artId === 'la_car') {
      LineArtOutline.drawCar(ctx, w, h)
    } else if (artId === 'la_train') {
      LineArtOutline.drawTrain(ctx, w, h)
    } else if (artId === 'la_boat') {
      LineArtOutline.drawBoat(ctx, w, h)
    } else if (artId === 'la_star') {
      LineArtOutline.drawStarArt(ctx, w, h)
    } else if (artId === 'la_rocket') {
      LineArtOutline.drawRocket(ctx, w, h)
    } else {
      ctx.strokeRect(w * 0.12, h * 0.12, w * 0.76, h * 0.76)
    }
  }

  private static region(
    key: string, x: number, y: number, rw: number, rh: number,
    hintZh: string, hintEn: string, shape: string = 'rect'
  ): RegionSpec {
    const s = new RegionSpec()
    s.key = key
    s.x = x
    s.y = y
    s.w = rw
    s.h = rh
    s.hintZh = hintZh
    s.hintEn = hintEn
    s.shape = shape
    return s
  }

  private static pack(artId: string, defs: RegionSpec[]): FillRegion[] {
    const out: FillRegion[] = []
    for (const d of defs) {
      const r = new FillRegion()
      r.id = `${artId}_${d.key}`
      r.x = d.x
      r.y = d.y
      r.w = d.w
      r.h = d.h
      r.shape = d.shape
      r.colorHintZh = d.hintZh
      r.colorHintEn = d.hintEn
      r.fillColor = '#FFFFFF'
      out.push(r)
    }
    return out
  }

  private static drawCat(ctx: CanvasRenderingContext2D, w: number, h: number): void {
    ctx.beginPath()
    ctx.ellipse(w * 0.50, h * 0.62, w * 0.28, h * 0.16, 0, 0, Math.PI * 2)
    ctx.stroke()
    ctx.beginPath()
    ctx.ellipse(w * 0.50, h * 0.30, w * 0.22, h * 0.14, 0, 0, Math.PI * 2)
    ctx.stroke()
    ctx.beginPath()
    ctx.moveTo(w * 0.28, h * 0.20)
    ctx.lineTo(w * 0.24, h * 0.08)
    ctx.lineTo(w * 0.38, h * 0.16)
    ctx.closePath()
    ctx.stroke()
    ctx.beginPath()
    ctx.moveTo(w * 0.72, h * 0.20)
    ctx.lineTo(w * 0.76, h * 0.08)
    ctx.lineTo(w * 0.62, h * 0.16)
    ctx.closePath()
    ctx.stroke()
    ctx.beginPath()
    ctx.ellipse(w * 0.76, h * 0.66, w * 0.10, h * 0.12, 0.4, 0, Math.PI * 2)
    ctx.stroke()
    LineArtOutline.drawEyes(ctx, w * 0.44, h * 0.28, w * 0.56, h * 0.28, w * 0.018)
    ctx.beginPath()
    ctx.moveTo(w * 0.50, h * 0.32)
    ctx.lineTo(w * 0.48, h * 0.36)
    ctx.lineTo(w * 0.52, h * 0.36)
    ctx.closePath()
    ctx.stroke()
    LineArtOutline.drawWhiskers(ctx, w * 0.50, h * 0.34, w * 0.12, h * 0.04)
  }

  private static drawDog(ctx: CanvasRenderingContext2D, w: number, h: number): void {
    ctx.beginPath()
    ctx.ellipse(w * 0.50, h * 0.62, w * 0.30, h * 0.14, 0, 0, Math.PI * 2)
    ctx.stroke()
    ctx.beginPath()
    ctx.ellipse(w * 0.50, h * 0.30, w * 0.20, h * 0.13, 0, 0, Math.PI * 2)
    ctx.stroke()
    ctx.beginPath()
    ctx.ellipse(w * 0.26, h * 0.18, w * 0.09, h * 0.12, -0.5, 0, Math.PI * 2)
    ctx.stroke()
    ctx.beginPath()
    ctx.ellipse(w * 0.74, h * 0.18, w * 0.09, h * 0.12, 0.5, 0, Math.PI * 2)
    ctx.stroke()
    LineArtOutline.drawEyes(ctx, w * 0.44, h * 0.28, w * 0.56, h * 0.28, w * 0.016)
    ctx.beginPath()
    ctx.ellipse(w * 0.50, h * 0.36, w * 0.06, h * 0.05, 0, 0, Math.PI * 2)
    ctx.stroke()
  }

  private static drawBird(ctx: CanvasRenderingContext2D, w: number, h: number): void {
    ctx.beginPath()
    ctx.ellipse(w * 0.40, h * 0.50, w * 0.20, h * 0.14, -0.15, 0, Math.PI * 2)
    ctx.stroke()
    ctx.beginPath()
    ctx.ellipse(w * 0.24, h * 0.40, w * 0.14, h * 0.10, -0.6, 0, Math.PI * 2)
    ctx.stroke()
    ctx.beginPath()
    ctx.arc(w * 0.64, h * 0.30, w * 0.13, 0, Math.PI * 2)
    ctx.stroke()
    ctx.beginPath()
    ctx.moveTo(w * 0.76, h * 0.32)
    ctx.lineTo(w * 0.90, h * 0.30)
    ctx.lineTo(w * 0.76, h * 0.38)
    ctx.closePath()
    ctx.stroke()
    LineArtOutline.drawEyes(ctx, w * 0.60, h * 0.28, w * 0.60, h * 0.28, w * 0.014)
  }

  private static drawFish(ctx: CanvasRenderingContext2D, w: number, h: number): void {
    ctx.beginPath()
    ctx.ellipse(w * 0.38, h * 0.50, w * 0.22, h * 0.15, 0, 0, Math.PI * 2)
    ctx.stroke()
    ctx.beginPath()
    ctx.moveTo(w * 0.56, h * 0.50)
    ctx.lineTo(w * 0.78, h * 0.34)
    ctx.lineTo(w * 0.78, h * 0.66)
    ctx.closePath()
    ctx.stroke()
    ctx.beginPath()
    ctx.moveTo(w * 0.36, h * 0.56)
    ctx.lineTo(w * 0.28, h * 0.64)
    ctx.lineTo(w * 0.40, h * 0.58)
    ctx.stroke()
    ctx.beginPath()
    ctx.arc(w * 0.48, h * 0.46, w * 0.04, 0, Math.PI * 2)
    ctx.fillStyle = '#3D3D3D'
    ctx.fill()
    ctx.stroke()
    ctx.beginPath()
    ctx.arc(w * 0.12, h * 0.16, w * 0.04, 0, Math.PI * 2)
    ctx.stroke()
    ctx.beginPath()
    ctx.arc(w * 0.22, h * 0.26, w * 0.03, 0, Math.PI * 2)
    ctx.stroke()
  }

  private static drawTree(ctx: CanvasRenderingContext2D, w: number, h: number): void {
    ctx.beginPath()
    ctx.moveTo(w * 0.50, h * 0.10)
    ctx.lineTo(w * 0.74, h * 0.48)
    ctx.lineTo(w * 0.26, h * 0.48)
    ctx.closePath()
    ctx.stroke()
    ctx.beginPath()
    ctx.moveTo(w * 0.50, h * 0.18)
    ctx.lineTo(w * 0.66, h * 0.44)
    ctx.lineTo(w * 0.34, h * 0.44)
    ctx.closePath()
    ctx.stroke()
    ctx.strokeRect(w * 0.44, h * 0.50, w * 0.12, h * 0.32)
    ctx.lineWidth = 2
    ctx.beginPath()
    ctx.moveTo(w * 0.04, h * 0.78)
    ctx.lineTo(w * 0.96, h * 0.78)
    ctx.stroke()
    ctx.lineWidth = 3
  }

  private static drawFlower(ctx: CanvasRenderingContext2D, w: number, h: number): void {
    for (let i = 0; i < 6; i++) {
      const a = (Math.PI * 2 * i) / 6 - Math.PI / 2
      ctx.beginPath()
      ctx.ellipse(
        w * 0.50 + Math.cos(a) * w * 0.16,
        h * 0.38 + Math.sin(a) * h * 0.14,
        w * 0.10, h * 0.08, a, 0, Math.PI * 2
      )
      ctx.stroke()
    }
    ctx.beginPath()
    ctx.arc(w * 0.50, h * 0.38, w * 0.12, 0, Math.PI * 2)
    ctx.stroke()
    ctx.strokeRect(w * 0.47, h * 0.58, w * 0.06, h * 0.28)
    ctx.beginPath()
    ctx.ellipse(w * 0.58, h * 0.66, w * 0.08, h * 0.05, 0.5, 0, Math.PI * 2)
    ctx.stroke()
  }

  private static drawSun(ctx: CanvasRenderingContext2D, w: number, h: number): void {
    ctx.beginPath()
    ctx.arc(w * 0.50, h * 0.48, w * 0.20, 0, Math.PI * 2)
    ctx.stroke()
    for (let i = 0; i < 8; i++) {
      const a = (Math.PI * 2 * i) / 8
      ctx.beginPath()
      ctx.moveTo(w * 0.50 + Math.cos(a) * w * 0.24, h * 0.48 + Math.sin(a) * h * 0.20)
      ctx.lineTo(w * 0.50 + Math.cos(a) * w * 0.32, h * 0.48 + Math.sin(a) * h * 0.26)
      ctx.stroke()
    }
    LineArtOutline.drawSmile(ctx, w * 0.50, h * 0.50, w * 0.08, h * 0.06)
    LineArtOutline.drawEyes(ctx, w * 0.44, h * 0.44, w * 0.56, h * 0.44, w * 0.012)
  }

  private static drawCar(ctx: CanvasRenderingContext2D, w: number, h: number): void {
    ctx.strokeRect(w * 0.12, h * 0.42, w * 0.76, h * 0.26)
    ctx.strokeRect(w * 0.28, h * 0.24, w * 0.44, h * 0.22)
    ctx.strokeRect(w * 0.32, h * 0.28, w * 0.36, h * 0.12)
    ctx.beginPath()
    ctx.arc(w * 0.28, h * 0.72, w * 0.09, 0, Math.PI * 2)
    ctx.stroke()
    ctx.beginPath()
    ctx.arc(w * 0.72, h * 0.72, w * 0.09, 0, Math.PI * 2)
    ctx.stroke()
    ctx.lineWidth = 2
    ctx.strokeRect(w * 0.04, h * 0.74, w * 0.92, h * 0.18)
    ctx.lineWidth = 3
  }

  private static drawTrain(ctx: CanvasRenderingContext2D, w: number, h: number): void {
    ctx.strokeRect(w * 0.10, h * 0.30, w * 0.34, h * 0.34)
    ctx.strokeRect(w * 0.46, h * 0.34, w * 0.24, h * 0.28)
    ctx.strokeRect(w * 0.70, h * 0.34, w * 0.22, h * 0.28)
    ctx.beginPath()
    ctx.arc(w * 0.22, h * 0.22, w * 0.08, 0, Math.PI * 2)
    ctx.stroke()
    ctx.beginPath()
    ctx.arc(w * 0.30, h * 0.14, w * 0.06, 0, Math.PI * 2)
    ctx.stroke()
    ctx.lineWidth = 2
    ctx.strokeRect(w * 0.08, h * 0.70, w * 0.84, h * 0.10)
    ctx.lineWidth = 3
  }

  private static drawBoat(ctx: CanvasRenderingContext2D, w: number, h: number): void {
    ctx.lineWidth = 2
    ctx.strokeRect(w * 0.04, h * 0.54, w * 0.92, h * 0.40)
    ctx.lineWidth = 3
    ctx.beginPath()
    ctx.moveTo(w * 0.22, h * 0.58)
    ctx.lineTo(w * 0.78, h * 0.58)
    ctx.lineTo(w * 0.68, h * 0.46)
    ctx.lineTo(w * 0.32, h * 0.46)
    ctx.closePath()
    ctx.stroke()
    ctx.beginPath()
    ctx.moveTo(w * 0.50, h * 0.46)
    ctx.lineTo(w * 0.50, h * 0.16)
    ctx.stroke()
    ctx.beginPath()
    ctx.moveTo(w * 0.50, h * 0.20)
    ctx.lineTo(w * 0.72, h * 0.46)
    ctx.lineTo(w * 0.50, h * 0.46)
    ctx.closePath()
    ctx.stroke()
    ctx.strokeRect(w * 0.60, h * 0.16, w * 0.08, h * 0.06)
  }

  private static drawStarArt(ctx: CanvasRenderingContext2D, w: number, h: number): void {
    LineArtOutline.drawStarPath(ctx, w * 0.50, h * 0.44, w * 0.24)
    ctx.stroke()
    ctx.beginPath()
    ctx.arc(w * 0.16, h * 0.24, w * 0.04, 0, Math.PI * 2)
    ctx.stroke()
    ctx.beginPath()
    ctx.arc(w * 0.80, h * 0.32, w * 0.03, 0, Math.PI * 2)
    ctx.stroke()
  }

  private static drawRocket(ctx: CanvasRenderingContext2D, w: number, h: number): void {
    ctx.beginPath()
    ctx.moveTo(w * 0.50, h * 0.06)
    ctx.lineTo(w * 0.60, h * 0.24)
    ctx.lineTo(w * 0.60, h * 0.66)
    ctx.lineTo(w * 0.40, h * 0.66)
    ctx.lineTo(w * 0.40, h * 0.24)
    ctx.closePath()
    ctx.stroke()
    ctx.beginPath()
    ctx.arc(w * 0.50, h * 0.34, w * 0.07, 0, Math.PI * 2)
    ctx.stroke()
    ctx.beginPath()
    ctx.moveTo(w * 0.34, h * 0.58)
    ctx.lineTo(w * 0.26, h * 0.70)
    ctx.lineTo(w * 0.40, h * 0.66)
    ctx.stroke()
    ctx.beginPath()
    ctx.moveTo(w * 0.66, h * 0.58)
    ctx.lineTo(w * 0.74, h * 0.70)
    ctx.lineTo(w * 0.60, h * 0.66)
    ctx.stroke()
    ctx.beginPath()
    ctx.moveTo(w * 0.42, h * 0.68)
    ctx.lineTo(w * 0.50, h * 0.86)
    ctx.lineTo(w * 0.58, h * 0.68)
    ctx.stroke()
  }

  private static drawEyes(
    ctx: CanvasRenderingContext2D, lx: number, ly: number, rx: number, ry: number, r: number
  ): void {
    ctx.fillStyle = '#FFFFFF'
    ctx.beginPath()
    ctx.arc(lx, ly, r * 1.4, 0, Math.PI * 2)
    ctx.fill()
    ctx.stroke()
    ctx.beginPath()
    ctx.arc(rx, ry, r * 1.4, 0, Math.PI * 2)
    ctx.fill()
    ctx.stroke()
    ctx.fillStyle = '#3D3D3D'
    ctx.beginPath()
    ctx.arc(lx, ly, r, 0, Math.PI * 2)
    ctx.fill()
    ctx.beginPath()
    ctx.arc(rx, ry, r, 0, Math.PI * 2)
    ctx.fill()
  }

  private static drawWhiskers(ctx: CanvasRenderingContext2D, cx: number, cy: number, span: number, drop: number): void {
    ctx.lineWidth = 2
    ctx.beginPath()
    ctx.moveTo(cx - span, cy)
    ctx.lineTo(cx - span * 2, cy - drop)
    ctx.stroke()
    ctx.beginPath()
    ctx.moveTo(cx - span, cy + drop * 0.5)
    ctx.lineTo(cx - span * 2, cy + drop)
    ctx.stroke()
    ctx.beginPath()
    ctx.moveTo(cx + span, cy)
    ctx.lineTo(cx + span * 2, cy - drop)
    ctx.stroke()
    ctx.beginPath()
    ctx.moveTo(cx + span, cy + drop * 0.5)
    ctx.lineTo(cx + span * 2, cy + drop)
    ctx.stroke()
    ctx.lineWidth = 3
  }

  private static drawSmile(ctx: CanvasRenderingContext2D, cx: number, cy: number, rw: number, rh: number): void {
    ctx.beginPath()
    ctx.arc(cx, cy, rw, 0.2 * Math.PI, 0.8 * Math.PI)
    ctx.stroke()
  }

  private static drawStarPath(ctx: CanvasRenderingContext2D, cx: number, cy: number, r: number): void {
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
  }
}
