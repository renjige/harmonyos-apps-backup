import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'

const STORE_NAME = 'career_progress'
const KEY_MAP = 'courseProgress'

export class CourseProgressEntry {
  courseId: string = ''
  percent: number = 0
  lastAt: string = ''
}

/**
 * 学习进度 — 本地 Preferences（按课程 id 记录 0–100%）。
 */
export class LearnProgressService {
  private static pref: preferences.Preferences | null = null
  private static map: Map<string, CourseProgressEntry> = new Map()
  private static ready: boolean = false

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      LearnProgressService.pref = await preferences.getPreferences(context, STORE_NAME)
      const raw = await LearnProgressService.pref.get(KEY_MAP, '{}')
      const text: string = typeof raw === 'string' ? raw : '{}'
      LearnProgressService.map = LearnProgressService.parseMap(text)
      LearnProgressService.ready = true
      AppStorage.setOrCreate('progressTick', 0)
    } catch {
      LearnProgressService.map = new Map()
      LearnProgressService.ready = true
    }
  }

  static isReady(): boolean {
    return LearnProgressService.ready
  }

  static getPercent(courseId: string): number {
    const row = LearnProgressService.map.get(courseId)
    if (row === undefined) {
      return 0
    }
    return row.percent
  }

  static listStarted(): CourseProgressEntry[] {
    const out: CourseProgressEntry[] = []
    LearnProgressService.map.forEach((v: CourseProgressEntry) => {
      if (v.percent > 0) {
        out.push(v)
      }
    })
    return out
  }

  static startedCount(): number {
    let n = 0
    LearnProgressService.map.forEach((v: CourseProgressEntry) => {
      if (v.percent > 0) {
        n = n + 1
      }
    })
    return n
  }

  static completedCount(): number {
    let n = 0
    LearnProgressService.map.forEach((v: CourseProgressEntry) => {
      if (v.percent >= 100) {
        n = n + 1
      }
    })
    return n
  }

  static async setPercent(courseId: string, percent: number): Promise<void> {
    if (courseId.length === 0) {
      return
    }
    let p = percent
    if (p < 0) {
      p = 0
    }
    if (p > 100) {
      p = 100
    }
    const row = new CourseProgressEntry()
    row.courseId = courseId
    row.percent = p
    row.lastAt = LearnProgressService.nowLabel()
    LearnProgressService.map.set(courseId, row)
    await LearnProgressService.persist()
  }

  static async bump(courseId: string, delta: number): Promise<void> {
    const cur = LearnProgressService.getPercent(courseId)
    await LearnProgressService.setPercent(courseId, cur + delta)
  }

  private static nowLabel(): string {
    const d = new Date()
    const y = d.getFullYear()
    const mo = d.getMonth() + 1
    const day = d.getDate()
    const moStr = mo < 10 ? `0${mo}` : `${mo}`
    const dayStr = day < 10 ? `0${day}` : `${day}`
    return `${y}-${moStr}-${dayStr}`
  }

  private static async persist(): Promise<void> {
    const obj = new ProgressWireRoot()
    LearnProgressService.map.forEach((v: CourseProgressEntry, k: string) => {
      obj.entries.push(LearnProgressService.toWire(k, v))
    })
    const json = JSON.stringify(obj.entries)
    if (LearnProgressService.pref !== null) {
      await LearnProgressService.pref.put(KEY_MAP, json)
      await LearnProgressService.pref.flush()
    }
    const tick = AppStorage.get<number>('progressTick') ?? 0
    AppStorage.setOrCreate('progressTick', tick + 1)
  }

  private static toWire(key: string, v: CourseProgressEntry): ProgressWireEntry {
    const w = new ProgressWireEntry()
    w.courseId = key.length > 0 ? key : v.courseId
    w.percent = v.percent
    w.lastAt = v.lastAt
    return w
  }

  private static parseMap(raw: string): Map<string, CourseProgressEntry> {
    const map = new Map<string, CourseProgressEntry>()
    try {
      const rows = JSON.parse(raw) as ProgressWireEntry[]
      for (let w of rows) {
        if (w.courseId.length === 0) {
          continue
        }
        const row = new CourseProgressEntry()
        row.courseId = w.courseId
        row.percent = w.percent
        row.lastAt = w.lastAt
        map.set(w.courseId, row)
      }
    } catch {
      // empty
    }
    return map
  }
}

class ProgressWireEntry {
  courseId: string = ''
  percent: number = 0
  lastAt: string = ''
}

class ProgressWireRoot {
  entries: ProgressWireEntry[] = []
}
