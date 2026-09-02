import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { BreakdownItem, OpinionItem, ThinkNote } from '../models/ThinkModels'
import { SparkLink } from '../models/SparkLinkModels'
import { ThoughtCard } from '../models/ThoughtModels'
import { AppContextService } from './AppContextService'
import { ThinkStore } from './ThinkStore'

const STORE = 'siwei_xia_bridge_v1'
const KEY_LINKS = 'links'

export class SparkBridge {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      SparkBridge.pref = await preferences.getPreferences(context, STORE)
    } catch {
      SparkBridge.pref = null
    }
  }

  static async ensureReady(): Promise<void> {
    if (SparkBridge.pref !== null) {
      return
    }
    const ctx = AppContextService.getContext()
    if (ctx !== null) {
      await SparkBridge.init(ctx)
    }
  }

  static async getLink(cardId: string): Promise<SparkLink> {
    await SparkBridge.ensureReady()
    const all = await SparkBridge.loadAll()
    for (const it of all) {
      if (it.cardId === cardId) {
        return it
      }
    }
    const empty = new SparkLink()
    empty.cardId = cardId
    return empty
  }

  static async linkedCount(): Promise<number> {
    const all = await SparkBridge.loadAll()
    let n = 0
    for (const it of all) {
      if (it.breakId.length > 0 || it.noteId.length > 0 || it.opinionId.length > 0) {
        n = n + 1
      }
    }
    return n
  }

  static async linkedCardIds(): Promise<string[]> {
    const all = await SparkBridge.loadAll()
    const ids: string[] = []
    for (const it of all) {
      if (it.breakId.length > 0 || it.noteId.length > 0 || it.opinionId.length > 0) {
        ids.push(it.cardId)
      }
    }
    return ids
  }

  static async isLinked(cardId: string): Promise<boolean> {
    const link = await SparkBridge.getLink(cardId)
    return link.breakId.length > 0 || link.noteId.length > 0 || link.opinionId.length > 0
  }

  static async spawnBreakdown(card: ThoughtCard): Promise<string> {
    const item = new BreakdownItem()
    item.id = ThinkStore.newId('bk')
    item.question = card.titleLine()
    item.current = card.body
    item.causes = ''
    item.solutions = ''
    item.createdAt = Date.now()
    item.updatedAt = item.createdAt
    await ThinkStore.saveBreak(item)
    await SparkBridge.attach(card.id, 'break', item.id)
    return item.id
  }

  static async spawnNote(card: ThoughtCard): Promise<string> {
    const item = new ThinkNote()
    item.id = ThinkStore.newId('nt')
    item.title = card.titleLine()
    item.body = card.body
    item.category = card.shelf.length > 0 ? card.shelf : '学习思考'
    item.createdAt = Date.now()
    item.updatedAt = item.createdAt
    await ThinkStore.saveNote(item)
    await SparkBridge.attach(card.id, 'note', item.id)
    return item.id
  }

  static async spawnOpinion(card: ThoughtCard): Promise<string> {
    const item = new OpinionItem()
    item.id = ThinkStore.newId('op')
    item.title = card.titleLine()
    item.viewpoint = card.body.length > 120 ? `${card.body.substring(0, 120)}…` : card.body
    item.remark = card.tagsCsv.length > 0 ? `来自标签：${card.tagsCsv}` : ''
    item.createdAt = Date.now()
    item.updatedAt = item.createdAt
    await ThinkStore.saveOpinion(item)
    await SparkBridge.attach(card.id, 'opinion', item.id)
    return item.id
  }

  private static async attach(cardId: string, kind: string, targetId: string): Promise<void> {
    const all = await SparkBridge.loadAll()
    let found = false
    for (const it of all) {
      if (it.cardId === cardId) {
        if (kind === 'break') {
          it.breakId = targetId
        } else if (kind === 'note') {
          it.noteId = targetId
        } else {
          it.opinionId = targetId
        }
        found = true
      }
    }
    if (!found) {
      const link = new SparkLink()
      link.cardId = cardId
      if (kind === 'break') {
        link.breakId = targetId
      } else if (kind === 'note') {
        link.noteId = targetId
      } else {
        link.opinionId = targetId
      }
      all.unshift(link)
    }
    await SparkBridge.persist(all)
  }

  private static async loadAll(): Promise<SparkLink[]> {
    await SparkBridge.ensureReady()
    if (SparkBridge.pref === null) {
      return []
    }
    try {
      const raw = await SparkBridge.pref.get(KEY_LINKS, '')
      return SparkBridge.parse(`${raw}`)
    } catch {
      return []
    }
  }

  private static async persist(list: SparkLink[]): Promise<void> {
    await SparkBridge.ensureReady()
    if (SparkBridge.pref === null) {
      return
    }
    const lines: string[] = []
    for (const it of list) {
      lines.push([it.cardId, it.breakId, it.noteId, it.opinionId].join('|'))
    }
    try {
      await SparkBridge.pref.put(KEY_LINKS, lines.join('\n'))
      await SparkBridge.pref.flush()
    } catch {
    }
  }

  private static parse(raw: string): SparkLink[] {
    const out: SparkLink[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const p = line.split('|')
      if (p.length < 4) {
        continue
      }
      const it = new SparkLink()
      it.cardId = p[0]
      it.breakId = p[1]
      it.noteId = p[2]
      it.opinionId = p[3]
      out.push(it)
    }
    return out
  }
}
