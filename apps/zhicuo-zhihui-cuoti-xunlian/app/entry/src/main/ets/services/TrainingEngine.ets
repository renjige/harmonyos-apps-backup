import { WrongEntry } from '../models/WrongModels'

export class TrainingSession {
  mode: string = 'random'
  subjectCode: string = 'all'
  knowledgeTag: string = ''
  queue: WrongEntry[] = []
  index: number = 0
  doneToday: number = 0
}

export class TrainingEngine {
  static dailyGoal: number = 5

  static filterPending(items: WrongEntry[]): WrongEntry[] {
    const out: WrongEntry[] = []
    for (const e of items) {
      if (e.status !== 'mastered') {
        out.push(e)
      }
    }
    return out
  }

  static buildQueue(items: WrongEntry[], mode: string, subjectCode: string, tag: string): WrongEntry[] {
    let pool = TrainingEngine.filterPending(items)
    if (mode === 'special') {
      const filtered: WrongEntry[] = []
      for (const e of pool) {
        if (subjectCode !== 'all' && e.subjectCode !== subjectCode) {
          continue
        }
        if (tag.length > 0 && e.knowledgeTag.indexOf(tag) < 0) {
          continue
        }
        filtered.push(e)
      }
      pool = filtered
    }
    return TrainingEngine.shuffle(pool)
  }

  static shuffle(items: WrongEntry[]): WrongEntry[] {
    const arr: WrongEntry[] = []
    for (const e of items) {
      arr.push(e)
    }
    for (let i = arr.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1))
      const tmp = arr[i]
      arr[i] = arr[j]
      arr[j] = tmp
    }
    return arr
  }

  static current(session: TrainingSession): WrongEntry | null {
    if (session.queue.length === 0 || session.index >= session.queue.length) {
      return null
    }
    return session.queue[session.index]
  }

  static progressPercent(session: TrainingSession): number {
    if (session.queue.length === 0) {
      return 0
    }
    return Math.floor((session.index / session.queue.length) * 100)
  }

  static todayKey(): string {
    const d = new Date()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const mm = m < 10 ? `0${m}` : `${m}`
    const dd = day < 10 ? `0${day}` : `${day}`
    return `train_${d.getFullYear()}-${mm}-${dd}`
  }

  static readTodayDone(): number {
    const raw = AppStorage.get<number>(TrainingEngine.todayKey())
    if (raw === undefined) {
      return 0
    }
    return raw
  }

  static bumpTodayDone(): void {
    const n = TrainingEngine.readTodayDone() + 1
    AppStorage.setOrCreate(TrainingEngine.todayKey(), n)
  }

  static todayProgressPercent(): number {
    const done = TrainingEngine.readTodayDone()
    const goal = TrainingEngine.dailyGoal
    if (goal <= 0) {
      return 0
    }
    const pct = Math.floor((done / goal) * 100)
    return pct > 100 ? 100 : pct
  }
}
