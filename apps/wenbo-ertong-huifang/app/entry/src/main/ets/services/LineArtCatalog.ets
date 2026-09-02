import { LineArtItem, PaletteColor, BrushDef, DrawStepItem, DrawGuideStep, DrawStroke, DrawPoint } from '../models/DrawModels'
import { LineArtOutline } from './LineArtOutline'

export class LineArtCatalog {
  static palette(): PaletteColor[] {
    const colors: PaletteColor[] = []
    const defs: string[][] = [
      ['#FF8A65', '暖橙', 'Orange'],
      ['#4FC3F7', '天蓝', 'Sky Blue'],
      ['#81C784', '草绿', 'Green'],
      ['#FFD54F', '柠檬黄', 'Yellow'],
      ['#F06292', '樱花粉', 'Pink'],
      ['#BA68C8', '葡萄紫', 'Purple'],
      ['#FFFFFF', '雪白', 'White'],
      ['#4A4A4A', '深灰', 'Gray'],
      ['#EF5350', '朱红', 'Red'],
      ['#26A69A', '青绿', 'Teal'],
      ['#FF7043', '珊瑚', 'Coral'],
      ['#8D6E63', '可可', 'Brown'],
    ]
    for (const d of defs) {
      const c = new PaletteColor()
      c.hex = d[0]
      c.nameZh = d[1]
      c.nameEn = d[2]
      colors.push(c)
    }
    return colors
  }

  static brushes(): BrushDef[] {
    const list: BrushDef[] = []
    const b0 = new BrushDef(); b0.id = 'crayon'; b0.label = '蜡笔'; b0.alpha = 0.92; list.push(b0)
    const b1 = new BrushDef(); b1.id = 'water'; b1.label = '水彩'; b1.alpha = 0.55; list.push(b1)
    const b2 = new BrushDef(); b2.id = 'marker'; b2.label = '马克笔'; b2.alpha = 1; list.push(b2)
    const b3 = new BrushDef(); b3.id = 'chalk'; b3.label = '粉笔'; b3.alpha = 0.75; list.push(b3)
    const b4 = new BrushDef(); b4.id = 'brush'; b4.label = '毛刷'; b4.alpha = 0.85; list.push(b4)
    return list
  }

  static brushWidth(size: string): number {
    if (size === 'thin') {
      return 4
    }
    if (size === 'thick') {
      return 16
    }
    return 8
  }

  static categories(): string[] {
    return ['animal', 'plant', 'vehicle', 'fairy']
  }

  static categoryLabel(key: string): string {
    if (key === 'plant') {
      return '植物'
    }
    if (key === 'vehicle') {
      return '交通'
    }
    if (key === 'fairy') {
      return '童话'
    }
    return '动物'
  }

  static lineArts(): LineArtItem[] {
    const list: LineArtItem[] = []
    list.push(LineArtCatalog.makeArt('la_cat', '小猫咪', 'animal', 'cover_animal', '给小花猫涂上喜欢的颜色'))
    list.push(LineArtCatalog.makeArt('la_dog', '小狗狗', 'animal', 'cover_animal', '汪汪汪，试试棕色和白色'))
    list.push(LineArtCatalog.makeArt('la_bird', '小鸟儿', 'animal', 'cover_animal', '天空蓝翅膀真好看'))
    list.push(LineArtCatalog.makeArt('la_fish', '小金鱼', 'animal', 'cover_animal', '在水里游呀游'))
    list.push(LineArtCatalog.makeArt('la_tree', '大树', 'plant', 'cover_plant', '树干棕色，叶子绿色'))
    list.push(LineArtCatalog.makeArt('la_flower', '小花朵', 'plant', 'cover_plant', '花瓣可以涂粉色'))
    list.push(LineArtCatalog.makeArt('la_sun', '小太阳', 'plant', 'cover_plant', '柠檬黄最温暖'))
    list.push(LineArtCatalog.makeArt('la_car', '小汽车', 'vehicle', 'cover_vehicle', '红色赛车还是蓝色巴士？'))
    list.push(LineArtCatalog.makeArt('la_train', '小火车', 'vehicle', 'cover_vehicle', '一节一节涂颜色'))
    list.push(LineArtCatalog.makeArt('la_boat', '小帆船', 'vehicle', 'cover_vehicle', '天蓝大海上的船'))
    list.push(LineArtCatalog.makeArt('la_star', '小星星', 'fairy', 'cover_fairy', '夜晚闪闪亮'))
    list.push(LineArtCatalog.makeArt('la_rocket', '小火箭', 'fairy', 'cover_fairy', '飞向太空吧'))
    return list
  }

