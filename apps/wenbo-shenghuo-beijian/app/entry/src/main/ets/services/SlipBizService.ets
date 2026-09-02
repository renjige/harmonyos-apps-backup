import { HttpClient } from './HttpClient'
import { CatalogItem, CatalogListPayload, CatalogMapper, CatalogWire, MsgListPayload, MsgWire, SlipItem, SlipSyncBody } from '../models/SlipModels'
import { AuthService } from './AuthService'

export class SlipBizService {
  static async loadCategories(): Promise<CatalogItem[]> {
    return SlipBizService.loadCatalog('/biz/life-memo/categories')
  }

  static async loadGreetings(): Promise<CatalogItem[]> {
    return SlipBizService.loadCatalog('/biz/life-memo/greetings')
  }

  static async loadScenes(): Promise<CatalogItem[]> {
    return SlipBizService.loadCatalog('/biz/life-memo/scenes')
  }

  static async findScene(id: string): Promise<CatalogItem | undefined> {
    const res = await HttpClient.get<CatalogWire>(`/biz/life-memo/scenes/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return CatalogMapper.fromWire(res.data)
    }
    return undefined
  }

  static async findCategory(id: string): Promise<CatalogItem | undefined> {
    const res = await HttpClient.get<CatalogWire>(`/biz/life-memo/categories/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return CatalogMapper.fromWire(res.data)
    }
    return undefined
  }

  static async loadMessages(): Promise<MsgWire[]> {
    const res = await HttpClient.get<MsgListPayload>('/messages')
    if (res.code === 0 && res.data !== undefined) {
      return res.data.list
    }
    return []
  }

  static async syncSave(item: SlipItem): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      return
    }
    const user = AuthService.currentUsername()
    if (user.length === 0 || user === '未登录') {
      return
    }
    const body = new SlipSyncBody()
    body.title = item.title
    body.content = item.content
    body.category = item.category
    body.date = item.date
    body.reminderTime = item.reminderTime
    body.isReminderEnabled = item.isReminderEnabled
    body.isImportant = item.isImportant
    body.isCompleted = item.isCompleted
    body.userId = user
    await HttpClient.post<CatalogWire>('/biz/life-memo/notes', body)
  }

  static async syncDelete(id: string): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      return
    }
    const user = AuthService.currentUsername()
    if (user.length === 0 || user === '未登录') {
      return
    }
    await HttpClient.delete<CatalogWire>(`/biz/life-memo/notes/${id}?userId=${encodeURIComponent(user)}`)
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
