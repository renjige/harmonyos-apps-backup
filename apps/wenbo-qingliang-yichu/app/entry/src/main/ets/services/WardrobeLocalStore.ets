import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import {
  WardrobeItemModel,
  WardrobeOutfitModel,
  WardrobeLookLogModel,
  WardrobeTipModel,
  WardrobeSummaryModel
} from '../models/WardrobeModels'
import { WardrobeMedia } from './WardrobeMedia'

const TAG = 'WardrobeLocalStore'
const PREF_STORE_NAME = 'cw_wardrobe_store_v1'
const STORAGE_KEY_ITEMS = 'cw_wardrobe_items_v1'
const STORAGE_KEY_OUTFITS = 'cw_wardrobe_outfits_v1'
const STORAGE_KEY_LOGS = 'cw_wardrobe_logs_v1'
const STORAGE_KEY_TIPS = 'cw_wardrobe_tips_v1'

export class WardrobeLocalStore {
  private static pref: preferences.Preferences | null = null
  private static initialized: boolean = false
  private static itemsCache: WardrobeItemModel[] = []
  private static outfitsCache: WardrobeOutfitModel[] = []
  private static logsCache: WardrobeLookLogModel[] = []
  private static tipsCache: WardrobeTipModel[] = []

  static async initWithContext(context: common.UIAbilityContext): Promise<void> {
    try {
      WardrobeLocalStore.pref = await preferences.getPreferences(context, PREF_STORE_NAME)
      const rawItems = await WardrobeLocalStore.pref.get(STORAGE_KEY_ITEMS, '')
      const rawOutfits = await WardrobeLocalStore.pref.get(STORAGE_KEY_OUTFITS, '')
      const rawLogs = await WardrobeLocalStore.pref.get(STORAGE_KEY_LOGS, '')

      // 1. Items
      if (typeof rawItems === 'string' && rawItems.length > 0) {
        try {
          const parsed = JSON.parse(rawItems) as WardrobeItemModel[]
          WardrobeLocalStore.itemsCache = parsed.map((x) => new WardrobeItemModel(
            x.id, x.name, x.category, x.color, x.colorHex, x.season, x.scene, x.remark, x.coverKey, x.wearCount, x.lastWornAt
          ))
        } catch {
          WardrobeLocalStore.itemsCache = WardrobeLocalStore.defaultItems()
        }
      } else {
        WardrobeLocalStore.itemsCache = WardrobeLocalStore.defaultItems()
        await WardrobeLocalStore.persistItemsAsync()
      }

      // 2. Outfits
      if (typeof rawOutfits === 'string' && rawOutfits.length > 0) {
        try {
          const parsed = JSON.parse(rawOutfits) as WardrobeOutfitModel[]
          WardrobeLocalStore.outfitsCache = parsed.map((x) => new WardrobeOutfitModel(
            x.id, x.title, x.style, x.scene, x.weather, x.topName, x.bottomName, x.shoesName, x.accessoryName, x.dressName, x.tips, x.isSaved
          ))
        } catch {
          WardrobeLocalStore.outfitsCache = WardrobeLocalStore.defaultOutfits()
        }
      } else {
        WardrobeLocalStore.outfitsCache = WardrobeLocalStore.defaultOutfits()
        await WardrobeLocalStore.persistOutfitsAsync()
      }

      // 3. Look Logs
      if (typeof rawLogs === 'string' && rawLogs.length > 0) {
        try {
          const parsed = JSON.parse(rawLogs) as WardrobeLookLogModel[]
          WardrobeLocalStore.logsCache = parsed.map((x) => new WardrobeLookLogModel(
            x.id, x.date, x.outfitId, x.outfitTitle, x.itemNames, x.style, x.scene, x.mood
          ))
        } catch {
          WardrobeLocalStore.logsCache = WardrobeLocalStore.defaultLogs()
        }
      } else {
        WardrobeLocalStore.logsCache = WardrobeLocalStore.defaultLogs()
        await WardrobeLocalStore.persistLogsAsync()
      }

      WardrobeLocalStore.tipsCache = WardrobeLocalStore.defaultTips()
      WardrobeLocalStore.initialized = true
      hilog.info(0x0000, TAG, 'WardrobeLocalStore initialized from preferences with %{public}d items', WardrobeLocalStore.itemsCache.length)
    } catch {
      WardrobeLocalStore.init()
    }
  }

