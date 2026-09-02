import { HttpClient } from './HttpClient'
import { MathCatalog } from './MathCatalog'
import { MathEngine } from './MathEngine'
import { MathLocalStore } from './MathLocalStore'
import { MathQuizLaunch } from './MathQuizLaunch'
import { MathRefresh } from './MathRefresh'
import {
  CatalogItem,
  CatalogListData,
  CustomSet,
  DayCheckIn,
  DayMark,
  DayMission,
  GrowthSnapshot,
  LocalBundle,
  MathQuestion,
  MathSettings,
  MedalView,
  PracticeSession,
  StudyPack,
  TimeEvent,
  WeakHint,
  WeekBar,
  WrongItem
} from '../models/MathModels'

const BASE = '/biz/kids-math'

export class MathBizService {
  static async loadModes(): Promise<CatalogItem[]> {
    const res = await HttpClient.get<CatalogListData>(`${BASE}/modes`)
    if (res.code === 0 && res.data !== undefined && res.data.list.length > 0) {
      return res.data.list
    }
    return MathCatalog.modes()
  }

  static async loadChallenges(): Promise<CatalogItem[]> {
    const res = await HttpClient.get<CatalogListData>(`${BASE}/challenges`)
    if (res.code === 0 && res.data !== undefined && res.data.list.length > 0) {
      return res.data.list
    }
    return MathCatalog.challenges()
  }

  static async loadMedals(): Promise<CatalogItem[]> {
    const res = await HttpClient.get<CatalogListData>(`${BASE}/medals`)
    if (res.code === 0 && res.data !== undefined && res.data.list.length > 0) {
      return res.data.list
    }
    return MathCatalog.medals()
  }

  static async loadTips(): Promise<CatalogItem[]> {
    const res = await HttpClient.get<CatalogListData>(`${BASE}/tips`)
    if (res.code === 0 && res.data !== undefined && res.data.list.length > 0) {
      return res.data.list
    }
    return MathCatalog.tips()
  }

  static findMode(id: string, list: CatalogItem[]): CatalogItem {
    for (const item of list) {
      if (item.id === id || item.operator === id) {
        return item
      }
    }
    const modes = MathCatalog.modes()
    for (const item of modes) {
      if (item.id === id || item.operator === id) {
        return item
      }
    }
    return new CatalogItem()
  }

  static findCatalog(id: string, list: CatalogItem[]): CatalogItem {
    for (const item of list) {
      if (item.id === id) {
        return item
      }
    }
    return new CatalogItem()
  }

  static todaySession(): PracticeSession | undefined {
    const today = MathLocalStore.today()
    const sessions = MathLocalStore.snapshot().sessions
    for (const s of sessions) {
      if (s.date === today && s.kind === 'daily') {
        return s
      }
    }
    return undefined
  }

  static todayStars(): number {
    const today = MathLocalStore.today()
    let n = 0
    for (const s of MathLocalStore.snapshot().sessions) {
      if (s.date === today) {
        n += (s.stars > 0 ? s.stars : 0)
      }
    }
    return n
  }

  static todayMissions(): DayMission[] {
    const today = MathLocalStore.today()
    let warm = false
    let daily = false
    let extra = false
    for (const s of MathLocalStore.snapshot().sessions) {
      if (s.date !== today) {
        continue
      }
      if (s.kind === 'warm') {
        warm = true
      }
      if (s.kind === 'daily') {
        daily = true
      }
      if (s.kind === 'table' || s.kind === 'challenge' || s.kind === 'story' || s.kind === 'game') {
        extra = true
      }
    }
    const m1 = new DayMission()
    m1.id = 'warm'
    m1.title = '热身 5 题'
    m1.hint = warm ? '已完成' : '先活动一下手指'
    m1.done = warm
    const m2 = new DayMission()
    m2.id = 'daily'
    m2.title = '今日挑战'
    m2.hint = daily ? '已完成' : '按设置题量练一组'
    m2.done = daily
    const m3 = new DayMission()
    m3.id = 'table'
    m3.title = '口诀或闯关'
    m3.hint = extra ? '已完成' : '打开口诀表或打一关'
    m3.done = extra
    const out: DayMission[] = []
    out.push(m1)
    out.push(m2)
    out.push(m3)
    return out
  }

