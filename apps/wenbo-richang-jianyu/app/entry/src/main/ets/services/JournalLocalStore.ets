import { SessionStore } from './SessionStore'
import { JournalItem, JournalItemWire } from '../models/JournalModels'

class DiaryCacheFile {
  items: JournalItemWire[] = []
}

class DeletedIdsFile {
  ids: string[] = []
}

class AliasFile {
  oldIds: string[] = []
  newIds: string[] = []
}

/** 用户笺语本地缓存：保存后立即可见，网络同步在后台进行 */
export class JournalLocalStore {
  private static cacheKey(userId: string): string {
    return `diary_cache_${userId}`
  }

  private static deletedKey(userId: string): string {
    return `diary_deleted_${userId}`
  }

  private static aliasKey(userId: string): string {
    return `diary_alias_${userId}`
  }

  static async deletedIds(userId: string): Promise<string[]> {
    if (userId.length === 0) {
      return []
    }
    const raw = await SessionStore.readRaw(JournalLocalStore.deletedKey(userId))
    if (raw.length === 0) {
      return []
    }
    try {
      const parsed = JSON.parse(raw) as DeletedIdsFile
      if (parsed === undefined || parsed === null || parsed.ids === undefined) {
        return []
      }
      return parsed.ids
    } catch {
      return []
    }
  }

  static async markDeleted(userId: string, id: string): Promise<void> {
    if (userId.length === 0 || id.length === 0) {
      return
    }
    const ids = await JournalLocalStore.deletedIds(userId)
    let exists = false
    for (const row of ids) {
      if (row === id) {
        exists = true
      }
    }
    if (exists) {
      return
    }
    ids.push(id)
    const file = new DeletedIdsFile()
    file.ids = ids
    await SessionStore.writeRaw(JournalLocalStore.deletedKey(userId), JSON.stringify(file))
  }

  static async isDeleted(userId: string, id: string): Promise<boolean> {
    const ids = await JournalLocalStore.deletedIds(userId)
    for (const row of ids) {
      if (row === id) {
        return true
      }
    }
    return false
  }

  static async rememberAlias(userId: string, oldId: string, newId: string): Promise<void> {
    if (userId.length === 0 || oldId.length === 0 || newId.length === 0 || oldId === newId) {
      return
    }
    const file = await JournalLocalStore.loadAlias(userId)
    const nextOld: string[] = []
    const nextNew: string[] = []
    let replaced = false
    let i = 0
    while (i < file.oldIds.length) {
      if (file.oldIds[i] === oldId) {
        nextOld.push(oldId)
        nextNew.push(newId)
        replaced = true
      } else {
        nextOld.push(file.oldIds[i])
        nextNew.push(file.newIds[i])
      }
      i += 1
    }
    if (!replaced) {
      nextOld.push(oldId)
      nextNew.push(newId)
    }
    const out = new AliasFile()
    out.oldIds = nextOld
    out.newIds = nextNew
    await SessionStore.writeRaw(JournalLocalStore.aliasKey(userId), JSON.stringify(out))
  }

  static async resolveId(userId: string, id: string): Promise<string> {
    if (userId.length === 0 || id.length === 0) {
      return id
    }
    const file = await JournalLocalStore.loadAlias(userId)
    let i = 0
    while (i < file.oldIds.length) {
      if (file.oldIds[i] === id) {
        return file.newIds[i]
      }
      i += 1
    }
    return id
  }

  private static async loadAlias(userId: string): Promise<AliasFile> {
    const empty = new AliasFile()
    const raw = await SessionStore.readRaw(JournalLocalStore.aliasKey(userId))
    if (raw.length === 0) {
      return empty
    }
    try {
      const parsed = JSON.parse(raw) as AliasFile
      if (parsed === undefined || parsed === null) {
        return empty
      }
      if (parsed.oldIds === undefined || parsed.newIds === undefined) {
        return empty
      }
      return parsed
    } catch {
      return empty
    }
  }

  static async list(userId: string): Promise<JournalItem[]> {
    if (userId.length === 0) {
      return []
    }
    const raw = await SessionStore.readRaw(JournalLocalStore.cacheKey(userId))
    if (raw.length === 0) {
      return []
    }
    try {
      const parsed = JSON.parse(raw) as DiaryCacheFile
      if (parsed === undefined || parsed === null || parsed.items === undefined) {
        return []
      }
      const out: JournalItem[] = []
      for (const w of parsed.items) {
        const item = JournalItem.fromWire(w)
        if (item.id.length > 0) {
          out.push(item)
        }
      }
      return out
    } catch {
      return []
    }
  }

  static async saveAll(userId: string, items: JournalItem[]): Promise<void> {
    if (userId.length === 0) {
      return
    }
    let json = '{"items":['
    let first = true
    for (const item of items) {
      if (!first) {
        json += ','
      }
      first = false
      json += item.toJsonString()
    }
    json += ']}'
    await SessionStore.writeRaw(JournalLocalStore.cacheKey(userId), json)
  }

  static async upsert(userId: string, item: JournalItem): Promise<JournalItem[]> {
    const list = await JournalLocalStore.list(userId)
    const next: JournalItem[] = []
    let replaced = false
    for (const row of list) {
      if (row.id === item.id) {
        next.push(item)
        replaced = true
      } else {
        next.push(row)
      }
    }
    if (!replaced) {
      next.unshift(item)
    }
    await JournalLocalStore.saveAll(userId, next)
    return next
  }

  static async remove(userId: string, id: string): Promise<JournalItem[]> {
    await JournalLocalStore.markDeleted(userId, id)
    const list = await JournalLocalStore.list(userId)
    const next: JournalItem[] = []
    for (const row of list) {
      if (row.id !== id) {
        next.push(row)
      }
    }
    await JournalLocalStore.saveAll(userId, next)
    return next
  }

  static async replaceId(userId: string, oldId: string, item: JournalItem): Promise<void> {
    const list = await JournalLocalStore.list(userId)
    const next: JournalItem[] = []
    let replaced = false
    for (const row of list) {
      if (row.id === oldId) {
        next.push(item)
        replaced = true
      } else if (row.id === item.id) {
        continue
      } else {
        next.push(row)
      }
    }
    if (!replaced) {
      next.unshift(item)
    }
    await JournalLocalStore.saveAll(userId, next)
    await JournalLocalStore.rememberAlias(userId, oldId, item.id)
  }

  static mergeRemote(localItems: JournalItem[], remoteItems: JournalItem[],
    deletedIds: string[]): JournalItem[] {
    const out: JournalItem[] = []
    for (const remote of remoteItems) {
      let skip = false
      for (const deadId of deletedIds) {
        if (deadId === remote.id) {
          skip = true
        }
      }
      if (skip) {
        continue
      }
      let cover = remote.coverKey
      for (const local of localItems) {
        if (local.id === remote.id && local.coverKey.startsWith('local:')) {
          cover = local.coverKey
          remote.imageKeys = local.imageKeys.length > 0 ? local.imageKeys : remote.imageKeys
        }
      }
      remote.coverKey = cover
      out.push(remote)
    }
    for (const local of localItems) {
      if (!local.id.startsWith('ljlocal_')) {
        continue
      }
      let dup = false
      for (const remote of remoteItems) {
        if (remote.title === local.title && remote.recordDate === local.recordDate) {
          let tombstoned = false
          for (const deadId of deletedIds) {
            if (deadId === remote.id) {
              tombstoned = true
            }
          }
          if (!tombstoned) {
            dup = true
          }
        }
      }
      if (!dup) {
        out.unshift(local)
      }
    }
    return out
  }
}
