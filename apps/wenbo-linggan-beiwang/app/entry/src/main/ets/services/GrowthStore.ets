import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  ActivityEvent,
  CheckInRecord,
  GrowthPayload,
  RecentBrowseItem,
  TopicItem
} from '../models/GrowthModels'
import { ContentSync } from './ContentSync'

const STORE_NAME = 'inspiration_growth'
const KEY_PREFIX = 'growth_'

class GrowthFileRoot {
  checkIns: CheckInRecord[] = []
  topics: TopicItem[] = []
  activity: ActivityEvent[] = []
  recent: RecentBrowseItem[] = []
  unlocked: string[] = []
}

export class GrowthStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      GrowthStore.pref = await preferences.getPreferences(context, STORE_NAME)
    } catch {
      GrowthStore.pref = null
    }
  }

  static empty(): GrowthPayload {
    return new GrowthPayload()
  }

  static async load(username: string): Promise<GrowthPayload> {
    if (username.length === 0 || GrowthStore.pref === null) {
      return GrowthStore.empty()
    }
    try {
      const rawValue = await GrowthStore.pref.get(`${KEY_PREFIX}${username}`, '')
      const raw: string = typeof rawValue === 'string' ? rawValue : ''
      if (raw.length === 0) {
        return GrowthStore.empty()
      }
      return GrowthStore.parse(raw)
    } catch {
      return GrowthStore.empty()
    }
  }

  static async save(username: string, payload: GrowthPayload): Promise<void> {
    if (username.length === 0 || GrowthStore.pref === null) {
      return
    }
    try {
      await GrowthStore.pref.put(`${KEY_PREFIX}${username}`, GrowthStore.encode(payload))
      await GrowthStore.pref.flush()
      const epoch = AppStorage.get<number>('growthEpoch') ?? 0
      AppStorage.setOrCreate('growthEpoch', epoch + 1)
      ContentSync.bump()
    } catch {
      // keep memory state; next write retries
    }
  }

  private static textOf(v: string): string {
    return v ?? ''
  }

  private static parse(raw: string): GrowthPayload {
    const out = new GrowthPayload()
    const root = JSON.parse(raw) as GrowthFileRoot
    if (root.checkIns !== undefined && root.checkIns !== null) {
      for (const row of root.checkIns) {
        out.checkIns.push(CheckInRecord.of(GrowthStore.textOf(row.date), GrowthStore.textOf(row.note)))
      }
    }
    if (root.topics !== undefined && root.topics !== null) {
      for (const row of root.topics) {
        const t = new TopicItem()
        t.id = GrowthStore.textOf(row.id)
        t.title = GrowthStore.textOf(row.title)
        t.summary = GrowthStore.textOf(row.summary)
        t.createdAt = GrowthStore.textOf(row.createdAt)
        if (row.inspirationIds !== undefined && row.inspirationIds !== null) {
          t.inspirationIds = row.inspirationIds
        }
        out.topics.push(t)
      }
    }
    if (root.activity !== undefined && root.activity !== null) {
      for (const row of root.activity) {
        const e = new ActivityEvent()
        e.type = GrowthStore.textOf(row.type)
        e.title = GrowthStore.textOf(row.title)
        e.refKind = GrowthStore.textOf(row.refKind)
        e.refId = GrowthStore.textOf(row.refId)
        e.at = GrowthStore.textOf(row.at)
        out.activity.push(e)
      }
    }
    if (root.recent !== undefined && root.recent !== null) {
      for (const row of root.recent) {
        const r = new RecentBrowseItem()
        r.kind = GrowthStore.textOf(row.kind)
        r.id = GrowthStore.textOf(row.id)
        r.title = GrowthStore.textOf(row.title)
        r.at = GrowthStore.textOf(row.at)
        out.recent.push(r)
      }
    }
    if (root.unlocked !== undefined && root.unlocked !== null) {
      out.unlocked = root.unlocked
    }
    return out
  }

  private static encode(p: GrowthPayload): string {
    return `{"checkIns":${GrowthStore.encodeCheckIns(p.checkIns)},"topics":${GrowthStore.encodeTopics(p.topics)},"activity":${GrowthStore.encodeActivity(p.activity)},"recent":${GrowthStore.encodeRecent(p.recent)},"unlocked":${JSON.stringify(p.unlocked)}}`
  }

  private static encodeCheckIns(list: CheckInRecord[]): string {
    const parts: string[] = []
    for (const row of list) {
      parts.push(`{"date":${JSON.stringify(row.date)},"note":${JSON.stringify(row.note)}}`)
    }
    return `[${parts.join(',')}]`
  }

  private static encodeTopics(list: TopicItem[]): string {
    const parts: string[] = []
    for (const row of list) {
      parts.push(`{"id":${JSON.stringify(row.id)},"title":${JSON.stringify(row.title)},"summary":${JSON.stringify(row.summary)},"inspirationIds":${JSON.stringify(row.inspirationIds)},"createdAt":${JSON.stringify(row.createdAt)}}`)
    }
    return `[${parts.join(',')}]`
  }

  private static encodeActivity(list: ActivityEvent[]): string {
    const parts: string[] = []
    for (const row of list) {
      parts.push(`{"type":${JSON.stringify(row.type)},"title":${JSON.stringify(row.title)},"refKind":${JSON.stringify(row.refKind)},"refId":${JSON.stringify(row.refId)},"at":${JSON.stringify(row.at)}}`)
    }
    return `[${parts.join(',')}]`
  }

  private static encodeRecent(list: RecentBrowseItem[]): string {
    const parts: string[] = []
    for (const row of list) {
      parts.push(`{"kind":${JSON.stringify(row.kind)},"id":${JSON.stringify(row.id)},"title":${JSON.stringify(row.title)},"at":${JSON.stringify(row.at)}}`)
    }
    return `[${parts.join(',')}]`
  }
}
