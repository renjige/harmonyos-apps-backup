import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { AtelierDetailNav } from './AtelierDetailNav'

const STORE_NAME = 'yuezhifang_local'
const KEY_MINUTES = 'read_minutes'
const KEY_DARK = 'dark_mode'
const KEY_READ_IDS = 'read_card_ids'
const KEY_STREAK = 'read_streak'
const KEY_LAST_DAY = 'read_last_day'

/** 本机学习进度（分钟累加）；不伪造他人数据 */
export class AtelierProgress {
  private static pref: preferences.Preferences | null = null
  private static minutes: number = 0
  private static readIds: string[] = []
  private static streak: number = 0
  private static lastDay: string = ''

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      AtelierProgress.pref = await preferences.getPreferences(context, STORE_NAME)
      const raw = await AtelierProgress.pref.get(KEY_MINUTES, 0)
      AtelierProgress.minutes = typeof raw === 'number' ? raw : 0
      const idsRaw = await AtelierProgress.pref.get(KEY_READ_IDS, '')
      AtelierProgress.readIds = AtelierProgress.decodeIds(typeof idsRaw === 'string' ? idsRaw : '')
      const streakRaw = await AtelierProgress.pref.get(KEY_STREAK, 0)
      AtelierProgress.streak = typeof streakRaw === 'number' ? streakRaw : 0
      const dayRaw = await AtelierProgress.pref.get(KEY_LAST_DAY, '')
      AtelierProgress.lastDay = typeof dayRaw === 'string' ? dayRaw : ''
    } catch {
      AtelierProgress.minutes = 0
    }
  }

  /** null = 从未手动切换，跟随系统；true/false = 用户显式选择 */
  static async readDarkPref(): Promise<boolean | null> {
    if (AtelierProgress.pref === null) {
      return null
    }
    try {
      const has = await AtelierProgress.pref.has(KEY_DARK)
      if (!has) {
        return null
      }
      const dark = await AtelierProgress.pref.get(KEY_DARK, false)
      return dark === true
    } catch {
      return null
    }
  }

  static totalMinutes(): number {
    return AtelierProgress.minutes
  }

  static readCardCount(): number {
    return AtelierProgress.readIds.length
  }

  static streakDays(): number {
    return AtelierProgress.streak
  }

  static isCardRead(cardId: string): boolean {
    for (const id of AtelierProgress.readIds) {
      if (id === cardId) {
        return true
      }
    }
    return false
  }

  static trailDoneCount(cardIds: string[]): number {
    let n = 0
    for (const id of cardIds) {
      if (AtelierProgress.isCardRead(id)) {
        n = n + 1
      }
    }
    return n
  }

  static async markCardRead(cardId: string): Promise<void> {
    if (cardId.length === 0 || AtelierProgress.isCardRead(cardId)) {
      return
    }
    const next: string[] = []
    for (const id of AtelierProgress.readIds) {
      next.push(id)
    }
    next.unshift(cardId)
    AtelierProgress.readIds = next
    const today = AtelierProgress.todayKey()
    if (AtelierProgress.lastDay.length === 0) {
      AtelierProgress.streak = 1
    } else if (AtelierProgress.lastDay === today) {
      // same day
    } else if (AtelierProgress.isYesterday(AtelierProgress.lastDay, today)) {
      AtelierProgress.streak = AtelierProgress.streak + 1
    } else {
      AtelierProgress.streak = 1
    }
    AtelierProgress.lastDay = today
    if (AtelierProgress.pref !== null) {
      await AtelierProgress.pref.put(KEY_READ_IDS, AtelierProgress.encodeIds(AtelierProgress.readIds))
      await AtelierProgress.pref.put(KEY_STREAK, AtelierProgress.streak)
      await AtelierProgress.pref.put(KEY_LAST_DAY, AtelierProgress.lastDay)
      await AtelierProgress.pref.flush()
    }
    AtelierDetailNav.bumpRefresh()
  }

  static async addReadMinutes(delta: number): Promise<void> {
    if (delta <= 0) {
      return
    }
    AtelierProgress.minutes = AtelierProgress.minutes + delta
    if (AtelierProgress.pref !== null) {
      await AtelierProgress.pref.put(KEY_MINUTES, AtelierProgress.minutes)
      await AtelierProgress.pref.flush()
    }
  }

  static async setDark(on: boolean): Promise<void> {
    AppStorage.setOrCreate('darkModeOn', on)
    if (AtelierProgress.pref !== null) {
      await AtelierProgress.pref.put(KEY_DARK, on)
      await AtelierProgress.pref.flush()
    }
  }

  static async clearCache(): Promise<void> {
    AtelierProgress.minutes = 0
    AtelierProgress.readIds = []
    AtelierProgress.streak = 0
    AtelierProgress.lastDay = ''
    if (AtelierProgress.pref !== null) {
      await AtelierProgress.pref.put(KEY_MINUTES, 0)
      await AtelierProgress.pref.put(KEY_READ_IDS, '')
      await AtelierProgress.pref.put(KEY_STREAK, 0)
      await AtelierProgress.pref.put(KEY_LAST_DAY, '')
      await AtelierProgress.pref.flush()
    }
    AtelierDetailNav.bumpRefresh()
  }

  private static todayKey(): string {
    const d = new Date()
    const y = d.getFullYear()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${y}-${ms}-${ds}`
  }

  private static isYesterday(prev: string, today: string): boolean {
    const parts = prev.split('-')
    if (parts.length !== 3) {
      return false
    }
    const y = Number(parts[0])
    const m = Number(parts[1])
    const d = Number(parts[2])
    const prevDate = new Date(y, m - 1, d)
    prevDate.setDate(prevDate.getDate() + 1)
    const py = prevDate.getFullYear()
    const pm = prevDate.getMonth() + 1
    const pd = prevDate.getDate()
    const pms = pm < 10 ? `0${pm}` : `${pm}`
    const pds = pd < 10 ? `0${pd}` : `${pd}`
    return `${py}-${pms}-${pds}` === today
  }

  private static encodeIds(ids: string[]): string {
    let json = '['
    for (let i = 0; i < ids.length; i++) {
      if (i > 0) {
        json += ','
      }
      json += `"${ids[i]}"`
    }
    json += ']'
    return json
  }

  private static decodeIds(text: string): string[] {
    const out: string[] = []
    if (text.length === 0) {
      return out
    }
    try {
      const parsed = JSON.parse(text) as string[]
      if (parsed === undefined) {
        return out
      }
      for (const id of parsed) {
        if (typeof id === 'string' && id.length > 0) {
          out.push(id)
        }
      }
    } catch {
      return out
    }
    return out
  }
}
