import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { DateHelper } from './DateHelper'
import { HomeRefresh } from './HomeRefresh'
import {
  DashStats, DayCount, ExploreQuest, FieldRecord, GewuBadge, GewuCheckin,
  GewuEvent, GewuPlan, GewuTopic, WeekMark
} from '../models/FieldModels'
class AlbumPair {
  objectId: string = ''
  album: string = ''
}

const STORE = 'gewu_trace_v1'
const KEY_RECORDS = 'fieldRecords'
const KEY_ALBUMS = 'albums'
const KEY_QUESTS = 'quests'
const KEY_TAGS = 'customTags'
const KEY_QUIZ = 'quizScore'
const KEY_PLANS = 'gewuPlans'
const KEY_CHECKINS = 'gewuCheckins'
const KEY_TOPICS = 'gewuTopics'
const KEY_EVENTS = 'gewuEvents'
const KEY_BADGES = 'gewuBadges'
const KEY_BROWSE = 'gewuBrowse'
const KEY_FAV_N = 'gewuFavN'
const KEY_QUIZ_N = 'gewuQuizN'

export class FieldStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      FieldStore.pref = await preferences.getPreferences(context, STORE)
    } catch {
      FieldStore.pref = null
    }
  }

  static async loadRecords(): Promise<FieldRecord[]> {
    const raw = await FieldStore.getString(KEY_RECORDS, '')
    const list = FieldStore.parseRecords(raw)
    list.sort((a: FieldRecord, b: FieldRecord) => b.createdAt - a.createdAt)
    return list
  }

  static async findRecord(id: string): Promise<FieldRecord | undefined> {
    const list = await FieldStore.loadRecords()
    for (const r of list) {
      if (r.id === id) {
        return r
      }
    }
    return undefined
  }

  static async recordsOfSubject(subjectId: string): Promise<FieldRecord[]> {
    const list = await FieldStore.loadRecords()
    const out: FieldRecord[] = []
    for (const r of list) {
      if (r.subjectId === subjectId) {
        out.push(r)
      }
    }
    out.sort((a: FieldRecord, b: FieldRecord) => a.createdAt - b.createdAt)
    return out
  }

  static async saveRecord(record: FieldRecord): Promise<boolean> {
    const title = record.title.trim()
    if (title.length === 0) {
      return false
    }
    record.title = title
    if (record.id.length === 0) {
      record.id = `r_${Date.now()}`
    }
    if (record.subjectId.length === 0) {
      record.subjectId = title
    }
    if (record.createdAt <= 0) {
      record.createdAt = Date.now()
    }
    if (record.dateKey.length === 0) {
      record.dateKey = DateHelper.todayKey()
    }
    const list = await FieldStore.loadRecords()
    let found = false
    const next: FieldRecord[] = []
    for (const r of list) {
      if (r.id === record.id) {
        next.push(record)
        found = true
      } else {
        next.push(r)
      }
    }
    if (!found) {
      next.push(record)
    }
    await FieldStore.putString(KEY_RECORDS, FieldStore.serializeRecords(next))
    await FieldStore.completeQuest('record')
    if (record.atlasKind === '植物图鉴') {
      await FieldStore.completeQuest('plant')
    }
    await FieldStore.mergeCustomTags(record.tags)
    if (record.albumKey.length > 0 && record.subjectId.length > 0) {
      await FieldStore.setAlbum(record.subjectId, record.albumKey)
    }
    await FieldStore.logEvent('record', record.title, record.id)
    await FieldStore.evaluateBadges()
    HomeRefresh.bump()
    return true
  }

  static async deleteRecord(id: string): Promise<void> {
    const list = await FieldStore.loadRecords()
    const next: FieldRecord[] = []
    for (const r of list) {
      if (r.id !== id) {
        next.push(r)
      }
    }
    await FieldStore.putString(KEY_RECORDS, FieldStore.serializeRecords(next))
  }

  static async albumOf(objectId: string): Promise<string> {
    const list = await FieldStore.loadAlbums()
    for (const p of list) {
      if (p.objectId === objectId) {
        return p.album
      }
    }
    return ''
  }

  static async setAlbum(objectId: string, album: string): Promise<void> {
    const list = await FieldStore.loadAlbums()
    const next: AlbumPair[] = []
    for (const p of list) {
      if (p.objectId !== objectId) {
        next.push(p)
      }
    }
    if (album.length > 0) {
      const n = new AlbumPair()
      n.objectId = objectId
      n.album = album
      next.push(n)
    }
    const lines: string[] = []
    for (const p of next) {
      lines.push(`${p.objectId}\t${p.album}`)
    }
    await FieldStore.putString(KEY_ALBUMS, lines.join('\n'))
  }

  static async objectsInAlbum(album: string): Promise<string[]> {
    const list = await FieldStore.loadAlbums()
    const out: string[] = []
    for (const p of list) {
      if (p.album === album) {
        out.push(p.objectId)
      }
    }
    return out
  }

  static async albumCount(): Promise<number> {
    return (await FieldStore.loadAlbums()).length
  }

  private static async loadAlbums(): Promise<AlbumPair[]> {
    const out: AlbumPair[] = []
    const lines = FieldStore.splitLines(await FieldStore.getString(KEY_ALBUMS, ''))
    for (const line of lines) {
      const idx = line.indexOf('\t')
      if (idx > 0) {
        const p = new AlbumPair()
        p.objectId = line.substring(0, idx)
        p.album = line.substring(idx + 1)
        out.push(p)
      }
    }
    return out
  }

  static async completeQuest(questId: string): Promise<void> {
    const today = DateHelper.todayKey()
    const token = `${today}|${questId}`
    const raw = await FieldStore.getString(KEY_QUESTS, '')
    const lines = FieldStore.splitLines(raw)
    for (const line of lines) {
      if (line === token) {
        return
      }
    }
    lines.push(token)
    await FieldStore.putString(KEY_QUESTS, lines.join('\n'))
  }

  static async isQuestDone(questId: string): Promise<boolean> {
    const token = `${DateHelper.todayKey()}|${questId}`
    const lines = FieldStore.splitLines(await FieldStore.getString(KEY_QUESTS, ''))
    for (const line of lines) {
      if (line === token) {
        return true
      }
    }
    return false
  }

  static async todayQuests(): Promise<ExploreQuest[]> {
    const defs: string[][] = [
      ['read', '完成一次今日阅读', '在每日一格标记已读'],
      ['record', '完成一次观察记录', '用模板写下一条格物记录'],
      ['collect', '收藏一个知识点', '收藏任意图鉴条目'],
      ['plant', '今日发现一种植物', '阅读或记录植物图鉴'],
      ['quiz', '完成一次格物小测', '在每日一格答对要点题']
    ]
    const out: ExploreQuest[] = []
    for (const d of defs) {
      const q = new ExploreQuest()
      q.id = FieldStore.cellAt(d, 0)
      q.title = FieldStore.cellAt(d, 1)
      q.hint = FieldStore.cellAt(d, 2)
      q.done = await FieldStore.isQuestDone(q.id)
      out.push(q)
    }
    return out
  }

  static async questDoneCount(): Promise<number> {
    const list = await FieldStore.todayQuests()
    let n = 0
    for (const q of list) {
      if (q.done) {
        n++
      }
    }
    return n
  }

  static async recordStreak(): Promise<number> {
    const list = await FieldStore.loadRecords()
    const days: string[] = []
    for (const r of list) {
      if (days.indexOf(r.dateKey) < 0) {
        days.push(r.dateKey)
      }
    }
    let streak = 0
    let cursor = DateHelper.todayKey()
    while (days.indexOf(cursor) >= 0) {
      streak++
      cursor = DateHelper.addDays(cursor, -1)
    }
    return streak
  }

  static async saveQuizScore(score: number, total: number): Promise<void> {
    const today = DateHelper.todayKey()
    await FieldStore.putString(KEY_QUIZ, `${today}\t${score}\t${total}`)
    await FieldStore.completeQuest('quiz')
    const n = FieldStore.parseCount(await FieldStore.getString(KEY_QUIZ_N, '0'))
    await FieldStore.putString(KEY_QUIZ_N, `${n + 1}`)
    await FieldStore.logEvent('quiz', `格物小测 ${score}/${total}`, today)
    await FieldStore.evaluateBadges()
    HomeRefresh.bump()
  }

  static async todayQuizScore(): Promise<string> {
    const raw = await FieldStore.getString(KEY_QUIZ, '')
    const today = DateHelper.todayKey()
    if (raw.indexOf(`${today}\t`) === 0) {
      return raw
    }
    return ''
  }

  static async weekMarks(): Promise<WeekMark[]> {
    const recs = await FieldStore.loadRecords()
    const keys: string[] = []
    for (const r of recs) {
      if (keys.indexOf(r.dateKey) < 0) {
        keys.push(r.dateKey)
      }
    }
    const out: WeekMark[] = []
    let i = 6
    while (i >= 0) {
      const key = DateHelper.addDays(DateHelper.todayKey(), 0 - i)
      const m = new WeekMark()
      m.key = key
      m.label = DateHelper.displayShort(key)
      m.hasRecord = keys.indexOf(key) >= 0
      out.push(m)
      i--
    }
    return out
  }

  static planDoneCount(plan: GewuPlan, recs: FieldRecord[]): number {
    let n = 0
    for (const r of recs) {
      if (!DateHelper.inRange(r.dateKey, plan.startKey, plan.endKey)) {
        continue
      }
      if (plan.atlasKind !== 'all' && r.atlasKind !== plan.atlasKind) {
        continue
      }
      n++
    }
    return n
  }

  static async loadPlans(): Promise<GewuPlan[]> {
    const out: GewuPlan[] = []
    const lines = FieldStore.splitLines(await FieldStore.getString(KEY_PLANS, ''))
    for (const line of lines) {
      const p = line.split('\t')
      if (p.length < 8) {
        continue
      }
      const plan = new GewuPlan()
      plan.id = FieldStore.cellAt(p, 0)
      plan.title = FieldStore.cellAt(p, 1)
      plan.atlasKind = FieldStore.cellAt(p, 2)
      plan.targetCount = FieldStore.parseCount(FieldStore.cellAt(p, 3))
      plan.startKey = FieldStore.cellAt(p, 4)
      plan.endKey = FieldStore.cellAt(p, 5)
      plan.note = FieldStore.decode(FieldStore.cellAt(p, 6))
      plan.createdAt = FieldStore.parseCount(FieldStore.cellAt(p, 7))
      out.push(plan)
    }
    out.sort((a: GewuPlan, b: GewuPlan) => b.createdAt - a.createdAt)
    return out
  }

  static async findPlan(id: string): Promise<GewuPlan | undefined> {
    const list = await FieldStore.loadPlans()
    for (const p of list) {
      if (p.id === id) {
        return p
      }
    }
    return undefined
  }

  static async savePlan(plan: GewuPlan): Promise<boolean> {
    const title = plan.title.trim()
    if (title.length === 0) {
      return false
    }
    plan.title = title
    if (plan.id.length === 0) {
      plan.id = `p_${Date.now()}`
    }
    if (plan.createdAt <= 0) {
      plan.createdAt = Date.now()
    }
    if (plan.targetCount < 1) {
      plan.targetCount = 3
    }
    if (plan.startKey.length === 0) {
      plan.startKey = DateHelper.todayKey()
    }
    if (plan.endKey.length === 0) {
      plan.endKey = DateHelper.addDays(plan.startKey, 6)
    }
    const list = await FieldStore.loadPlans()
    const next: GewuPlan[] = []
    let found = false
    for (const p of list) {
      if (p.id === plan.id) {
        next.push(plan)
        found = true
      } else {
        next.push(p)
      }
    }
    if (!found) {
      next.push(plan)
    }
    await FieldStore.putString(KEY_PLANS, FieldStore.serializePlans(next))
    await FieldStore.logEvent('plan', plan.title, plan.id)
    await FieldStore.evaluateBadges()
    return true
  }

  static async deletePlan(id: string): Promise<void> {
    const list = await FieldStore.loadPlans()
    const next: GewuPlan[] = []
    for (const p of list) {
      if (p.id !== id) {
        next.push(p)
      }
    }
    await FieldStore.putString(KEY_PLANS, FieldStore.serializePlans(next))
  }

  static async spotlightPlan(): Promise<GewuPlan | undefined> {
    const recs = await FieldStore.loadRecords()
    const today = DateHelper.todayKey()
    const list = await FieldStore.loadPlans()
    for (const p of list) {
      if (DateHelper.inRange(today, p.startKey, p.endKey)) {
        if (FieldStore.planDoneCount(p, recs) < p.targetCount) {
          return p
        }
      }
    }
    if (list.length > 0) {
      for (const p of list) {
        return p
      }
    }
    return undefined
  }

  static async loadCheckins(): Promise<GewuCheckin[]> {
    const out: GewuCheckin[] = []
    const lines = FieldStore.splitLines(await FieldStore.getString(KEY_CHECKINS, ''))
    for (const line of lines) {
      const p = line.split('\t')
      if (p.length < 4) {
        continue
      }
      const c = new GewuCheckin()
      c.dateKey = FieldStore.cellAt(p, 0)
      c.note = FieldStore.decode(FieldStore.cellAt(p, 1))
      c.objectId = FieldStore.cellAt(p, 2)
      c.createdAt = FieldStore.parseCount(FieldStore.cellAt(p, 3))
      out.push(c)
    }
    out.sort((a: GewuCheckin, b: GewuCheckin) => {
      if (a.dateKey < b.dateKey) {
        return 1
      }
      if (a.dateKey > b.dateKey) {
        return -1
      }
      return 0
    })
    return out
  }

  static async todayCheckin(): Promise<GewuCheckin | undefined> {
    const today = DateHelper.todayKey()
    const list = await FieldStore.loadCheckins()
    for (const c of list) {
      if (c.dateKey === today) {
        return c
      }
    }
    return undefined
  }

  static async saveCheckin(note: string, objectId: string): Promise<boolean> {
    const today = DateHelper.todayKey()
    const item = new GewuCheckin()
    item.dateKey = today
    item.note = note.trim()
    item.objectId = objectId
    item.createdAt = Date.now()
    const list = await FieldStore.loadCheckins()
    const next: GewuCheckin[] = []
    let found = false
    for (const c of list) {
      if (c.dateKey === today) {
        next.push(item)
        found = true
      } else {
        next.push(c)
      }
    }
    if (!found) {
      next.push(item)
    }
    await FieldStore.putString(KEY_CHECKINS, FieldStore.serializeCheckins(next))
    await FieldStore.logEvent('checkin', item.note.length > 0 ? item.note : '今日物候打卡', today)
    await FieldStore.evaluateBadges()
    HomeRefresh.bump()
    return true
  }

  static async checkinStreak(): Promise<number> {
    const list = await FieldStore.loadCheckins()
    const days: string[] = []
    for (const c of list) {
      if (days.indexOf(c.dateKey) < 0) {
        days.push(c.dateKey)
      }
    }
    let streak = 0
    let cursor = DateHelper.todayKey()
    while (days.indexOf(cursor) >= 0) {
      streak++
      cursor = DateHelper.addDays(cursor, -1)
    }
    return streak
  }

  static async loadTopics(): Promise<GewuTopic[]> {
    const out: GewuTopic[] = []
    const lines = FieldStore.splitLines(await FieldStore.getString(KEY_TOPICS, ''))
    for (const line of lines) {
      const p = line.split('\t')
      if (p.length < 4) {
        continue
      }
      const t = new GewuTopic()
      t.id = FieldStore.cellAt(p, 0)
      t.title = FieldStore.cellAt(p, 1)
      const ids = FieldStore.cellAt(p, 2)
      t.objectIds = ids.length > 0 ? ids.split(',') : []
      t.createdAt = FieldStore.parseCount(FieldStore.cellAt(p, 3))
      out.push(t)
    }
    out.sort((a: GewuTopic, b: GewuTopic) => b.createdAt - a.createdAt)
    return out
  }

  static async findTopic(id: string): Promise<GewuTopic | undefined> {
    const list = await FieldStore.loadTopics()
    for (const t of list) {
      if (t.id === id) {
        return t
      }
    }
    return undefined
  }

  static async saveTopic(topic: GewuTopic): Promise<boolean> {
    const title = topic.title.trim()
    if (title.length === 0) {
      return false
    }
    topic.title = title
    if (topic.id.length === 0) {
      topic.id = `t_${Date.now()}`
    }
    if (topic.createdAt <= 0) {
      topic.createdAt = Date.now()
    }
    const list = await FieldStore.loadTopics()
    const next: GewuTopic[] = []
    let found = false
    for (const t of list) {
      if (t.id === topic.id) {
        next.push(topic)
        found = true
      } else {
        next.push(t)
      }
    }
    if (!found) {
      next.push(topic)
    }
    await FieldStore.putString(KEY_TOPICS, FieldStore.serializeTopics(next))
    await FieldStore.logEvent('topic', topic.title, topic.id)
    await FieldStore.evaluateBadges()
    return true
  }

  static async deleteTopic(id: string): Promise<void> {
    const list = await FieldStore.loadTopics()
    const next: GewuTopic[] = []
    for (const t of list) {
      if (t.id !== id) {
        next.push(t)
      }
    }
    await FieldStore.putString(KEY_TOPICS, FieldStore.serializeTopics(next))
  }

  static async loadEvents(): Promise<GewuEvent[]> {
    const out: GewuEvent[] = []
    const lines = FieldStore.splitLines(await FieldStore.getString(KEY_EVENTS, ''))
    for (const line of lines) {
      const p = line.split('\t')
      if (p.length < 5) {
        continue
      }
      const e = new GewuEvent()
      e.dateKey = FieldStore.cellAt(p, 0)
      e.kind = FieldStore.cellAt(p, 1)
      e.title = FieldStore.decode(FieldStore.cellAt(p, 2))
      e.refId = FieldStore.cellAt(p, 3)
      e.at = FieldStore.parseCount(FieldStore.cellAt(p, 4))
      out.push(e)
    }
    return out
  }

  static async logEvent(kind: string, title: string, refId: string): Promise<void> {
    const e = new GewuEvent()
    e.dateKey = DateHelper.todayKey()
    e.kind = kind
    e.title = title
    e.refId = refId
    e.at = Date.now()
    const list = await FieldStore.loadEvents()
    const next: GewuEvent[] = []
    next.push(e)
    let n = 0
    for (const item of list) {
      if (n >= 79) {
        break
      }
      next.push(item)
      n++
    }
    await FieldStore.putString(KEY_EVENTS, FieldStore.serializeEvents(next))
  }

  static async browseIds(): Promise<string[]> {
    return FieldStore.splitLines(await FieldStore.getString(KEY_BROWSE, ''))
  }

  static async touchBrowse(id: string): Promise<void> {
    if (id.length === 0) {
      return
    }
    const cur = await FieldStore.browseIds()
    const next: string[] = []
    next.push(id)
    for (const item of cur) {
      if (item !== id && next.length < 20) {
        next.push(item)
      }
    }
    await FieldStore.putString(KEY_BROWSE, next.join('\n'))
    await FieldStore.evaluateBadges()
  }

  static async setFavCount(n: number): Promise<void> {
    await FieldStore.putString(KEY_FAV_N, `${n}`)
    await FieldStore.evaluateBadges()
  }

  static async loadBadges(): Promise<GewuBadge[]> {
    await FieldStore.evaluateBadges()
    const unlocked = FieldStore.splitLines(await FieldStore.getString(KEY_BADGES, ''))
    const list = GewuBadge.catalog()
    for (const b of list) {
      b.unlocked = unlocked.indexOf(b.id) >= 0
    }
    return list
  }

  static async weekBars(): Promise<DayCount[]> {
    const recs = await FieldStore.loadRecords()
    const keys = DateHelper.keysLastN(7)
    const out: DayCount[] = []
    for (const key of keys) {
      const d = new DayCount()
      d.key = key
      d.label = DateHelper.displayShort(key)
      let n = 0
      for (const r of recs) {
        if (r.dateKey === key) {
          n++
        }
      }
      d.count = n
      out.push(d)
    }
    return out
  }

  static async loadDash(favCount: number): Promise<DashStats> {
    const s = new DashStats()
    s.questDone = await FieldStore.questDoneCount()
    const cin = await FieldStore.todayCheckin()
    s.checkinToday = cin !== undefined
    const recs = await FieldStore.loadRecords()
    s.recordCount = recs.length
    s.favCount = favCount
    const rs = await FieldStore.recordStreak()
    const cs = await FieldStore.checkinStreak()
    s.streak = rs > cs ? rs : cs
    s.checkinCount = (await FieldStore.loadCheckins()).length
    s.ritualDone = s.questDone + (s.checkinToday ? 1 : 0)
    s.ritualTotal = 6
    const plan = await FieldStore.spotlightPlan()
    if (plan !== undefined) {
      s.planTitle = plan.title
      s.planId = plan.id
      s.planTarget = plan.targetCount
      s.planDone = FieldStore.planDoneCount(plan, recs)
    }
    s.weekLine = FieldStore.composeReview(recs, await FieldStore.loadCheckins(), 7)
    s.monthLine = FieldStore.composeReview(recs, await FieldStore.loadCheckins(), 30)
    return s
  }

  static async evaluateBadges(): Promise<void> {
    const unlocked = FieldStore.splitLines(await FieldStore.getString(KEY_BADGES, ''))
    const recs = await FieldStore.loadRecords()
    const checkins = await FieldStore.loadCheckins()
    const favN = FieldStore.parseCount(await FieldStore.getString(KEY_FAV_N, '0'))
    const quizN = FieldStore.parseCount(await FieldStore.getString(KEY_QUIZ_N, '0'))
    const rs = await FieldStore.recordStreak()
    const cs = await FieldStore.checkinStreak()
    const streak = rs > cs ? rs : cs
    const browse = await FieldStore.browseIds()
    const plans = await FieldStore.loadPlans()
    let planDone = false
    for (const p of plans) {
      if (FieldStore.planDoneCount(p, recs) >= p.targetCount && p.targetCount > 0) {
        planDone = true
      }
    }
    const hits: string[] = []
    if (recs.length >= 1) {
      hits.push('first_record')
    }
    if (checkins.length >= 1) {
      hits.push('first_checkin')
    }
    if (recs.length >= 10) {
      hits.push('records_10')
    }
    if (recs.length >= 50) {
      hits.push('records_50')
    }
    if (favN >= 5) {
      hits.push('fav_5')
    }
    if (streak >= 7) {
      hits.push('streak_7')
    }
    if (streak >= 30) {
      hits.push('streak_30')
    }
    if (quizN >= 3) {
      hits.push('quiz_3')
    }
    if (planDone) {
      hits.push('plan_done')
    }
    if (browse.length >= 8) {
      hits.push('browse_8')
    }
    const next: string[] = []
    for (const id of unlocked) {
      next.push(id)
    }
    let changed = false
    for (const id of hits) {
      if (next.indexOf(id) < 0) {
        next.push(id)
        changed = true
        const b = FieldStore.badgeTitle(id)
        await FieldStore.logEvent('badge', `解锁印记：${b}`, id)
      }
    }
    if (changed) {
      await FieldStore.putString(KEY_BADGES, next.join('\n'))
    }
  }

  private static badgeTitle(id: string): string {
    for (const b of GewuBadge.catalog()) {
      if (b.id === id) {
        return b.title
      }
    }
    return id
  }

  private static composeReview(recs: FieldRecord[], checkins: GewuCheckin[], days: number): string {
    const start = DateHelper.addDays(DateHelper.todayKey(), 1 - days)
    const end = DateHelper.todayKey()
    let rn = 0
    let cn = 0
    for (const r of recs) {
      if (DateHelper.inRange(r.dateKey, start, end)) {
        rn++
      }
    }
    for (const c of checkins) {
      if (DateHelper.inRange(c.dateKey, start, end)) {
        cn++
      }
    }
    if (days <= 7) {
      return `本周写下 ${rn} 则观察，物候打卡 ${cn} 天。`
    }
    return `近三十日写下 ${rn} 则观察，物候打卡 ${cn} 天。`
  }

  private static serializePlans(items: GewuPlan[]): string {
    const lines: string[] = []
    for (const p of items) {
      lines.push([p.id, p.title, p.atlasKind, `${p.targetCount}`, p.startKey, p.endKey,
        FieldStore.encode(p.note), `${p.createdAt}`].join('\t'))
    }
    return lines.join('\n')
  }

  private static serializeCheckins(items: GewuCheckin[]): string {
    const lines: string[] = []
    for (const c of items) {
      lines.push([c.dateKey, FieldStore.encode(c.note), c.objectId, `${c.createdAt}`].join('\t'))
    }
    return lines.join('\n')
  }

  private static serializeTopics(items: GewuTopic[]): string {
    const lines: string[] = []
    for (const t of items) {
      lines.push([t.id, t.title, t.objectIds.join(','), `${t.createdAt}`].join('\t'))
    }
    return lines.join('\n')
  }

  private static serializeEvents(items: GewuEvent[]): string {
    const lines: string[] = []
    for (const e of items) {
      lines.push([e.dateKey, e.kind, FieldStore.encode(e.title), e.refId, `${e.at}`].join('\t'))
    }
    return lines.join('\n')
  }

  private static parseCount(raw: string): number {
    if (raw.length === 0) {
      return 0
    }
    const n = parseInt(raw, 10)
    if (n > 0) {
      return n
    }
    if (n === 0) {
      return 0
    }
    return 0
  }

  static async customTags(): Promise<string[]> {
    return FieldStore.splitLines(await FieldStore.getString(KEY_TAGS, ''))
  }

  private static async mergeCustomTags(tags: string[]): Promise<void> {
    const cur = await FieldStore.customTags()
    for (const t of tags) {
      if (t.length > 0 && cur.indexOf(t) < 0) {
        cur.push(t)
      }
    }
    await FieldStore.putString(KEY_TAGS, cur.join('\n'))
  }

  private static serializeRecords(items: FieldRecord[]): string {
    const lines: string[] = []
    for (const r of items) {
      const body = FieldStore.encode(r.body)
      const tags = r.tags.join('|')
      lines.push([r.id, r.subjectId, r.title, r.atlasKind, r.albumKey, r.templateKey,
        body, r.place, r.dateKey, r.coverKey, tags, `${r.createdAt}`].join('\t'))
    }
    return lines.join('\n')
  }

  private static parseRecords(raw: string): FieldRecord[] {
    const out: FieldRecord[] = []
    const lines = FieldStore.splitLines(raw)
    for (const line of lines) {
      const p = line.split('\t')
      if (p.length < 12) {
        continue
      }
      const r = new FieldRecord()
      r.id = FieldStore.cellAt(p, 0)
      r.subjectId = FieldStore.cellAt(p, 1)
      r.title = FieldStore.cellAt(p, 2)
      r.atlasKind = FieldStore.cellAt(p, 3)
      r.albumKey = FieldStore.cellAt(p, 4)
      r.templateKey = FieldStore.cellAt(p, 5)
      r.body = FieldStore.decode(FieldStore.cellAt(p, 6))
      r.place = FieldStore.cellAt(p, 7)
      r.dateKey = FieldStore.cellAt(p, 8)
      r.coverKey = FieldStore.cellAt(p, 9)
      const tagRaw = FieldStore.cellAt(p, 10)
      r.tags = tagRaw.length > 0 ? tagRaw.split('|') : []
      r.createdAt = parseInt(FieldStore.cellAt(p, 11), 10)
      out.push(r)
    }
    return out
  }

  private static cellAt(parts: string[], index: number): string {
    let i = 0
    for (const cell of parts) {
      if (i === index) {
        return cell
      }
      i++
    }
    return ''
  }

  private static encode(text: string): string {
    return text.split('\n').join('\\n').split('\t').join(' ')
  }

  private static decode(text: string): string {
    return text.split('\\n').join('\n')
  }

  private static splitLines(raw: string): string[] {
    const out: string[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length > 0) {
        out.push(line)
      }
    }
    return out
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (FieldStore.pref === null) {
      return fallback
    }
    try {
      const v = await FieldStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (FieldStore.pref === null) {
      return
    }
    try {
      await FieldStore.pref.put(key, value)
      await FieldStore.pref.flush()
    } catch {
    }
  }
}
