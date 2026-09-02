import { HttpClient } from './HttpClient'
import { KingdomLocalStore } from './KingdomLocalStore'
import {
  CatalogItem,
  CatalogListData,
  GrowthSnapshot,
  LevelProgress,
  LocalBundle,
  MsgItem,
  MsgListData,
  PracticeSession,
  QuizQuestion,
  RelicView,
  WeekMark
} from '../models/KingdomModels'

const BASE = '/biz/kids-kingdom'

export class KingdomBizService {
  static async loadLevels(): Promise<CatalogItem[]> {
    const res = await HttpClient.get<CatalogListData>(`${BASE}/levels`)
    if (res.code === 0 && res.data !== undefined) {
      return KingdomBizService.sortByOrder(KingdomBizService.mapList(res.data.list))
    }
    return []
  }

  static async loadQuestions(): Promise<CatalogItem[]> {
    const res = await HttpClient.get<CatalogListData>(`${BASE}/questions`)
    if (res.code === 0 && res.data !== undefined) {
      return KingdomBizService.mapList(res.data.list)
    }
    return []
  }

  static async loadDailies(): Promise<CatalogItem[]> {
    const res = await HttpClient.get<CatalogListData>(`${BASE}/dailies`)
    if (res.code === 0 && res.data !== undefined) {
      return KingdomBizService.mapList(res.data.list)
    }
    return []
  }

  static async loadRelics(): Promise<CatalogItem[]> {
    const res = await HttpClient.get<CatalogListData>(`${BASE}/relics`)
    if (res.code === 0 && res.data !== undefined) {
      return KingdomBizService.mapList(res.data.list)
    }
    return []
  }

  static async loadGuides(): Promise<CatalogItem[]> {
    const res = await HttpClient.get<CatalogListData>(`${BASE}/guides`)
    if (res.code === 0 && res.data !== undefined) {
      return KingdomBizService.mapList(res.data.list)
    }
    return []
  }

  static async loadMessages(): Promise<MsgItem[]> {
    const res = await HttpClient.get<MsgListData>('/messages')
    if (res.code === 0 && res.data !== undefined) {
      const out: MsgItem[] = []
      for (const row of res.data.list) {
        const m = new MsgItem()
        m.id = row.id
        m.title = row.title
        m.body = row.body
        out.push(m)
      }
      return out
    }
    return []
  }

  static mapList(raw: CatalogItem[]): CatalogItem[] {
    const out: CatalogItem[] = []
    if (raw === undefined) {
      return out
    }
    for (const row of raw) {
      out.push(KingdomBizService.mapOne(row))
    }
    return out
  }

  static mapOne(raw: CatalogItem): CatalogItem {
    const item = new CatalogItem()
    item.id = KingdomBizService.asText(raw.id)
    item.title = KingdomBizService.asText(raw.title)
    item.subtitle = KingdomBizService.asText(raw.subtitle)
    item.summary = KingdomBizService.asText(raw.summary)
    item.body = KingdomBizService.asText(raw.body)
    const desc = KingdomBizService.asText(raw.description)
    if (item.body.length === 0) {
      item.body = desc
    }
    item.coverKey = KingdomBizService.asText(raw.coverKey)
    item.kind = KingdomBizService.asText(raw.kind)
    item.skill = KingdomBizService.asText(raw.skill)
    item.difficulty = raw.difficulty
    item.questionCount = raw.questionCount
    item.sortOrder = raw.sortOrder
    item.prompt = KingdomBizService.asText(raw.prompt)
    item.optionA = KingdomBizService.asText(raw.optionA)
    item.optionB = KingdomBizService.asText(raw.optionB)
    item.optionC = KingdomBizService.asText(raw.optionC)
    item.optionD = KingdomBizService.asText(raw.optionD)
    item.answerIndex = raw.answerIndex
    item.sequence = KingdomBizService.asText(raw.sequence)
    item.visualA = KingdomBizService.asText(raw.visualA)
    item.visualB = KingdomBizService.asText(raw.visualB)
    item.visualC = KingdomBizService.asText(raw.visualC)
    item.visualD = KingdomBizService.asText(raw.visualD)
    item.hint = KingdomBizService.asText(raw.hint)
    item.explanation = KingdomBizService.asText(raw.explanation)
    item.rule = KingdomBizService.asText(raw.rule)
    item.levelId = KingdomBizService.asText(raw.levelId)
    item.description = desc
    return item
  }

