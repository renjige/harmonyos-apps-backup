import { ReadingPlan } from '../models/UserKnowledgeModels'
import { LocalPrefs } from './LocalPrefs'
import { CheckInStore } from './CheckInStore'
import { TimelineService } from './TimelineService'

const KEY_PREFIX = 'daily_tasks_'

export class DailyTaskState {
  dateKey: string = ''
  readDone: boolean = false
  reviewDone: boolean = false
  recordDone: boolean = false

  finishedCount(): number {
    let n = 0
    if (this.readDone) {
      n++
    }
    if (this.reviewDone) {
      n++
    }
    if (this.recordDone) {
      n++
    }
    return n
  }
}

export class DailyTaskStore {
  /** 读取并同步今日真实行为（阅读/复习/记录），避免任务 UI 与计数不一致。 */
  static async loadTodaySynced(): Promise<DailyTaskState> {
    const s = await DailyTaskStore.readPersisted()
    let changed = false
    const todayRead = await CheckInStore.getTodayReadCount()
    if (todayRead > 0 && !s.readDone) {
      s.readDone = true
      changed = true
    }
    const events = await TimelineService.listAll()
    const todayKey = s.dateKey
    for (const e of events) {
      if (!DailyTaskStore.isSameDay(e.timestamp, todayKey)) {
        continue
      }
      if (e.type === 'read' && !s.readDone) {
        s.readDone = true
        changed = true
      }
      if (e.type === 'review_done' && !s.reviewDone) {
        s.reviewDone = true
        changed = true
      }
      if ((e.type === 'knowledge_create' || e.type === 'spark_create') && !s.recordDone) {
        s.recordDone = true
        changed = true
      }
    }
    if (changed) {
      await DailyTaskStore.persist(s)
    }
    return s
  }

  static async today(): Promise<DailyTaskState> {
    return DailyTaskStore.loadTodaySynced()
  }

  static async markRead(): Promise<void> {
    const s = await DailyTaskStore.readPersisted()
    s.readDone = true
    await DailyTaskStore.persist(s)
  }

  static async markReview(): Promise<void> {
    const s = await DailyTaskStore.readPersisted()
    s.reviewDone = true
    await DailyTaskStore.persist(s)
  }

  static async markRecord(): Promise<void> {
    const s = await DailyTaskStore.readPersisted()
    s.recordDone = true
    await DailyTaskStore.persist(s)
  }

  private static async readPersisted(): Promise<DailyTaskState> {
    const dateKey = ReadingPlan.dateKey(new Date())
    const raw = await LocalPrefs.getString(`${KEY_PREFIX}${dateKey}`, '')
    const s = new DailyTaskState()
    s.dateKey = dateKey
    if (raw.length === 0) {
      return s
    }
    const parts = raw.split('|')
    s.readDone = parts.length > 0 && parts[0] === '1'
    s.reviewDone = parts.length > 1 && parts[1] === '1'
    s.recordDone = parts.length > 2 && parts[2] === '1'
    return s
  }

  private static isSameDay(iso: string, dateKey: string): boolean {
    if (iso.length < 8) {
      return false
    }
    try {
      const d = new Date(iso)
      return ReadingPlan.dateKey(d) === dateKey
    } catch {
      return false
    }
  }

  private static async persist(s: DailyTaskState): Promise<void> {
    const raw = `${s.readDone ? '1' : '0'}|${s.reviewDone ? '1' : '0'}|${s.recordDone ? '1' : '0'}`
    await LocalPrefs.putString(`${KEY_PREFIX}${s.dateKey}`, raw)
  }
}
