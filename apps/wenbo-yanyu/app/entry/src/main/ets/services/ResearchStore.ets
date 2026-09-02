import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  CollectionFolder,
  DailyThink,
  ReadingRecord,
  ResearchNote,
  ResearchPlan,
  ResearchStats,
  ResearchTag,
  ResearchTopic,
  SparkItem,
  TimelineEvent,
  ViewpointCard
} from '../models/ResearchModels'
import { AppRefresh } from './AppRefresh'
import { AppStoreContext } from './AppStoreContext'

const STORE = 'yanyu_research'

export class ResearchStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.Context): Promise<void> {
    AppStoreContext.bind(context)
    if (ResearchStore.pref !== null) {
      return
    }
    ResearchStore.pref = await preferences.getPreferences(context, STORE)
  }

  static async ensureReady(): Promise<boolean> {
    if (ResearchStore.pref !== null) {
      return true
    }
    const ctx = AppStoreContext.get()
    if (ctx === null) {
      return false
    }
    try {
      ResearchStore.pref = await preferences.getPreferences(ctx, STORE)
      return ResearchStore.pref !== null
    } catch {
      return false
    }
  }

  static todayKey(): string {
    const d = new Date()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${ms}-${ds}`
  }

  static timeLabel(at: number): string {
    const d = new Date(at)
    const m = d.getMonth() + 1
    const day = d.getDate()
    const h = d.getHours()
    const min = d.getMinutes()
    const hs = h < 10 ? `0${h}` : `${h}`
    const mins = min < 10 ? `0${min}` : `${min}`
    return `${d.getFullYear()}-${m}-${day} ${hs}:${mins}`
  }

  static presetTags(): ResearchTag[] {
    return [
      ResearchTag.of('learn', '待学习', '1'),
      ResearchTag.of('done', '已整理', '1'),
      ResearchTag.of('focus', '重点关注', '1'),
      ResearchTag.of('spark', '灵感记录', '1')
    ]
  }

  static topicCategories(): string[] {
    return ['历史研究', '读书笔记', '行业观察', '兴趣收藏']
  }

  static coverKeys(): string[] {
    return ['cover_library', 'cover_academic', 'cover_essay', 'cover_daily', 'cover_cafe', 'cover_story']
  }

  static bump(): void {
    AppRefresh.bumpResearch()
  }

  static async listNotes(): Promise<ResearchNote[]> {
    return ResearchStore.parseNotes(await ResearchStore.get('notes'))
  }

  static async findNote(id: string): Promise<ResearchNote | undefined> {
    const list = await ResearchStore.listNotes()
    for (const n of list) {
      if (n.id === id) {
        return n
      }
    }
    return undefined
  }

  static async saveNote(note: ResearchNote): Promise<void> {
    note.updatedAt = Date.now()
    const list = await ResearchStore.listNotes()
    const next: ResearchNote[] = []
    let found = false
    for (const n of list) {
      if (n.id === note.id) {
        next.push(note)
        found = true
      } else {
        next.push(n)
      }
    }
    if (!found) {
      next.unshift(note)
    }
    await ResearchStore.put('notes', ResearchStore.serializeNotes(next))
    ResearchStore.bump()
  }

  static async deleteNote(id: string): Promise<void> {
    const list = await ResearchStore.listNotes()
    const next: ResearchNote[] = []
    for (const n of list) {
      if (n.id !== id) {
        next.push(n)
      }
    }
    await ResearchStore.put('notes', ResearchStore.serializeNotes(next))
    ResearchStore.bump()
  }

  static async searchNotes(query: string, tagKey: string): Promise<ResearchNote[]> {
    const q = query.trim()
    const list = await ResearchStore.listNotes()
    const out: ResearchNote[] = []
    for (const n of list) {
      if (tagKey.length > 0 && n.tagKeys.indexOf(tagKey) < 0) {
        continue
      }
      if (q.length === 0) {
        out.push(n)
        continue
      }
      const blob = `${n.title} ${n.body} ${n.viewpoint}`
      if (blob.indexOf(q) >= 0) {
        out.push(n)
      }
    }
    return out
  }

  static async notesInTopic(topicId: string): Promise<ResearchNote[]> {
    const list = await ResearchStore.listNotes()
    const out: ResearchNote[] = []
    for (const n of list) {
      if (n.topicId === topicId) {
        out.push(n)
      }
    }
    return out
  }

  static async findTopic(id: string): Promise<ResearchTopic | undefined> {
    const list = await ResearchStore.listTopics()
    for (const t of list) {
      if (t.id === id) {
        return t
      }
    }
    return undefined
  }

  static async notesInCollection(collectionId: string): Promise<ResearchNote[]> {
    const list = await ResearchStore.listNotes()
    const out: ResearchNote[] = []
    for (const n of list) {
      if (n.collectionId === collectionId || (collectionId === 'starred' && n.starred === '1')) {
        out.push(n)
      }
    }
    return out
  }

  static hasTag(tagKeys: string, key: string): boolean {
    const parts = tagKeys.split('|')
    for (const p of parts) {
      if (p === key) {
        return true
      }
    }
    return false
  }

  static toggleTag(tagKeys: string, key: string): string {
    if (ResearchStore.hasTag(tagKeys, key)) {
      const next: string[] = []
      const parts = tagKeys.split('|')
      for (const p of parts) {
        if (p.length > 0 && p !== key) {
          next.push(p)
        }
      }
      return next.join('|')
    }
    if (tagKeys.length === 0) {
      return key
    }
    return `${tagKeys}|${key}`
  }

  static async findPlan(id: string): Promise<ResearchPlan | undefined> {
    const list = await ResearchStore.listPlans()
    for (const p of list) {
      if (p.id === id) {
        return p
      }
    }
    return undefined
  }

  static async findReading(id: string): Promise<ReadingRecord | undefined> {
    const list = await ResearchStore.listReadings()
    for (const r of list) {
      if (r.id === id) {
        return r
      }
    }
    return undefined
  }

  static async listTopics(): Promise<ResearchTopic[]> {
    return ResearchStore.parseTopics(await ResearchStore.get('topics'))
  }

  static async saveTopic(topic: ResearchTopic): Promise<void> {
    const list = await ResearchStore.listTopics()
    const next: ResearchTopic[] = []
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
      next.unshift(topic)
    }
    await ResearchStore.put('topics', ResearchStore.serializeTopics(next))
    ResearchStore.bump()
  }

  static async deleteTopic(id: string): Promise<void> {
    const list = await ResearchStore.listTopics()
    const next: ResearchTopic[] = []
    for (const t of list) {
      if (t.id !== id) {
        next.push(t)
      }
    }
    await ResearchStore.put('topics', ResearchStore.serializeTopics(next))
    ResearchStore.bump()
  }

  static async allTags(): Promise<ResearchTag[]> {
    const custom = ResearchStore.parseTags(await ResearchStore.get('tags'))
    const out: ResearchTag[] = ResearchStore.presetTags()
    for (const t of custom) {
      out.push(t)
    }
    return out
  }

  static async addCustomTag(label: string): Promise<void> {
    const name = label.trim()
    if (name.length === 0) {
      return
    }
    const list = ResearchStore.parseTags(await ResearchStore.get('tags'))
    const tag = ResearchTag.of(`u_${Date.now()}`, name, '0')
    list.push(tag)
    await ResearchStore.put('tags', ResearchStore.serializeTags(list))
    ResearchStore.bump()
  }

  static async listSparks(): Promise<SparkItem[]> {
    return ResearchStore.parseSparks(await ResearchStore.get('sparks'))
  }

  static async saveSpark(item: SparkItem): Promise<void> {
    const list = await ResearchStore.listSparks()
    list.unshift(item)
    await ResearchStore.put('sparks', ResearchStore.serializeSparks(list))
    ResearchStore.bump()
  }

  static async deleteSpark(id: string): Promise<void> {
    const list = await ResearchStore.listSparks()
    const next: SparkItem[] = []
    for (const s of list) {
      if (s.id !== id) {
        next.push(s)
      }
    }
    await ResearchStore.put('sparks', ResearchStore.serializeSparks(next))
    ResearchStore.bump()
  }

  static async listCards(): Promise<ViewpointCard[]> {
    return ResearchStore.parseCards(await ResearchStore.get('cards'))
  }

  static async saveCard(card: ViewpointCard): Promise<void> {
    const list = await ResearchStore.listCards()
    list.unshift(card)
    await ResearchStore.put('cards', ResearchStore.serializeCards(list))
    ResearchStore.bump()
  }

  static async deleteCard(id: string): Promise<void> {
    const list = await ResearchStore.listCards()
    const next: ViewpointCard[] = []
    for (const c of list) {
      if (c.id !== id) {
        next.push(c)
      }
    }
    await ResearchStore.put('cards', ResearchStore.serializeCards(next))
    ResearchStore.bump()
  }

  static async listReadings(): Promise<ReadingRecord[]> {
    return ResearchStore.parseReadings(await ResearchStore.get('readings'))
  }

  static async saveReading(row: ReadingRecord): Promise<void> {
    const list = await ResearchStore.listReadings()
    const next: ReadingRecord[] = []
    let found = false
    for (const r of list) {
      if (r.id === row.id) {
        next.push(row)
        found = true
      } else {
        next.push(r)
      }
    }
    if (!found) {
      next.unshift(row)
    }
    await ResearchStore.put('readings', ResearchStore.serializeReadings(next))
    ResearchStore.bump()
  }

  static async deleteReading(id: string): Promise<void> {
    const list = await ResearchStore.listReadings()
    const next: ReadingRecord[] = []
    for (const r of list) {
      if (r.id !== id) {
        next.push(r)
      }
    }
    await ResearchStore.put('readings', ResearchStore.serializeReadings(next))
    ResearchStore.bump()
  }

  static async listPlans(): Promise<ResearchPlan[]> {
    return ResearchStore.parsePlans(await ResearchStore.get('plans'))
  }

  static async savePlan(plan: ResearchPlan): Promise<void> {
    const list = await ResearchStore.listPlans()
    const next: ResearchPlan[] = []
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
      next.unshift(plan)
    }
    await ResearchStore.put('plans', ResearchStore.serializePlans(next))
    ResearchStore.bump()
  }

  static async deletePlan(id: string): Promise<void> {
    const list = await ResearchStore.listPlans()
    const next: ResearchPlan[] = []
    for (const p of list) {
      if (p.id !== id) {
        next.push(p)
      }
    }
    await ResearchStore.put('plans', ResearchStore.serializePlans(next))
    ResearchStore.bump()
  }

  static async listFolders(): Promise<CollectionFolder[]> {
    return ResearchStore.parseFolders(await ResearchStore.get('folders'))
  }

  static async saveFolder(folder: CollectionFolder): Promise<void> {
    const list = await ResearchStore.listFolders()
    list.unshift(folder)
    await ResearchStore.put('folders', ResearchStore.serializeFolders(list))
    ResearchStore.bump()
  }

  static async deleteFolder(id: string): Promise<void> {
    const list = await ResearchStore.listFolders()
    const next: CollectionFolder[] = []
    for (const f of list) {
      if (f.id !== id) {
        next.push(f)
      }
    }
    await ResearchStore.put('folders', ResearchStore.serializeFolders(next))
    ResearchStore.bump()
  }

  static async listDaily(): Promise<DailyThink[]> {
    return ResearchStore.parseDaily(await ResearchStore.get('daily'))
  }

  static async saveDaily(row: DailyThink): Promise<void> {
    const list = await ResearchStore.listDaily()
    const next: DailyThink[] = []
    let found = false
    for (const d of list) {
      if (d.dateKey === row.dateKey) {
        next.push(row)
        found = true
      } else {
        next.push(d)
      }
    }
    if (!found) {
      next.unshift(row)
    }
    await ResearchStore.put('daily', ResearchStore.serializeDaily(next))
    ResearchStore.bump()
  }

  static async listTimeline(): Promise<TimelineEvent[]> {
    const events: TimelineEvent[] = []
    const notes = await ResearchStore.listNotes()
    for (const n of notes) {
      const e = new TimelineEvent()
      e.id = n.id
      e.kind = '笔记'
      e.title = n.title
      e.summary = n.viewpoint.length > 0 ? n.viewpoint : n.body
      e.at = n.updatedAt
      events.push(e)
    }
    const sparks = await ResearchStore.listSparks()
    for (const s of sparks) {
      const e = new TimelineEvent()
      e.id = s.id
      e.kind = '灵感'
      e.title = s.text
      e.summary = s.remark
      e.at = s.createdAt
      events.push(e)
    }
    const readings = await ResearchStore.listReadings()
    for (const r of readings) {
      const e = new TimelineEvent()
      e.id = r.id
      e.kind = '阅读'
      e.title = r.title
      e.summary = r.thought
      e.at = r.createdAt
      events.push(e)
    }
    const daily = await ResearchStore.listDaily()
    for (const d of daily) {
      const e = new TimelineEvent()
      e.id = d.dateKey
      e.kind = '每日思考'
      e.title = d.dateKey
      e.summary = d.viewpoint
      e.at = d.createdAt
      events.push(e)
    }
    events.sort((a: TimelineEvent, b: TimelineEvent): number => b.at - a.at)
    return events
  }

  static async stats(): Promise<ResearchStats> {
    const s = new ResearchStats()
    const notes = await ResearchStore.listNotes()
    s.noteCount = notes.length
    s.topicCount = (await ResearchStore.listTopics()).length
    s.sparkCount = (await ResearchStore.listSparks()).length
    s.cardCount = (await ResearchStore.listCards()).length
    s.readingCount = (await ResearchStore.listReadings()).length
    s.planCount = (await ResearchStore.listPlans()).length
    const weekAgo = Date.now() - 7 * 86400000
    for (const n of notes) {
      const ts = n.updatedAt > 0 ? n.updatedAt : n.createdAt
      if (ts >= weekAgo) {
        s.weekNotes += 1
      }
    }
    const daily = await ResearchStore.listDaily()
    s.streak = ResearchStore.calcStreak(daily)
    return s
  }

  static async starredNoteCount(): Promise<number> {
    const notes = await ResearchStore.listNotes()
    let count = 0
    for (const n of notes) {
      if (n.starred === '1') {
        count += 1
      }
    }
    return count
  }

  private static calcStreak(daily: DailyThink[]): number {
    const set: string[] = []
    for (const d of daily) {
      set.push(d.dateKey)
    }
    let streak = 0
    const cursor = new Date()
    while (streak < 366) {
      const m = cursor.getMonth() + 1
      const day = cursor.getDate()
      const ms = m < 10 ? `0${m}` : `${m}`
      const ds = day < 10 ? `0${day}` : `${day}`
      const key = `${cursor.getFullYear()}-${ms}-${ds}`
      let hit = false
      for (const k of set) {
        if (k === key) {
          hit = true
        }
      }
      if (!hit) {
        break
      }
      streak += 1
      cursor.setDate(cursor.getDate() - 1)
    }
    return streak
  }

  private static esc(s: string): string {
    return s.replace(/\t/g, ' ').replace(/\n/g, '\\n')
  }

  private static unesc(s: string): string {
    return s.replace(/\\n/g, '\n')
  }

  private static cell(parts: string[], index: number): string {
    let i = 0
    for (const p of parts) {
      if (i === index) {
        return p
      }
      i += 1
    }
    return ''
  }

  private static serializeNotes(items: ResearchNote[]): string {
    const lines: string[] = []
    for (const n of items) {
      lines.push([
        n.id, ResearchStore.esc(n.title), ResearchStore.esc(n.body), ResearchStore.esc(n.viewpoint),
        n.topicId, n.tagKeys, n.coverKey, n.photoPath, n.collectionId, n.starred,
        `${n.createdAt}`, `${n.updatedAt}`
      ].join('\t'))
    }
    return lines.join('\n')
  }

  private static parseNotes(raw: string): ResearchNote[] {
    const out: ResearchNote[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      const n = new ResearchNote()
      n.id = ResearchStore.cell(parts, 0)
      n.title = ResearchStore.unesc(ResearchStore.cell(parts, 1))
      n.body = ResearchStore.unesc(ResearchStore.cell(parts, 2))
      n.viewpoint = ResearchStore.unesc(ResearchStore.cell(parts, 3))
      n.topicId = ResearchStore.cell(parts, 4)
      n.tagKeys = ResearchStore.cell(parts, 5)
      n.coverKey = ResearchStore.cell(parts, 6)
      n.photoPath = ResearchStore.cell(parts, 7)
      n.collectionId = ResearchStore.cell(parts, 8)
      n.starred = ResearchStore.cell(parts, 9)
      n.createdAt = parseInt(ResearchStore.cell(parts, 10), 10)
      n.updatedAt = parseInt(ResearchStore.cell(parts, 11), 10)
      if (n.id.length > 0) {
        out.push(n)
      }
    }
    return out
  }

  private static serializeTopics(items: ResearchTopic[]): string {
    const lines: string[] = []
    for (const t of items) {
      lines.push([t.id, ResearchStore.esc(t.title), ResearchStore.esc(t.summary), t.category, t.coverKey, `${t.createdAt}`].join('\t'))
    }
    return lines.join('\n')
  }

  private static parseTopics(raw: string): ResearchTopic[] {
    const out: ResearchTopic[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      const t = new ResearchTopic()
      t.id = ResearchStore.cell(parts, 0)
      t.title = ResearchStore.unesc(ResearchStore.cell(parts, 1))
      t.summary = ResearchStore.unesc(ResearchStore.cell(parts, 2))
      t.category = ResearchStore.cell(parts, 3)
      t.coverKey = ResearchStore.cell(parts, 4)
      t.createdAt = parseInt(ResearchStore.cell(parts, 5), 10)
      if (t.id.length > 0) {
        out.push(t)
      }
    }
    return out
  }

  private static serializeTags(items: ResearchTag[]): string {
    const lines: string[] = []
    for (const t of items) {
      lines.push(`${t.key}\t${ResearchStore.esc(t.label)}\t${t.builtin}`)
    }
    return lines.join('\n')
  }

  private static parseTags(raw: string): ResearchTag[] {
    const out: ResearchTag[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      out.push(ResearchTag.of(ResearchStore.cell(parts, 0), ResearchStore.unesc(ResearchStore.cell(parts, 1)), ResearchStore.cell(parts, 2)))
    }
    return out
  }

  private static serializeSparks(items: SparkItem[]): string {
    const lines: string[] = []
    for (const s of items) {
      lines.push(`${s.id}\t${ResearchStore.esc(s.text)}\t${ResearchStore.esc(s.remark)}\t${s.createdAt}`)
    }
    return lines.join('\n')
  }

  private static parseSparks(raw: string): SparkItem[] {
    const out: SparkItem[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      const s = new SparkItem()
      s.id = ResearchStore.cell(parts, 0)
      s.text = ResearchStore.unesc(ResearchStore.cell(parts, 1))
      s.remark = ResearchStore.unesc(ResearchStore.cell(parts, 2))
      s.createdAt = parseInt(ResearchStore.cell(parts, 3), 10)
      out.push(s)
    }
    return out
  }

  private static serializeCards(items: ViewpointCard[]): string {
    const lines: string[] = []
    for (const c of items) {
      lines.push(`${c.id}\t${ResearchStore.esc(c.quote)}\t${c.sourceId}\t${c.createdAt}`)
    }
    return lines.join('\n')
  }

  private static parseCards(raw: string): ViewpointCard[] {
    const out: ViewpointCard[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      const c = new ViewpointCard()
      c.id = ResearchStore.cell(parts, 0)
      c.quote = ResearchStore.unesc(ResearchStore.cell(parts, 1))
      c.sourceId = ResearchStore.cell(parts, 2)
      c.createdAt = parseInt(ResearchStore.cell(parts, 3), 10)
      out.push(c)
    }
    return out
  }

  private static serializeReadings(items: ReadingRecord[]): string {
    const lines: string[] = []
    for (const r of items) {
      lines.push(`${r.id}\t${ResearchStore.esc(r.title)}\t${ResearchStore.esc(r.progress)}\t${ResearchStore.esc(r.thought)}\t${r.createdAt}`)
    }
    return lines.join('\n')
  }

  private static parseReadings(raw: string): ReadingRecord[] {
    const out: ReadingRecord[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      const r = new ReadingRecord()
      r.id = ResearchStore.cell(parts, 0)
      r.title = ResearchStore.unesc(ResearchStore.cell(parts, 1))
      r.progress = ResearchStore.unesc(ResearchStore.cell(parts, 2))
      r.thought = ResearchStore.unesc(ResearchStore.cell(parts, 3))
      r.createdAt = parseInt(ResearchStore.cell(parts, 4), 10)
      out.push(r)
    }
    return out
  }

  private static serializePlans(items: ResearchPlan[]): string {
    const lines: string[] = []
    for (const p of items) {
      lines.push([
        p.id, ResearchStore.esc(p.title), ResearchStore.esc(p.goal),
        ResearchStore.esc(p.stageA), ResearchStore.esc(p.stageB), ResearchStore.esc(p.stageC),
        p.doneA, p.doneB, p.doneC, `${p.createdAt}`
      ].join('\t'))
    }
    return lines.join('\n')
  }

  private static parsePlans(raw: string): ResearchPlan[] {
    const out: ResearchPlan[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      const p = new ResearchPlan()
      p.id = ResearchStore.cell(parts, 0)
      p.title = ResearchStore.unesc(ResearchStore.cell(parts, 1))
      p.goal = ResearchStore.unesc(ResearchStore.cell(parts, 2))
      p.stageA = ResearchStore.unesc(ResearchStore.cell(parts, 3))
      p.stageB = ResearchStore.unesc(ResearchStore.cell(parts, 4))
      p.stageC = ResearchStore.unesc(ResearchStore.cell(parts, 5))
      p.doneA = ResearchStore.cell(parts, 6)
      p.doneB = ResearchStore.cell(parts, 7)
      p.doneC = ResearchStore.cell(parts, 8)
      p.createdAt = parseInt(ResearchStore.cell(parts, 9), 10)
      out.push(p)
    }
    return out
  }

  private static serializeFolders(items: CollectionFolder[]): string {
    const lines: string[] = []
    for (const f of items) {
      lines.push(`${f.id}\t${ResearchStore.esc(f.title)}\t${f.createdAt}`)
    }
    return lines.join('\n')
  }

  private static parseFolders(raw: string): CollectionFolder[] {
    const out: CollectionFolder[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      const f = new CollectionFolder()
      f.id = ResearchStore.cell(parts, 0)
      f.title = ResearchStore.unesc(ResearchStore.cell(parts, 1))
      f.createdAt = parseInt(ResearchStore.cell(parts, 2), 10)
      out.push(f)
    }
    return out
  }

  private static serializeDaily(items: DailyThink[]): string {
    const lines: string[] = []
    for (const d of items) {
      lines.push(`${d.dateKey}\t${ResearchStore.esc(d.viewpoint)}\t${d.createdAt}`)
    }
    return lines.join('\n')
  }

  private static parseDaily(raw: string): DailyThink[] {
    const out: DailyThink[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      const d = new DailyThink()
      d.dateKey = ResearchStore.cell(parts, 0)
      d.viewpoint = ResearchStore.unesc(ResearchStore.cell(parts, 1))
      d.createdAt = parseInt(ResearchStore.cell(parts, 2), 10)
      out.push(d)
    }
    return out
  }

  private static async get(key: string): Promise<string> {
    const ready = await ResearchStore.ensureReady()
    if (!ready || ResearchStore.pref === null) {
      return ''
    }
    try {
      const v = await ResearchStore.pref.get(key, '')
      if (typeof v === 'string') {
        return v
      }
    } catch {
      return ''
    }
    return ''
  }

  private static async put(key: string, value: string): Promise<void> {
    const ready = await ResearchStore.ensureReady()
    if (!ready || ResearchStore.pref === null) {
      return
    }
    await ResearchStore.pref.put(key, value)
    await ResearchStore.pref.flush()
  }
}