  static tagOfOp(op: string): string {
    if (op === 'story') {
      return '应用题'
    }
    if (op === 'table_mul' || op === 'table_div' || op === 'mul' || op === 'div') {
      return '口诀'
    }
    if (op === 'add' || op === 'sub' || op === 'add2' || op === 'sub2' || op === 'make10') {
      return '口算'
    }
    return '数感'
  }

  static weekAnswered(): number {
    const bars = MathBizService.weekBars()
    let n = 0
    for (const b of bars) {
      n += b.value
    }
    return n
  }

  static goalTarget(): number {
    const g = MathLocalStore.settings().weekGoal
    return g > 0 ? g : 50
  }

  static goalPct(): number {
    const t = MathBizService.goalTarget()
    if (t <= 0) {
      return 0
    }
    const n = MathBizService.weekAnswered()
    const p = Math.floor((n / t) * 100)
    return p > 100 ? 100 : p
  }

  static lastSessions(limit: number): PracticeSession[] {
    const out: PracticeSession[] = []
    for (const s of MathLocalStore.snapshot().sessions) {
      if (out.length < limit) {
        out.push(s)
      }
    }
    return out
  }

  static sessionTitle(kind: string): string {
    return MathQuizLaunch.title(kind)
  }

  static todayCheckIn(): DayCheckIn | undefined {
    const today = MathLocalStore.today()
    for (const c of MathLocalStore.snapshot().checkins) {
      if (c.date === today) {
        return c
      }
    }
    return undefined
  }

  static ensureTodayCheckIn(list: DayCheckIn[], source: string, note: string): DayCheckIn[] {
    const today = MathLocalStore.today()
    const out: DayCheckIn[] = []
    let found = false
    for (const c of list) {
      if (c.date === today) {
        found = true
        if (note.length > 0) {
          const n = new DayCheckIn()
          n.id = c.id
          n.date = c.date
          n.note = note
          n.source = source
          out.push(n)
        } else {
          out.push(c)
        }
      } else {
        out.push(c)
      }
    }
    if (!found) {
      const c = new DayCheckIn()
      c.id = MathLocalStore.newId('ck')
      c.date = today
      c.note = note
      c.source = source
      out.push(c)
    }
    return out
  }

  static async saveCheckIn(note: string): Promise<void> {
    const bundle = MathLocalStore.snapshot()
    const next = MathBizService.cloneBundle(bundle)
    next.checkins = MathBizService.ensureTodayCheckIn(bundle.checkins, 'manual', note)
    next.medals = MathBizService.evalMedals(next)
    await MathLocalStore.saveBundle(next)
    MathRefresh.bump()
  }

  static async setWeekGoal(n: number): Promise<void> {
    const s = MathLocalStore.settings()
    const next = new MathSettings()
    next.dailyCount = s.dailyCount
    next.difficulty = s.difficulty
    next.sound = s.sound
    next.motion = s.motion
    next.grade = s.grade
    next.planStart = s.planStart
    next.planPreset = s.planPreset
    next.weekGoal = n
    await MathBizService.saveSettings(next)
  }

  static async saveCustomSet(set: CustomSet): Promise<void> {
    const bundle = MathLocalStore.snapshot()
    const next = MathBizService.cloneBundle(bundle)
    const kept: CustomSet[] = []
    let replaced = false
    for (const old of bundle.customSets) {
      if (old.id === set.id) {
        kept.push(set)
        replaced = true
      } else {
        kept.push(old)
      }
    }
    if (!replaced) {
      kept.push(set)
    }
    next.customSets = kept
    next.medals = MathBizService.evalMedals(next)
    await MathLocalStore.saveBundle(next)
    MathRefresh.bump()
  }

  static async removeCustomSet(id: string): Promise<void> {
    const bundle = MathLocalStore.snapshot()
    const next = MathBizService.cloneBundle(bundle)
    const kept: CustomSet[] = []
    for (const s of bundle.customSets) {
      if (s.id !== id) {
        kept.push(s)
      }
    }
    next.customSets = kept
    await MathLocalStore.saveBundle(next)
    MathRefresh.bump()
  }

  static async savePack(pack: StudyPack): Promise<void> {
    const bundle = MathLocalStore.snapshot()
    const next = MathBizService.cloneBundle(bundle)
    const kept: StudyPack[] = []
    let replaced = false
    for (const old of bundle.packs) {
      if (old.id === pack.id) {
        kept.push(pack)
        replaced = true
      } else {
        kept.push(old)
      }
    }
    if (!replaced) {
      kept.push(pack)
    }
    next.packs = kept
    await MathLocalStore.saveBundle(next)
    MathRefresh.bump()
  }

