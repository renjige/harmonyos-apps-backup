import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { Theme } from '../components/design-system/Theme'
import { InspirationFile, InspirationItem, InspirationWire, JournalEntry, JournalFile, JournalWire } from '../models/JournalModels'
import { MemoFile, MemoItem, MemoWire, TplItem, TripDateHelp, TripFile, TripItem, TripWire } from '../models/TripModels'

const STORE_NAME = 'xinglv_jian_local'
const KEY_TRIPS = 'trips_json'
const KEY_ITEMS = 'items_json'
const KEY_JOURNALS = 'journals_json'
const KEY_INSPIRATIONS = 'inspirations_json'
const KEY_DARK = 'dark_mode'
const KEY_REMIND = 'smart_remind'
const KEY_FONT = 'font_level'
const KEY_THEME = 'color_mode'

export class TripStore {
  private static pref: preferences.Preferences | null = null
  private static trips: TripItem[] = []
  private static items: MemoItem[] = []
  private static journals: JournalEntry[] = []
  private static inspirations: InspirationItem[] = []
  private static idSeq: number = 0

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      TripStore.pref = await preferences.getPreferences(context, STORE_NAME)
      const tripsRaw = await TripStore.pref.get(KEY_TRIPS, '[]')
      const itemsRaw = await TripStore.pref.get(KEY_ITEMS, '[]')
      const journalsRaw = await TripStore.pref.get(KEY_JOURNALS, '[]')
      const inspirationsRaw = await TripStore.pref.get(KEY_INSPIRATIONS, '[]')
      TripStore.trips = TripStore.parseTrips(typeof tripsRaw === 'string' ? tripsRaw : '[]')
      TripStore.items = TripStore.parseItems(typeof itemsRaw === 'string' ? itemsRaw : '[]')
      TripStore.journals = TripStore.parseJournals(typeof journalsRaw === 'string' ? journalsRaw : '[]')
      TripStore.inspirations = TripStore.parseInspirations(typeof inspirationsRaw === 'string' ? inspirationsRaw : '[]')
      TripStore.repairTripIds()
      const dark = await TripStore.pref.get(KEY_DARK, false)
      const remind = await TripStore.pref.get(KEY_REMIND, true)
      const font = await TripStore.pref.get(KEY_FONT, 1)
      AppStorage.setOrCreate('darkModeOn', dark === true)
      Theme.applyDark(dark === true)
      AppStorage.setOrCreate('colorMode', dark === true ? 'dark' : 'light')
      AppStorage.setOrCreate('smartRemindOn', remind !== false)
      const fontLevel = typeof font === 'number' ? font : 1
      AppStorage.setOrCreate('fontLevel', fontLevel)
    } catch {
      TripStore.trips = []
      TripStore.items = []
      TripStore.journals = []
      TripStore.inspirations = []
    }
  }

  static allJournals(): JournalEntry[] {
    const copy: JournalEntry[] = []
    for (const j of TripStore.journals) {
      copy.push(j)
    }
    return TripStore.sortJournals(copy)
  }

  static findJournal(id: string): JournalEntry | undefined {
    for (const j of TripStore.journals) {
      if (j.id === id) {
        return j
      }
    }
    return undefined
  }

  static allInspirations(): InspirationItem[] {
    const copy: InspirationItem[] = []
    for (const i of TripStore.inspirations) {
      copy.push(i)
    }
    return TripStore.sortInspirations(copy)
  }

  static findInspiration(id: string): InspirationItem | undefined {
    for (const i of TripStore.inspirations) {
      if (i.id === id) {
        return i
      }
    }
    return undefined
  }

  static visitedCityCount(): number {
    const cities: string[] = []
    for (const t of TripStore.trips) {
      if (t.location.length > 0 && !cities.includes(t.location)) {
        cities.push(t.location)
      }
    }
    for (const j of TripStore.journals) {
      if (j.location.length > 0 && !cities.includes(j.location)) {
        cities.push(j.location)
      }
    }
    for (const i of TripStore.inspirations) {
      if (i.destination.length > 0 && !cities.includes(i.destination)) {
        cities.push(i.destination)
      }
    }
    return cities.length
  }

  static inspirationCount(): number {
    return TripStore.inspirations.length
  }

  static journalCount(): number {
    return TripStore.journals.length
  }

  static exportJson(): string {
    const parts: string[] = []
    parts.push('"trips":[')
    const tripParts: string[] = []
    for (const t of TripStore.trips) {
      tripParts.push(t.toJsonString())
    }
    parts.push(tripParts.join(','))
    parts.push('],"journals":[')
    const journalParts: string[] = []
    for (const j of TripStore.journals) {
      journalParts.push(j.toJsonString())
    }
    parts.push(journalParts.join(','))
    parts.push('],"inspirations":[')
    const inspireParts: string[] = []
    for (const i of TripStore.inspirations) {
      inspireParts.push(i.toJsonString())
    }
    parts.push(inspireParts.join(','))
    parts.push(']}')
    return `{${parts.join('')}`
  }

  static allTrips(): TripItem[] {
    const copy: TripItem[] = []
    for (const t of TripStore.trips) {
      copy.push(t)
    }
    return TripStore.sortTrips(copy)
  }

  static sortTrips(list: TripItem[]): TripItem[] {
    const work: TripItem[] = []
    for (const t of list) {
      work.push(t)
    }
    const result: TripItem[] = []
    while (work.length > 0) {
      let best: TripItem = work[0]
      for (const t of work) {
        if (t.createdAt > best.createdAt) {
          best = t
        } else if (t.createdAt === best.createdAt && t.updatedAt > best.updatedAt) {
          best = t
        }
      }
      result.push(best)
      const next: TripItem[] = []
      for (const t of work) {
        if (t.id !== best.id) {
          next.push(t)
        }
      }
      work.length = 0
      for (const t of next) {
        work.push(t)
      }
    }
    return result
  }

  static allItems(): MemoItem[] {
    const copy: MemoItem[] = []
    for (const n of TripStore.items) {
      copy.push(n)
    }
    return copy
  }

  static findTrip(id: string): TripItem | undefined {
    for (const t of TripStore.trips) {
      if (t.id === id) {
        return t
      }
    }
    return undefined
  }

  static findItem(id: string): MemoItem | undefined {
    for (const n of TripStore.items) {
      if (n.id === id) {
        return n
      }
    }
    return undefined
  }

  static itemsOf(tripId: string): MemoItem[] {
    const out: MemoItem[] = []
    for (const n of TripStore.items) {
      if (n.tripId === tripId) {
        out.push(n)
      }
    }
    return TripStore.sortItems(out)
  }

  static itemsOnDate(iso: string): MemoItem[] {
    const out: MemoItem[] = []
    for (const n of TripStore.items) {
      if (n.itemDate === iso && n.status !== 'cancelled') {
        out.push(n)
      }
    }
    return TripStore.sortItems(out)
  }

  static itemCount(tripId: string): number {
    let n = 0
    for (const it of TripStore.items) {
      if (it.tripId === tripId) {
        n += 1
      }
    }
    return n
  }

  static sortItems(list: MemoItem[]): MemoItem[] {
    const work: MemoItem[] = []
    for (const n of list) {
      work.push(n)
    }
    const result: MemoItem[] = []
    while (work.length > 0) {
      let best: MemoItem = work[0]
      for (const n of work) {
        if (n.itemDate < best.itemDate) {
          best = n
        } else if (n.itemDate === best.itemDate && TripDateHelp.cmpTime(n.time, best.time) < 0) {
          best = n
        }
      }
      result.push(best)
      const next: MemoItem[] = []
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

  static async saveTrip(item: TripItem): Promise<void> {
    const next: TripItem[] = []
    let replaced = false
    for (const t of TripStore.trips) {
      if (t.id === item.id) {
        next.push(item)
        replaced = true
      } else {
        next.push(t)
      }
    }
    if (!replaced) {
      next.unshift(item)
    }
    TripStore.trips = next
    await TripStore.flushTrips()
    TripStore.bump()
  }

  static async saveItem(item: MemoItem): Promise<void> {
    const next: MemoItem[] = []
    let replaced = false
    for (const n of TripStore.items) {
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
    TripStore.items = next
    await TripStore.flushItems()
    TripStore.bump()
  }

  static async removeTrip(id: string): Promise<void> {
    const nextT: TripItem[] = []
    for (const t of TripStore.trips) {
      if (t.id !== id) {
        nextT.push(t)
      }
    }
    TripStore.trips = nextT
    const nextI: MemoItem[] = []
    for (const n of TripStore.items) {
      if (n.tripId !== id) {
        nextI.push(n)
      }
    }
    TripStore.items = nextI
    await TripStore.flushTrips()
    await TripStore.flushItems()
    TripStore.bump()
  }

  static async removeItem(id: string): Promise<void> {
    const next: MemoItem[] = []
    for (const n of TripStore.items) {
      if (n.id !== id) {
        next.push(n)
      }
    }
    TripStore.items = next
    await TripStore.flushItems()
    TripStore.bump()
  }

  static newTripId(): string {
    TripStore.idSeq += 1
    return `trip_${Date.now()}_${TripStore.idSeq}`
  }

  static newItemId(): string {
    TripStore.idSeq += 1
    return `item_${Date.now()}_${TripStore.idSeq}`
  }

  static newJournalId(): string {
    TripStore.idSeq += 1
    return `journal_${Date.now()}_${TripStore.idSeq}`
  }

  static newInspirationId(): string {
    TripStore.idSeq += 1
    return `inspire_${Date.now()}_${TripStore.idSeq}`
  }

  private static repairTripIds(): void {
    const seen: string[] = []
    let changed = false
    for (const t of TripStore.trips) {
      if (t.id.length === 0 || seen.indexOf(t.id) >= 0) {
        t.id = TripStore.newTripId()
        changed = true
      }
      seen.push(t.id)
    }
    if (changed) {
      void TripStore.flushTrips()
    }
  }

  static async saveJournal(item: JournalEntry): Promise<void> {
    const next: JournalEntry[] = []
    let replaced = false
    for (const j of TripStore.journals) {
      if (j.id === item.id) {
        next.push(item)
        replaced = true
      } else {
        next.push(j)
      }
    }
    if (!replaced) {
      next.unshift(item)
    }
    TripStore.journals = next
    await TripStore.flushJournals()
    TripStore.bump()
  }

  static async removeJournal(id: string): Promise<void> {
    const next: JournalEntry[] = []
    for (const j of TripStore.journals) {
      if (j.id !== id) {
        next.push(j)
      }
    }
    TripStore.journals = next
    await TripStore.flushJournals()
    TripStore.bump()
  }

  static async saveInspiration(item: InspirationItem): Promise<void> {
    const next: InspirationItem[] = []
    let replaced = false
    for (const i of TripStore.inspirations) {
      if (i.id === item.id) {
        next.push(item)
        replaced = true
      } else {
        next.push(i)
      }
    }
    if (!replaced) {
      next.unshift(item)
    }
    TripStore.inspirations = next
    await TripStore.flushInspirations()
    TripStore.bump()
  }

  static async removeInspiration(id: string): Promise<void> {
    const next: InspirationItem[] = []
    for (const i of TripStore.inspirations) {
      if (i.id !== id) {
        next.push(i)
      }
    }
    TripStore.inspirations = next
    await TripStore.flushInspirations()
    TripStore.bump()
  }

  static sortJournals(list: JournalEntry[]): JournalEntry[] {
    const work: JournalEntry[] = []
    for (const j of list) {
      work.push(j)
    }
    const result: JournalEntry[] = []
    while (work.length > 0) {
      let best: JournalEntry = work[0]
      for (const j of work) {
        if (j.recordDate > best.recordDate) {
          best = j
        } else if (j.recordDate === best.recordDate && j.createdAt > best.createdAt) {
          best = j
        }
      }
      result.push(best)
      const next: JournalEntry[] = []
      for (const j of work) {
        if (j.id !== best.id) {
          next.push(j)
        }
      }
      work.length = 0
      for (const j of next) {
        work.push(j)
      }
    }
    return result
  }

  static sortInspirations(list: InspirationItem[]): InspirationItem[] {
    const work: InspirationItem[] = []
    for (const i of list) {
      work.push(i)
    }
    const result: InspirationItem[] = []
    while (work.length > 0) {
      let best: InspirationItem = work[0]
      for (const i of work) {
        if (i.createdAt > best.createdAt) {
          best = i
        }
      }
      result.push(best)
      const next: InspirationItem[] = []
      for (const i of work) {
        if (i.id !== best.id) {
          next.push(i)
        }
      }
      work.length = 0
      for (const i of next) {
        work.push(i)
      }
    }
    return result
  }

  static async applyTemplate(tpl: TplItem): Promise<string> {
    const trip = new TripItem()
    trip.id = TripStore.newTripId()
    trip.title = tpl.title
    trip.startDate = TripDateHelp.todayIso()
    trip.endDate = TripDateHelp.addDaysIso(trip.startDate, Math.max(0, tpl.durationDays - 1))
    trip.remark = tpl.summary
    trip.status = 'upcoming'
    trip.createdAt = Date.now()
    trip.updatedAt = Date.now()
    await TripStore.saveTrip(trip)
    for (const s of tpl.steps) {
      const item = new MemoItem()
      item.id = TripStore.newItemId()
      item.tripId = trip.id
      item.title = s.title
      item.itemDate = TripDateHelp.addDaysIso(trip.startDate, s.offsetDays)
      item.time = s.time
      item.location = s.location
      item.remark = s.remark
      item.status = 'pending'
      item.createdAt = Date.now()
      item.updatedAt = Date.now()
      await TripStore.saveItem(item)
    }
    return trip.id
  }

  static bump(): void {
    const n = AppStorage.get<number>('tripRefresh') ?? 0
    AppStorage.setOrCreate('tripRefresh', n + 1)
  }

  static async setDark(on: boolean): Promise<void> {
    Theme.applyDark(on)
    AppStorage.setOrCreate('darkModeOn', on)
    AppStorage.setOrCreate('colorMode', on ? 'dark' : 'light')
    await TripStore.putBool(KEY_DARK, on)
    await TripStore.putString(KEY_THEME, on ? 'dark' : 'light')
  }

  static async setRemind(on: boolean): Promise<void> {
    AppStorage.setOrCreate('smartRemindOn', on)
    await TripStore.putBool(KEY_REMIND, on)
  }

  static async setFontLevel(level: number): Promise<void> {
    AppStorage.setOrCreate('fontLevel', level)
    await TripStore.putNumber(KEY_FONT, level)
    TripStore.bump()
  }

  static async setColorMode(mode: string): Promise<void> {
    AppStorage.setOrCreate('colorMode', mode)
    await TripStore.putString(KEY_THEME, mode)
    TripStore.bump()
  }

  private static async flushTrips(): Promise<void> {
    const parts: string[] = []
    for (const t of TripStore.trips) {
      parts.push(t.toJsonString())
    }
    await TripStore.putString(KEY_TRIPS, `[${parts.join(',')}]`)
  }

  private static async flushItems(): Promise<void> {
    const parts: string[] = []
    for (const n of TripStore.items) {
      parts.push(n.toJsonString())
    }
    await TripStore.putString(KEY_ITEMS, `[${parts.join(',')}]`)
  }

  private static async flushJournals(): Promise<void> {
    const parts: string[] = []
    for (const j of TripStore.journals) {
      parts.push(j.toJsonString())
    }
    await TripStore.putString(KEY_JOURNALS, `[${parts.join(',')}]`)
  }

  private static async flushInspirations(): Promise<void> {
    const parts: string[] = []
    for (const i of TripStore.inspirations) {
      parts.push(i.toJsonString())
    }
    await TripStore.putString(KEY_INSPIRATIONS, `[${parts.join(',')}]`)
  }

  private static parseTrips(raw: string): TripItem[] {
    const out: TripItem[] = []
    if (raw.length < 2) {
      return out
    }
    try {
      const parsed = JSON.parse(raw) as TripWire[]
      const file = new TripFile()
      file.items = parsed
      for (const w of file.items) {
        out.push(TripItem.fromWire(w))
      }
    } catch {
      return out
    }
    return out
  }

  private static parseItems(raw: string): MemoItem[] {
    const out: MemoItem[] = []
    if (raw.length < 2) {
      return out
    }
    try {
      const parsed = JSON.parse(raw) as MemoWire[]
      const file = new MemoFile()
      file.items = parsed
      for (const w of file.items) {
        out.push(MemoItem.fromWire(w))
      }
    } catch {
      return out
    }
    return out
  }

  private static parseJournals(raw: string): JournalEntry[] {
    const out: JournalEntry[] = []
    if (raw.length < 2) {
      return out
    }
    try {
      const parsed = JSON.parse(raw) as JournalWire[]
      const file = new JournalFile()
      file.items = parsed
      for (const w of file.items) {
        out.push(JournalEntry.fromWire(w))
      }
    } catch {
      return out
    }
    return out
  }

  private static parseInspirations(raw: string): InspirationItem[] {
    const out: InspirationItem[] = []
    if (raw.length < 2) {
      return out
    }
    try {
      const parsed = JSON.parse(raw) as InspirationWire[]
      const file = new InspirationFile()
      file.items = parsed
      for (const w of file.items) {
        out.push(InspirationItem.fromWire(w))
      }
    } catch {
      return out
    }
    return out
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (TripStore.pref === null) {
      return
    }
    await TripStore.pref.put(key, value)
    await TripStore.pref.flush()
  }

  private static async putBool(key: string, value: boolean): Promise<void> {
    if (TripStore.pref === null) {
      return
    }
    await TripStore.pref.put(key, value)
    await TripStore.pref.flush()
  }

  private static async putNumber(key: string, value: number): Promise<void> {
    if (TripStore.pref === null) {
      return
    }
    await TripStore.pref.put(key, value)
    await TripStore.pref.flush()
  }
}
