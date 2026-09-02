import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { QuizRecord, QuizStats } from '../models/FanGrowthModels'

const STORE = 'star_quiz_records'
const MAX_RECORDS = 20

export class QuizRecordService {
  private static pref: preferences.Preferences | null = null
  private static records: QuizRecord[] = []
  private static stats: QuizStats = new QuizStats()

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      QuizRecordService.pref = await preferences.getPreferences(context, STORE)
      const raw = await QuizRecordService.pref.get('records', '[]')
      const text: string = typeof raw === 'string' ? raw : '[]'
      QuizRecordService.records = QuizRecordService.parseRecords(text)
      const statsRaw = await QuizRecordService.pref.get('stats', '')
      const statsText: string = typeof statsRaw === 'string' ? statsRaw : ''
      QuizRecordService.stats = QuizRecordService.parseStats(statsText)
    } catch {
      QuizRecordService.records = []
      QuizRecordService.stats = new QuizStats()
    }
  }

  static list(): QuizRecord[] {
    const out: QuizRecord[] = []
    for (const r of QuizRecordService.records) {
      out.push(r)
    }
    return out
  }

  static statsSnapshot(): QuizStats {
    const s = new QuizStats()
    s.bestScore = QuizRecordService.stats.bestScore
    s.bestTotal = QuizRecordService.stats.bestTotal
    s.totalAttempts = QuizRecordService.stats.totalAttempts
    s.totalCorrect = QuizRecordService.stats.totalCorrect
    s.totalQuestions = QuizRecordService.stats.totalQuestions
    return s
  }

  static async saveRound(score: number, total: number, wrongIds: string[]): Promise<void> {
    const row = new QuizRecord()
    row.id = `qr_${Date.now()}`
    row.score = score
    row.total = total
    row.at = Date.now()
    for (const id of wrongIds) {
      row.wrongIds.push(id)
    }
    const next: QuizRecord[] = []
    next.push(row)
    for (const r of QuizRecordService.records) {
      next.push(r)
      if (next.length >= MAX_RECORDS) {
        break
      }
    }
    QuizRecordService.records = next
    QuizRecordService.stats.totalAttempts += 1
    QuizRecordService.stats.totalCorrect += score
    QuizRecordService.stats.totalQuestions += total
    if (score > QuizRecordService.stats.bestScore ||
      (score === QuizRecordService.stats.bestScore && total > QuizRecordService.stats.bestTotal)) {
      QuizRecordService.stats.bestScore = score
      QuizRecordService.stats.bestTotal = total
    }
    await QuizRecordService.persist()
  }

  private static async persist(): Promise<void> {
    const payload: QuizRecordWire[] = []
    for (const r of QuizRecordService.records) {
      const w = new QuizRecordWire()
      w.id = r.id
      w.score = r.score
      w.total = r.total
      w.wrongIds = r.wrongIds.join(',')
      w.at = r.at
      payload.push(w)
    }
    const sw = new QuizStatsWire()
    sw.bestScore = QuizRecordService.stats.bestScore
    sw.bestTotal = QuizRecordService.stats.bestTotal
    sw.totalAttempts = QuizRecordService.stats.totalAttempts
    sw.totalCorrect = QuizRecordService.stats.totalCorrect
    sw.totalQuestions = QuizRecordService.stats.totalQuestions
    try {
      if (QuizRecordService.pref !== null) {
        await QuizRecordService.pref.put('records', JSON.stringify(payload))
        await QuizRecordService.pref.put('stats', JSON.stringify(sw))
        await QuizRecordService.pref.flush()
      }
    } catch {
    }
    const tick = AppStorage.get<number>('growthTick') ?? 0
    AppStorage.setOrCreate('growthTick', tick + 1)
  }

  private static parseRecords(raw: string): QuizRecord[] {
    try {
      const parsed = JSON.parse(raw) as QuizRecordWire[]
      const out: QuizRecord[] = []
      for (const w of parsed) {
        const r = new QuizRecord()
        r.id = w.id
        r.score = w.score
        r.total = w.total
        r.at = w.at
        if (w.wrongIds.length > 0) {
          const parts = w.wrongIds.split(',')
          for (const p of parts) {
            if (p.length > 0) {
              r.wrongIds.push(p)
            }
          }
        }
        out.push(r)
      }
      return out
    } catch {
      return []
    }
  }

  private static parseStats(raw: string): QuizStats {
    const s = new QuizStats()
    if (raw.length === 0) {
      return s
    }
    try {
      const w = JSON.parse(raw) as QuizStatsWire
      s.bestScore = w.bestScore ?? 0
      s.bestTotal = w.bestTotal ?? 0
      s.totalAttempts = w.totalAttempts ?? 0
      s.totalCorrect = w.totalCorrect ?? 0
      s.totalQuestions = w.totalQuestions ?? 0
      return s
    } catch {
      return s
    }
  }
}

class QuizRecordWire {
  id: string = ''
  score: number = 0
  total: number = 0
  wrongIds: string = ''
  at: number = 0
}

class QuizStatsWire {
  bestScore: number = 0
  bestTotal: number = 0
  totalAttempts: number = 0
  totalCorrect: number = 0
  totalQuestions: number = 0
}