  static async removePack(id: string): Promise<void> {
    const bundle = MathLocalStore.snapshot()
    const next = MathBizService.cloneBundle(bundle)
    const kept: StudyPack[] = []
    for (const p of bundle.packs) {
      if (p.id !== id) {
        kept.push(p)
      }
    }
    next.packs = kept
    await MathLocalStore.saveBundle(next)
    MathRefresh.bump()
  }

  static packOps(pack: StudyPack): string[] {
    const out: string[] = []
    const parts = pack.modes.split(',')
    for (const p of parts) {
      const t = p.trim()
      if (t.length > 0) {
        out.push(t)
      }
    }
    return out
  }

  static async pushRecent(modeId: string): Promise<void> {
    if (modeId.length === 0) {
      return
    }
    const bundle = MathLocalStore.snapshot()
    const next = MathBizService.cloneBundle(bundle)
    const ids: string[] = []
    ids.push(modeId)
    const parts = bundle.recentModes.split(',')
    for (const p of parts) {
      const t = p.trim()
      if (t.length > 0 && t !== modeId && ids.length < 8) {
        ids.push(t)
      }
    }
    let joined = ''
    for (const id of ids) {
      joined = joined.length > 0 ? `${joined},${id}` : id
    }
    next.recentModes = joined
    await MathLocalStore.saveBundle(next)
  }

  static async saveWrongNote(id: string, note: string): Promise<void> {
    const bundle = MathLocalStore.snapshot()
    const next = MathBizService.cloneBundle(bundle)
    const wrongs: WrongItem[] = []
    for (const w of bundle.wrongs) {
      if (w.id === id) {
        const n = new WrongItem()
        n.id = w.id
        n.expression = w.expression
        n.userAnswer = w.userAnswer
        n.correctAnswer = w.correctAnswer
        n.lastAt = w.lastAt
        n.left = w.left
        n.right = w.right
        n.op = w.op
        n.qType = w.qType
        n.story = w.story
        n.answerLabel = w.answerLabel
        n.choiceA = w.choiceA
        n.choiceB = w.choiceB
        n.choiceC = w.choiceC
        n.tag = w.tag
        n.note = note
        wrongs.push(n)
      } else {
        wrongs.push(w)
      }
    }
    next.wrongs = wrongs
    await MathLocalStore.saveBundle(next)
    MathRefresh.bump()
  }

  static timeline(): TimeEvent[] {
    const out: TimeEvent[] = []
    for (const s of MathLocalStore.snapshot().sessions) {
      const e = new TimeEvent()
      e.id = s.id
      e.date = s.date
      e.kind = 'session'
      e.title = MathQuizLaunch.title(s.kind)
      e.hint = `${s.correct} / ${s.total} 正确 · ${s.stars} 星`
      out.push(e)
    }
    for (const c of MathLocalStore.snapshot().checkins) {
      const e = new TimeEvent()
      e.id = c.id
      e.date = c.date
      e.kind = 'checkin'
      e.title = '学习打卡'
      e.hint = c.note.length > 0 ? c.note : '今天练过了'
      out.push(e)
    }
    for (const s of MathLocalStore.snapshot().customSets) {
      const e = new TimeEvent()
      e.id = s.id
      e.date = s.createdAt
      e.kind = 'custom'
      e.title = `家长出题 · ${s.title}`
      e.hint = `${s.items.length} 题`
      out.push(e)
    }
    return MathBizService.sortEvents(out)
  }

  private static sortEvents(list: TimeEvent[]): TimeEvent[] {
    const n = list.length
    for (let i = 0; i < n; i++) {
      for (let j = i + 1; j < n; j++) {
        const a = list[i]
        const b = list[j]
        if (b.date > a.date || (b.date === a.date && b.id > a.id)) {
          list[i] = b
          list[j] = a
        }
      }
    }
    const capped: TimeEvent[] = []
    for (const e of list) {
      if (capped.length < 40) {
        capped.push(e)
      }
    }
    return capped
  }