  static asText(value: string): string {
    if (value === undefined) {
      return ''
    }
    return value
  }

  static sortByOrder(list: CatalogItem[]): CatalogItem[] {
    const out: CatalogItem[] = []
    for (const item of list) {
      out.push(item)
    }
    for (let i = 0; i < out.length; i++) {
      for (let j = i + 1; j < out.length; j++) {
        if (out[j].sortOrder < out[i].sortOrder) {
          const tmp = out[i]
          out[i] = out[j]
          out[j] = tmp
        }
      }
    }
    return out
  }

  static findById(id: string, list: CatalogItem[]): CatalogItem {
    for (const item of list) {
      if (item.id === id) {
        return item
      }
    }
    return new CatalogItem()
  }

  static questionsForLevel(levelId: string, all: CatalogItem[]): QuizQuestion[] {
    const out: QuizQuestion[] = []
    for (const item of all) {
      if (item.levelId === levelId) {
        out.push(KingdomBizService.toQuestion(item))
      }
    }
    return out
  }

  static toQuestion(item: CatalogItem): QuizQuestion {
    const q = new QuizQuestion()
    q.id = item.id
    q.levelId = item.levelId
    q.kind = item.kind
    q.skill = item.skill
    q.prompt = item.prompt.length > 0 ? item.prompt : item.title
    q.optionA = item.optionA
    q.optionB = item.optionB
    q.optionC = item.optionC
    q.optionD = item.optionD
    q.answerIndex = item.answerIndex
    q.sequence = item.sequence
    q.visualA = item.visualA
    q.visualB = item.visualB
    q.visualC = item.visualC
    q.visualD = item.visualD
    q.hint = item.hint
    q.explanation = item.explanation
    q.coverKey = item.coverKey
    return q
  }

  static todayDaily(list: CatalogItem[]): CatalogItem {
    if (list.length === 0) {
      return new CatalogItem()
    }
    const idx = KingdomLocalStore.dayIndex() % list.length
    if (idx >= 0 && idx < list.length) {
      return list[idx]
    }
    return list[0]
  }

  static isDailyDone(): boolean {
    return KingdomLocalStore.snapshot().lastDailyDate === KingdomLocalStore.today()
  }

  static isUnlocked(level: CatalogItem, all: CatalogItem[]): boolean {
    if (level.sortOrder <= 1) {
      return true
    }
    for (const item of all) {
      if (item.sortOrder === level.sortOrder - 1) {
        return KingdomBizService.levelDone(item.id)
      }
    }
    return false
  }

  static levelDone(levelId: string): boolean {
    for (const row of KingdomLocalStore.snapshot().levels) {
      if (row.levelId === levelId && row.completed) {
        return true
      }
    }
    return false
  }

  static levelStars(levelId: string): number {
    for (const row of KingdomLocalStore.snapshot().levels) {
      if (row.levelId === levelId) {
        return row.stars
      }
    }
    return 0
  }

  static nextPlayable(all: CatalogItem[]): CatalogItem {
    for (const item of all) {
      if (KingdomBizService.isUnlocked(item, all) && !KingdomBizService.levelDone(item.id)) {
        return item
      }
    }
    if (all.length > 0) {
      return all[all.length - 1]
    }
    return new CatalogItem()
  }

  static starsOf(correct: number, total: number): number {
    if (total <= 0) {
      return 0
    }
    if (correct >= total) {
      return 3
    }
    if (correct * 100 >= total * 80) {
      return 2
    }
    return 1
  }

