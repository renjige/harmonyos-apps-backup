import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { AthleteItem, EventItem } from '../models/StarModels'
import { StarBizService } from './StarBizService'
import { AuthService } from './AuthService'
import { EventStatusUtil } from './EventStatusUtil'

export class ReminderEntry {
  eventId: string = ''
  title: string = ''
  content: string = ''
  fireAt: number = 0
  shown: number = 0
}

class ReminderMapWire {
  entries: ReminderEntry[] = []
}

export class ReminderService {
  static lastError: string = ''
  private static pref: preferences.Preferences | null = null
  private static reminderMap: ReminderMapWire = new ReminderMapWire()

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      ReminderService.pref = await preferences.getPreferences(context, 'star_reminder_local')
      const notifyValue = await ReminderService.pref.get('notifyEnabled', true)
      AppStorage.setOrCreate('notifyEnabled', notifyValue !== false)
      const mapValue = await ReminderService.pref.get('reminderMap', '')
      const mapRaw: string = typeof mapValue === 'string' ? mapValue : ''
      ReminderService.reminderMap = ReminderService.parseReminderMap(mapRaw)
    } catch {
      AppStorage.setOrCreate('notifyEnabled', true)
      ReminderService.reminderMap = new ReminderMapWire()
    }
  }

  static notifyEnabled(): boolean {
    return AppStorage.get<boolean>('notifyEnabled') !== false
  }

  static listScheduled(): ReminderEntry[] {
    const out: ReminderEntry[] = []
    const now = Date.now()
    for (const row of ReminderService.reminderMap.entries) {
      if (row.eventId.length > 0 && row.fireAt > now && row.shown === 0) {
        out.push(row)
      }
    }
    return out
  }

  static scheduledCount(): number {
    return ReminderService.listScheduled().length
  }

  static peekDue(): ReminderEntry {
    const empty = new ReminderEntry()
    const now = Date.now()
    for (const row of ReminderService.reminderMap.entries) {
      if (row.eventId.length > 0 && row.fireAt > 0 && row.fireAt <= now && row.shown === 0) {
        return row
      }
    }
    return empty
  }

  static async markShown(eventId: string): Promise<void> {
    if (eventId.length === 0) {
      return
    }
    const next = new ReminderMapWire()
    for (const row of ReminderService.reminderMap.entries) {
      if (row.eventId === eventId) {
        const updated = new ReminderEntry()
        updated.eventId = row.eventId
        updated.title = row.title
        updated.content = row.content
        updated.fireAt = row.fireAt
        updated.shown = 1
        next.entries.push(updated)
      } else {
        next.entries.push(row)
      }
    }
    ReminderService.reminderMap = next
    await ReminderService.putString('reminderMap', ReminderService.serializeMap(next))
  }

  static computeRemindAt(event: EventItem, remindMinutes: number): string {
    if (event.startAt.length === 0) {
      return ''
    }
    const eventDate = new Date(event.startAt)
    const fire = new Date(eventDate.getTime() - remindMinutes * 60 * 1000)
    return fire.toISOString()
  }

  static async cancelForEvent(eventId: string): Promise<void> {
    const next = new ReminderMapWire()
    for (const row of ReminderService.reminderMap.entries) {
      if (row.eventId !== eventId) {
        next.entries.push(row)
      }
    }
    ReminderService.reminderMap = next
    await ReminderService.putString('reminderMap', ReminderService.serializeMap(next))
  }

  static async scheduleForEvent(
    event: EventItem,
    athlete: AthleteItem,
    remindMinutes: number
  ): Promise<boolean> {
    ReminderService.lastError = ''
    if (!ReminderService.notifyEnabled()) {
      ReminderService.lastError = '请先在设置中开启应用内提醒'
      return false
    }
    if (!EventStatusUtil.isFuture(event.startAt)) {
      ReminderService.lastError = '该赛事已开始或已结束，无法设置提醒'
      return false
    }
    await ReminderService.cancelForEvent(event.id)
    const remindIso = ReminderService.computeRemindAt(event, remindMinutes)
    if (remindIso.length === 0) {
      ReminderService.lastError = '赛事时间无效'
      return false
    }
    const fire = new Date(remindIso)
    if (fire.getTime() <= Date.now()) {
      ReminderService.lastError = '提醒时间已过，请选择更短提前量'
      return false
    }
    const entry = new ReminderEntry()
    entry.eventId = event.id
    entry.title = event.title.length > 0 ? event.title : '赛事提醒'
    entry.content = `${athlete.title} · ${event.leagueName} · ${event.timeLabel()} 即将开始`
    entry.fireAt = fire.getTime()
    entry.shown = 0
    const next = new ReminderMapWire()
    for (const row of ReminderService.reminderMap.entries) {
      next.entries.push(row)
    }
    next.entries.push(entry)
    ReminderService.reminderMap = next
    await ReminderService.putString('reminderMap', ReminderService.serializeMap(next))
    if (AuthService.isLoggedIn()) {
      await StarBizService.createReminder(event, athlete, remindMinutes)
    }
    return true
  }

  private static serializeMap(wire: ReminderMapWire): string {
    const chunks: string[] = []
    for (const row of wire.entries) {
      const eventId = ReminderService.escapeJson(row.eventId)
      const title = ReminderService.escapeJson(row.title)
      const content = ReminderService.escapeJson(row.content)
      chunks.push(
        `{"eventId":"${eventId}","title":"${title}","content":"${content}","fireAt":${row.fireAt},"shown":${row.shown}}`
      )
    }
    return `{"entries":[${chunks.join(',')}]}`
  }

  private static escapeJson(raw: string): string {
    let out = ''
    for (let i = 0; i < raw.length; i++) {
      const ch = raw.charAt(i)
      if (ch === '"') {
        out += '\\"'
      } else if (ch === '\\') {
        out += '\\\\'
      } else if (ch === '\n') {
        out += ' '
      } else {
        out += ch
      }
    }
    return out
  }

  private static parseReminderMap(raw: string): ReminderMapWire {
    const empty = new ReminderMapWire()
    if (raw.length === 0) {
      return empty
    }
    try {
      const parsed = JSON.parse(raw) as ReminderMapWire
      const out = new ReminderMapWire()
      for (const row of parsed.entries) {
        const entry = new ReminderEntry()
        entry.eventId = row.eventId
        entry.title = row.title
        entry.content = row.content
        entry.fireAt = row.fireAt
        entry.shown = row.shown
        if (entry.eventId.length > 0 && entry.fireAt > 0) {
          out.entries.push(entry)
        }
      }
      return out
    } catch {
      return empty
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (ReminderService.pref === null) {
      return
    }
    try {
      await ReminderService.pref.put(key, value)
      await ReminderService.pref.flush()
    } catch {
    }
  }
}