  static periodReport(period: string): string {
    const g = MathBizService.growth()
    const grade = MathBizService.gradeLabel(MathLocalStore.settings().grade)
    let days = 0
    let questions = 0
    const today = MathLocalStore.today()
    if (period === 'today') {
      for (const s of MathLocalStore.snapshot().sessions) {
        if (s.date === today) {
          days = 1
          questions += s.total
        }
      }
      let line = '童趣算坊 · 今日回顾\n'
      line = `${line}路径：${grade}\n`
      line = `${line}今天练了 ${questions} 题\n`
      line = `${line}累计星星 ${g.stars}\n`
      line = `${line}说明：陪伴记录，不排名，不承诺成绩。`
      return line
    }
    if (period === 'month') {
      const marks = MathBizService.monthMarks()
      for (const m of marks) {
        if (m.done) {
          days += 1
        }
      }
      for (const s of MathLocalStore.snapshot().sessions) {
        if (s.date.length >= 7 && today.length >= 7 && s.date.substring(0, 7) === today.substring(0, 7)) {
          questions += s.total
        }
      }
      let line = '童趣算坊 · 本月回顾\n'
      line = `${line}路径：${grade}\n`
      line = `${line}本月练了 ${days} 天，共 ${questions} 题\n`
      line = `${line}累计星星 ${g.stars}，平均正确率 ${g.sessions > 0 ? g.accuracy : 0}%\n`
      line = `${line}说明：陪伴记录，不排名，不承诺成绩。`
      return line
    }
    return MathBizService.weekReport()
  }

  static todayAccuracy(): number {
    const today = MathLocalStore.today()
    let total = 0
    let correct = 0
    for (const s of MathLocalStore.snapshot().sessions) {
      if (s.date === today) {
        total += s.total
        correct += s.correct
      }
    }
    if (total <= 0) {
      return 0
    }
    return Math.round((correct / total) * 100)
  }

  static growth(): GrowthSnapshot {
    const b = MathLocalStore.snapshot()
    const g = new GrowthSnapshot()
    g.stars = b.stars
    g.sessions = b.sessions.length
    g.answered = b.answered
    g.correct = b.correct
    g.streak = b.streak
    g.lastDate = b.lastDate
    g.medals = b.medals
    if (b.answered > 0) {
      g.accuracy = Math.round((b.correct / b.answered) * 100)
    }
    return g
  }

  static weekBars(): WeekBar[] {
    const labels: string[] = ['一', '二', '三', '四', '五', '六', '日']
    const counts: number[] = [0, 0, 0, 0, 0, 0, 0]
    const now = new Date()
    const start = new Date(now.getFullYear(), now.getMonth(), now.getDate())
    const weekday = start.getDay() === 0 ? 6 : start.getDay() - 1
    start.setDate(start.getDate() - weekday)
    for (const s of MathLocalStore.snapshot().sessions) {
      const parts = s.date.split('-')
      if (parts.length !== 3) {
        continue
      }
      const d = new Date(Number.parseInt(parts[0]), Number.parseInt(parts[1]) - 1, Number.parseInt(parts[2]))
      const diff = Math.floor((d.getTime() - start.getTime()) / 86400000)
      if (diff >= 0 && diff < 7) {
        counts[diff] += s.total
      }
    }
    const bars: WeekBar[] = []
    for (let i = 0; i < 7; i++) {
      const bar = new WeekBar()
      bar.label = labels[i]
      bar.value = counts[i]
      bars.push(bar)
    }
    return bars
  }

  static monthMarks(): DayMark[] {
    const practiced: string[] = []
    for (const s of MathLocalStore.snapshot().sessions) {
      let seen = false
      for (const p of practiced) {
        if (p === s.date) {
          seen = true
        }
      }
      if (!seen) {
        practiced.push(s.date)
      }
    }
    const marks: DayMark[] = []
    for (let i = -27; i <= 0; i++) {
      const date = MathLocalStore.formatDay(i)
      const m = new DayMark()
      m.date = date
      m.label = date.substring(8)
      m.done = MathBizService.hasDate(practiced, date)
      marks.push(m)
    }
    return marks
  }

