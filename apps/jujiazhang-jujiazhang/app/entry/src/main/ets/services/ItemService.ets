import { HomeItem } from '../models/JujiaModels'
import { JujiaLocalStore } from './JujiaLocalStore'
import { ActivityService } from './ActivityService'
import { AchievementService } from './AchievementService'

export class ItemService {
  static async list(): Promise<HomeItem[]> {
    return JujiaLocalStore.items()
  }

  static async expiringSoon(): Promise<HomeItem[]> {
    const rows = await ItemService.list()
    const out: HomeItem[] = []
    for (const row of rows) {
      if (row.isExpiringSoon()) {
        out.push(row)
      }
    }
    out.sort((a: HomeItem, b: HomeItem) => a.daysUntilExpiry() - b.daysUntilExpiry())
    return out
  }

  static async countAll(): Promise<number> {
    return (await ItemService.list()).length
  }

  static async countExpiring(): Promise<number> {
    return (await ItemService.expiringSoon()).length
  }

  static async find(id: string): Promise<HomeItem | null> {
    const rows = await ItemService.list()
    for (const row of rows) {
      if (row.id === id) {
        return row
      }
    }
    return null
  }

  static clone(row: HomeItem): HomeItem {
    const item = new HomeItem()
    item.id = row.id
    item.name = row.name
    item.category = row.category
    item.purchaseDate = row.purchaseDate
    item.expiryDate = row.expiryDate
    item.location = row.location
    item.room = row.room
    item.customTag = row.customTag
    item.remark = row.remark
    item.remindLeadDays = row.remindLeadDays
    item.reminderAgentId = row.reminderAgentId
    item.userId = row.userId
    item.createdAt = row.createdAt
    item.updatedAt = row.updatedAt
    return item
  }

  static async create(draft: HomeItem): Promise<HomeItem> {
    const rows = await ItemService.list()
    const row = new HomeItem()
    row.id = JujiaLocalStore.newId('item')
    row.name = draft.name
    row.category = draft.category
    row.purchaseDate = draft.purchaseDate
    row.expiryDate = draft.expiryDate
    row.location = draft.location
    row.room = draft.room
    row.customTag = draft.customTag
    row.remark = draft.remark
    row.remindLeadDays = draft.remindLeadDays
    row.userId = draft.userId.length > 0 ? draft.userId : 'local'
    row.createdAt = JujiaLocalStore.nowIso()
    row.updatedAt = row.createdAt
    rows.push(row)
    await JujiaLocalStore.saveItems(rows)
    await ActivityService.log('create', 'item', row.id, row.name, `${row.category} · ${row.room}`)
    await AchievementService.evaluate()
    return row
  }

  static async update(row: HomeItem): Promise<void> {
    const rows = await ItemService.list()
    const next: HomeItem[] = []
    for (const item of rows) {
      if (item.id === row.id) {
        row.updatedAt = JujiaLocalStore.nowIso()
        next.push(row)
      } else {
        next.push(item)
      }
    }
    await JujiaLocalStore.saveItems(next)
  }

  static async remove(id: string): Promise<void> {
    const rows = await ItemService.list()
    const next: HomeItem[] = []
    for (const item of rows) {
      if (item.id !== id) {
        next.push(item)
      }
    }
    await JujiaLocalStore.saveItems(next)
  }
}