  static async recordLevel(levelId: string, kind: string, skill: string, correct: number, total: number): Promise<number> {
    const stars = KingdomBizService.starsOf(correct, total)
    const today = KingdomLocalStore.today()
    const bundle = KingdomBizService.cloneBundle()
    const sess = new PracticeSession()
    sess.id = KingdomLocalStore.newId('sess')
    sess.kind = 'level'
    sess.levelId = levelId
    sess.total = total
    sess.correct = correct
    sess.stars = stars
    sess.date = today
    bundle.sessions.push(sess)
    bundle.stars += stars
    bundle.answered += total
    bundle.correct += correct
    KingdomBizService.addSkill(bundle, skill, correct)
    KingdomBizService.touchStreak(bundle, today)
    let found = false
    const nextLevels: LevelProgress[] = []
    for (const row of bundle.levels) {
      if (row.levelId === levelId) {
        found = true
        const n = new LevelProgress()
        n.levelId = levelId
        n.kind = kind
        n.stars = row.stars > stars ? row.stars : stars
        n.correct = correct
        n.total = total
        n.completed = true
        n.completedAt = today
        nextLevels.push(n)
      } else {
        nextLevels.push(row)
      }
    }
    if (!found) {
      const n = new LevelProgress()
      n.levelId = levelId
      n.kind = kind
      n.stars = stars
      n.correct = correct
      n.total = total
      n.completed = true
      n.completedAt = today
      nextLevels.push(n)
    }
    bundle.levels = nextLevels
    await KingdomLocalStore.saveBundle(bundle)
    return stars
  }

  static async recordDaily(item: CatalogItem, ok: boolean): Promise<number> {
    if (KingdomBizService.isDailyDone()) {
      return 0
    }
    const stars = ok ? 2 : 1
    const today = KingdomLocalStore.today()
    const bundle = KingdomBizService.cloneBundle()
    const sess = new PracticeSession()
    sess.id = KingdomLocalStore.newId('daily')
    sess.kind = 'daily'
    sess.levelId = item.id
    sess.total = 1
    sess.correct = ok ? 1 : 0
    sess.stars = stars
    sess.date = today
    bundle.sessions.push(sess)
    bundle.stars += stars
    bundle.answered += 1
    bundle.correct += ok ? 1 : 0
    if (bundle.lastDailyDate !== today) {
      bundle.dailiesDone += 1
      bundle.lastDailyDate = today
    }
    KingdomBizService.addSkill(bundle, item.skill.length > 0 ? item.skill : 'observe', ok ? 1 : 0)
    KingdomBizService.touchStreak(bundle, today)
    await KingdomLocalStore.saveBundle(bundle)
    return stars
  }

  static growth(): GrowthSnapshot {
    const b = KingdomLocalStore.snapshot()
    const g = new GrowthSnapshot()
    g.stars = b.stars
    g.dailies = b.dailiesDone
    g.streak = b.streak
    g.lastDate = b.lastDate
    g.observe = b.observe
    g.logic = b.logic
    g.memory = b.memory
    g.create = b.create
    g.answered = b.answered
    let done = 0
    for (const row of b.levels) {
      if (row.completed) {
        done += 1
      }
    }
    g.levelsDone = done
    return g
  }

  static weekMarks(): WeekMark[] {
    const labels: string[] = ['一', '二', '三', '四', '五', '六', '日']
    const flags: boolean[] = [false, false, false, false, false, false, false]
    const now = new Date()
    const start = new Date(now.getFullYear(), now.getMonth(), now.getDate())
    const weekday = start.getDay() === 0 ? 6 : start.getDay() - 1
    start.setDate(start.getDate() - weekday)
    for (const s of KingdomLocalStore.snapshot().sessions) {
      const parts = s.date.split('-')
      if (parts.length !== 3) {
        continue
      }
      const d = new Date(Number.parseInt(parts[0]), Number.parseInt(parts[1]) - 1, Number.parseInt(parts[2]))
      const diff = Math.floor((d.getTime() - start.getTime()) / 86400000)
      if (diff >= 0 && diff < 7) {
        flags[diff] = true
      }
    }
    const out: WeekMark[] = []
    for (let i = 0; i < 7; i++) {
      const m = new WeekMark()
      m.label = labels[i]
      m.done = flags[i]
      out.push(m)
    }
    return out
  }

