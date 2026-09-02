import { HttpClient } from './HttpClient'
import {
  XuListPayload, XuMsgItem, XuMsgPayload, XuTipItem, XuTipWire, XuWriteBody
} from '../models/XuModels'
import { XuAgendaItem, XuHabitItem, XuNoteItem } from '../models/XuModels'
import { AuthService } from './AuthService'

export class XuBizService {
  static lastError: string = ''

  static async loadTips(): Promise<XuTipItem[]> {
    const res = await HttpClient.get<XuListPayload>('/biz/task-efficiency/tips')
    const out: XuTipItem[] = []
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      for (const w of res.data.list) {
        out.push(XuBizService.mapTip(w))
      }
    }
    return out
  }

  static async findTip(id: string): Promise<XuTipItem | undefined> {
    const res = await HttpClient.get<XuTipWire>(`/biz/task-efficiency/tips/${id}`)
    if (res.code === 0 && res.data !== undefined && res.data !== null) {
      return XuBizService.mapTip(res.data)
    }
    return undefined
  }

  static async loadMessages(): Promise<XuMsgItem[]> {
    const res = await HttpClient.get<XuMsgPayload>('/biz/task-efficiency/messages')
    const out: XuMsgItem[] = []
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      for (const w of res.data.list) {
        const m = new XuMsgItem()
        m.id = w.id
        m.title = w.title
        m.body = w.body
        out.push(m)
      }
    }
    return out
  }

  static async syncAgenda(item: XuAgendaItem): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      return
    }
    const uid = AuthService.currentUsername()
    const json =
      `{"title":${JSON.stringify(item.title)},"summary":${JSON.stringify(item.remark)},` +
      `"description":${JSON.stringify(item.kind)},"priority":${JSON.stringify(item.priority)},` +
      `"dueDate":${JSON.stringify(item.dateKey)},"dueTime":${JSON.stringify(item.timeText)},` +
      `"userId":${JSON.stringify(uid)},"status":${JSON.stringify(item.done ? 'done' : 'pending')}}`
    await HttpClient.post<XuTipWire>('/biz/task-efficiency/tasks', XuWriteBody.of(json))
  }

  static async syncHabit(item: XuHabitItem): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      return
    }
    const uid = AuthService.currentUsername()
    const json =
      `{"title":${JSON.stringify(item.title)},"description":${JSON.stringify(item.remark)},` +
      `"userId":${JSON.stringify(uid)}}`
    await HttpClient.post<XuTipWire>('/biz/task-efficiency/habits', XuWriteBody.of(json))
  }

  static async syncNote(item: XuNoteItem): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      return
    }
    const uid = AuthService.currentUsername()
    const json =
      `{"title":${JSON.stringify(item.title)},"summary":${JSON.stringify(item.summary(80))},` +
      `"body":${JSON.stringify(item.body)},"userId":${JSON.stringify(uid)}}`
    await HttpClient.post<XuTipWire>('/biz/task-efficiency/notes', XuWriteBody.of(json))
  }

  private static mapTip(w: XuTipWire): XuTipItem {
    const t = new XuTipItem()
    t.id = w.id
    t.title = w.title
    t.summary = w.summary
    t.body = w.body
    t.coverKey = w.coverMedia.length > 0 ? w.coverMedia : w.coverKey
    t.readMinutes = w.readMinutes > 0 ? w.readMinutes : 3
    return t
  }
}
