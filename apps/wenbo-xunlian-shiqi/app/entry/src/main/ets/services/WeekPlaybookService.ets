import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { WeekPlaySlot } from '../models/PlayModels'

const STORE = 'week_playbook_v1'
const KEY = 'slots_json'

export class WeekPlaybookService {
  private static pref: preferences.Preferences | null = null
  private static cache: WeekPlaySlot[] = []
  private static rev: number = 0

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      WeekPlaybookService.pref = await preferences.getPreferences(context, STORE)
      WeekPlaybookService.cache = WeekPlaybookService.parse(
        await WeekPlaybookService.read(KEY, '[]'))
      WeekPlaybookService.rev += 1
      WeekPlaybookService.syncRevision()
    } catch {
      WeekPlaybookService.cache = []
    }
  }

  static revision(): number {
    return WeekPlaybookService.rev
  }

  static list(): WeekPlaySlot[] {
    return WeekPlaybookService.copyList(WeekPlaybookService.cache)
  }

  static async regenerate(): Promise<WeekPlaySlot[]> {
    const labels: string[] = [
      '周一|跟练日|follow',
      '周二|图鉴探索|discover',
      '周三|挑战打卡|challenge',
      '周四|呼吸放松|breath',
      '周五|写运动笔记|card',
      '周六|清单 + 目标|check',
      '周日|成长复盘|recap'
    ]
    const out: WeekPlaySlot[] = []
    for (const row of labels) {
      const p = row.split('|')
      const s = new WeekPlaySlot()
      s.weekday = p[0] ?? ''
      s.label = p[1] ?? ''
      s.action = p[2] ?? 'discover'
      s.done = false
      out.push(s)
    }
    WeekPlaybookService.cache = out
    WeekPlaybookService.rev += 1
    WeekPlaybookService.syncRevision()
    await WeekPlaybookService.flush()
    return WeekPlaybookService.list()
  }

  /** 仅标记完成，不在进入玩法时反复翻转 */
  static async setDone(weekday: string, done: boolean): Promise<WeekPlaySlot[]> {
    const next: WeekPlaySlot[] = []
    for (const s of WeekPlaybookService.cache) {
      const n = new WeekPlaySlot()
      n.weekday = s.weekday
      n.label = s.label
      n.action = s.action
      n.done = s.weekday === weekday ? done : s.done
      next.push(n)
    }
    WeekPlaybookService.cache = next
    WeekPlaybookService.rev += 1
    WeekPlaybookService.syncRevision()
    await WeekPlaybookService.flush()
    return WeekPlaybookService.list()
  }

  static syncRevision(): void {
    AppStorage.setOrCreate('weekPlaybookRev', WeekPlaybookService.rev)
  }

  private static copyList(src: WeekPlaySlot[]): WeekPlaySlot[] {
    const out: WeekPlaySlot[] = []
    for (const s of src) {
      const n = new WeekPlaySlot()
      n.weekday = s.weekday
      n.label = s.label
      n.action = s.action
      n.done = s.done
      out.push(n)
    }
    return out
  }

  private static async flush(): Promise<void> {
    if (WeekPlaybookService.pref === null) {
      return
    }
    const payload: string[] = []
    for (const s of WeekPlaybookService.cache) {
      payload.push(`${s.weekday}|${s.label}|${s.action}|${s.done ? '1' : '0'}`)
    }
    await WeekPlaybookService.pref.put(KEY, payload.join('\n'))
    await WeekPlaybookService.pref.flush()
  }

  private static async read(key: string, fallback: string): Promise<string> {
    if (WeekPlaybookService.pref === null) {
      return fallback
    }
    const raw = await WeekPlaybookService.pref.get(key, fallback)
    return typeof raw === 'string' ? raw : fallback
  }

  private static parse(text: string): WeekPlaySlot[] {
    if (text.length === 0 || text === '[]') {
      return []
    }
    // 新格式：一行 weekday|label|action|done
    if (text.indexOf('|') >= 0 && text.charAt(0) !== '[') {
      const out: WeekPlaySlot[] = []
      const rows = text.split('\n')
      for (const row of rows) {
        if (row.length === 0) {
          continue
        }
        const p = row.split('|')
        const s = new WeekPlaySlot()
        s.weekday = p[0] ?? ''
        s.label = p[1] ?? ''
        s.action = p[2] ?? ''
        s.done = (p[3] ?? '0') === '1'
        if (s.weekday.length > 0) {
          out.push(s)
        }
      }
      return out
    }
    // 兼容旧 JSON
    try {
      const arr = JSON.parse(text) as Object[]
      const out: WeekPlaySlot[] = []
      for (let i = 0; i < arr.length; i++) {
        const raw = arr[i] as Record<string, string | boolean | number>
        const s = new WeekPlaySlot()
        const wd = raw['weekday']
        const lb = raw['label']
        const ac = raw['action']
        const dn = raw['done']
        s.weekday = typeof wd === 'string' ? wd : ''
        s.label = typeof lb === 'string' ? lb : ''
        s.action = typeof ac === 'string' ? ac : ''
        s.done = dn === true || dn === 1
        if (s.weekday.length > 0) {
          out.push(s)
        }
      }
      return out
    } catch {
      return []
    }
  }
}
