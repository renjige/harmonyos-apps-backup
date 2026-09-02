import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  AchievementBadge,
  ActivityEvent,
  CheckInRecord,
  FavoriteEntry,
  ProcurementPlan,
  ProcurementTopic
} from '../models/ShoppingModels'
import { ShoppingLocalStore } from './ShoppingLocalStore'

const STORE = 'shopping_memo_local'
const KEY_GROWTH = 'growthData'

export class GrowthWire {
  plans: ProcurementPlan[] = []
  checkIns: CheckInRecord[] = []
  events: ActivityEvent[] = []
  badges: AchievementBadge[] = []
  topics: ProcurementTopic[] = []
  favorites: FavoriteEntry[] = []
}

export class GrowthLocalStore {
  private static pref: preferences.Preferences | null = null
  private static cache: GrowthWire = new GrowthWire()

  static async init(context: common.Context): Promise<void> {
    try {
      GrowthLocalStore.pref = await preferences.getPreferences(context, STORE)
      const rawValue = await GrowthLocalStore.pref.get(KEY_GROWTH, '')
      const raw: string = typeof rawValue === 'string' ? rawValue : ''
      GrowthLocalStore.cache = GrowthLocalStore.parse(raw)
      GrowthLocalStore.ensureDefaultBadges()
    } catch {
      GrowthLocalStore.cache = new GrowthWire()
      GrowthLocalStore.ensureDefaultBadges()
    }
  }

  static plans(): ProcurementPlan[] {
    return GrowthLocalStore.copyPlans(GrowthLocalStore.cache.plans)
  }

  static checkIns(): CheckInRecord[] {
    return GrowthLocalStore.copyCheckIns(GrowthLocalStore.cache.checkIns)
  }

  static events(): ActivityEvent[] {
    return GrowthLocalStore.copyEvents(GrowthLocalStore.cache.events)
  }

  static badges(): AchievementBadge[] {
    return GrowthLocalStore.copyBadges(GrowthLocalStore.cache.badges)
  }

  static topics(): ProcurementTopic[] {
    return GrowthLocalStore.copyTopics(GrowthLocalStore.cache.topics)
  }

  static favorites(): FavoriteEntry[] {
    return GrowthLocalStore.copyFavorites(GrowthLocalStore.cache.favorites)
  }

  static snapshotWire(): GrowthWire {
    const out = new GrowthWire()
    out.plans = GrowthLocalStore.copyPlans(GrowthLocalStore.cache.plans)
    out.checkIns = GrowthLocalStore.copyCheckIns(GrowthLocalStore.cache.checkIns)
    out.events = GrowthLocalStore.copyEvents(GrowthLocalStore.cache.events)
    out.badges = GrowthLocalStore.copyBadges(GrowthLocalStore.cache.badges)
    out.topics = GrowthLocalStore.copyTopics(GrowthLocalStore.cache.topics)
    out.favorites = GrowthLocalStore.copyFavorites(GrowthLocalStore.cache.favorites)
    return out
  }

  static async saveAll(next: GrowthWire): Promise<void> {
    GrowthLocalStore.cache = next
    await GrowthLocalStore.persist()
  }

  static async persist(): Promise<void> {
    if (GrowthLocalStore.pref === null) {
      return
    }
    try {
      await GrowthLocalStore.pref.put(KEY_GROWTH, JSON.stringify(GrowthLocalStore.cache))
      await GrowthLocalStore.pref.flush()
    } catch {
    }
  }

  static newId(prefix: string): string {
    return `${prefix}_${Date.now()}_${GrowthLocalStore.cache.events.length}`
  }

  static ensureDefaultBadges(): void {
    if (GrowthLocalStore.cache.badges.length > 0) {
      return
    }
    GrowthLocalStore.cache.badges = GrowthLocalStore.defaultBadges()
  }

  static defaultBadges(): AchievementBadge[] {
    const defs: string[] = [
      'first_list|首次清单|创建第一份采购清单|1',
      'first_check|首次勾选|勾选第一件商品|1',
      'check_10|勾选达人|累计勾选 10 件商品|10',
      'check_50|采购能手|累计勾选 50 件商品|50',
      'streak_3|连续 3 天|连续 3 天完成采购打卡|3',
      'streak_7|连续 7 天|连续 7 天完成采购打卡|7',
      'plan_done|计划达成|完成一次本周采购计划|1',
      'star_3|收藏达人|收藏 3 份清单或方案|3'
    ]
    const out: AchievementBadge[] = []
    for (const line of defs) {
      const parts = line.split('|')
      const b = new AchievementBadge()
      b.id = parts[0]
      b.title = parts[1]
      b.desc = parts[2]
      b.target = Number.parseInt(parts[3])
      if (Number.isNaN(b.target)) {
        b.target = 1
      }
      b.progress = 0
      b.unlockedAt = ''
      out.push(b)
    }
    return out
  }