  static findLineArt(id: string): LineArtItem | null {
    for (const item of LineArtCatalog.lineArts()) {
      if (item.id === id) {
        return item
      }
    }
    return null
  }

  static byCategory(cat: string): LineArtItem[] {
    const out: LineArtItem[] = []
    for (const item of LineArtCatalog.lineArts()) {
      if (item.category === cat) {
        out.push(item)
      }
    }
    return out
  }

  static drawSteps(): DrawStepItem[] {
    const list: DrawStepItem[] = []
    const s0 = new DrawStepItem(); s0.id = 'ds_fish'; s0.title = '画一条小鱼'; s0.summary = '四步完成'; s0.stepCount = 4; s0.coverKey = 'cover_animal'; list.push(s0)
    const s1 = new DrawStepItem(); s1.id = 'ds_house'; s1.title = '画一座小房子'; s1.summary = '四步完成'; s1.stepCount = 4; s1.coverKey = 'cover_plant'; list.push(s1)
    const s2 = new DrawStepItem(); s2.id = 'ds_sun'; s2.title = '画一个小太阳'; s2.summary = '三步完成'; s2.stepCount = 3; s2.coverKey = 'cover_plant'; list.push(s2)
    return list
  }

  private static makeArt(id: string, title: string, category: string, cover: string, summary: string): LineArtItem {
    const item = new LineArtItem()
    item.id = id
    item.title = title
    item.category = category
    item.summary = summary
    item.description = `${summary}。点击封闭区域即可填色，完成后保存到画廊。`
    item.coverKey = cover
    item.regions = LineArtOutline.regionsFor(id)
    return item
  }

  static guideSteps(guideId: string): DrawGuideStep[] {
    if (guideId === 'ds_fish') {
      return LineArtCatalog.buildGuideFish()
    }
    if (guideId === 'ds_house') {
      return LineArtCatalog.buildGuideHouse()
    }
    return LineArtCatalog.buildGuideSun()
  }

  private static strokeFromPoints(color: string, width: number, coords: number[][]): DrawStroke {
    const s = new DrawStroke()
    s.color = color
    s.width = width
    s.tool = 'marker'
    const pts: DrawPoint[] = []
    for (const c of coords) {
      const p = new DrawPoint()
      p.x = c[0]
      p.y = c[1]
      pts.push(p)
    }
    s.points = pts
    return s
  }

  private static buildGuideFish(): DrawGuideStep[] {
    const out: DrawGuideStep[] = []
    const s0 = new DrawGuideStep()
    s0.order = 0
    s0.instruction = '先画一条胖胖的鱼身体'
    s0.strokes = [LineArtCatalog.strokeFromPoints('#4FC3F7', 8, [[80, 200], [280, 200]])]
    out.push(s0)
    const s1 = new DrawGuideStep()
    s1.order = 1
    s1.instruction = '加上三角形尾巴'
    s1.strokes = [LineArtCatalog.strokeFromPoints('#81C784', 8, [[280, 200], [330, 160], [330, 240], [280, 200]])]
    out.push(s1)
    const s2 = new DrawGuideStep()
    s2.order = 2
    s2.instruction = '画眼睛和小鱼鳍'
    s2.strokes = [
      LineArtCatalog.strokeFromPoints('#FFD54F', 6, [[120, 190], [140, 190]]),
      LineArtCatalog.strokeFromPoints('#FFD54F', 6, [[200, 220], [230, 210]])
    ]
    out.push(s2)
    const s3 = new DrawGuideStep()
    s3.order = 3
    s3.instruction = '旁边加泡泡，完成啦'
    s3.strokes = [
      LineArtCatalog.strokeFromPoints('#BA68C8', 5, [[60, 120], [60, 100]]),
      LineArtCatalog.strokeFromPoints('#BA68C8', 5, [[90, 80], [90, 60]])
    ]
    out.push(s3)
    return out
  }

