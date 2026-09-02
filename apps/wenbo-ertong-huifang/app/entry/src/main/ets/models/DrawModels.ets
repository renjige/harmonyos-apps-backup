/** 儿童绘坊 — 绘画与画廊数据模型 */

export class DrawPoint {
  x: number = 0
  y: number = 0
}

export class DrawStroke {
  id: string = ''
  tool: string = 'crayon'
  color: string = '#FF8A65'
  width: number = 8
  eraser: boolean = false
  points: DrawPoint[] = []
}

export class FillRegion {
  id: string = ''
  x: number = 0
  y: number = 0
  w: number = 0
  h: number = 0
  /** rect | ellipse */
  shape: string = 'rect'
  fillColor: string = '#FFFFFF'
  colorHintZh: string = ''
  colorHintEn: string = ''
}

export class LineArtItem {
  id: string = ''
  title: string = ''
  category: string = ''
  summary: string = ''
  description: string = ''
  coverKey: string = ''
  regions: FillRegion[] = []
}

export class ArtworkItem {
  id: string = ''
  title: string = ''
  kind: string = 'free'
  createdAt: string = ''
  strokeData: string = ''
  fillData: string = ''
  lineArtId: string = ''
  accentColor: string = '#FF8A65'
}

/** 贴纸拼贴 — 画布上的单个贴纸 */
export class StickerPlacement {
  id: string = ''
  stickerId: string = ''
  /** 归一化中心坐标 0~1 */
  nx: number = 0
  ny: number = 0
  color: string = '#FFD54F'
  /** small | mid | large */
  sizeKey: string = 'mid'
}

export class StickerDef {
  id: string = ''
  label: string = ''
  category: string = ''
  defaultColor: string = '#FFD54F'
}

export class DotPoint {
  id: number = 0
  /** 画布内归一化横坐标 0~1（相对可绘区域） */
  nx: number = 0
  /** 画布内归一化纵坐标 0~1（相对可绘区域） */
  ny: number = 0
  x: number = 0
  y: number = 0
  linked: boolean = false
}

export class DrawGuideStep {
  order: number = 0
  instruction: string = ''
  strokes: DrawStroke[] = []
}

export class DrawStepItem {
  id: string = ''
  title: string = ''
  summary: string = ''
  stepCount: number = 4
  coverKey: string = ''
}

export class AppSettings {
  soundOn: boolean = true
  brushSize: string = 'mid'
  privacyAccepted: boolean = false
}

export class GalleryBundle {
  artworks: ArtworkItem[] = []
  totalStars: number = 0
  settings: AppSettings = new AppSettings()
}

export class BrushDef {
  id: string = ''
  label: string = ''
  alpha: number = 1
}

export class PaletteColor {
  hex: string = ''
  nameZh: string = ''
  nameEn: string = ''
}