  static clonePlan(row: ProcurementPlan): ProcurementPlan {
    const out = new ProcurementPlan()
    out.id = row.id ?? ''
    out.title = row.title ?? ''
    out.period = row.period ?? 'week'
    out.startDate = row.startDate ?? ''
    out.endDate = row.endDate ?? ''
    out.targetItemCount = row.targetItemCount ?? 0
    out.targetBudgetYuan = row.targetBudgetYuan ?? ''
    out.linkedListIds = row.linkedListIds !== undefined ? row.linkedListIds.slice() : []
    out.status = row.status ?? 'active'
    out.createdAt = row.createdAt ?? ''
    return out
  }

  static cloneCheckIn(row: CheckInRecord): CheckInRecord {
    const out = new CheckInRecord()
    out.dateKey = row.dateKey ?? ''
    out.source = row.source ?? 'manual'
    out.note = row.note ?? ''
    out.createdAt = row.createdAt ?? ''
    return out
  }

  static cloneEvent(row: ActivityEvent): ActivityEvent {
    const out = new ActivityEvent()
    out.id = row.id ?? ''
    out.type = row.type ?? ''
    out.title = row.title ?? ''
    out.summary = row.summary ?? ''
    out.refId = row.refId ?? ''
    out.createdAt = row.createdAt ?? ''
    return out
  }

  static cloneBadge(row: AchievementBadge): AchievementBadge {
    const out = new AchievementBadge()
    out.id = row.id ?? ''
    out.title = row.title ?? ''
    out.desc = row.desc ?? ''
    out.iconKey = row.iconKey ?? 'check'
    out.target = row.target ?? 1
    out.progress = row.progress ?? 0
    out.unlockedAt = row.unlockedAt ?? ''
    return out
  }

  static cloneTopic(row: ProcurementTopic): ProcurementTopic {
    const out = new ProcurementTopic()
    out.id = row.id ?? ''
    out.title = row.title ?? ''
    out.coverKey = row.coverKey ?? 'tpl_daily'
    out.listIds = row.listIds !== undefined ? row.listIds.slice() : []
    out.memoIds = row.memoIds !== undefined ? row.memoIds.slice() : []
    out.updatedAt = row.updatedAt ?? ''
    return out
  }

  static cloneFavorite(row: FavoriteEntry): FavoriteEntry {
    const out = new FavoriteEntry()
    out.refType = row.refType ?? ''
    out.refId = row.refId ?? ''
    out.title = row.title ?? ''
    out.subtitle = row.subtitle ?? ''
    out.createdAt = row.createdAt ?? ''
    return out
  }

  static copyPlans(rows: ProcurementPlan[]): ProcurementPlan[] {
    const out: ProcurementPlan[] = []
    for (const row of rows) {
      out.push(GrowthLocalStore.clonePlan(row))
    }
    return out
  }

  static copyCheckIns(rows: CheckInRecord[]): CheckInRecord[] {
    const out: CheckInRecord[] = []
    for (const row of rows) {
      out.push(GrowthLocalStore.cloneCheckIn(row))
    }
    return out
  }

  static copyEvents(rows: ActivityEvent[]): ActivityEvent[] {
    const out: ActivityEvent[] = []
    for (const row of rows) {
      out.push(GrowthLocalStore.cloneEvent(row))
    }
    return out
  }

  static copyBadges(rows: AchievementBadge[]): AchievementBadge[] {
    const out: AchievementBadge[] = []
    for (const row of rows) {
      out.push(GrowthLocalStore.cloneBadge(row))
    }
    return out
  }

  static copyTopics(rows: ProcurementTopic[]): ProcurementTopic[] {
    const out: ProcurementTopic[] = []
    for (const row of rows) {
      out.push(GrowthLocalStore.cloneTopic(row))
    }
    return out
  }

  static copyFavorites(rows: FavoriteEntry[]): FavoriteEntry[] {
    const out: FavoriteEntry[] = []
    for (const row of rows) {
      out.push(GrowthLocalStore.cloneFavorite(row))
    }
    return out
  }

  private static parse(raw: string): GrowthWire {
    const out = new GrowthWire()
    if (raw.length === 0) {
      return out
    }
    try {
      const parsed = JSON.parse(raw) as GrowthWire
      if (parsed.plans !== undefined) {
        out.plans = GrowthLocalStore.copyPlans(parsed.plans)
      }
      if (parsed.checkIns !== undefined) {
        out.checkIns = GrowthLocalStore.copyCheckIns(parsed.checkIns)
      }
      if (parsed.events !== undefined) {
        out.events = GrowthLocalStore.copyEvents(parsed.events)
      }
      if (parsed.badges !== undefined) {
        out.badges = GrowthLocalStore.copyBadges(parsed.badges)
      }
      if (parsed.topics !== undefined) {
        out.topics = GrowthLocalStore.copyTopics(parsed.topics)
      }
      if (parsed.favorites !== undefined) {
        out.favorites = GrowthLocalStore.copyFavorites(parsed.favorites)
      }
      return out
    } catch {
      return out
    }
  }
}
