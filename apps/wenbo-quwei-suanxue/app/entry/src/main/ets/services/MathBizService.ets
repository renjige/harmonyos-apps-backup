import { HttpClient } from './HttpClient'
import { MathCatalog } from './MathCatalog'
import { MathEngine } from './MathEngine'
import { MathLocalStore } from './MathLocalStore'
import {
  CatalogItem,
  CatalogListData,
  GrowthSnapshot,
  LocalBundle,
  MathQuestion,
  MathSettings,
  MedalView,
  PracticeSession,
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
        n += s.stars
      }
    }
    return n
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
    misses: WrongItem[]
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
    next.stars = bundle.stars + session.stars
    next.answered = bundle.answered + session.total
    next.correct = bundle.correct + session.correct
    next.settings = bundle.settings
    next.lastDate = session.date
    if (bundle.lastDate === session.date) {
      next.streak = bundle.streak > 0 ? bundle.streak : 1
    } else if (bundle.lastDate === MathLocalStore.yesterday(session.date)) {
      next.streak = bundle.streak + 1
    } else {
      next.streak = 1
    }
    next.medals = MathBizService.evalMedals(next)
    await MathLocalStore.saveBundle(next)
    return session
  }

  static async saveSettings(settings: MathSettings): Promise<void> {
    const bundle = MathLocalStore.snapshot()
    const next = MathBizService.cloneBundle(bundle)
    next.settings = settings
    await MathLocalStore.saveBundle(next)
  }

  static async clearAll(): Promise<void> {
    await MathLocalStore.saveBundle(new LocalBundle())
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
  }

  private static cloneBundle(bundle: LocalBundle): LocalBundle {
    const next = new LocalBundle()
    next.sessions = bundle.sessions
    next.wrongs = bundle.wrongs
    next.stars = bundle.stars
    next.streak = bundle.streak
    next.lastDate = bundle.lastDate
    next.answered = bundle.answered
    next.correct = bundle.correct
    next.medals = bundle.medals
    next.settings = bundle.settings
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
    MathBizService.addMedal(ids, 'km_medal_hundred', bundle.answered >= 100)
    const acc = bundle.answered > 0 ? (bundle.correct / bundle.answered) * 100 : 0
    MathBizService.addMedal(ids, 'km_medal_ace', bundle.answered >= 30 && acc >= 90)
    return ids
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
