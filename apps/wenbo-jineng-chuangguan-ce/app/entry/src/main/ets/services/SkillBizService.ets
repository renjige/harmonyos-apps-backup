import { HttpClient } from './HttpClient'
import { ProgressStore } from './ProgressStore'
import {
  BadgeListData,
  CategoryListData,
  KpiListData,
  LeaderboardListData,
  LevelListData,
  MsgListData,
  SkillBadge,
  SkillCategory,
  SkillLevel,
  LeaderboardEntry,
  KpiItem,
  MsgItem
} from '../models/SkillModels'

const BASE = '/biz/skill-challenge'

export class SkillBizService {
  private static memLevels: SkillLevel[] = []

  static lastHint(): string {
    if (HttpClient.lastError.length > 0) {
      return HttpClient.lastError
    }
    return '请检查网络后重试。闯关进度仍保存在本机。'
  }

  static async loadCategories(): Promise<SkillCategory[]> {
    const res = await HttpClient.get<CategoryListData>(`${BASE}/categories`)
    if (res.code === 0 && res.data !== undefined && res.data.list.length > 0) {
      return res.data.list
    }
    return []
  }

  static async loadRecommended(): Promise<SkillLevel[]> {
    return SkillBizService.fetchLevels(`${BASE}/levels?recommend=1`, 'catalog_recommend')
  }

  static async loadLevelsByCategory(category: string): Promise<SkillLevel[]> {
    const path = category.length > 0 ?
      `${BASE}/levels?category=${category}` : `${BASE}/levels`
    return SkillBizService.fetchLevels(path, `catalog_lv_${category}`)
  }

  static async loadAllLevels(): Promise<SkillLevel[]> {
    return SkillBizService.fetchLevels(`${BASE}/levels`, 'catalog_levels')
  }

  static async loadLevel(id: string): Promise<SkillLevel | undefined> {
    const found = SkillBizService.findLevel(SkillBizService.memLevels, id)
    if (found !== undefined) {
      return found
    }
    const res = await HttpClient.get<SkillLevel>(`${BASE}/levels/${id}`)
    if (res.code === 0 && res.data !== undefined && res.data.id.length > 0) {
      const level = SkillBizService.mapLevel(res.data)
      SkillBizService.rememberLevel(level)
      return level
    }
    return undefined
  }

  static async loadBadges(): Promise<SkillBadge[]> {
    const res = await HttpClient.get<BadgeListData>(`${BASE}/badges`)
    if (res.code === 0 && res.data !== undefined) {
      return res.data.list
    }
    return []
  }

