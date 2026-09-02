import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { ColorPalette } from '../models/PaletteModels'

const STORE = 'zhange_palette_v1'
const KEY_PALETTES = 'palettes'
const KEY_SEEDED = 'seeded'

export class PaletteStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      PaletteStore.pref = await preferences.getPreferences(context, STORE)
      await PaletteStore.ensureSeed()
    } catch {
      PaletteStore.pref = null
    }
  }

  static async loadAll(): Promise<ColorPalette[]> {
    const raw = await PaletteStore.getString(KEY_PALETTES, '')
    return PaletteStore.parsePalettes(raw)
  }

  static async findById(id: string): Promise<ColorPalette | undefined> {
    const list = await PaletteStore.loadAll()
    for (const item of list) {
      if (item.id === id) {
        return item
      }
    }
    return undefined
  }

  static async save(item: ColorPalette): Promise<void> {
    const list = await PaletteStore.loadAll()
    let found = false
    const next: ColorPalette[] = []
    for (const row of list) {
      if (row.id === item.id) {
        next.push(item)
        found = true
      } else {
        next.push(row)
      }
    }
    if (!found) {
      next.unshift(item)
    }
    await PaletteStore.persist(next)
  }

  static async remove(id: string): Promise<void> {
    const list = await PaletteStore.loadAll()
    const next: ColorPalette[] = []
    for (const row of list) {
      if (row.id !== id) {
        next.push(row)
      }
    }
    await PaletteStore.persist(next)
  }

  static async replaceAll(items: ColorPalette[]): Promise<void> {
    await PaletteStore.persist(items)
  }

  static async lastUpdatedLabel(): Promise<string> {
    const list = await PaletteStore.loadAll()
    if (list.length === 0) {
      return '暂无'
    }
    let latest = list[0].createdAt
    for (const row of list) {
      if (row.createdAt > latest) {
        latest = row.createdAt
      }
    }
    return latest.length > 10 ? latest.substring(0, 10) : latest
  }

  static async totalColorCount(): Promise<number> {
    const list = await PaletteStore.loadAll()
    let total = 0
    for (const row of list) {
      total += row.colors.length
    }
    return total
  }

  private static async ensureSeed(): Promise<void> {
    const seeded = await PaletteStore.getString(KEY_SEEDED, '')
    if (seeded === '1') {
      return
    }
    await PaletteStore.persist(PaletteStore.defaultSeed())
    await PaletteStore.putString(KEY_SEEDED, '1')
  }

  private static defaultSeed(): ColorPalette[] {
    const rows: ColorPalette[] = []
    const p1 = new ColorPalette()
    p1.id = 'pal_deep_blue'
    p1.name = '深海蓝调'
    p1.colors = ['#2C3E6B', '#4A6FA5', '#C9A84C', '#F5F0E8', '#1A2332']
    p1.note = '沉稳专业，适合品牌与工具类界面'
    p1.createdAt = '2026-08-20'
    p1.tags = ['品牌', '专业']
    rows.push(p1)

    const p2 = new ColorPalette()
    p2.id = 'pal_warm_gold'
    p2.name = '暖金暮光'
    p2.colors = ['#C9A84C', '#E8D5A3', '#8B6914', '#2C3E6B', '#FFF8F0']
    p2.note = '暖色点缀，适合展示与内容型页面'
    p2.createdAt = '2026-08-18'
    p2.tags = ['暖色', '展示']
    rows.push(p2)

    const p3 = new ColorPalette()
    p3.id = 'pal_forest'
    p3.name = '森绿清新'
    p3.colors = ['#2D6A4F', '#52B788', '#D8F3DC', '#1B4332', '#95D5B2']
    p3.note = '自然健康，适合生活与环保主题'
    p3.createdAt = '2026-08-15'
    p3.tags = ['自然', '清新']
    rows.push(p3)

    return rows
  }

  private static parsePalettes(raw: string): ColorPalette[] {
    if (raw.length === 0) {
      return []
    }
    try {
      const parsed = JSON.parse(raw) as object[]
      const rows: ColorPalette[] = []
      for (const item of parsed) {
        rows.push(PaletteStore.objectToPalette(item))
      }
      return rows
    } catch {
      return []
    }
  }

  private static objectToPalette(row: object): ColorPalette {
    const p = new ColorPalette()
    const r = row as Record<string, string | string[]>
    p.id = typeof r['id'] === 'string' ? r['id'] : `pal_${Date.now()}`
    p.name = typeof r['name'] === 'string' ? r['name'] : '未命名色板'
    p.note = typeof r['note'] === 'string' ? r['note'] : ''
    p.createdAt = typeof r['createdAt'] === 'string' ? r['createdAt'] : ''
    if (Array.isArray(r['colors'])) {
      p.colors = r['colors'] as string[]
    }
    if (Array.isArray(r['tags'])) {
      p.tags = r['tags'] as string[]
    }
    return p
  }

  private static paletteToObject(p: ColorPalette): object {
    const row: Record<string, string | string[]> = {}
    row['id'] = p.id
    row['name'] = p.name
    row['note'] = p.note
    row['createdAt'] = p.createdAt
    row['colors'] = p.colors
    row['tags'] = p.tags
    return row
  }

  private static async persist(list: ColorPalette[]): Promise<void> {
    const rows: object[] = []
    for (const item of list) {
      rows.push(PaletteStore.paletteToObject(item))
    }
    await PaletteStore.putString(KEY_PALETTES, JSON.stringify(rows))
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (PaletteStore.pref === null) {
      return fallback
    }
    try {
      const v = await PaletteStore.pref.get(key, fallback)
      return typeof v === 'string' ? v : `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (PaletteStore.pref === null) {
      return
    }
    try {
      await PaletteStore.pref.put(key, value)
      await PaletteStore.pref.flush()
    } catch {
      // ignore
    }
  }
}
