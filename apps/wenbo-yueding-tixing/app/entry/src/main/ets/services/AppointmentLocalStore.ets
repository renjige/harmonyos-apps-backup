import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { AppointmentItem, LocalAppointmentBundle } from '../models/AppointmentModels'

const STORE = 'appointment_local'
const KEY_BUNDLE = 'bundle'
const KEY_ONBOARD = 'onboardingDone'
const KEY_NOTIFY = 'notifyEnabled'
const KEY_REMINDER_MAP = 'reminderMap'
const KEY_PLACES = 'favPlaces'
const KEY_CONTACTS = 'favContacts'

class BundleWire {
  items: AppointmentItem[] = []
}

class ReminderMapWire {
  entries: ReminderEntry[] = []
}

class ReminderEntry {
  appointmentId: string = ''
  agentId: number = 0
}

export class AppointmentLocalStore {
  private static pref: preferences.Preferences | null = null
  private static cache: LocalAppointmentBundle = new LocalAppointmentBundle()
  private static reminderMap: ReminderMapWire = new ReminderMapWire()
  private static favPlaces: string[] = []
  private static favContacts: string[] = []

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      AppointmentLocalStore.pref = await preferences.getPreferences(context, STORE)
      const rawValue = await AppointmentLocalStore.pref.get(KEY_BUNDLE, '')
      const raw: string = typeof rawValue === 'string' ? rawValue : ''
      AppointmentLocalStore.cache = AppointmentLocalStore.parseBundle(raw)
      const mapValue = await AppointmentLocalStore.pref.get(KEY_REMINDER_MAP, '')
      const mapRaw: string = typeof mapValue === 'string' ? mapValue : ''
      AppointmentLocalStore.reminderMap = AppointmentLocalStore.parseReminderMap(mapRaw)
      const onboardValue = await AppointmentLocalStore.pref.get(KEY_ONBOARD, false)
      AppStorage.setOrCreate(KEY_ONBOARD, onboardValue === true)
      const notifyValue = await AppointmentLocalStore.pref.get(KEY_NOTIFY, true)
      AppStorage.setOrCreate(KEY_NOTIFY, notifyValue !== false)
      const placesValue = await AppointmentLocalStore.pref.get(KEY_PLACES, '')
      AppointmentLocalStore.favPlaces = AppointmentLocalStore.splitFav(
        typeof placesValue === 'string' ? placesValue : '')
      const contactsValue = await AppointmentLocalStore.pref.get(KEY_CONTACTS, '')
      AppointmentLocalStore.favContacts = AppointmentLocalStore.splitFav(
        typeof contactsValue === 'string' ? contactsValue : '')
    } catch {
      AppointmentLocalStore.cache = new LocalAppointmentBundle()
      AppointmentLocalStore.reminderMap = new ReminderMapWire()
      AppStorage.setOrCreate(KEY_ONBOARD, false)
      AppStorage.setOrCreate(KEY_NOTIFY, true)
    }
  }

  static snapshot(): LocalAppointmentBundle {
    return AppointmentLocalStore.cache
  }

  static items(): AppointmentItem[] {
    return AppointmentLocalStore.cache.items
  }

  static async saveBundle(next: LocalAppointmentBundle): Promise<void> {
    AppointmentLocalStore.cache = next
    await AppointmentLocalStore.putString(KEY_BUNDLE, AppointmentLocalStore.serializeBundle(next))
  }

  static serializeBundle(bundle: LocalAppointmentBundle): string {
    const wire = new BundleWire()
    wire.items = bundle.items
    return JSON.stringify(wire)
  }

  static async setOnboardingDone(): Promise<void> {
    AppStorage.setOrCreate(KEY_ONBOARD, true)
    await AppointmentLocalStore.putBool(KEY_ONBOARD, true)
  }

  static async setNotifyEnabled(enabled: boolean): Promise<void> {
    AppStorage.setOrCreate(KEY_NOTIFY, enabled)
    await AppointmentLocalStore.putBool(KEY_NOTIFY, enabled)
  }

  static places(): string[] {
    return AppointmentLocalStore.favPlaces
  }

  static contacts(): string[] {
    return AppointmentLocalStore.favContacts
  }

  static async rememberFav(place: string, contact: string): Promise<void> {
    if (place.length > 0) {
      AppointmentLocalStore.favPlaces = AppointmentLocalStore.pushUnique(AppointmentLocalStore.favPlaces, place)
      await AppointmentLocalStore.putString(KEY_PLACES, AppointmentLocalStore.joinFav(AppointmentLocalStore.favPlaces))
    }
    if (contact.length > 0) {
      AppointmentLocalStore.favContacts = AppointmentLocalStore.pushUnique(AppointmentLocalStore.favContacts, contact)
      await AppointmentLocalStore.putString(KEY_CONTACTS, AppointmentLocalStore.joinFav(AppointmentLocalStore.favContacts))
    }
  }

  private static pushUnique(list: string[], value: string): string[] {
    const out: string[] = [value]
    for (const row of list) {
      if (row !== value) {
        out.push(row)
      }
    }
    const limited: string[] = []
    for (let i = 0; i < out.length && i < 6; i++) {
      limited.push(out[i])
    }
    return limited
  }

  private static splitFav(raw: string): string[] {
    if (raw.length === 0) {
      return []
    }
    return raw.split('|')
  }

  private static joinFav(list: string[]): string {
    let text = ''
    for (let i = 0; i < list.length; i++) {
      text = i === 0 ? list[i] : `${text}|${list[i]}`
    }
    return text
  }

  static reminderAgentId(appointmentId: string): number {
    for (const row of AppointmentLocalStore.reminderMap.entries) {
      if (row.appointmentId === appointmentId) {
        return row.agentId
      }
    }
    return 0
  }

  static async setReminderAgentId(appointmentId: string, agentId: number): Promise<void> {
    const next = new ReminderMapWire()
    let found = false
    for (const row of AppointmentLocalStore.reminderMap.entries) {
      if (row.appointmentId === appointmentId) {
        const entry = new ReminderEntry()
        entry.appointmentId = appointmentId
        entry.agentId = agentId
        next.entries.push(entry)
        found = true
      } else {
        next.entries.push(row)
      }
    }
    if (!found) {
      const entry = new ReminderEntry()
      entry.appointmentId = appointmentId
      entry.agentId = agentId
      next.entries.push(entry)
    }
    AppointmentLocalStore.reminderMap = next
    await AppointmentLocalStore.putString(KEY_REMINDER_MAP, JSON.stringify(next))
  }

  static async removeReminderAgentId(appointmentId: string): Promise<void> {
    const next = new ReminderMapWire()
    for (const row of AppointmentLocalStore.reminderMap.entries) {
      if (row.appointmentId !== appointmentId) {
        next.entries.push(row)
      }
    }
    AppointmentLocalStore.reminderMap = next
    await AppointmentLocalStore.putString(KEY_REMINDER_MAP, JSON.stringify(next))
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (AppointmentLocalStore.pref === null) {
      return
    }
    try {
      await AppointmentLocalStore.pref.put(key, value)
      await AppointmentLocalStore.pref.flush()
    } catch {
    }
  }

  private static async putBool(key: string, value: boolean): Promise<void> {
    if (AppointmentLocalStore.pref === null) {
      return
    }
    try {
      await AppointmentLocalStore.pref.put(key, value)
      await AppointmentLocalStore.pref.flush()
    } catch {
    }
  }

  static nowIso(): string {
    return new Date().toISOString()
  }

  static today(): string {
    const d = new Date()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms: string = m < 10 ? `0${m}` : `${m}`
    const ds: string = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${ms}-${ds}`
  }

  static newId(prefix: string): string {
    return `${prefix}_${Date.now()}`
  }

  static async clearCache(): Promise<void> {
    if (AppointmentLocalStore.pref === null) {
      return
    }
    try {
      await AppointmentLocalStore.pref.flush()
    } catch {
    }
  }

  private static parseBundle(raw: string): LocalAppointmentBundle {
    const empty = new LocalAppointmentBundle()
    if (raw.length === 0) {
      return empty
    }
    try {
      const parsed = JSON.parse(raw) as BundleWire
      const out = new LocalAppointmentBundle()
      if (parsed.items !== undefined) {
        const hydrated: AppointmentItem[] = []
        for (const row of parsed.items) {
          hydrated.push(AppointmentItem.hydrate(row))
        }
        out.items = hydrated
      }
      return out
    } catch {
      return empty
    }
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
}