  static init(): void {
    if (WardrobeLocalStore.initialized) return

    // 1. Load or seed Items
    const rawItems = AppStorage.get<string>(STORAGE_KEY_ITEMS)
    if (rawItems && rawItems.length > 0) {
      try {
        const parsed = JSON.parse(rawItems) as WardrobeItemModel[]
        WardrobeLocalStore.itemsCache = parsed.map((x) => new WardrobeItemModel(
          x.id, x.name, x.category, x.color, x.colorHex, x.season, x.scene, x.remark, x.coverKey, x.wearCount, x.lastWornAt
        ))
      } catch {
        WardrobeLocalStore.itemsCache = WardrobeLocalStore.defaultItems()
      }
    } else {
      WardrobeLocalStore.itemsCache = WardrobeLocalStore.defaultItems()
      WardrobeLocalStore.persistItems()
    }

    // 2. Load or seed Outfits
    const rawOutfits = AppStorage.get<string>(STORAGE_KEY_OUTFITS)
    if (rawOutfits && rawOutfits.length > 0) {
      try {
        const parsed = JSON.parse(rawOutfits) as WardrobeOutfitModel[]
        WardrobeLocalStore.outfitsCache = parsed.map((x) => new WardrobeOutfitModel(
          x.id, x.title, x.style, x.scene, x.weather, x.topName, x.bottomName, x.shoesName, x.accessoryName, x.dressName, x.tips, x.isSaved
        ))
      } catch {
        WardrobeLocalStore.outfitsCache = WardrobeLocalStore.defaultOutfits()
      }
    } else {
      WardrobeLocalStore.outfitsCache = WardrobeLocalStore.defaultOutfits()
      WardrobeLocalStore.persistOutfits()
    }

    // 3. Load or seed Look Logs
    const rawLogs = AppStorage.get<string>(STORAGE_KEY_LOGS)
    if (rawLogs && rawLogs.length > 0) {
      try {
        const parsed = JSON.parse(rawLogs) as WardrobeLookLogModel[]
        WardrobeLocalStore.logsCache = parsed.map((x) => new WardrobeLookLogModel(
          x.id, x.date, x.outfitId, x.outfitTitle, x.itemNames, x.style, x.scene, x.mood
        ))
      } catch {
        WardrobeLocalStore.logsCache = WardrobeLocalStore.defaultLogs()
      }
    } else {
      WardrobeLocalStore.logsCache = WardrobeLocalStore.defaultLogs()
      WardrobeLocalStore.persistLogs()
    }

    // 4. Load or seed Tips
    WardrobeLocalStore.tipsCache = WardrobeLocalStore.defaultTips()
    WardrobeLocalStore.initialized = true
  }

  // --- Items CRUD ---
  static getItems(category: string = '全部'): WardrobeItemModel[] {
    WardrobeLocalStore.init()
    if (category === '全部' || category === '') {
      return [...WardrobeLocalStore.itemsCache]
    }
    return WardrobeLocalStore.itemsCache.filter((x) => x.category === category)
  }

  static getItem(id: string): WardrobeItemModel | undefined {
    WardrobeLocalStore.init()
    return WardrobeLocalStore.itemsCache.find((x) => x.id === id)
  }

  static addItem(item: WardrobeItemModel): void {
    WardrobeLocalStore.init()
    if (!item.id || item.id.length === 0) {
      item.id = 'item_' + Date.now().toString(36)
    }
    item.colorHex = WardrobeMedia.resolveColorHex(item.color)
    WardrobeLocalStore.itemsCache.unshift(item)
    WardrobeLocalStore.persistItems()
  }

  static updateItem(item: WardrobeItemModel): void {
    WardrobeLocalStore.init()
    const idx = WardrobeLocalStore.itemsCache.findIndex((x) => x.id === item.id)
    if (idx >= 0) {
      item.colorHex = WardrobeMedia.resolveColorHex(item.color)
      item.updatedAt = new Date().toISOString()
      WardrobeLocalStore.itemsCache[idx] = item
      WardrobeLocalStore.persistItems()
    }
  }

  static deleteItem(id: string): boolean {
    WardrobeLocalStore.init()
    const before = WardrobeLocalStore.itemsCache.length
    WardrobeLocalStore.itemsCache = WardrobeLocalStore.itemsCache.filter((x) => x.id !== id)
    if (WardrobeLocalStore.itemsCache.length !== before) {
      WardrobeLocalStore.persistItems()
      return true
    }
    return false
  }