  static async loadBadge(id: string): Promise<SkillBadge | undefined> {
    const list = await SkillBizService.loadBadges()
    const found = SkillBizService.findBadge(list, id)
    if (found !== undefined) {
      return found
    }
    const res = await HttpClient.get<SkillBadge>(`${BASE}/badges/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return res.data
    }
    return undefined
  }

  static async loadLeaderboard(category: string): Promise<LeaderboardEntry[]> {
    const cat = category.length > 0 ? category : 'all'
    const path = cat === 'all' ? `${BASE}/leaderboard` : `${BASE}/leaderboard?category=${cat}`
    const res = await HttpClient.get<LeaderboardListData>(path)
    if (res.code === 0 && res.data !== undefined) {
      return res.data.list
    }
    return []
  }

  static async loadKpis(): Promise<KpiItem[]> {
    const res = await HttpClient.get<KpiListData>(`${BASE}/kpis`)
    if (res.code === 0 && res.data !== undefined) {
      return SkillBizService.mapKpis(res.data.list)
    }
    return []
  }

  static async loadMessages(): Promise<MsgItem[]> {
    const res = await HttpClient.get<MsgListData>(`${BASE}/messages`)
    if (res.code === 0 && res.data !== undefined) {
      return res.data.list
    }
    return []
  }

  static findLevel(list: SkillLevel[], id: string): SkillLevel | undefined {
    for (const p of list) {
      if (p.id === id) {
        return p
      }
    }
    return undefined
  }

  static findCategory(list: SkillCategory[], id: string): SkillCategory | undefined {
    for (const p of list) {
      if (p.id === id || p.category === id) {
        return p
      }
    }
    return undefined
  }

  static findBadge(list: SkillBadge[], id: string): SkillBadge | undefined {
    for (const p of list) {
      if (p.id === id) {
        return p
      }
    }
    return undefined
  }

  static difficultyStars(level: SkillLevel): string {
    const d = level.difficulty > 0 ? level.difficulty : 1
    let stars = ''
    for (let i = 0; i < d && i < 5; i++) {
      stars = `${stars}★`
    }
    return stars.length > 0 ? stars : '★'
  }

  private static async fetchLevels(path: string, catalogKey: string): Promise<SkillLevel[]> {
    const res = await HttpClient.get<LevelListData>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list.length > 0) {
      const list = SkillBizService.mapLevels(res.data.list)
      SkillBizService.rememberLevels(list)
      try {
        const raw = JSON.stringify(list)
        void ProgressStore.saveCatalog(catalogKey, raw)
      } catch {
      }
      return list
    }
    return SkillBizService.fromLevelCache(catalogKey)
  }

  private static mapLevel(raw: SkillLevel): SkillLevel {
    const lv = new SkillLevel()
    lv.id = raw.id ?? ''
    lv.title = raw.title ?? ''
    lv.subtitle = raw.subtitle ?? ''
    lv.summary = raw.summary ?? ''
    lv.body = raw.body ?? ''
    lv.description = raw.description ?? ''
    lv.taskBody = raw.taskBody ?? ''
    lv.coverKey = raw.coverKey ?? 'hero_bg'
    lv.category = raw.category ?? ''
    lv.categoryId = raw.categoryId ?? raw.category ?? ''
    lv.categoryLabel = raw.categoryLabel ?? ''
    lv.difficulty = raw.difficulty > 0 ? raw.difficulty : 1
    lv.durationMin = raw.durationMin > 0 ? raw.durationMin : 15
    lv.growthValue = raw.growthValue > 0 ? raw.growthValue : (raw.xp > 0 ? raw.xp : 20)
    lv.xp = raw.xp > 0 ? raw.xp : lv.growthValue
    lv.prerequisiteId = raw.prerequisiteId ?? ''
    return lv
  }

  private static mapLevels(list: SkillLevel[]): SkillLevel[] {
    const out: SkillLevel[] = []
    for (const raw of list) {
      out.push(SkillBizService.mapLevel(raw))
    }
    return out
  }

  private static mapKpi(raw: KpiItem): KpiItem {
    const k = new KpiItem()
    k.key = raw.key ?? ''
    k.id = k.key.length > 0 ? k.key : (raw.id ?? '')
    k.label = raw.label ?? ''
    const v = raw.value
    k.value = typeof v === 'number' ? `${v}` : (v ?? '')
    k.unit = raw.unit ?? ''
    k.trend = raw.trend ?? ''
    return k
  }

  private static mapKpis(list: KpiItem[]): KpiItem[] {
    const out: KpiItem[] = []
    for (const raw of list) {
      out.push(SkillBizService.mapKpi(raw))
    }
    return out
  }

  private static rememberLevel(level: SkillLevel): void {
    let found = false
    for (let i = 0; i < SkillBizService.memLevels.length; i++) {
      if (SkillBizService.memLevels[i].id === level.id) {
        SkillBizService.memLevels[i] = level
        found = true
        break
      }
    }
    if (!found) {
      SkillBizService.memLevels.push(level)
    }
  }

  private static rememberLevels(list: SkillLevel[]): void {
    for (const lv of list) {
      SkillBizService.rememberLevel(lv)
    }
  }

  private static fromLevelCache(key: string): SkillLevel[] {
    const raw = ProgressStore.catalog(key)
    if (raw.length === 0) {
      return []
    }
    try {
      const parsed = JSON.parse(raw) as SkillLevel[]
      return SkillBizService.mapLevels(parsed)
    } catch {
      return []
    }
  }
}