  private static buildGuideHouse(): DrawGuideStep[] {
    const out: DrawGuideStep[] = []
    const s0 = new DrawGuideStep()
    s0.order = 0
    s0.instruction = '画一个正方形当房子'
    s0.strokes = [LineArtCatalog.strokeFromPoints('#FF8A65', 8, [[100, 280], [260, 280], [260, 160], [100, 160], [100, 280]])]
    out.push(s0)
    const s1 = new DrawGuideStep()
    s1.order = 1
    s1.instruction = '屋顶画成大三角形'
    s1.strokes = [LineArtCatalog.strokeFromPoints('#EF5350', 8, [[80, 160], [180, 80], [280, 160]])]
    out.push(s1)
    const s2 = new DrawGuideStep()
    s2.order = 2
    s2.instruction = '加一扇门和两扇窗'
    s2.strokes = [
      LineArtCatalog.strokeFromPoints('#4FC3F7', 6, [[160, 280], [160, 220]]),
      LineArtCatalog.strokeFromPoints('#4FC3F7', 6, [[120, 200], [150, 200]]),
      LineArtCatalog.strokeFromPoints('#4FC3F7', 6, [[210, 200], [240, 200]])
    ]
    out.push(s2)
    const s3 = new DrawGuideStep()
    s3.order = 3
    s3.instruction = '烟囱和小太阳装饰'
    s3.strokes = [
      LineArtCatalog.strokeFromPoints('#FFD54F', 6, [[220, 100], [220, 60]]),
      LineArtCatalog.strokeFromPoints('#FFD54F', 8, [[300, 80], [320, 80]])
    ]
    out.push(s3)
    return out
  }

  private static buildGuideSun(): DrawGuideStep[] {
    const out: DrawGuideStep[] = []
    const s0 = new DrawGuideStep()
    s0.order = 0
    s0.instruction = '先画一个大圆'
    s0.strokes = [LineArtCatalog.strokeFromPoints('#FFD54F', 10, [[180, 180], [220, 180]])]
    out.push(s0)
    const s1 = new DrawGuideStep()
    s1.order = 1
    s1.instruction = '四周画上光芒'
    s1.strokes = [
      LineArtCatalog.strokeFromPoints('#FF8A65', 8, [[200, 80], [200, 40]]),
      LineArtCatalog.strokeFromPoints('#FF8A65', 8, [[200, 280], [200, 320]]),
      LineArtCatalog.strokeFromPoints('#FF8A65', 8, [[80, 180], [40, 180]]),
      LineArtCatalog.strokeFromPoints('#FF8A65', 8, [[320, 180], [360, 180]])
    ]
    out.push(s1)
    const s2 = new DrawGuideStep()
    s2.order = 2
    s2.instruction = '给小太阳画上笑脸'
    s2.strokes = [
      LineArtCatalog.strokeFromPoints('#4A4A4A', 4, [[170, 170], [190, 170]]),
      LineArtCatalog.strokeFromPoints('#4A4A4A', 4, [[210, 170], [230, 170]]),
      LineArtCatalog.strokeFromPoints('#4A4A4A', 4, [[175, 200], [200, 215], [225, 200]])
    ]
    out.push(s2)
    return out
  }

  static mediaResource(key: string): Resource {
    if (key === 'cover_plant') {
      return $r('app.media.cover_plant')
    }
    if (key === 'cover_vehicle') {
      return $r('app.media.cover_vehicle')
    }
    if (key === 'cover_fairy') {
      return $r('app.media.cover_fairy')
    }
    if (key === 'card_doodle') {
      return $r('app.media.card_doodle')
    }
    if (key === 'card_fill') {
      return $r('app.media.card_fill')
    }
    if (key === 'card_workshop') {
      return $r('app.media.cover_fairy')
    }
    return $r('app.media.cover_animal')
  }
}