  // --- Outfits CRUD ---
  static getOutfits(style: string = '全部', scene: string = '全部', weather: string = '全部'): WardrobeOutfitModel[] {
    WardrobeLocalStore.init()
    return WardrobeLocalStore.outfitsCache.filter((x) => {
      const matchStyle = style === '全部' || style === '' || x.style === style
      const matchScene = scene === '全部' || scene === '' || x.scene === scene
      const matchWeather = weather === '全部' || weather === '' || x.weather === weather
      return matchStyle && matchScene && matchWeather
    })
  }

  static getSavedOutfits(): WardrobeOutfitModel[] {
    WardrobeLocalStore.init()
    return WardrobeLocalStore.outfitsCache.filter((x) => x.isSaved)
  }

  static getOutfit(id: string): WardrobeOutfitModel | undefined {
    WardrobeLocalStore.init()
    return WardrobeLocalStore.outfitsCache.find((x) => x.id === id)
  }

  static saveOutfit(outfit: WardrobeOutfitModel): void {
    WardrobeLocalStore.init()
    if (!outfit.id || outfit.id.length === 0) {
      outfit.id = 'outfit_' + Date.now().toString(36)
    }
    outfit.isSaved = true
    const idx = WardrobeLocalStore.outfitsCache.findIndex((x) => x.id === outfit.id)
    if (idx >= 0) {
      WardrobeLocalStore.outfitsCache[idx] = outfit
    } else {
      WardrobeLocalStore.outfitsCache.unshift(outfit)
    }
    WardrobeLocalStore.persistOutfits()
  }

  static unsaveOutfit(id: string): void {
    WardrobeLocalStore.init()
    const idx = WardrobeLocalStore.outfitsCache.findIndex((x) => x.id === id)
    if (idx >= 0) {
      WardrobeLocalStore.outfitsCache[idx].isSaved = false
      WardrobeLocalStore.persistOutfits()
    }
  }

  // --- Look Logs CRUD ---
  static getLookLogs(): WardrobeLookLogModel[] {
    WardrobeLocalStore.init()
    return [...WardrobeLocalStore.logsCache]
  }

  static getLogByDate(dateStr: string): WardrobeLookLogModel | undefined {
    WardrobeLocalStore.init()
    return WardrobeLocalStore.logsCache.find((x) => x.date === dateStr)
  }

  static getLookLogByDate(dateStr: string): WardrobeLookLogModel | undefined {
    return WardrobeLocalStore.getLogByDate(dateStr)
  }

  static addLookLog(log: WardrobeLookLogModel): void {
    WardrobeLocalStore.init()
    if (!log.id || log.id.length === 0) {
      log.id = 'log_' + Date.now().toString(36)
    }
    // Remove existing log for same date if any
    WardrobeLocalStore.logsCache = WardrobeLocalStore.logsCache.filter((x) => x.date !== log.date)
    WardrobeLocalStore.logsCache.unshift(log)
    WardrobeLocalStore.persistLogs()

    // Increment wear counts for included items
    if (Array.isArray(log.itemNames)) {
      for (const name of log.itemNames) {
        const item = WardrobeLocalStore.itemsCache.find((x) => x.name === name)
        if (item) {
          item.wearCount = (item.wearCount || 0) + 1
          item.lastWornAt = log.date
        }
      }
      WardrobeLocalStore.persistItems()
    }
  }

  static deleteLookLog(dateStr: string): void {
    WardrobeLocalStore.init()
    WardrobeLocalStore.logsCache = WardrobeLocalStore.logsCache.filter((x) => x.date !== dateStr)
    WardrobeLocalStore.persistLogs()
  }

  // --- Tips ---
  static getTips(): WardrobeTipModel[] {
    WardrobeLocalStore.init()
    return [...WardrobeLocalStore.tipsCache]
  }

  // --- Summary & Insights ---
  static getSummary(): WardrobeSummaryModel {
    WardrobeLocalStore.init()
    const items = WardrobeLocalStore.itemsCache
    const logs = WardrobeLocalStore.logsCache

    let tops = 0
    let bottoms = 0
    let dresses = 0
    let jackets = 0
    let shoes = 0
    let accessories = 0

    const colorCounts: Record<string, number> = {}

    for (const it of items) {
      if (it.category === '上装') tops++
      else if (it.category === '下装') bottoms++
      else if (it.category === '连衣裙') dresses++
      else if (it.category === '外套') jackets++
      else if (it.category === '鞋履') shoes++
      else if (it.category === '配饰') accessories++

      const c = it.color || '浅色'
      colorCounts[c] = (colorCounts[c] || 0) + 1
    }

    let topColor = '浅蓝 / 米白'
    let maxColorCount = 0
    for (const key of Object.keys(colorCounts)) {
      if (colorCounts[key] > maxColorCount) {
        maxColorCount = colorCounts[key]
        topColor = key
      }
    }

    const currentMonth = new Date().toISOString().slice(0, 7)
    const monthlyLooks = logs.filter((x) => x.date.startsWith(currentMonth)).length

    return new WardrobeSummaryModel(
      items.length,
      tops,
      bottoms,
      dresses,
      jackets,
      shoes,
      accessories,
      monthlyLooks > 0 ? monthlyLooks : logs.length,
      topColor,
      '清爽简约',
      '日常 / 通勤'
    )
  }

