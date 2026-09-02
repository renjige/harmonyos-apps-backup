import { HttpClient } from './HttpClient'
import {
  WardrobeItemModel,
  WardrobeOutfitModel,
  WardrobeTipModel
} from '../models/WardrobeModels'
import { WardrobeLocalStore } from './WardrobeLocalStore'

interface ApiListPayload<T> {
  list: T[]
}

interface OutfitWire {
  id: string
  title: string
  style?: string
  scene?: string
  weather?: string
  topName?: string
  bottomName?: string
  shoesName?: string
  accessoryName?: string
  dressName?: string
  tips?: string
  isSaved?: boolean
}

interface TipWire {
  id: string
  title: string
  category?: string
  summary?: string
  content?: string
  tag?: string
}

export class WardrobeBizService {
  static async loadItems(category: string = '全部'): Promise<WardrobeItemModel[]> {
    WardrobeLocalStore.init()
    return WardrobeLocalStore.getItems(category)
  }

  static async addItem(item: WardrobeItemModel): Promise<void> {
    WardrobeLocalStore.addItem(item)
    try {
      await HttpClient.post<WardrobeItemModel>('/biz/cool-wardrobe/items', item)
    } catch {
      // Offline fallback
    }
  }

  static async updateItem(item: WardrobeItemModel): Promise<void> {
    WardrobeLocalStore.updateItem(item)
    try {
      await HttpClient.put<WardrobeItemModel>(`/biz/cool-wardrobe/items/${item.id}`, item)
    } catch {
      // Offline fallback
    }
  }

  static async deleteItem(id: string): Promise<boolean> {
    const ok = WardrobeLocalStore.deleteItem(id)
    try {
      await HttpClient.delete<void>(`/biz/cool-wardrobe/items/${id}`)
    } catch {
      // Offline fallback
    }
    return ok
  }

  static async loadOutfits(style: string = '全部', scene: string = '全部', weather: string = '全部'): Promise<WardrobeOutfitModel[]> {
    WardrobeLocalStore.init()
    try {
      const res = await HttpClient.get<ApiListPayload<OutfitWire>>('/biz/cool-wardrobe/outfits')
      if (res.code === 0 && res.data && Array.isArray(res.data.list)) {
        const mapped = res.data.list.map((x) => new WardrobeOutfitModel(
          x.id,
          x.title,
          x.style || '清爽',
          x.scene || '日常',
          x.weather || '晴',
          x.topName || '',
          x.bottomName || '',
          x.shoesName || '',
          x.accessoryName || '',
          x.dressName || '',
          x.tips || '',
          x.isSaved ?? false
        ))
        return mapped.filter((x) => {
          const matchStyle = style === '全部' || style === '' || x.style === style
          const matchScene = scene === '全部' || scene === '' || x.scene === scene
          const matchWeather = weather === '全部' || weather === '' || x.weather === weather
          return matchStyle && matchScene && matchWeather
        })
      }
    } catch {
      // Offline fallback
    }
    return WardrobeLocalStore.getOutfits(style, scene, weather)
  }

  static async loadTips(): Promise<WardrobeTipModel[]> {
    WardrobeLocalStore.init()
    try {
      const res = await HttpClient.get<ApiListPayload<TipWire>>('/biz/cool-wardrobe/tips')
      if (res.code === 0 && res.data && Array.isArray(res.data.list)) {
        return res.data.list.map((x) => new WardrobeTipModel(
          x.id,
          x.title,
          x.category || '色彩',
          x.summary || '',
          x.content || '',
          x.tag || '生活美学'
        ))
      }
    } catch {
      // Offline fallback
    }
    return WardrobeLocalStore.getTips()
  }

  static async syncItemToCloud(item: WardrobeItemModel): Promise<void> {
    try {
      await HttpClient.post<WardrobeItemModel>('/biz/cool-wardrobe/items', item)
    } catch {
      // Silent catch for offline capability
    }
  }

  static async syncOutfitToCloud(outfit: WardrobeOutfitModel): Promise<void> {
    try {
      await HttpClient.post<WardrobeOutfitModel>('/biz/cool-wardrobe/outfits', outfit)
    } catch {
      // Silent catch
    }
  }
}
