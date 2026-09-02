import { FamilyMemo } from '../models/JujiaModels'
import { JujiaLocalStore } from './JujiaLocalStore'
import { ActivityService } from './ActivityService'
import { AchievementService } from './AchievementService'

export class MemoService {
  static async list(): Promise<FamilyMemo[]> {
    const rows = JujiaLocalStore.memos()
    rows.sort((a: FamilyMemo, b: FamilyMemo) => {
      if (a.pinned !== b.pinned) {
        return a.pinned ? -1 : 1
      }
      return b.updatedAt.localeCompare(a.updatedAt)
    })
    return rows
  }

  static async find(id: string): Promise<FamilyMemo | null> {
    const rows = await MemoService.list()
    for (const row of rows) {
      if (row.id === id) {
        return row
      }
    }
    return null
  }

  static clone(row: FamilyMemo): FamilyMemo {
    const memo = new FamilyMemo()
    memo.id = row.id
    memo.title = row.title
    memo.body = row.body
    memo.tag = row.tag
    memo.pinned = row.pinned
    memo.userId = row.userId
    memo.createdAt = row.createdAt
    memo.updatedAt = row.updatedAt
    return memo
  }

  static async create(draft: FamilyMemo): Promise<FamilyMemo> {
    const rows = JujiaLocalStore.memos()
    const row = new FamilyMemo()
    row.id = JujiaLocalStore.newId('memo')
    row.title = draft.title
    row.body = draft.body
    row.tag = draft.tag
    row.pinned = draft.pinned
    row.userId = draft.userId.length > 0 ? draft.userId : 'local'
    row.createdAt = JujiaLocalStore.nowIso()
    row.updatedAt = row.createdAt
    rows.push(row)
    await JujiaLocalStore.saveMemos(rows)
    await ActivityService.log('create', 'memo', row.id, row.title, row.tag)
    await AchievementService.evaluate()
    return row
  }

  static async update(row: FamilyMemo): Promise<void> {
    const rows = JujiaLocalStore.memos()
    const next: FamilyMemo[] = []
    for (const item of rows) {
      if (item.id === row.id) {
        row.updatedAt = JujiaLocalStore.nowIso()
        next.push(row)
      } else {
        next.push(item)
      }
    }
    await JujiaLocalStore.saveMemos(next)
  }

  static async remove(id: string): Promise<void> {
    const rows = JujiaLocalStore.memos()
    const next: FamilyMemo[] = []
    for (const item of rows) {
      if (item.id !== id) {
        next.push(item)
      }
    }
    await JujiaLocalStore.saveMemos(next)
  }

  static async countAll(): Promise<number> {
    return (await MemoService.list()).length
  }
}
