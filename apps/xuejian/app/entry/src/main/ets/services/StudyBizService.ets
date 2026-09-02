import { HttpClient } from './HttpClient'
import {
  CatalogItem, CatalogListPayload, CatalogMapper, CatalogWire, MsgListPayload, MsgWire
} from '../models/StudyModels'

export class StudyBizService {
  static async loadMethods(): Promise<CatalogItem[]> {
    return StudyBizService.loadCatalog('/biz/study-sight/methods')
  }

  static async loadTips(): Promise<CatalogItem[]> {
    return StudyBizService.loadCatalog('/biz/study-sight/tips')
  }

  static async loadCategories(): Promise<CatalogItem[]> {
    return StudyBizService.loadCatalog('/biz/study-sight/categories')
  }

  static async findMethod(id: string): Promise<CatalogItem | undefined> {
    return StudyBizService.findOne(`/biz/study-sight/methods/${id}`)
  }

  static async findTip(id: string): Promise<CatalogItem | undefined> {
    return StudyBizService.findOne(`/biz/study-sight/tips/${id}`)
  }

  static async loadMessages(): Promise<MsgWire[]> {
    const res = await HttpClient.get<MsgListPayload>('/messages')
    if (res.code === 0 && res.data !== undefined) {
      return res.data.list
    }
    return []
  }

  private static async findOne(path: string): Promise<CatalogItem | undefined> {
    const res = await HttpClient.get<CatalogWire>(path)
    if (res.code === 0 && res.data !== undefined) {
      return CatalogMapper.fromWire(res.data)
    }
    return undefined
  }

  private static async loadCatalog(path: string): Promise<CatalogItem[]> {
    const res = await HttpClient.get<CatalogListPayload>(path)
    const out: CatalogItem[] = []
    if (res.code === 0 && res.data !== undefined) {
      for (const w of res.data.list) {
        out.push(CatalogMapper.fromWire(w))
      }
    }
    return out
  }
}
