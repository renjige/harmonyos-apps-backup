import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { BadgeItem, WeekDayCell } from '../models/CareerModels'
import { FavoriteService } from './FavoriteService'

const STORE_NAME = 'career_study_stats'
const KEY_CHAPTERS = 'chapterDone'
const KEY_DAILY = 'dailyMinutes'
const KEY_WISDOM = 'wisdomDone'

class ChapterDoneWire {
  courseId: string = ''
  indices: number[] = []
}

class DailyWire {
  dateKey: string = ''
  minutes: number = 0
}

/**
 * 学习统计：章节完成、每日学习时长、成就判定。
 */
export class StudyStatsService {
  private static pref: preferences.Preferences | null = null
  private static chapterMap: Map<string, number[]> = new Map()
  private static dailyMap: Map<string, number> = new Map()
  private static wisdomDone: boolean = false
  private static ready: boolean = false

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      StudyStatsService.pref = await preferences.getPreferences(context, STORE_NAME)
      const chRaw = await StudyStatsService.pref.get(KEY_CHAPTERS, '[]')
      const dayRaw = await StudyStatsService.pref.get(KEY_DAILY, '[]')
      const wRaw = await StudyStatsService.pref.get(KEY_WISDOM, false)
      StudyStatsService.chapterMap = StudyStatsService.parseChapters(
        typeof chRaw === 'string' ? chRaw : '[]')
      StudyStatsService.dailyMap = StudyStatsService.parseDaily(
        typeof dayRaw === 'string' ? dayRaw : '[]')
      StudyStatsService.wisdomDone = wRaw === true
      StudyStatsService.ready = true
    } catch {
      StudyStatsService.ready = true
    }
  }

  static isChapterDone(courseId: string, index: number): boolean {
    const arr = StudyStatsService.chapterMap.get(courseId)
    if (arr === undefined) {
      return false
    }
    for (let n of arr) {
      if (n === index) {
        return true
      }
    }
    return false
  }

  static doneCount(courseId: string): number {
    const arr = StudyStatsService.chapterMap.get(courseId)
    return arr !== undefined ? arr.length : 0
  }

  static async markChapterDone(courseId: string, index: number, total: number): Promise<number> {
    let arr = StudyStatsService.chapterMap.get(courseId)
    if (arr === undefined) {
      arr = []
    }
    let exists = false
    for (let n of arr) {
      if (n === index) {
        exists = true
        break
      }
    }
    if (!exists) {
      arr.push(index)
      arr.sort((a: number, b: number) => a - b)
      StudyStatsService.chapterMap.set(courseId, arr)
      await StudyStatsService.addMinutes(8 + (index % 4))
    }
    const percent = total > 0 ? Math.min(100, Math.round(arr.length * 100 / total)) : 0
    await StudyStatsService.persist()
    return percent
  }

  static async addMinutes(minutes: number): Promise<void> {
    if (minutes <= 0) {
      return
    }
    const key = StudyStatsService.todayKey()
    const cur = StudyStatsService.dailyMap.get(key) ?? 0
    StudyStatsService.dailyMap.set(key, cur + minutes)
    await StudyStatsService.persist()
  }

  static getTodayMinutes(): number {
    return StudyStatsService.dailyMap.get(StudyStatsService.todayKey()) ?? 0
  }

  static getTotalMinutes(): number {
    let sum = 0
    StudyStatsService.dailyMap.forEach((v: number) => {
      sum = sum + v
    })
    return sum
  }

  static studiedDaysThisWeek(): number {
    let n = 0
    for (let cell of StudyStatsService.weekCalendar()) {
      if (cell.studied) {
        n = n + 1
      }
    }
    return n
  }

  static weekCalendar(): WeekDayCell[] {
    const out: WeekDayCell[] = []
    const labels: string[] = ['一', '二', '三', '四', '五', '六', '日']
    const now = new Date()
    const day = now.getDay()
    const mondayOffset = day === 0 ? -6 : 1 - day
    const todayKey = StudyStatsService.todayKey()
    let i = 0
    while (i < 7) {
      const d = new Date(now.getFullYear(), now.getMonth(), now.getDate() + mondayOffset + i)
      const cell = new WeekDayCell()
      cell.label = labels[i]
      cell.dateKey = StudyStatsService.dateKeyOf(d)
      cell.minutes = StudyStatsService.dailyMap.get(cell.dateKey) ?? 0
      cell.studied = cell.minutes > 0
      cell.isToday = cell.dateKey === todayKey
      out.push(cell)
      i = i + 1
    }
    return out
  }

  static async setWisdomDone(): Promise<void> {
    StudyStatsService.wisdomDone = true
    await StudyStatsService.persist()
  }

  static isWisdomDone(): boolean {
    return StudyStatsService.wisdomDone
  }

  static listBadges(startedCount: number, completedCount: number, enrollCount: number): BadgeItem[] {
    const out: BadgeItem[] = []
    out.push(StudyStatsService.badge('first_chapter', '初出茅庐', '完成任意课程第一章', 'check',
      StudyStatsService.anyChapterDone()))
    out.push(StudyStatsService.badge('week_streak', '持之以恒', '本周学习 ≥3 天', 'chart',
      StudyStatsService.studiedDaysThisWeek() >= 3))
    out.push(StudyStatsService.badge('starter5', '好学之星', '开始学习的课程 ≥3 门', 'biz',
      startedCount >= 3))
    out.push(StudyStatsService.badge('fav3', '收藏达人', '收藏课程 ≥3 门', 'ai',
      FavoriteService.count() >= 3))
    out.push(StudyStatsService.badge('wisdom', '智慧觉醒', '完成智慧学习问卷', 'ai',
      StudyStatsService.wisdomDone))
    out.push(StudyStatsService.badge('finish1', '结业先锋', '完整学完 1 门课程', 'check',
      completedCount >= 1))
    out.push(StudyStatsService.badge('finish3', '职场进阶', '完整学完 3 门课程', 'chart',
      completedCount >= 3))
    out.push(StudyStatsService.badge('enroll1', '行动派', '提交过课程或活动报名', 'message',
      enrollCount >= 1))
    return out
  }

  private static badge(id: string, title: string, desc: string, icon: string, unlocked: boolean): BadgeItem {
    const b = new BadgeItem()
    b.id = id
    b.title = title
    b.description = desc
    b.iconName = icon
    b.unlocked = unlocked
    return b
  }

  private static anyChapterDone(): boolean {
    let found = false
    StudyStatsService.chapterMap.forEach((arr: number[]) => {
      if (arr.length > 0) {
        found = true
      }
    })
    return found
  }

  private static todayKey(): string {
    return StudyStatsService.dateKeyOf(new Date())
  }

  private static dateKeyOf(d: Date): string {
    const y = d.getFullYear()
    const mo = d.getMonth() + 1
    const day = d.getDate()
    const moStr = mo < 10 ? `0${mo}` : `${mo}`
    const dayStr = day < 10 ? `0${day}` : `${day}`
    return `${y}-${moStr}-${dayStr}`
  }

  private static async persist(): Promise<void> {
    const chArr: ChapterDoneWire[] = []
    StudyStatsService.chapterMap.forEach((indices: number[], courseId: string) => {
      const w = new ChapterDoneWire()
      w.courseId = courseId
      w.indices = indices
      chArr.push(w)
    })
    const dayArr: DailyWire[] = []
    StudyStatsService.dailyMap.forEach((minutes: number, dateKey: string) => {
      const w = new DailyWire()
      w.dateKey = dateKey
      w.minutes = minutes
      dayArr.push(w)
    })
    if (StudyStatsService.pref !== null) {
      await StudyStatsService.pref.put(KEY_CHAPTERS, JSON.stringify(chArr))
      await StudyStatsService.pref.put(KEY_DAILY, JSON.stringify(dayArr))
      await StudyStatsService.pref.put(KEY_WISDOM, StudyStatsService.wisdomDone)
      await StudyStatsService.pref.flush()
    }
    const tick = AppStorage.get<number>('progressTick') ?? 0
    AppStorage.setOrCreate('progressTick', tick + 1)
  }

  private static parseChapters(raw: string): Map<string, number[]> {
    const map = new Map<string, number[]>()
    try {
      const rows = JSON.parse(raw) as ChapterDoneWire[]
      for (let w of rows) {
        if (w.courseId.length > 0) {
          map.set(w.courseId, w.indices)
        }
      }
    } catch {
      // empty
    }
    return map
  }

  private static parseDaily(raw: string): Map<string, number> {
    const map = new Map<string, number>()
    try {
      const rows = JSON.parse(raw) as DailyWire[]
      for (let w of rows) {
        if (w.dateKey.length > 0) {
          map.set(w.dateKey, w.minutes)
        }
      }
    } catch {
      // empty
    }
    return map
  }
}
