import { HttpClient } from './HttpClient'
import { AuthService } from './AuthService'
import { pasteboard } from '@kit.BasicServicesKit'
import {
  CatalogItem,
  CatalogListData,
  EntryListData,
  MsgListData,
  MsgRecord,
  WrongEntry,
  WrongEntryWrite
} from '../models/WrongModels'
import { WrongMedia } from './WrongMedia'

const BASE = '/biz/wrong-notebook'

export class WrongBizService {
  static lastError: string = ''

  static async loadSubjects(): Promise<CatalogItem[]> {
    const res = await HttpClient.get<CatalogListData>(`${BASE}/subjects`)
    if (res.code === 0 && res.data !== undefined) {
      return res.data.list
    }
    return []
  }

  static async loadMethods(): Promise<CatalogItem[]> {
    const res = await HttpClient.get<CatalogListData>(`${BASE}/methods`)
    if (res.code === 0 && res.data !== undefined) {
      return res.data.list
    }
    return []
  }

  static async loadTips(): Promise<CatalogItem[]> {
    const res = await HttpClient.get<CatalogListData>(`${BASE}/tips`)
    if (res.code === 0 && res.data !== undefined) {
      return res.data.list
    }
    return []
  }

  static async loadArticles(): Promise<CatalogItem[]> {
    const res = await HttpClient.get<CatalogListData>(`${BASE}/articles`)
    if (res.code === 0 && res.data !== undefined) {
      return res.data.list
    }
    return []
  }

  static async loadEntries(): Promise<WrongEntry[]> {
    if (!AuthService.isLoggedIn()) {
      return []
    }
    const user = AuthService.currentUsername()
    const res = await HttpClient.get<EntryListData>(`${BASE}/entries?userId=${encodeURIComponent(user)}`)
    if (res.code === 0 && res.data !== undefined) {
      return res.data.list
    }
    return []
  }

  static async loadMessages(): Promise<MsgRecord[]> {
    const res = await HttpClient.get<MsgListData>('/messages')
    if (res.code === 0 && res.data !== undefined) {
      return res.data.list
    }
    const alt = await HttpClient.get<MsgListData>(`${BASE}/messages`)
    if (alt.code === 0 && alt.data !== undefined) {
      return alt.data.list
    }
    return []
  }

  static findCatalog(id: string, list: CatalogItem[]): CatalogItem {
    for (const item of list) {
      if (item.id === id) {
        return item
      }
    }
    return new CatalogItem()
  }

  static findEntry(id: string, list: WrongEntry[]): WrongEntry {
    for (const item of list) {
      if (item.id === id) {
        return item
      }
    }
    return new WrongEntry()
  }

  static async saveEntry(write: WrongEntryWrite): Promise<boolean> {
    WrongBizService.lastError = ''
    write.userId = AuthService.currentUsername()
    write.coverKey = WrongMedia.subjectCover(write.subjectCode)
    const res = await HttpClient.post<WrongEntry>(`${BASE}/entries`, write)
    if (res.code === 0 && res.data !== undefined) {
      return true
    }
    WrongBizService.lastError = res.message.length > 0 ? res.message : '保存失败'
    return false
  }

  static async updateEntry(id: string, write: WrongEntryWrite): Promise<boolean> {
    WrongBizService.lastError = ''
    write.userId = AuthService.currentUsername()
    const res = await HttpClient.put<WrongEntry>(`${BASE}/entries/${id}`, write)
    if (res.code === 0 && res.data !== undefined) {
      return true
    }
    WrongBizService.lastError = res.message.length > 0 ? res.message : '更新失败'
    return false
  }

  static async deleteEntry(id: string): Promise<boolean> {
    const user = AuthService.currentUsername()
    const res = await HttpClient.delete<WrongEntry>(`${BASE}/entries/${id}?userId=${encodeURIComponent(user)}`)
    return res.code === 0
  }

  static async copyExport(text: string): Promise<boolean> {
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      const board = pasteboard.getSystemPasteboard()
      await board.setData(data)
      return true
    } catch {
      return false
    }
  }
}