  static weakHint(): WeakHint {
    const hint = new WeakHint()
    let add = 0
    let sub = 0
    let mul = 0
    let other = 0
    let otherOp = 'story'
    for (const w of MathLocalStore.snapshot().wrongs) {
      if (w.op === 'add' || w.op === 'add2' || w.op === 'make10' || w.op === 'chain') {
        add += 1
      } else if (w.op === 'sub' || w.op === 'sub2' || w.op === 'blank') {
        sub += 1
      } else if (w.op === 'mul' || w.op === 'table_mul' || w.op === 'div' || w.op === 'table_div') {
        mul += 1
      } else {
        other += 1
        otherOp = w.op.length > 0 ? w.op : 'story'
      }
    }
    hint.mode = 'add'
    hint.count = add
    hint.title = '加法'
    if (sub > hint.count) {
      hint.mode = 'sub'
      hint.count = sub
      hint.title = '减法'
    }
    if (mul > hint.count) {
      hint.mode = 'mul'
      hint.count = mul
      hint.title = '乘除'
    }
    if (other > hint.count) {
      hint.mode = otherOp
      hint.count = other
      hint.title = MathCatalog.modeTitle(otherOp)
    }
    return hint
  }

  static weekReport(): string {
    const g = MathBizService.growth()
    const bars = MathBizService.weekBars()
    let days = 0
    let questions = 0
    for (const b of bars) {
      if (b.value > 0) {
        days += 1
      }
      questions += b.value
    }
    const weak = MathBizService.weakHint()
    const grade = MathBizService.gradeLabel(MathLocalStore.settings().grade)
    let line = '童趣算坊 · 本周练习\n'
    line = `${line}年级路径：${grade}\n`
    line = `${line}本周练了 ${days} 天，共 ${questions} 题\n`
    line = `${line}累计星星 ${g.stars}，平均正确率 ${g.sessions > 0 ? g.accuracy : 0}%\n`
    if (weak.count > 0) {
      line = `${line}可以再练一练：${weak.title}\n`
    } else {
      line = `${line}最近没有待复习的错题。\n`
    }
    line = `${line}说明：这是陪伴记录，不排名，也不承诺提高考试成绩。`
    return line
  }

  static gradeLabel(grade: string): string {
    if (grade === 'age35') {
      return '幼儿启蒙 3-5 岁'
    }
    if (grade === 'age912' || grade === 'g3') {
      return '思维提升 9-12 岁'
    }
    if (grade === 'g2') {
      return '基础计算 6-8 岁'
    }
    return '基础计算 6-8 岁'
  }

  static planPresetLabel(p: string): string {
    if (p === 'addsub') {
      return '加减为主'
    }
    if (p === 'story') {
      return '应用题为主'
    }
    if (p === 'sense') {
      return '数感为主'
    }
    return '均衡练习'
  }

  static planPresetMode(p: string): string {
    if (p === 'addsub') {
      return 'add'
    }
    if (p === 'story') {
      return 'story'
    }
    if (p === 'sense') {
      return 'sense'
    }
    return MathEngine.gradeMode(MathLocalStore.settings().grade)
  }

  static challengeLocked(id: string): boolean {
    const need = MathCatalog.towerNeed(id)
    if (id !== 'km_ch_cog' && id !== 'km_ch_add' && id !== 'km_ch_mul' && id !== 'km_ch_life') {
      return false
    }
    return MathLocalStore.snapshot().challengeClear < need
  }

  static planIndex(): number {
    const start = MathLocalStore.settings().planStart
    if (start.length === 0) {
      return -1
    }
    const d = MathLocalStore.daysBetween(start, MathLocalStore.today())
    if (d < 0) {
      return 0
    }
    if (d > 6) {
      return 7
    }
    return d
  }

  static planDoneDays(): number {
    const start = MathLocalStore.settings().planStart
    if (start.length === 0) {
      return 0
    }
    const end = MathLocalStore.datePlus(start, 6)
    const dates: string[] = []
    for (const s of MathLocalStore.snapshot().sessions) {
      if (s.date >= start && s.date <= end) {
        if (!MathBizService.hasDate(dates, s.date)) {
          dates.push(s.date)
        }
      }
    }
    return dates.length
  }

  static async startPlan(): Promise<void> {
    const settings = MathLocalStore.settings()
    if (settings.planStart.length > 0 && MathBizService.planIndex() < 7) {
      return
    }
    const next = new MathSettings()
    next.dailyCount = settings.dailyCount
    next.difficulty = settings.difficulty
    next.sound = settings.sound
    next.motion = settings.motion
    next.grade = settings.grade
    next.planStart = MathLocalStore.today()
    next.planPreset = settings.planPreset
    next.weekGoal = settings.weekGoal > 0 ? settings.weekGoal : 50
    await MathBizService.saveSettings(next)
  }

