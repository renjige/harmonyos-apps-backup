import { LearningHubService } from './LearningHubService'
import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { CommonSenseTime } from '../models/CommonSenseModels'
import {
  ChecklistDoc,
  ChecklistItem,
  FolderBind,
  RemindPref
} from '../models/CommonSenseToolModels'
import { CommonSenseDetailNav } from './CommonSenseDetailNav'

const STORE_NAME = 'changshiji_tools'
const KEY_BINDS = 'folder_binds'
const KEY_MASTERED = 'mastered_ids'
const KEY_WRONG = 'wrong_ids'
const KEY_LISTS = 'checklists'
const KEY_REMIND = 'remind_pref'

/** 清单、收藏夹分类、已掌握、错题、提醒（本机，新用户为空）。 */
export class CommonSenseLocalService {
  private static pref: preferences.Preferences | null = null
  private static binds: FolderBind[] = []
  private static mastered: string[] = []
  private static wrongs: string[] = []
  private static lists: ChecklistDoc[] = []
  private static remind: RemindPref = new RemindPref()

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      CommonSenseLocalService.pref = await preferences.getPreferences(context, STORE_NAME)
      CommonSenseLocalService.binds = CommonSenseLocalService.parseBinds(
        await CommonSenseLocalService.readText(KEY_BINDS, '[]'))
      CommonSenseLocalService.mastered = CommonSenseLocalService.parseIds(
        await CommonSenseLocalService.readText(KEY_MASTERED, '[]'))
      CommonSenseLocalService.wrongs = CommonSenseLocalService.parseIds(
        await CommonSenseLocalService.readText(KEY_WRONG, '[]'))
      CommonSenseLocalService.lists = CommonSenseLocalService.parseLists(
        await CommonSenseLocalService.readText(KEY_LISTS, '[]'))
      CommonSenseLocalService.remind = CommonSenseLocalService.parseRemind(
        await CommonSenseLocalService.readText(KEY_REMIND, '{}'))
    } catch {
      CommonSenseLocalService.binds = []
      CommonSenseLocalService.mastered = []
      CommonSenseLocalService.wrongs = []
      CommonSenseLocalService.lists = []
      CommonSenseLocalService.remind = new RemindPref()
    }
  }

  static folderOf(factId: string): string {
    for (const row of CommonSenseLocalService.binds) {
      if (row.factId === factId) {
        return row.folder
      }
    }
    return ''
  }

  static folderNames(): string[] {
    const names: string[] = []
    for (const row of CommonSenseLocalService.binds) {
      if (row.folder.length > 0 && names.indexOf(row.folder) < 0) {
        names.push(row.folder)
      }
    }
    return names
  }

  static async setFolder(factId: string, folder: string): Promise<void> {
    const next: FolderBind[] = []
    let found = false
    for (const row of CommonSenseLocalService.binds) {
      if (row.factId === factId) {
        const bind = new FolderBind()
        bind.factId = factId
        bind.folder = folder
        next.push(bind)
        found = true
      } else {
        next.push(row)
      }
    }
    if (!found && folder.length > 0) {
      const bind = new FolderBind()
      bind.factId = factId
      bind.folder = folder
      next.push(bind)
    }
    CommonSenseLocalService.binds = next
    await CommonSenseLocalService.flushText(KEY_BINDS, JSON.stringify(next))
    CommonSenseLocalService.bump()
  }

  static isMastered(id: string): boolean {
    return CommonSenseLocalService.hasId(CommonSenseLocalService.mastered, id)
  }

  static masteredIds(): string[] {
    return CommonSenseLocalService.copyIds(CommonSenseLocalService.mastered)
  }

  static async markMastered(id: string, title: string = ''): Promise<void> {
    if (id.length === 0 || CommonSenseLocalService.isMastered(id)) {
      return
    }
    CommonSenseLocalService.mastered = CommonSenseLocalService.prepend(CommonSenseLocalService.mastered, id)
    await CommonSenseLocalService.flushText(KEY_MASTERED, JSON.stringify(CommonSenseLocalService.mastered))
    if (title.length > 0) {
      void LearningHubService.onMaster(id, title)
    }
    CommonSenseLocalService.bump()
  }

  static async recordQuiz(correctIds: string[], wrongIds: string[]): Promise<void> {
    for (const id of correctIds) {
      await CommonSenseLocalService.markMastered(id)
      CommonSenseLocalService.wrongs = CommonSenseLocalService.drop(CommonSenseLocalService.wrongs, id)
    }
    for (const id of wrongIds) {
      CommonSenseLocalService.wrongs = CommonSenseLocalService.prepend(CommonSenseLocalService.wrongs, id)
    }
    await CommonSenseLocalService.flushText(KEY_WRONG, JSON.stringify(CommonSenseLocalService.wrongs))
    CommonSenseLocalService.bump()
  }

  static listsAll(): ChecklistDoc[] {
    const copy: ChecklistDoc[] = []
    for (const row of CommonSenseLocalService.lists) {
      copy.push(row)
    }
    return copy
  }

  static findList(id: string): ChecklistDoc | undefined {
    for (const row of CommonSenseLocalService.lists) {
      if (row.id === id) {
        return row
      }
    }
    return undefined
  }

  static cloneList(doc: ChecklistDoc): ChecklistDoc {
    const copy = new ChecklistDoc()
    copy.id = doc.id
    copy.title = doc.title
    copy.createdAt = doc.createdAt
    copy.items = []
    for (const row of doc.items) {
      const item = new ChecklistItem()
      item.id = row.id
      item.title = row.title
      item.learned = row.learned
      item.remark = row.remark
      item.factId = row.factId
      copy.items.push(item)
    }
    return copy
  }

  static async addFactToLatest(title: string, factId: string): Promise<string> {
    if (CommonSenseLocalService.lists.length === 0) {
      const doc = await CommonSenseLocalService.createList('我的学习清单')
      await CommonSenseLocalService.addListItem(doc.id, title, factId)
      return doc.title
    }
    const first = CommonSenseLocalService.lists[0]
    await CommonSenseLocalService.addListItem(first.id, title, factId)
    return first.title
  }

  static async createList(title: string): Promise<ChecklistDoc> {
    const doc = new ChecklistDoc()
    doc.id = `list_${Date.now()}`
    doc.title = title.length > 0 ? title : '未命名清单'
    doc.createdAt = CommonSenseTime.todayKey()
    doc.items = []
    const next: ChecklistDoc[] = [doc]
    for (const row of CommonSenseLocalService.lists) {
      next.push(row)
    }
    CommonSenseLocalService.lists = next
    await CommonSenseLocalService.flushLists()
    CommonSenseLocalService.bump()
    return doc
  }

  static async addListItem(listId: string, title: string, factId: string): Promise<void> {
    const item = new ChecklistItem()
    item.id = `it_${Date.now()}`
    item.title = title
    item.factId = factId
    item.learned = false
    item.remark = ''
    const next: ChecklistDoc[] = []
    for (const row of CommonSenseLocalService.lists) {
      if (row.id === listId) {
        const items: ChecklistItem[] = [item]
        for (const old of row.items) {
          items.push(old)
        }
        row.items = items
      }
      next.push(row)
    }
    CommonSenseLocalService.lists = next
    await CommonSenseLocalService.flushLists()
    CommonSenseLocalService.bump()
  }

  static async toggleLearned(listId: string, itemId: string, title: string = ''): Promise<void> {
    let becameLearned = false
    for (const row of CommonSenseLocalService.lists) {
      if (row.id === listId) {
        for (const item of row.items) {
          if (item.id === itemId) {
            item.learned = !item.learned
            becameLearned = item.learned
          }
        }
      }
    }
    await CommonSenseLocalService.flushLists()
    if (becameLearned && title.length > 0) {
      void LearningHubService.onListLearned(itemId, title)
    }
    CommonSenseLocalService.bump()
  }

  static wrongIds(): string[] {
    return CommonSenseLocalService.copyIds(CommonSenseLocalService.wrongs)
  }

  static async saveRemark(listId: string, itemId: string, remark: string): Promise<void> {
    for (const row of CommonSenseLocalService.lists) {
      if (row.id === listId) {
        for (const item of row.items) {
          if (item.id === itemId) {
            item.remark = remark
          }
        }
      }
    }
    await CommonSenseLocalService.flushLists()
    CommonSenseLocalService.bump()
  }

  static async removeList(listId: string): Promise<void> {
    const next: ChecklistDoc[] = []
    for (const row of CommonSenseLocalService.lists) {
      if (row.id !== listId) {
        next.push(row)
      }
    }
    CommonSenseLocalService.lists = next
    await CommonSenseLocalService.flushLists()
    CommonSenseLocalService.bump()
  }

  static remindPref(): RemindPref {
    const copy = new RemindPref()
    copy.enabled = CommonSenseLocalService.remind.enabled
    copy.hour = CommonSenseLocalService.remind.hour
    copy.minute = CommonSenseLocalService.remind.minute
    copy.agentId = CommonSenseLocalService.remind.agentId
    return copy
  }

  static async saveRemind(pref: RemindPref): Promise<void> {
    CommonSenseLocalService.remind.enabled = pref.enabled
    CommonSenseLocalService.remind.hour = pref.hour
    CommonSenseLocalService.remind.minute = pref.minute
    CommonSenseLocalService.remind.agentId = pref.agentId
    await CommonSenseLocalService.flushText(KEY_REMIND, pref.toJsonString())
    CommonSenseLocalService.bump()
  }

  static listCount(): number {
    return CommonSenseLocalService.lists.length
  }

  static masteredCount(): number {
    return CommonSenseLocalService.mastered.length
  }

  private static async readText(key: string, fallback: string): Promise<string> {
    if (CommonSenseLocalService.pref === null) {
      return fallback
    }
    const raw = await CommonSenseLocalService.pref.get(key, fallback)
    return typeof raw === 'string' ? raw : fallback
  }

  private static async flushText(key: string, text: string): Promise<void> {
    if (CommonSenseLocalService.pref === null) {
      return
    }
    await CommonSenseLocalService.pref.put(key, text)
    await CommonSenseLocalService.pref.flush()
  }

  private static async flushLists(): Promise<void> {
    await CommonSenseLocalService.flushText(KEY_LISTS, JSON.stringify(CommonSenseLocalService.lists))
  }

  private static bump(): void {
    CommonSenseDetailNav.bumpRefresh()
  }

  private static hasId(list: string[], id: string): boolean {
    for (const row of list) {
      if (row === id) {
        return true
      }
    }
    return false
  }

  private static copyIds(list: string[]): string[] {
    const out: string[] = []
    for (const id of list) {
      out.push(id)
    }
    return out
  }

  private static prepend(list: string[], id: string): string[] {
    const next: string[] = [id]
    for (const row of list) {
      if (row !== id) {
        next.push(row)
      }
    }
    return next
  }

  private static drop(list: string[], id: string): string[] {
    const next: string[] = []
    for (const row of list) {
      if (row !== id) {
        next.push(row)
      }
    }
    return next
  }

  private static parseIds(text: string): string[] {
    const out: string[] = []
    try {
      const parsed = JSON.parse(text) as string[]
      for (const id of parsed) {
        out.push(id)
      }
    } catch {
    }
    return out
  }

  private static parseBinds(text: string): FolderBind[] {
    const out: FolderBind[] = []
    try {
      const parsed = JSON.parse(text) as FolderBind[]
      for (const row of parsed) {
        const bind = new FolderBind()
        bind.factId = row.factId
        bind.folder = row.folder
        out.push(bind)
      }
    } catch {
    }
    return out
  }

  private static parseLists(text: string): ChecklistDoc[] {
    const out: ChecklistDoc[] = []
    try {
      const parsed = JSON.parse(text) as ChecklistDoc[]
      for (const row of parsed) {
        const doc = new ChecklistDoc()
        doc.id = row.id
        doc.title = row.title
        doc.createdAt = row.createdAt
        doc.items = []
        if (row.items !== undefined) {
          for (const it of row.items) {
            const item = new ChecklistItem()
            item.id = it.id
            item.title = it.title
            item.learned = it.learned
            item.remark = it.remark
            item.factId = it.factId
            doc.items.push(item)
          }
        }
        out.push(doc)
      }
    } catch {
    }
    return out
  }

  private static parseRemind(text: string): RemindPref {
    const pref = new RemindPref()
    try {
      const parsed = JSON.parse(text) as RemindPref
      pref.enabled = parsed.enabled === true
      pref.hour = parsed.hour > 0 ? parsed.hour : 21
      pref.minute = parsed.minute >= 0 ? parsed.minute : 0
      pref.agentId = parsed.agentId
    } catch {
    }
    return pref
  }
}
