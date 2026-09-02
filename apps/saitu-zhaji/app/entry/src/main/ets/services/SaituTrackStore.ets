import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { JourneyMilestone, SavedInsight } from '../models/SaituModels'
import { SaituRefreshSignals } from './SaituRefreshSignals'

const STORE = 'saitu_zhaji_track_v1'
const KEY_MILESTONES = 'milestones'
const KEY_INSIGHTS = 'insights'

export class SaituTrackStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      SaituTrackStore.pref = await preferences.getPreferences(context, STORE)
    } catch {
      SaituTrackStore.pref = null
    }
  }

  static async loadMilestones(): Promise<JourneyMilestone[]> {
    return SaituTrackStore.parseMilestones(await SaituTrackStore.getString(KEY_MILESTONES, ''))
  }

  static async saveMilestone(item: JourneyMilestone): Promise<void> {
    item.updatedAt = Date.now()
    const list = await SaituTrackStore.loadMilestones()
    const next: JourneyMilestone[] = []
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
      next.push(item)
    }
    next.sort((a, b) => b.createdAt - a.createdAt)
    await SaituTrackStore.persistMilestones(next)
    SaituRefreshSignals.bumpTrackEpoch()
  }

  static async deleteMilestone(id: string): Promise<void> {
    const list = await SaituTrackStore.loadMilestones()
    const next: JourneyMilestone[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await SaituTrackStore.persistMilestones(next)
    SaituRefreshSignals.bumpTrackEpoch()
  }

  static async findMilestone(id: string): Promise<JourneyMilestone | undefined> {
    const list = await SaituTrackStore.loadMilestones()
    for (const it of list) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static async loadInsights(): Promise<SavedInsight[]> {
    const list = SaituTrackStore.parseInsights(await SaituTrackStore.getString(KEY_INSIGHTS, ''))
    list.sort((a, b) => b.createdAt - a.createdAt)
    return list
  }

  static async saveInsight(item: SavedInsight): Promise<void> {
    const list = await SaituTrackStore.loadInsights()
    list.unshift(item)
    await SaituTrackStore.persistInsights(list)
  }

  static async deleteInsight(id: string): Promise<void> {
    const list = await SaituTrackStore.loadInsights()
    const next: SavedInsight[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await SaituTrackStore.persistInsights(next)
  }

  static async findInsight(id: string): Promise<SavedInsight | undefined> {
    const list = await SaituTrackStore.loadInsights()
    for (const it of list) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static async clearAll(): Promise<void> {
    await SaituTrackStore.putString(KEY_MILESTONES, '')
    await SaituTrackStore.putString(KEY_INSIGHTS, '')
  }

  private static async persistMilestones(items: JourneyMilestone[]): Promise<void> {
    const lines: string[] = []
    for (const it of items) {
      const title = it.title.replace(/\t/g, ' ')
      const note = it.note.replace(/\n/g, '\\n').replace(/\t/g, ' ')
      lines.push([it.id, it.journeyId, title, note, it.dueDate, it.done ? '1' : '0',
        `${it.createdAt}`, `${it.updatedAt}`].join('\t'))
    }
    await SaituTrackStore.putString(KEY_MILESTONES, lines.join('\n'))
  }

  private static parseMilestones(raw: string): JourneyMilestone[] {
    const out: JourneyMilestone[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 8) {
        continue
      }
      const m = new JourneyMilestone()
      m.id = parts[0]
      m.journeyId = parts[1]
      m.title = parts[2]
      m.note = parts[3].replace(/\\n/g, '\n')
      m.dueDate = parts[4]
      m.done = parts[5] === '1'
      m.createdAt = parseInt(parts[6], 10)
      m.updatedAt = parseInt(parts[7], 10)
      out.push(m)
    }
    return out
  }

  private static async persistInsights(items: SavedInsight[]): Promise<void> {
    const lines: string[] = []
    for (const it of items) {
      const body = it.body.replace(/\n/g, '\\n').replace(/\t/g, ' ')
      lines.push([it.id, it.periodKind, it.periodLabel, body, `${it.recordCount}`,
        it.topTag, it.keywords.replace(/\t/g, ' '), `${it.createdAt}`, it.favorite ? '1' : '0'].join('\t'))
    }
    await SaituTrackStore.putString(KEY_INSIGHTS, lines.join('\n'))
  }

  private static parseInsights(raw: string): SavedInsight[] {
    const out: SavedInsight[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 8) {
        continue
      }
      const s = new SavedInsight()
      s.id = parts[0]
      s.periodKind = parts[1]
      s.periodLabel = parts[2]
      s.body = parts[3].replace(/\\n/g, '\n')
      s.recordCount = parseInt(parts[4], 10)
      s.topTag = parts[5]
      s.keywords = parts[6]
      s.createdAt = parseInt(parts[7], 10)
      if (parts.length >= 9) {
        s.favorite = parts[8] === '1'
      }
      out.push(s)
    }
    return out
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (SaituTrackStore.pref === null) {
      return fallback
    }
    try {
      const v = await SaituTrackStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (SaituTrackStore.pref === null) {
      return
    }
    try {
      await SaituTrackStore.pref.put(key, value)
      await SaituTrackStore.pref.flush()
    } catch {
      // ignore
    }
  }
}