  private static hasDate(list: string[], date: string): boolean {
    for (const x of list) {
      if (x === date) {
        return true
      }
    }
    return false
  }

  static medalViews(defs: CatalogItem[]): MedalView[] {
    const unlocked = MathLocalStore.snapshot().medals
    const out: MedalView[] = []
    for (const d of defs) {
      const v = new MedalView()
      v.id = d.id
      v.title = d.title
      v.summary = d.summary
      v.body = d.body
      v.coverKey = d.coverKey
      v.unlocked = MathBizService.hasMedal(unlocked, d.id)
      out.push(v)
    }
    return out
  }

  static async recordSession(
    kind: string,
    mode: string,
    questions: MathQuestion[],
    correct: number,
    durationMs: number,
    misses: WrongItem[],
    challengeId: string = ''
  ): Promise<PracticeSession> {
    const bundle = MathLocalStore.snapshot()
    const session = new PracticeSession()
    session.id = MathLocalStore.newId('sess')
    session.kind = kind
    session.mode = mode
    session.total = questions.length
    session.correct = correct
    session.stars = MathEngine.stars(correct, questions.length)
    session.durationMs = durationMs
    session.date = MathLocalStore.today()

    const next = new LocalBundle()
    next.sessions = [session]
    for (const old of bundle.sessions) {
      next.sessions.push(old)
    }
    next.wrongs = MathBizService.mergeWrongs(bundle.wrongs, misses, questions, correct)
    next.favorites = bundle.favorites
    next.stars = bundle.stars + session.stars
    next.answered = bundle.answered + session.total
    next.correct = bundle.correct + session.correct
    next.settings = bundle.settings
    next.lastDate = session.date
    next.challengeClear = bundle.challengeClear
    next.checkins = bundle.checkins
    next.customSets = bundle.customSets
    next.packs = bundle.packs
    next.recentModes = bundle.recentModes
    if (bundle.lastDate === session.date) {
      next.streak = bundle.streak > 0 ? bundle.streak : 1
    } else if (bundle.lastDate === MathLocalStore.yesterday(session.date)) {
      next.streak = bundle.streak + 1
    } else {
      next.streak = 1
    }
    const gain = MathCatalog.towerGain(challengeId)
    if (gain > next.challengeClear) {
      next.challengeClear = gain
    }
    next.checkins = MathBizService.ensureTodayCheckIn(next.checkins, 'auto', '')
    next.medals = MathBizService.evalMedals(next)
    await MathLocalStore.saveBundle(next)
    MathRefresh.bump()
    return session
  }

  static async saveSettings(settings: MathSettings): Promise<void> {
    const bundle = MathLocalStore.snapshot()
    const next = MathBizService.cloneBundle(bundle)
    next.settings = settings
    await MathLocalStore.saveBundle(next)
    MathRefresh.bump()
  }

  static async clearAll(): Promise<void> {
    await MathLocalStore.saveBundle(new LocalBundle())
    MathRefresh.bump()
  }

  static async removeWrong(id: string): Promise<void> {
    const bundle = MathLocalStore.snapshot()
    const next = MathBizService.cloneBundle(bundle)
    const kept: WrongItem[] = []
    for (const w of bundle.wrongs) {
      if (w.id !== id) {
        kept.push(w)
      }
    }
    next.wrongs = kept
    await MathLocalStore.saveBundle(next)
    MathRefresh.bump()
  }

  static async toggleFavorite(item: WrongItem): Promise<boolean> {
    const bundle = MathLocalStore.snapshot()
    const next = MathBizService.cloneBundle(bundle)
    const kept: WrongItem[] = []
    let removed = false
    for (const f of bundle.favorites) {
      if (f.expression === item.expression) {
        removed = true
      } else {
        kept.push(f)
      }
    }
    if (!removed) {
      const copy = new WrongItem()
      copy.id = MathLocalStore.newId('fav')
      copy.expression = item.expression
      copy.userAnswer = item.userAnswer
      copy.correctAnswer = item.correctAnswer
      copy.lastAt = MathLocalStore.today()
      copy.left = item.left
      copy.right = item.right
      copy.op = item.op
      copy.qType = item.qType
      copy.story = item.story
      copy.answerLabel = item.answerLabel
      copy.choiceA = item.choiceA
      copy.choiceB = item.choiceB
      copy.choiceC = item.choiceC
      copy.tag = item.tag.length > 0 ? item.tag : MathBizService.tagOfOp(item.op)
      copy.note = item.note
      kept.push(copy)
    }
    next.favorites = kept
    await MathLocalStore.saveBundle(next)
    MathRefresh.bump()
    return !removed
  }