  // --- Persistence ---
  private static persistItems(): void {
    const json = JSON.stringify(WardrobeLocalStore.itemsCache)
    AppStorage.setOrCreate(STORAGE_KEY_ITEMS, json)
    if (WardrobeLocalStore.pref !== null) {
      try {
        WardrobeLocalStore.pref.put(STORAGE_KEY_ITEMS, json).then(() => {
          if (WardrobeLocalStore.pref !== null) {
            WardrobeLocalStore.pref.flush()
          }
        }).catch(() => {})
      } catch {}
    }
  }

  private static async persistItemsAsync(): Promise<void> {
    const json = JSON.stringify(WardrobeLocalStore.itemsCache)
    AppStorage.setOrCreate(STORAGE_KEY_ITEMS, json)
    if (WardrobeLocalStore.pref !== null) {
      try {
        await WardrobeLocalStore.pref.put(STORAGE_KEY_ITEMS, json)
        await WardrobeLocalStore.pref.flush()
      } catch {}
    }
  }

  private static persistOutfits(): void {
    const json = JSON.stringify(WardrobeLocalStore.outfitsCache)
    AppStorage.setOrCreate(STORAGE_KEY_OUTFITS, json)
    if (WardrobeLocalStore.pref !== null) {
      try {
        WardrobeLocalStore.pref.put(STORAGE_KEY_OUTFITS, json).then(() => {
          if (WardrobeLocalStore.pref !== null) {
            WardrobeLocalStore.pref.flush()
          }
        }).catch(() => {})
      } catch {}
    }
  }

  private static async persistOutfitsAsync(): Promise<void> {
    const json = JSON.stringify(WardrobeLocalStore.outfitsCache)
    AppStorage.setOrCreate(STORAGE_KEY_OUTFITS, json)
    if (WardrobeLocalStore.pref !== null) {
      try {
        await WardrobeLocalStore.pref.put(STORAGE_KEY_OUTFITS, json)
        await WardrobeLocalStore.pref.flush()
      } catch {}
    }
  }

  private static persistLogs(): void {
    const json = JSON.stringify(WardrobeLocalStore.logsCache)
    AppStorage.setOrCreate(STORAGE_KEY_LOGS, json)
    if (WardrobeLocalStore.pref !== null) {
      try {
        WardrobeLocalStore.pref.put(STORAGE_KEY_LOGS, json).then(() => {
          if (WardrobeLocalStore.pref !== null) {
            WardrobeLocalStore.pref.flush()
          }
        }).catch(() => {})
      } catch {}
    }
  }

  private static async persistLogsAsync(): Promise<void> {
    const json = JSON.stringify(WardrobeLocalStore.logsCache)
    AppStorage.setOrCreate(STORAGE_KEY_LOGS, json)
    if (WardrobeLocalStore.pref !== null) {
      try {
        await WardrobeLocalStore.pref.put(STORAGE_KEY_LOGS, json)
        await WardrobeLocalStore.pref.flush()
      } catch {}
    }
  }

