/**
 * Wardrobe Data Models — ArkTS strict-mode compatible classes.
 */

export class WardrobeItemModel {
  id: string = ''
  name: string = ''
  category: string = '上装' // 全部 / 上装 / 下装 / 连衣裙 / 外套 / 鞋履 / 配饰
  color: string = '浅蓝'
  colorHex: string = '#8FB8DE'
  season: string = '夏季' // 春季 / 夏季 / 秋季 / 冬季 / 四季
  scene: string = '日常' // 日常 / 通勤 / 约会 / 休闲 / 运动
  remark: string = ''
  coverKey: string = 'shirt_blue'
  wearCount: number = 0
  lastWornAt: string = ''
  createdAt: string = ''
  updatedAt: string = ''

  constructor(
    id: string = '',
    name: string = '',
    category: string = '上装',
    color: string = '浅蓝',
    colorHex: string = '#8FB8DE',
    season: string = '夏季',
    scene: string = '日常',
    remark: string = '',
    coverKey: string = 'shirt_blue',
    wearCount: number = 0,
    lastWornAt: string = ''
  ) {
    this.id = id
    this.name = name
    this.category = category
    this.color = color
    this.colorHex = colorHex
    this.season = season
    this.scene = scene
    this.remark = remark
    this.coverKey = coverKey
    this.wearCount = wearCount
    this.lastWornAt = lastWornAt
    this.createdAt = new Date().toISOString()
    this.updatedAt = new Date().toISOString()
  }
}

export class WardrobeOutfitModel {
  id: string = ''
  title: string = ''
  style: string = '清爽' // 清爽 / 简约 / 休闲 / 优雅
  scene: string = '日常' // 日常 / 通勤 / 约会 / 休闲 / 运动
  weather: string = '晴' // 晴 / 多云 / 阴 / 雨
  topName: string = ''
  bottomName: string = ''
  shoesName: string = ''
  accessoryName: string = ''
  dressName: string = ''
  tips: string = ''
  isSaved: boolean = false
  createdAt: string = ''
  updatedAt: string = ''

  constructor(
    id: string = '',
    title: string = '',
    style: string = '清爽',
    scene: string = '日常',
    weather: string = '晴',
    topName: string = '',
    bottomName: string = '',
    shoesName: string = '',
    accessoryName: string = '',
    dressName: string = '',
    tips: string = '',
    isSaved: boolean = false
  ) {
    this.id = id
    this.title = title
    this.style = style
    this.scene = scene
    this.weather = weather
    this.topName = topName
    this.bottomName = bottomName
    this.shoesName = shoesName
    this.accessoryName = accessoryName
    this.dressName = dressName
    this.tips = tips
    this.isSaved = isSaved
    this.createdAt = new Date().toISOString()
    this.updatedAt = new Date().toISOString()
  }
}

export class WardrobeLookLogModel {
  id: string = ''
  date: string = '' // YYYY-MM-DD
  outfitId: string = ''
  outfitTitle: string = ''
  itemNames: string[] = []
  style: string = '清爽'
  scene: string = '日常'
  mood: string = '今天穿搭很清爽舒服'
  createdAt: string = ''

  constructor(
    id: string = '',
    date: string = '',
    outfitId: string = '',
    outfitTitle: string = '',
    itemNames: string[] = [],
    style: string = '清爽',
    scene: string = '日常',
    mood: string = ''
  ) {
    this.id = id
    this.date = date
    this.outfitId = outfitId
    this.outfitTitle = outfitTitle
    this.itemNames = itemNames
    this.style = style
    this.scene = scene
    this.mood = mood
    this.createdAt = new Date().toISOString()
  }
}

export class WardrobeTipModel {
  id: string = ''
  title: string = ''
  category: string = '色彩'
  summary: string = ''
  content: string = ''
  tag: string = ''

  constructor(
    id: string = '',
    title: string = '',
    category: string = '色彩',
    summary: string = '',
    content: string = '',
    tag: string = ''
  ) {
    this.id = id
    this.title = title
    this.category = category
    this.summary = summary
    this.content = content
    this.tag = tag
  }
}

export class WardrobeSummaryModel {
  totalItems: number = 0
  tops: number = 0
  bottoms: number = 0
  dresses: number = 0
  jackets: number = 0
  shoes: number = 0
  accessories: number = 0
  monthlyLooks: number = 0
  topColor: string = '浅蓝 / 米白'
  topStyle: string = '清爽简约'
  topScene: string = '日常 / 通勤'

  totalCount: number = 0
  topsCount: number = 0
  bottomsCount: number = 0
  dressesCount: number = 0
  jacketsCount: number = 0
  shoesCount: number = 0
  accessoriesCount: number = 0
  monthlyLookCount: number = 0

  constructor(
    totalItems: number = 0,
    tops: number = 0,
    bottoms: number = 0,
    dresses: number = 0,
    jackets: number = 0,
    shoes: number = 0,
    accessories: number = 0,
    monthlyLooks: number = 0,
    topColor: string = '浅蓝 / 米白',
    topStyle: string = '清爽简约',
    topScene: string = '日常 / 通勤'
  ) {
    this.totalItems = totalItems
    this.tops = tops
    this.bottoms = bottoms
    this.dresses = dresses
    this.jackets = jackets
    this.shoes = shoes
    this.accessories = accessories
    this.monthlyLooks = monthlyLooks
    this.topColor = topColor
    this.topStyle = topStyle
    this.topScene = topScene

    this.totalCount = totalItems
    this.topsCount = tops
    this.bottomsCount = bottoms
    this.dressesCount = dresses
    this.jacketsCount = jackets
    this.shoesCount = shoes
    this.accessoriesCount = accessories
    this.monthlyLookCount = monthlyLooks
  }
}