  static isFavorite(expression: string): boolean {
    for (const f of MathLocalStore.snapshot().favorites) {
      if (f.expression === expression) {
        return true
      }
    }
    return false
  }

  private static cloneBundle(bundle: LocalBundle): LocalBundle {
    const next = new LocalBundle()
    next.sessions = bundle.sessions
    next.wrongs = bundle.wrongs
    next.favorites = bundle.favorites
    next.stars = bundle.stars
    next.streak = bundle.streak
    next.lastDate = bundle.lastDate
    next.answered = bundle.answered
    next.correct = bundle.correct
    next.medals = bundle.medals
    next.challengeClear = bundle.challengeClear
    next.settings = bundle.settings
    next.checkins = bundle.checkins
    next.customSets = bundle.customSets
    next.packs = bundle.packs
    next.recentModes = bundle.recentModes
    return next
  }

  private static mergeWrongs(
    existing: WrongItem[],
    misses: WrongItem[],
    questions: MathQuestion[],
    correct: number
  ): WrongItem[] {
    const out: WrongItem[] = []
    for (const m of misses) {
      out.push(m)
    }
    const solved: string[] = []
    if (correct === questions.length) {
      for (const q of questions) {
        solved.push(q.expression)
      }
    }
    for (const w of existing) {
      let drop = false
      for (const exp of solved) {
        if (w.expression === exp) {
          drop = true
        }
      }
      if (!drop) {
        let dup = false
        for (const m of out) {
          if (m.expression === w.expression) {
            dup = true
          }
        }
        if (!dup) {
          out.push(w)
        }
      }
    }
    return out
  }

  private static evalMedals(bundle: LocalBundle): string[] {
    const ids: string[] = []
    for (const id of bundle.medals) {
      ids.push(id)
    }
    MathBizService.addMedal(ids, 'km_medal_first', bundle.sessions.length >= 1)
    MathBizService.addMedal(ids, 'km_medal_streak7', bundle.streak >= 7)
    MathBizService.addMedal(ids, 'km_medal_fifty', bundle.answered >= 50)
    MathBizService.addMedal(ids, 'km_medal_hundred', bundle.answered >= 100)
    const acc = bundle.answered > 0 ? (bundle.correct / bundle.answered) * 100 : 0
    MathBizService.addMedal(ids, 'km_medal_ace', bundle.answered >= 30 && acc >= 90)
    MathBizService.addMedal(ids, 'km_medal_perfect', MathBizService.hasPerfectSession(bundle.sessions))
    MathBizService.addMedal(ids, 'km_medal_story', MathBizService.hasKind(bundle.sessions, 'story'))
    MathBizService.addMedal(ids, 'km_medal_plan', MathBizService.planDoneDays() >= 5)
    MathBizService.addMedal(ids, 'km_medal_tower', bundle.challengeClear >= 1)
    MathBizService.addMedal(ids, 'km_medal_custom', bundle.customSets.length >= 1)
    MathBizService.addMedal(ids, 'km_medal_fav10', bundle.favorites.length >= 10)
    MathBizService.addMedal(ids, 'km_medal_checkin7', bundle.checkins.length >= 7)
    MathBizService.addMedal(ids, 'km_medal_streak30', bundle.streak >= 30)
    return ids
  }

  private static hasKind(sessions: PracticeSession[], kind: string): boolean {
    for (const s of sessions) {
      if (s.kind === kind || s.mode === kind) {
        return true
      }
    }
    return false
  }

  private static hasPerfectSession(sessions: PracticeSession[]): boolean {
    for (const s of sessions) {
      if (s.total > 0 && s.correct === s.total) {
        return true
      }
    }
    return false
  }

  private static addMedal(ids: string[], id: string, ok: boolean): void {
    if (!ok) {
      return
    }
    for (const x of ids) {
      if (x === id) {
        return
      }
    }
    ids.push(id)
  }

  private static hasMedal(ids: string[], id: string): boolean {
    for (const x of ids) {
      if (x === id) {
        return true
      }
    }
    return false
  }
}
