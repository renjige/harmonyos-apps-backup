import { HttpClient } from './HttpClient'
import {
  GuideItem,
  GuideListData,
  JigsawItem,
  JigsawListData,
  MedalItem,
  MedalListData,
  ThemeItem,
  ThemeListData
} from '../models/JigsawModels'

const BASE = '/biz/kids-jigsaw'
const CACHE_JIG = 'jigsawCacheJson'
const CACHE_THEME = 'jigsawThemeCacheJson'

export class JigsawBizService {
  static async loadThemes(): Promise<ThemeItem[]> {
    const res = await HttpClient.get<ThemeListData>(`${BASE}/themes`)
    if (res.code === 0 && res.data !== undefined && res.data.list.length > 0) {
      AppStorage.setOrCreate(CACHE_THEME, JSON.stringify(res.data.list))
      return res.data.list
    }
    return JigsawBizService.themesFromCache()
  }

  static async loadJigsaws(): Promise<JigsawItem[]> {
    const res = await HttpClient.get<JigsawListData>(`${BASE}/jigsaws`)
    if (res.code === 0 && res.data !== undefined && res.data.list.length > 0) {
      AppStorage.setOrCreate(CACHE_JIG, JSON.stringify(res.data.list))
      return res.data.list
    }
    return JigsawBizService.jigsawsFromCache()
  }

  static async loadMedals(): Promise<MedalItem[]> {
    const res = await HttpClient.get<MedalListData>(`${BASE}/medals`)
    if (res.code === 0 && res.data !== undefined) {
      return res.data.list
    }
    return []
  }

  static async loadGuides(): Promise<GuideItem[]> {
    const res = await HttpClient.get<GuideListData>(`${BASE}/guides`)
    if (res.code === 0 && res.data !== undefined) {
      return res.data.list
    }
    return []
  }

  static findJigsaw(list: JigsawItem[], id: string): JigsawItem | undefined {
    for (const item of list) {
      if (item.id === id) {
        return item
      }
    }
    return undefined
  }

  static byTheme(list: JigsawItem[], theme: string): JigsawItem[] {
    const out: JigsawItem[] = []
    for (const item of list) {
      if (item.theme === theme) {
        out.push(item)
      }
    }
    return out
  }

  static findTheme(list: ThemeItem[], theme: string): ThemeItem | undefined {
    for (const item of list) {
      if (item.theme === theme || item.id === theme) {
        return item
      }
    }
    return undefined
  }

  private static themesFromCache(): ThemeItem[] {
    const raw = AppStorage.get<string>(CACHE_THEME) ?? ''
    if (raw.length === 0) {
      return []
    }
    try {
      const parsed = JSON.parse(raw) as ThemeItem[]
      return parsed
    } catch {
      return []
    }
  }

  private static jigsawsFromCache(): JigsawItem[] {
    const raw = AppStorage.get<string>(CACHE_JIG) ?? ''
    if (raw.length === 0) {
      return []
    }
    try {
      const parsed = JSON.parse(raw) as JigsawItem[]
      return parsed
    } catch {
      return []
    }
  }
}
