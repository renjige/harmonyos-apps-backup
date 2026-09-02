import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  DashboardStats, Journey, JourneyProgress, RecordLocation, SaituRecord, UserProfile
} from '../models/SaituModels'
import { DateHelper } from './DateHelper'
import { SaituTrackStore } from './SaituTrackStore'
import { SaituSportStore } from './SaituSportStore'
import { SaituCheckInStore } from './SaituCheckInStore'
import { SaituPlanStore } from './SaituPlanStore'
import { SaituAchievementStore } from './SaituAchievementStore'
import { CheckIn, JourneyPlan, AchievementUnlock } from '../models/SaituGrowthModels'
import { SportEvent, SportAlbum, SportFollow, TrainingLog } from '../models/SaituSportModels'
import { JourneyMilestone, SavedInsight } from '../models/SaituModels'

const STORE = 'saitu_zhaji_v1'
const KEY_RECORDS = 'records'
const KEY_JOURNEYS = 'journeys'
const KEY_PROFILE = 'profile'

class ExportRow {
  id: string = ''
  content: string = ''
  journeyId: string = ''
  tags: string[] = []
  images: string[] = []
  createdAt: number = 0
}

class ExportPayload {
  app: string = '赛途札记'
  version: string = '1.3.0'
  exportedAt: number = 0
  records: ExportRow[] = []
  journeys: Journey[] = []
  sportEvents: SportEvent[] = []
  trainings: TrainingLog[] = []
  albums: SportAlbum[] = []
  follows: SportFollow[] = []
  checkIns: CheckIn[] = []
  plans: JourneyPlan[] = []
  milestones: JourneyMilestone[] = []
  insights: SavedInsight[] = []
  achievements: AchievementUnlock[] = []
}

