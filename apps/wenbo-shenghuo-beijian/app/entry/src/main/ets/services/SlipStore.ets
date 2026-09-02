import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { SlipFile, SlipItem, SlipWire } from '../models/SlipModels'
import { SlipDateUtil } from './SlipDateUtil'
import { AuthService } from './AuthService'
import { SlipBizService } from './SlipBizService'

const STORE_NAME = 'life_slip_local'
const KEY_NOTES = 'slips_json'
const KEY_SEEDED = 'samples_seeded'
const KEY_DARK = 'dark_mode'
const KEY_REMIND = 'daily_remind'

export class SlipStore {
  private static pref: preferences.Preferences | null = null
  private static notes: SlipItem[] = []

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      SlipStore.pref = await preferences.getPreferences(context, STORE_NAME)
      const rawValue = await SlipStore.pref.get(KEY_NOTES, '[]')
      const raw: string = typeof rawValue === 'string' ? rawValue : '[]'
      SlipStore.notes = SlipStore.parseNotes(raw)
      const seeded = await SlipStore.pref.get(KEY_SEEDED, false)
      if (seeded !== true && SlipStore.notes.length === 0) {
        await SlipStore.seedSamples()
      }
      const dark = await SlipStore.pref.get(KEY_DARK, false)
      const remind = await SlipStore.pref.get(KEY_REMIND, false)
      AppStorage.setOrCreate('darkModeOn', dark === true)
      AppStorage.setOrCreate('dailyRemindOn', remind === true)
    } catch {
      SlipStore.notes = []
    }
  }

  static all(): SlipItem[] {
    const copy: SlipItem[] = []
    for (const n of SlipStore.notes) {
      copy.push(n)
    }
    return copy
  }

  static find(id: string): SlipItem | undefined {
    for (const n of SlipStore.notes) {
      if (n.id === id) {
        return n
      }
    }
    return undefined
  }

  static byDate(iso: string): SlipItem[] {
    const out: SlipItem[] = []
    for (const n of SlipStore.sorted()) {
      if (n.date === iso) {
        out.push(n)
      }
    }
    return out
  }

  static markedDates(): string[] {
    const out: string[] = []
    for (const n of SlipStore.notes) {
      if (n.date.length === 0) {
        continue
      }
      if (!SlipDateUtil.contains(out, n.date)) {
        out.push(n.date)
      }
    }
    return out
  }

  static sorted(): SlipItem[] {
    const work: SlipItem[] = SlipStore.all()
    const result: SlipItem[] = []
    while (work.length > 0) {
      let best: SlipItem | undefined = undefined
      for (const n of work) {
        if (best === undefined) {
          best = n
        } else if (n.isCompleted !== best.isCompleted) {
          if (!n.isCompleted) {
            best = n
          }
        } else if (n.isImportant !== best.isImportant) {
          if (n.isImportant) {
            best = n
          }
        } else if (n.updatedAt > best.updatedAt) {
          best = n
        }
      }
      if (best === undefined) {
        break
      }
      result.push(best)
      const next: SlipItem[] = []
      for (const n of work) {
        if (n.id !== best.id) {
          next.push(n)
        }
      }
      work.length = 0
      for (const n of next) {
        work.push(n)
      }
    }
    return result
  }

  static async save(item: SlipItem): Promise<void> {
    const next: SlipItem[] = []
    let replaced = false
    for (const n of SlipStore.notes) {
      if (n.id === item.id) {
        next.push(item)
        replaced = true
      } else {
        next.push(n)
      }
    }
    if (!replaced) {
      next.unshift(item)
    }
    SlipStore.notes = next
    await SlipStore.flushNotes()
    SlipStore.bump()
    if (AuthService.isLoggedIn()) {
      void SlipBizService.syncSave(item)
    }
  }

  static async remove(id: string): Promise<void> {
    const next: SlipItem[] = []
    for (const n of SlipStore.notes) {
      if (n.id !== id) {
        next.push(n)
      }
    }
    SlipStore.notes = next
    await SlipStore.flushNotes()
    SlipStore.bump()
    if (AuthService.isLoggedIn()) {
      void SlipBizService.syncDelete(id)
    }
  }

  static async clearAll(): Promise<void> {
    SlipStore.notes = []
    await SlipStore.flushNotes()
    SlipStore.bump()
  }

  static async clearCompleted(): Promise<void> {
    const next: SlipItem[] = []
    for (const n of SlipStore.notes) {
      if (!n.isCompleted) {
        next.push(n)
      }
    }
    SlipStore.notes = next
    await SlipStore.flushNotes()
    SlipStore.bump()
  }

  static async toggleDone(id: string): Promise<void> {
    const found = SlipStore.find(id)
    if (found === undefined) {
      return
    }
    found.isCompleted = !found.isCompleted
    found.completedAt = found.isCompleted ? Date.now() : 0
    found.updatedAt = Date.now()
    await SlipStore.save(found)
  }

  static exportText(): string {
    const lines: string[] = ['生活备笺 · 导出']
    for (const n of SlipStore.sorted()) {
      const state = n.isCompleted ? '已完成' : '待办'
      lines.push('')
      lines.push(`${n.date} · ${n.category} · ${state}`)
      lines.push(n.title)
      if (n.content.length > 0) {
        lines.push(n.content)
      }
    }
    return lines.join('\n')
  }

  static bump(): void {
    const n = AppStorage.get<number>('slipRefresh') ?? 0
    AppStorage.setOrCreate('slipRefresh', n + 1)
  }

  static async setDark(on: boolean): Promise<void> {
    AppStorage.setOrCreate('darkModeOn', on)
    await SlipStore.putBool(KEY_DARK, on)
    SlipStore.bump()
  }

  static async setRemind(on: boolean): Promise<void> {
    AppStorage.setOrCreate('dailyRemindOn', on)
    await SlipStore.putBool(KEY_REMIND, on)
  }

  static newId(): string {
    return `slip_${Date.now()}_${SlipStore.notes.length}`
  }

  private static async seedSamples(): Promise<void> {
    const today = SlipDateUtil.todayIso()
    const a = new SlipItem()
    a.id = 'sample_shop'
    a.title = '买洗衣液'
    a.content = '周末去超市时记得补一瓶。'
    a.category = '购物'
    a.date = today
    a.reminderTime = '18:30'
    a.isReminderEnabled = true
    a.createdAt = Date.now()
    a.updatedAt = Date.now()
    const b = new SlipItem()
    b.id = 'sample_life'
    b.title = '整理书桌'
    b.content = '把用不到的纸张收进抽屉。'
    b.category = '生活'
    b.date = today
    b.createdAt = Date.now() - 1000
    b.updatedAt = Date.now() - 1000
    const c = new SlipItem()
    c.id = 'sample_family'
    c.title = '晚上给家人打电话'
    c.content = '问问这一周过得怎么样。'
    c.category = '家庭'
    c.date = today
    c.reminderTime = '20:00'
    c.isReminderEnabled = true
    c.createdAt = Date.now() - 2000
    c.updatedAt = Date.now() - 2000
    SlipStore.notes = [a, b, c]
    await SlipStore.flushNotes()
    await SlipStore.putBool(KEY_SEEDED, true)
  }

  private static async flushNotes(): Promise<void> {
    const parts: string[] = []
    for (const n of SlipStore.notes) {
      parts.push(n.toJsonString())
    }
    await SlipStore.putString(KEY_NOTES, `[${parts.join(',')}]`)
  }

  private static parseNotes(raw: string): SlipItem[] {
    const out: SlipItem[] = []
    if (raw.length < 2) {
      return out
    }
    try {
      const parsed = JSON.parse(raw) as SlipWire[]
      const file = new SlipFile()
      file.items = parsed
      for (const w of file.items) {
        out.push(SlipItem.fromWire(w))
      }
    } catch {
      return out
    }
    return out
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (SlipStore.pref === null) {
      return
    }
    await SlipStore.pref.put(key, value)
    await SlipStore.pref.flush()
  }

  private static async putBool(key: string, value: boolean): Promise<void> {
    if (SlipStore.pref === null) {
      return
    }
    await SlipStore.pref.put(key, value)
    await SlipStore.pref.flush()
  }
}
