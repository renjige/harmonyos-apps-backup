import { HttpClient } from './HttpClient'
import {
  CatalogItem,
  CatalogListPayload,
  CatalogWire,
  GearWriteRequest,
  MessageItem,
  MessageListPayload,
  MessageWire
} from '../models/GearModels'

export class ReadyResult {
  score: number = 0
  covered: string = ''
  missing: string = ''
}

export class GearBizService {
  static username(): string {
    return AppStorage.get<string>('currentUsername') ?? ''
  }

  static mapList(list: CatalogWire[]): CatalogItem[] {
    const out: CatalogItem[] = []
    for (const w of list) {
      out.push(CatalogItem.fromWire(w))
    }
    return out
  }

  static async loadPath(path: string): Promise<CatalogItem[]> {
    const res = await HttpClient.get<CatalogListPayload>(`/biz/outdoor-gear/${path}`)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return GearBizService.mapList(res.data.list)
    }
    return []
  }

  static async findPath(path: string, id: string): Promise<CatalogItem | undefined> {
    const res = await HttpClient.get<CatalogWire>(`/biz/outdoor-gear/${path}/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return CatalogItem.fromWire(res.data)
    }
    const all = await GearBizService.loadPath(path)
    for (const r of all) {
      if (r.id === id) {
        return r
      }
    }
    return undefined
  }

  static async loadCategories(): Promise<CatalogItem[]> {
    return GearBizService.loadPath('categories')
  }

  static async findCategory(id: string): Promise<CatalogItem | undefined> {
    return GearBizService.findPath('categories', id)
  }

  static async loadCatalog(): Promise<CatalogItem[]> {
    return GearBizService.loadPath('catalog')
  }

  static async findCatalog(id: string): Promise<CatalogItem | undefined> {
    return GearBizService.findPath('catalog', id)
  }

  static async loadTrails(): Promise<CatalogItem[]> {
    return GearBizService.loadPath('trails')
  }

  static async findTrail(id: string): Promise<CatalogItem | undefined> {
    return GearBizService.findPath('trails', id)
  }

  static async loadNotes(): Promise<CatalogItem[]> {
    return GearBizService.loadPath('notes')
  }

  static async findNote(id: string): Promise<CatalogItem | undefined> {
    return GearBizService.findPath('notes', id)
  }

  static async loadMine(path: string): Promise<CatalogItem[]> {
    const uid = GearBizService.username()
    const q = uid.length > 0 ? `?userId=${encodeURIComponent(uid)}` : ''
    const res = await HttpClient.get<CatalogListPayload>(`/biz/outdoor-gear/${path}${q}`)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return GearBizService.mapList(res.data.list)
    }
    return []
  }

  static async findMine(path: string, id: string): Promise<CatalogItem | undefined> {
    return GearBizService.findPath(path, id)
  }

  static async loadMessages(): Promise<MessageItem[]> {
    const res = await HttpClient.get<MessageListPayload>('/messages')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: MessageItem[] = []
      for (const w of res.data.list) {
        out.push(MessageItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async create(path: string, req: GearWriteRequest): Promise<boolean> {
    req.userId = GearBizService.username()
    const res = await HttpClient.post<CatalogWire>(`/biz/outdoor-gear/${path}`, req)
    return res.code === 0
  }

  static async update(path: string, id: string, req: GearWriteRequest): Promise<boolean> {
    req.userId = GearBizService.username()
    const res = await HttpClient.put<CatalogWire>(`/biz/outdoor-gear/${path}/${id}`, req)
    return res.code === 0
  }

  static async remove(path: string, id: string): Promise<boolean> {
    const res = await HttpClient.delete<CatalogWire>(`/biz/outdoor-gear/${path}/${id}`)
    return res.code === 0
  }

  static async like(id: string): Promise<boolean> {
    const res = await HttpClient.post<CatalogWire>(`/biz/outdoor-gear/posts/${id}/like`, new GearWriteRequest())
    return res.code === 0
  }

  static async loadComments(postId: string): Promise<CatalogItem[]> {
    const res = await HttpClient.get<CatalogListPayload>(`/biz/outdoor-gear/comments?postId=${encodeURIComponent(postId)}`)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return GearBizService.mapList(res.data.list)
    }
    return []
  }

  static totalWeightG(items: CatalogItem[]): number {
    let n = 0
    for (const it of items) {
      n += it.weightG
    }
    return n
  }

  static weightKgText(g: number): string {
    if (g <= 0) {
      return '0.00 kg'
    }
    return `${(g / 1000).toFixed(2)} kg`
  }

  static readyForTrail(trail: CatalogItem, gear: CatalogItem[]): ReadyResult {
    const rec = trail.recList()
    const result = new ReadyResult()
    if (rec.length === 0) {
      result.score = 100
      result.covered = '无推荐类别'
      return result
    }
    const owned: string[] = []
    const miss: string[] = []
    for (const cat of rec) {
      const name = cat.trim()
      let hit = false
      for (const g of gear) {
        if (g.category === name) {
          hit = true
        }
      }
      if (hit) {
        owned.push(name)
      } else {
        miss.push(name)
      }
    }
    result.score = Math.round((owned.length * 100) / rec.length)
    result.covered = owned.length > 0 ? owned.join('、') : '尚未覆盖'
    result.missing = miss.length > 0 ? miss.join('、') : '无缺口'
    return result
  }
}