export class SaituLocalStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      SaituLocalStore.pref = await preferences.getPreferences(context, STORE)
    } catch {
      SaituLocalStore.pref = null
    }
  }

  static async loadRecords(): Promise<SaituRecord[]> {
    const raw = await SaituLocalStore.getString(KEY_RECORDS, '')
    const list = SaituLocalStore.parseRecords(raw)
    list.sort((a, b) => b.createdAt - a.createdAt)
    return list
  }

  static async saveRecord(record: SaituRecord): Promise<void> {
    record.updatedAt = Date.now()
    const list = await SaituLocalStore.loadRecords()
    const next: SaituRecord[] = []
    let found = false
    for (const it of list) {
      if (it.id === record.id) {
        next.push(record)
        found = true
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.push(record)
    }
    next.sort((a, b) => b.createdAt - a.createdAt)
    await SaituLocalStore.persistRecords(next)
  }

  static async deleteRecord(id: string): Promise<void> {
    const list = await SaituLocalStore.loadRecords()
    const next: SaituRecord[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await SaituLocalStore.persistRecords(next)
  }

  static async findRecord(id: string): Promise<SaituRecord | undefined> {
    const list = await SaituLocalStore.loadRecords()
    for (const it of list) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static async loadJourneys(): Promise<Journey[]> {
    const raw = await SaituLocalStore.getString(KEY_JOURNEYS, '')
    const list = SaituLocalStore.parseJourneys(raw)
    list.sort((a, b) => b.createdAt - a.createdAt)
    return list
  }

  static async saveJourney(journey: Journey): Promise<void> {
    journey.updatedAt = Date.now()
    const list = await SaituLocalStore.loadJourneys()
    const next: Journey[] = []
    let found = false
    for (const it of list) {
      if (it.id === journey.id) {
        next.push(journey)
        found = true
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.push(journey)
    }
    await SaituLocalStore.persistJourneys(next)
    SaituLocalStore.notifyJourneyChanged()
  }

  static async deleteJourney(id: string): Promise<void> {
    const list = await SaituLocalStore.loadJourneys()
    const next: Journey[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await SaituLocalStore.persistJourneys(next)
    const records = await SaituLocalStore.loadRecords()
    for (const r of records) {
      if (r.journeyId === id) {
        r.journeyId = ''
        await SaituLocalStore.saveRecord(r)
      }
    }
    SaituLocalStore.notifyJourneyChanged()
  }

  static notifyJourneyChanged(): void {
    const n = (AppStorage.get<number>('saituJourneyEpoch') ?? 0) + 1
    AppStorage.setOrCreate('saituJourneyEpoch', n)
  }

  static async findJourney(id: string): Promise<Journey | undefined> {
    if (id.length === 0) {
      return undefined
    }
    const list = await SaituLocalStore.loadJourneys()
    for (const it of list) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static async loadProfile(): Promise<UserProfile> {
    const raw = await SaituLocalStore.getString(KEY_PROFILE, '')
    if (raw.length === 0) {
      return new UserProfile()
    }
    const parts = raw.split('\t')
    const p = new UserProfile()
    p.nickname = parts.length > 0 && parts[0].length > 0 ? parts[0] : p.nickname
    p.themeMode = parts.length > 1 && parts[1].length > 0 ? parts[1] : p.themeMode
    return p
  }

  static async saveProfile(profile: UserProfile): Promise<void> {
    await SaituLocalStore.putString(KEY_PROFILE, `${profile.nickname}\t${profile.themeMode}`)
  }

  static async dashboardStats(): Promise<DashboardStats> {
    const records = await SaituLocalStore.loadRecords()
    const journeys = await SaituLocalStore.loadJourneys()
    const stats = new DashboardStats()
    stats.totalRecords = records.length
    stats.totalJourneys = journeys.length
    stats.streakDays = SaituLocalStore.calcStreak(records)
    const weekKeys = DateHelper.lastNDays(7)
    const monthKeys = DateHelper.lastNDays(30)
    const weekSet = new Set<string>()
    for (const k of weekKeys) {
      weekSet.add(k)
    }
    const monthSet = new Set<string>()
    for (const k of monthKeys) {
      monthSet.add(k)
    }
    let photos = 0
    let tagged = 0
    for (const r of records) {
      photos += r.images.length
      if (r.tags.length > 0) {
        tagged++
      }
      const dk = r.dateKey()
      if (weekSet.has(dk)) {
        stats.weekRecords++
      }
      if (monthSet.has(dk)) {
        stats.monthRecords++
      }
    }
    stats.photoCount = photos
    stats.taggedCount = tagged
    const milestones = await SaituTrackStore.loadMilestones()
    stats.milestoneTotal = milestones.length
    let done = 0
    for (const m of milestones) {
      if (m.done) {
        done++
      }
    }
    stats.milestoneDone = done
    const insights = await SaituTrackStore.loadInsights()
    stats.savedReports = insights.length
    return stats
  }

  static async journeyProgress(): Promise<JourneyProgress[]> {
    const records = await SaituLocalStore.loadRecords()
    const journeys = await SaituLocalStore.loadJourneys()
    const milestones = await SaituTrackStore.loadMilestones()
    const recMap = new Map<string, number>()
    for (const r of records) {
      if (r.journeyId.length > 0) {
        recMap.set(r.journeyId, (recMap.get(r.journeyId) ?? 0) + 1)
      }
    }
    const doneMap = new Map<string, number>()
    const totalMap = new Map<string, number>()
    for (const m of milestones) {
      totalMap.set(m.journeyId, (totalMap.get(m.journeyId) ?? 0) + 1)
      if (m.done) {
        doneMap.set(m.journeyId, (doneMap.get(m.journeyId) ?? 0) + 1)
      }
    }
    const out: JourneyProgress[] = []
    for (const j of journeys) {
      const p = new JourneyProgress()
      p.journeyId = j.id
      p.name = j.name
      p.color = j.color
      p.recordCount = recMap.get(j.id) ?? 0
      p.milestoneTotal = totalMap.get(j.id) ?? 0
      p.milestoneDone = doneMap.get(j.id) ?? 0
      if (p.milestoneTotal > 0) {
        p.ratio = p.milestoneDone / p.milestoneTotal
        p.progressLabel = `节点 ${p.milestoneDone}/${p.milestoneTotal} · 札记 ${p.recordCount}`
      } else {
        p.ratio = p.recordCount > 0 ? 0.35 : 0.08
        p.progressLabel = `札记 ${p.recordCount} 条 · 尚未设节点`
      }
      out.push(p)
    }
    out.sort((a, b) => b.milestoneDone - a.milestoneDone)
    return out
  }

  static async recordsInRange(startKey: string, endKey: string): Promise<SaituRecord[]> {
    const list = await SaituLocalStore.loadRecords()
    const out: SaituRecord[] = []
    for (const r of list) {
      const dk = r.dateKey()
      if (dk >= startKey && dk <= endKey) {
        out.push(r)
      }
    }
    return out
  }

  static async exportJson(): Promise<string> {
    const records = await SaituLocalStore.loadRecords()
    const journeys = await SaituLocalStore.loadJourneys()
    const payload = new ExportPayload()
    payload.exportedAt = Date.now()
    for (const r of records) {
      const row = new ExportRow()
      row.id = r.id
      row.content = r.content
      row.journeyId = r.journeyId
      row.tags = r.tags
      row.images = r.images
      row.createdAt = r.createdAt
      payload.records.push(row)
    }
    payload.journeys = journeys
    payload.sportEvents = await SaituSportStore.loadEvents()
    payload.trainings = await SaituSportStore.loadTrainings()
    payload.albums = await SaituSportStore.loadAlbums()
    payload.follows = await SaituSportStore.loadFollows()
    payload.checkIns = await SaituCheckInStore.loadCheckIns()
    payload.plans = await SaituPlanStore.loadPlans()
    payload.milestones = await SaituTrackStore.loadMilestones()
    payload.insights = await SaituTrackStore.loadInsights()
    payload.achievements = await SaituAchievementStore.loadUnlocks()
    return JSON.stringify(payload)
  }

  static async clearAll(): Promise<void> {
    await SaituLocalStore.putString(KEY_RECORDS, '')
    await SaituLocalStore.putString(KEY_JOURNEYS, '')
    await SaituTrackStore.clearAll()
    await SaituSportStore.clearAll()
    await SaituCheckInStore.clearAll()
    await SaituPlanStore.clearAll()
    await SaituAchievementStore.clearAll()
  }

  private static calcStreak(records: SaituRecord[]): number {
    const keys = new Set<string>()
    for (const r of records) {
      keys.add(r.dateKey())
    }
    let streak = 0
    const cursor = new Date()
    for (;;) {
      const key = DateHelper.keyFromDate(cursor)
      if (keys.has(key)) {
        streak++
        cursor.setDate(cursor.getDate() - 1)
      } else {
        break
      }
    }
    return streak
  }

  private static async persistRecords(items: SaituRecord[]): Promise<void> {
    const lines: string[] = []
    for (const it of items) {
      lines.push(SaituLocalStore.serializeRecord(it))
    }
    await SaituLocalStore.putString(KEY_RECORDS, lines.join('\n'))
  }

  private static async persistJourneys(items: Journey[]): Promise<void> {
    const lines: string[] = []
    for (const it of items) {
      lines.push(SaituLocalStore.serializeJourney(it))
    }
    await SaituLocalStore.putString(KEY_JOURNEYS, lines.join('\n'))
  }

  private static serializeRecord(it: SaituRecord): string {
    const content = it.content.replace(/\n/g, '\\n').replace(/\t/g, ' ')
    const tags = it.tags.join(',')
    const images = it.images.join('|')
    let loc = ''
    if (it.location !== null) {
      loc = `${it.location.lat}|${it.location.lng}|${it.location.address.replace(/\t/g, ' ')}`
    }
    return [
      it.id, content, tags, images, loc, it.journeyId,
      `${it.createdAt}`, `${it.updatedAt}`, it.favorite ? '1' : '0'
    ].join('\t')
  }

  private static parseRecords(raw: string): SaituRecord[] {
    const out: SaituRecord[] = []
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
      const r = new SaituRecord()
      r.id = parts[0]
      r.content = parts[1].replace(/\\n/g, '\n')
      r.tags = parts[2].length > 0 ? parts[2].split(',') : []
      r.images = parts[3].length > 0 ? parts[3].split('|') : []
      if (parts[4].length > 0) {
        const lp = parts[4].split('|')
        if (lp.length >= 3) {
          r.location = RecordLocation.fromParts(parseFloat(lp[0]), parseFloat(lp[1]), lp[2])
        }
      } else {
        r.location = null
      }
      r.journeyId = parts[5]
      r.createdAt = parseInt(parts[6], 10)
      r.updatedAt = parseInt(parts[7], 10)
      if (parts.length >= 9) {
        r.favorite = parts[8] === '1'
      }
      out.push(r)
    }
    return out
  }

  private static serializeJourney(it: Journey): string {
    const desc = it.description.replace(/\n/g, '\\n').replace(/\t/g, ' ')
    const updated = it.updatedAt > 0 ? it.updatedAt : it.createdAt
    return [it.id, it.name, desc, it.startDate, it.endDate, it.color, `${it.createdAt}`, `${updated}`].join('\t')
  }

  private static parseJourneys(raw: string): Journey[] {
    const out: Journey[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 7) {
        continue
      }
      const j = new Journey()
      j.id = parts[0]
      j.name = parts[1]
      j.description = parts[2].replace(/\\n/g, '\n')
      j.startDate = parts[3]
      j.endDate = parts[4]
      j.color = parts[5]
      j.createdAt = parseInt(parts[6], 10)
      if (parts.length >= 8) {
        j.updatedAt = parseInt(parts[7], 10)
      } else {
        j.updatedAt = j.createdAt
      }
      out.push(j)
    }
    return out
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (SaituLocalStore.pref === null) {
      return fallback
    }
    try {
      const v = await SaituLocalStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (SaituLocalStore.pref === null) {
      return
    }
    try {
      await SaituLocalStore.pref.put(key, value)
      await SaituLocalStore.pref.flush()
    } catch {
      // ignore
    }
  }
}