  // --- Default Seeds ---
  private static defaultItems(): WardrobeItemModel[] {
    return [
      new WardrobeItemModel('item-01', '浅蓝亚麻衬衫', '上装', '浅蓝', '#8FB8DE', '夏季', '通勤', '透气亲肤，夏日职场与日常通勤百搭', 'shirt_blue', 12, '2026-08-18'),
      new WardrobeItemModel('item-02', '米白直筒休闲阔腿裤', '下装', '米白', '#F3EFE6', '夏季', '日常', '垂感极佳，清凉显瘦', 'pants_beige', 15, '2026-08-19'),
      new WardrobeItemModel('item-03', '薄荷绿真丝短袖', '上装', '薄荷绿', '#A8DADC', '夏季', '休闲', '微光泽感，夏日视觉降温必备', 'top_mint', 8, '2026-08-15'),
      new WardrobeItemModel('item-04', '法式复古白茶长裙', '连衣裙', '白色', '#FFFFFF', '夏季', '约会', '轻盈收腰，优雅灵动', 'dress_white', 6, '2026-08-10'),
      new WardrobeItemModel('item-05', '浅灰防晒轻薄开衫', '外套', '浅灰', '#D3D7D9', '夏季', '通勤', '空调房与户外防晒两用', 'jacket_grey', 10, '2026-08-16'),
      new WardrobeItemModel('item-06', '经典小白休闲平底鞋', '鞋履', '白色', '#FAFAFA', '四季', '日常', '舒适软底，百搭任何夏季穿搭', 'shoes_white', 20, '2026-08-19'),
      new WardrobeItemModel('item-07', '编织草编手提包', '配饰', '米色', '#E8D8C8', '夏季', '休闲', '夏日度假与周末悠闲风格点缀', 'bag_straw', 5, '2026-08-12'),
      new WardrobeItemModel('item-08', '藏青极简通勤西裤', '下装', '深蓝', '#1D3557', '四季', '通勤', '利落剪裁，修饰腿型', 'pants_navy', 9, '2026-08-14'),
    ]
  }

  private static defaultOutfits(): WardrobeOutfitModel[] {
    return [
      new WardrobeOutfitModel('outfit-01', '清凉薄荷风通勤搭配', '清爽', '通勤', '晴', '浅蓝亚麻衬衫', '米白直筒休闲阔腿裤', '经典小白休闲平底鞋', '编织草编手提包', '', '浅色系能够让整体造型更加轻盈，适合春夏季日常与轻办公穿着。', true),
      new WardrobeOutfitModel('outfit-02', '夏日周末微风漫步', '简约', '日常', '多云', '薄荷绿真丝短袖', '米白直筒休闲阔腿裤', '经典小白休闲平底鞋', '浅灰防晒轻薄开衫', '', '薄荷绿与米白色系碰撞，营造自然清爽的视觉层次感。', false),
      new WardrobeOutfitModel('outfit-03', '法式优雅午后约会', '优雅', '约会', '晴', '', '', '经典小白休闲平底鞋', '编织草编手提包', '法式复古白茶长裙', '一袭白裙搭配草编配饰，夏日法式松弛感自然流露。', true),
      new WardrobeOutfitModel('outfit-04', '都市利落干练职场装', '简约', '通勤', '阴', '浅蓝亚麻衬衫', '藏青极简通勤西裤', '经典小白休闲平底鞋', '浅灰防晒轻薄开衫', '', '经典蓝白与深蓝冷色调搭配，营造沉稳利落的职场气场。', true),
    ]
  }

  private static defaultLogs(): WardrobeLookLogModel[] {
    const today = new Date().toISOString().slice(0, 10)
    return [
      new WardrobeLookLogModel('log-01', today, 'outfit-01', '清凉薄荷风通勤搭配', ['浅蓝亚麻衬衫', '米白直筒休闲阔腿裤', '经典小白休闲平底鞋'], '清爽', '通勤', '今天工作很顺畅，衣服很透气凉快'),
    ]
  }

  private static defaultTips(): WardrobeTipModel[] {
    return [
      new WardrobeTipModel('tip-01', '夏日清凉色彩法则：用 60% 浅色打底', '色彩', '以米白、浅灰或淡青为大面积基底，点缀 30% 清爽主色与 10% 配饰。', '在闷热的夏日，视觉降温的核心在于大面积使用高明度、低饱和度的中性色。例如米白阔腿裤搭配浅蓝衬衫，整体明亮通透，给人带来如沐清风的舒适感。', '色彩美学'),
      new WardrobeTipModel('tip-02', '天然面料的呼吸感：亚麻与真丝的夏季搭配', '材质', '亚麻的质朴肌理与真丝的垂坠光泽，碰撞出高级的极简层次。', '夏季穿搭追求体感与质感的平衡。亚麻面料具有天然的吸湿排汗特性，与触感柔滑的真丝上衣搭配，兼顾了凉爽舒适与现代都市生活的高级质感。', '材质精选'),
      new WardrobeTipModel('tip-03', '胶囊衣橱的减法艺术：精简常穿的 20 件单品', '整理', '定期整理衣橱，留下真正让你感到自信与舒展的衣服。', '整理衣物也是整理每天的心情。通过按季节、场景和颜色分类，将超过 3 个月未记录穿着的衣物进行合理归置，让衣橱始终保持井然有序与呼吸感。', '智慧整理'),
    ]
  }
}