  static relicViews(defs: CatalogItem[]): RelicView[] {
    const out: RelicView[] = []
    for (const item of defs) {
      const v = new RelicView()
      v.id = item.id
      v.title = item.title
      v.summary = item.summary
      v.body = item.body
      v.coverKey = item.coverKey
      v.rule = item.rule
      v.unlocked = KingdomBizService.ruleMet(item.rule)
      out.push(v)
    }
    return out
  }

  static ruleMet(rule: string): boolean {
    const g = KingdomBizService.growth()
    if (rule.startsWith('levels>=')) {
      return g.levelsDone >= Number.parseInt(rule.substring(8))
    }
    if (rule.startsWith('dailies>=')) {
      return g.dailies >= Number.parseInt(rule.substring(9))
    }
    if (rule.startsWith('stars>=')) {
      return g.stars >= Number.parseInt(rule.substring(7))
    }
    if (rule.startsWith('streak>=')) {
      return g.streak >= Number.parseInt(rule.substring(8))
    }
    if (rule === 'kinds>=4') {
      return KingdomBizService.kindCount() >= 4
    }
    if (rule.startsWith('level:')) {
      return KingdomBizService.levelDone(rule.substring(6))
    }
    return false
  }

  static kindCount(): number {
    const seen: string[] = []
    for (const row of KingdomLocalStore.snapshot().levels) {
      if (!row.completed) {
        continue
      }
      let has = false
      for (const k of seen) {
        if (k === row.kind) {
          has = true
        }
      }
      if (!has && row.kind.length > 0) {
        seen.push(row.kind)
      }
    }
    return seen.length
  }

  static optionLabel(q: QuizQuestion, index: number): string {
    if (index === 0) {
      return q.optionA
    }
    if (index === 1) {
      return q.optionB
    }
    if (index === 2) {
      return q.optionC
    }
    return q.optionD
  }

  static optionVisual(q: QuizQuestion, index: number): string {
    if (index === 0) {
      return q.visualA
    }
    if (index === 1) {
      return q.visualB
    }
    if (index === 2) {
      return q.visualC
    }
    return q.visualD
  }

  static visualColor(key: string): string {
    if (key === 'red') {
      return '#E11D48'
    }
    if (key === 'gold') {
      return '#F5C842'
    }
    if (key === 'blue') {
      return '#3B5BDB'
    }
    if (key === 'green') {
      return '#6BCB77'
    }
    if (key === 'purple') {
      return '#7C3AED'
    }
    if (key === 'orange') {
      return '#F97316'
    }
    if (key === 'mint') {
      return '#5EEAD4'
    }
    if (key === 'forest') {
      return '#166534'
    }
    if (key === 'ice') {
      return '#BAE6FD'
    }
    if (key === 'navy') {
      return '#1A1A2E'
    }
    return '#5B6ABF'
  }

  private static cloneBundle(): LocalBundle {
    const src = KingdomLocalStore.snapshot()
    const out = new LocalBundle()
    out.sessions = src.sessions
    out.levels = src.levels
    out.stars = src.stars
    out.streak = src.streak
    out.lastDate = src.lastDate
    out.dailiesDone = src.dailiesDone
    out.lastDailyDate = src.lastDailyDate
    out.relics = src.relics
    out.observe = src.observe
    out.logic = src.logic
    out.memory = src.memory
    out.create = src.create
    out.answered = src.answered
    out.correct = src.correct
    out.settings.sound = src.settings.sound
    out.settings.fontScale = src.settings.fontScale
    return out
  }

  private static addSkill(bundle: LocalBundle, skill: string, n: number): void {
    if (skill === 'observe') {
      bundle.observe += n
    } else if (skill === 'memory') {
      bundle.memory += n
    } else if (skill === 'create') {
      bundle.create += n
    } else {
      bundle.logic += n
    }
  }

  private static touchStreak(bundle: LocalBundle, today: string): void {
    if (bundle.lastDate === today) {
      return
    }
    if (bundle.lastDate === KingdomLocalStore.yesterday(today)) {
      bundle.streak += 1
    } else {
      bundle.streak = 1
    }
    bundle.lastDate = today
  }
}
