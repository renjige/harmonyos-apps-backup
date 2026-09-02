import { YunCraftItem } from '../models/YunModels'
import { YunDateHelper, YunLocalStore } from './YunLocalStore'

const KEY_CRAFT = 'craft_v1'

export class YunCraftStore {
  static async load(): Promise<YunCraftItem[]> {
    const raw = await YunLocalStore.rawGet(KEY_CRAFT, '')
    return YunCraftStore.parse(raw)
  }

  static async save(item: YunCraftItem): Promise<boolean> {
    item.updatedAt = Date.now()
    if (!YunDateHelper.isValidTs(item.createdAt)) {
      item.createdAt = YunDateHelper.tsFromId(item.id)
    }
    const list = await YunCraftStore.load()
    const next: YunCraftItem[] = []
    let found = false
    for (const it of list) {
      if (it.id === item.id) {
        next.push(item)
        found = true
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.unshift(item)
    }
    return await YunLocalStore.rawPut(KEY_CRAFT, YunCraftStore.serialize(next))
  }

  static async remove(id: string): Promise<void> {
    const list = await YunCraftStore.load()
    const next: YunCraftItem[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await YunLocalStore.rawPut(KEY_CRAFT, YunCraftStore.serialize(next))
  }

  static async find(id: string): Promise<YunCraftItem | undefined> {
    const list = await YunCraftStore.load()
    for (const it of list) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static async clearAll(): Promise<void> {
    await YunLocalStore.rawPut(KEY_CRAFT, '')
  }

  static filter(list: YunCraftItem[], kind: string, board: string): YunCraftItem[] {
    const out: YunCraftItem[] = []
    for (const it of list) {
      if (kind === 'pin' && !it.pinned) {
        continue
      }
      if (kind !== 'all' && kind !== 'pin' && it.kind !== kind) {
        continue
      }
      if (board.length > 0 && it.category !== board) {
        continue
      }
      out.push(it)
    }
    return out
  }

  static counts(list: YunCraftItem[]): number[] {
    let tips = 0
    let goals = 0
    for (const it of list) {
      tips++
      if (it.kind === 'goal' && it.progress < 100) {
        goals++
      }
    }
    return [tips, goals]
  }

  private static serialize(items: YunCraftItem[]): string {
    const lines: string[] = []
    for (const it of items) {
      const title = it.title.replace(/\t/g, ' ').replace(/\n/g, ' ')
      const body = it.body.replace(/\t/g, ' ').replace(/\n/g, '\\n')
      const extra = it.extra.replace(/\t/g, ' ').replace(/\n/g, '\\n')
      lines.push(`${it.id}\t${it.kind}\t${title}\t${body}\t${extra}\t${it.category}\t${it.pinned ? '1' : '0'}\t${it.progress}\t${it.createdAt}\t${it.updatedAt}`)
    }
    return lines.join('\n')
  }

  private static parse(raw: string): YunCraftItem[] {
    const out: YunCraftItem[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 10) {
        continue
      }
      const it = YunCraftItem.create(parts[0], parts[1], parts[2])
      it.body = parts[3].replace(/\\n/g, '\n')
      it.extra = parts[4].replace(/\\n/g, '\n')
      it.category = parts[5].length > 0 ? parts[5] : '家庭'
      it.pinned = parts[6] === '1'
      it.progress = parseInt(parts[7], 10)
      if (!(it.progress >= 0)) {
        it.progress = 0
      }
      it.createdAt = YunDateHelper.sanitizeTs(parseInt(parts[8], 10), parts[0])
      it.updatedAt = YunDateHelper.sanitizeTs(parseInt(parts[9], 10), parts[0])
      out.push(it)
    }
    out.sort((a, b) => b.updatedAt - a.updatedAt)
    return out
  }
}
