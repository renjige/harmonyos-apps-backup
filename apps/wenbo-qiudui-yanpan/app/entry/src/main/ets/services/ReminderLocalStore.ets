import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'

const STORE = 'sports_reminder_local'
const KEY_DEFAULT_MINUTES = 'defaultRemindMinutes'
const KEY_NOTIFY = 'notifyEnabled'
const KEY_REMINDER_MAP = 'reminderMap'

class ReminderEntry {
  matchId: string = ''
  agentId: number = 0
}

class ReminderMapWire {
  entries: ReminderEntry[] = []
}

export class ReminderLocalStore {
  private static pref: preferences.Preferences | null = null
  private static reminderMap: ReminderMapWire = new ReminderMapWire()

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      ReminderLocalStore.pref = await preferences.getPreferences(context, STORE)
      const minutesValue = await ReminderLocalStore.pref.get(KEY_DEFAULT_MINUTES, 30)
      AppStorage.setOrCreate('defaultRemindMinutes', typeof minutesValue === 'number' ? minutesValue : 30)
      const notifyValue = await ReminderLocalStore.pref.get(KEY_NOTIFY, true)
      AppStorage.setOrCreate('notifyEnabled', notifyValue !== false)
      const mapValue = await ReminderLocalStore.pref.get(KEY_REMINDER_MAP, '')
      const mapRaw: string = typeof mapValue === 'string' ? mapValue : ''
      ReminderLocalStore.reminderMap = ReminderLocalStore.parseReminderMap(mapRaw)
    } catch {
      AppStorage.setOrCreate('defaultRemindMinutes', 30)
      AppStorage.setOrCreate('notifyEnabled', true)
      ReminderLocalStore.reminderMap = new ReminderMapWire()
    }
  }

  static defaultMinutes(): number {
    const v = AppStorage.get<number>('defaultRemindMinutes')
    if (v === 10 || v === 30 || v === 60) {
      return v
    }
    return 30
  }

  static async setDefaultMinutes(minutes: number): Promise<void> {
    AppStorage.setOrCreate('defaultRemindMinutes', minutes)
    await ReminderLocalStore.putNumber(KEY_DEFAULT_MINUTES, minutes)
  }

  static async setNotifyEnabled(enabled: boolean): Promise<void> {
    AppStorage.setOrCreate('notifyEnabled', enabled)
    await ReminderLocalStore.putBool(KEY_NOTIFY, enabled)
  }

  static reminderAgentId(matchId: string): number {
    for (const row of ReminderLocalStore.reminderMap.entries) {
      if (row.matchId === matchId) {
        return row.agentId
      }
    }
    return 0
  }

  static async setReminderAgentId(matchId: string, agentId: number): Promise<void> {
    const next = new ReminderMapWire()
    let found = false
    for (const row of ReminderLocalStore.reminderMap.entries) {
      if (row.matchId === matchId) {
        const entry = new ReminderEntry()
        entry.matchId = matchId
        entry.agentId = agentId
        next.entries.push(entry)
        found = true
      } else {
        next.entries.push(row)
      }
    }
    if (!found) {
      const entry = new ReminderEntry()
      entry.matchId = matchId
      entry.agentId = agentId
      next.entries.push(entry)
    }
    ReminderLocalStore.reminderMap = next
    await ReminderLocalStore.putString(KEY_REMINDER_MAP, JSON.stringify(next))
  }

  static async removeReminderAgentId(matchId: string): Promise<void> {
    const next = new ReminderMapWire()
    for (const row of ReminderLocalStore.reminderMap.entries) {
      if (row.matchId !== matchId) {
        next.entries.push(row)
      }
    }
    ReminderLocalStore.reminderMap = next
    await ReminderLocalStore.putString(KEY_REMINDER_MAP, JSON.stringify(next))
  }

  private static parseReminderMap(raw: string): ReminderMapWire {
    const empty = new ReminderMapWire()
    if (raw.length === 0) {
      return empty
    }
    try {
      return JSON.parse(raw) as ReminderMapWire
    } catch {
      return empty
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (ReminderLocalStore.pref === null) {
      return
    }
    try {
      await ReminderLocalStore.pref.put(key, value)
      await ReminderLocalStore.pref.flush()
    } catch {
    }
  }

  private static async putNumber(key: string, value: number): Promise<void> {
    if (ReminderLocalStore.pref === null) {
      return
    }
    try {
      await ReminderLocalStore.pref.put(key, value)
      await ReminderLocalStore.pref.flush()
    } catch {
    }
  }

  private static async putBool(key: string, value: boolean): Promise<void> {
    if (ReminderLocalStore.pref === null) {
      return
    }
    try {
      await ReminderLocalStore.pref.put(key, value)
      await ReminderLocalStore.pref.flush()
    } catch {
    }
  }
}
