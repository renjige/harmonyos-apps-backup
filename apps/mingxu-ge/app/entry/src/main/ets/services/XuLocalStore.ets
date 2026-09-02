import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  XuAgendaItem, XuAppStats, XuDateHelper, XuHabitItem, XuMoodItem, XuNoteItem
} from '../models/XuModels'
import { Theme } from '../components/design-system/Theme'

const STORE = 'mingxu_ge'
const KEY_AGENDA = 'agenda_v1'
const KEY_HABITS = 'habits_v1'
const KEY_NOTES = 'notes_v1'
const KEY_MOOD = 'mood_v1'
const KEY_DARK = 'dark_v1'
const KEY_REMIND = 'remind_v1'
const KEY_FIRST = 'first_v1'

export class XuLocalStore {
  private static pref: preferences.Preferences | null = null
  private static ctx: common.UIAbilityContext | null = null
  private static agendaMem: XuAgendaItem[] = []
  private static habitsMem: XuHabitItem[] = []
  private static notesMem: XuNoteItem[] = []
  private static moodsMem: XuMoodItem[] = []
  private static memLoaded: boolean = false

  static isReady(): boolean {
    return XuLocalStore.memLoaded
  }

  static notifyChanged(): void {
    XuLocalStore.publishHomeStats()
    AppStorage.setOrCreate('xuDataEpoch', Date.now())
  }

  /** 首页双环直接读 AppStorage，避免 Hidden Tab 不触发 @Prop/@Watch 刷新 */
  static publishHomeStats(): void {
    const today = XuDateHelper.todayKey()
    let todayTotal = 0
    let todayDone = 0
    let allTotal = XuLocalStore.agendaMem.length
    let allDone = 0
    for (const it of XuLocalStore.agendaMem) {
      if (it.done) {
        allDone++
      }
      if (it.dateKey === today) {
        todayTotal++
        if (it.done) {
          todayDone++
        }
      }
    }
    let habitTotal = XuLocalStore.habitsMem.length
    let habitDone = 0
    for (const h of XuLocalStore.habitsMem) {
      if (h.lastCheck === today) {
        habitDone++
      }
    }
    let agendaDone = 0
    let agendaTotal = 0
    let agendaHint = '去日程页添加'
    if (todayTotal > 0) {
      agendaDone = todayDone
      agendaTotal = todayTotal
      const pct = Math.round(todayDone * 100 / todayTotal)
      agendaHint = `${pct}% 今日已完成`
    } else if (allTotal > 0) {
      agendaDone = allDone
      agendaTotal = allTotal
      agendaHint = `今日无 · 待办共 ${allTotal - allDone} 项`
    }
    let habitHint = '点我添加习惯'
    if (habitTotal > 0) {
      const pct = Math.round(habitDone * 100 / habitTotal)
      habitHint = `${pct}% 已打卡`
    }
    AppStorage.setOrCreate('xuAgendaCount', allTotal)
    AppStorage.setOrCreate('xuHabitCount', habitTotal)
    AppStorage.setOrCreate('xuNoteCount', XuLocalStore.notesMem.length)
    AppStorage.setOrCreate('xuHomeAgendaDone', agendaDone)
    AppStorage.setOrCreate('xuHomeAgendaTotal', agendaTotal)
    AppStorage.setOrCreate('xuHomeAgendaHint', agendaHint)
    AppStorage.setOrCreate('xuHomeHabitDone', habitDone)
    AppStorage.setOrCreate('xuHomeHabitTotal', habitTotal)
    AppStorage.setOrCreate('xuHomeHabitHint', habitHint)
  }

  private static async openPreferences(context: common.UIAbilityContext): Promise<void> {
    try {
      const appCtx = context.getApplicationContext()
      XuLocalStore.pref = await preferences.getPreferences(appCtx, STORE)
      return
    } catch {
      // fallback
    }
    try {
      XuLocalStore.pref = await preferences.getPreferences(context, STORE)
    } catch {
      XuLocalStore.pref = null
    }
  }

  private static readyPromise: Promise<boolean> | null = null

  static async ensureReady(): Promise<boolean> {
    if (XuLocalStore.memLoaded) {
      return true
    }
    if (XuLocalStore.readyPromise !== null) {
      return XuLocalStore.readyPromise
    }
    XuLocalStore.readyPromise = (async (): Promise<boolean> => {
      if (XuLocalStore.ctx !== null && XuLocalStore.pref === null) {
        await XuLocalStore.openPreferences(XuLocalStore.ctx)
      }
      await XuLocalStore.hydrateMemFromDisk()
      XuLocalStore.memLoaded = true
      XuLocalStore.publishHomeStats()
      AppStorage.setOrCreate('xuLocalStoreReady', Date.now())
      return true
    })()
    return XuLocalStore.readyPromise
  }

  static async init(context: common.UIAbilityContext): Promise<void> {
    XuLocalStore.ctx = context
    await XuLocalStore.openPreferences(context)
    await XuLocalStore.ensureReady()
    const dark = await XuLocalStore.getString(KEY_DARK, '0')
    Theme.setColorMode(dark === '1' ? 'dark' : (dark === '2' ? 'system' : 'light'))
    if (dark === '1') {
      Theme.setForcedDark(true)
    }
  }

  private static async hydrateMemFromDisk(): Promise<void> {
    XuLocalStore.agendaMem = XuLocalStore.parseAgenda(await XuLocalStore.getString(KEY_AGENDA, ''))
    XuLocalStore.habitsMem = XuLocalStore.parseHabits(await XuLocalStore.getString(KEY_HABITS, ''))
    XuLocalStore.notesMem = XuLocalStore.parseNotes(await XuLocalStore.getString(KEY_NOTES, ''))
    XuLocalStore.moodsMem = XuLocalStore.parseMoods(await XuLocalStore.getString(KEY_MOOD, ''))
  }

  private static cloneAgenda(item: XuAgendaItem): XuAgendaItem {
    const it = new XuAgendaItem()
    it.id = item.id
    it.kind = item.kind
    it.title = item.title
    it.remark = item.remark
    it.dateKey = item.dateKey
    it.timeText = item.timeText
    it.priority = item.priority
    it.done = item.done
    it.remindOn = item.remindOn
    it.createdAt = item.createdAt
    it.updatedAt = item.updatedAt
    return it
  }

  private static cloneHabit(item: XuHabitItem): XuHabitItem {
    const h = new XuHabitItem()
    h.id = item.id
    h.title = item.title
    h.remark = item.remark
    h.streak = item.streak
    h.lastCheck = item.lastCheck
    h.createdAt = item.createdAt
    return h
  }

  private static cloneNote(item: XuNoteItem): XuNoteItem {
    const n = new XuNoteItem()
    n.id = item.id
    n.title = item.title
    n.body = item.body
    n.tags = item.tags
    n.createdAt = item.createdAt
    n.updatedAt = item.updatedAt
    return n
  }

  static async loadAgenda(): Promise<XuAgendaItem[]> {
    await XuLocalStore.ensureReady()
    const out: XuAgendaItem[] = []
    for (const it of XuLocalStore.agendaMem) {
      out.push(XuLocalStore.cloneAgenda(it))
    }
    return out
  }

  static async saveAgenda(item: XuAgendaItem): Promise<void> {
    await XuLocalStore.ensureReady()
    const next: XuAgendaItem[] = []
    let found = false
    for (const it of XuLocalStore.agendaMem) {
      if (it.id === item.id) {
        next.push(XuLocalStore.cloneAgenda(item))
        found = true
      } else {
        next.push(XuLocalStore.cloneAgenda(it))
      }
    }
    if (!found) {
      next.push(XuLocalStore.cloneAgenda(item))
    }
    XuLocalStore.agendaMem = next
    await XuLocalStore.putString(KEY_AGENDA, XuLocalStore.serAgenda(next))
    XuLocalStore.notifyChanged()
  }

  static async deleteAgenda(id: string): Promise<void> {
    await XuLocalStore.ensureReady()
    const next: XuAgendaItem[] = []
    for (const it of XuLocalStore.agendaMem) {
      if (it.id !== id) {
        next.push(XuLocalStore.cloneAgenda(it))
      }
    }
    XuLocalStore.agendaMem = next
    await XuLocalStore.putString(KEY_AGENDA, XuLocalStore.serAgenda(next))
    XuLocalStore.notifyChanged()
  }

  static async findAgenda(id: string): Promise<XuAgendaItem | undefined> {
    await XuLocalStore.ensureReady()
    for (const it of XuLocalStore.agendaMem) {
      if (it.id === id) {
        return XuLocalStore.cloneAgenda(it)
      }
    }
    return undefined
  }

  static async agendaOnDate(dateKey: string): Promise<XuAgendaItem[]> {
    const list = await XuLocalStore.loadAgenda()
    const out: XuAgendaItem[] = []
    for (const it of list) {
      if (it.dateKey === dateKey) {
        out.push(it)
      }
    }
    out.sort((a, b) => a.timeText.localeCompare(b.timeText))
    return out
  }

  static async loadHabits(): Promise<XuHabitItem[]> {
    await XuLocalStore.ensureReady()
    const out: XuHabitItem[] = []
    for (const it of XuLocalStore.habitsMem) {
      out.push(XuLocalStore.cloneHabit(it))
    }
    return out
  }

  static async saveHabit(item: XuHabitItem): Promise<void> {
    await XuLocalStore.ensureReady()
    const next: XuHabitItem[] = []
    let found = false
    for (const it of XuLocalStore.habitsMem) {
      if (it.id === item.id) {
        next.push(XuLocalStore.cloneHabit(item))
        found = true
      } else {
        next.push(XuLocalStore.cloneHabit(it))
      }
    }
    if (!found) {
      next.push(XuLocalStore.cloneHabit(item))
    }
    XuLocalStore.habitsMem = next
    await XuLocalStore.putString(KEY_HABITS, XuLocalStore.serHabits(next))
    XuLocalStore.notifyChanged()
  }

  static async deleteHabit(id: string): Promise<void> {
    await XuLocalStore.ensureReady()
    const next: XuHabitItem[] = []
    for (const it of XuLocalStore.habitsMem) {
      if (it.id !== id) {
        next.push(XuLocalStore.cloneHabit(it))
      }
    }
    XuLocalStore.habitsMem = next
    await XuLocalStore.putString(KEY_HABITS, XuLocalStore.serHabits(next))
    XuLocalStore.notifyChanged()
  }

  static async findHabit(id: string): Promise<XuHabitItem | undefined> {
    await XuLocalStore.ensureReady()
    for (const it of XuLocalStore.habitsMem) {
      if (it.id === id) {
        return XuLocalStore.cloneHabit(it)
      }
    }
    return undefined
  }

  static async toggleHabit(id: string, todayKey: string): Promise<XuHabitItem | undefined> {
    await XuLocalStore.ensureReady()
    let target: XuHabitItem | undefined = undefined
    for (const it of XuLocalStore.habitsMem) {
      if (it.id === id) {
        target = it
        break
      }
    }
    if (target === undefined) {
      return undefined
    }
    if (target.lastCheck === todayKey) {
      target.lastCheck = ''
      if (target.streak > 0) {
        target.streak = target.streak - 1
      }
    } else {
      target.lastCheck = todayKey
      target.streak = target.streak + 1
    }
    await XuLocalStore.saveHabit(target)
    return XuLocalStore.cloneHabit(target)
  }

  static async loadNotes(): Promise<XuNoteItem[]> {
    await XuLocalStore.ensureReady()
    const out: XuNoteItem[] = []
    for (const it of XuLocalStore.notesMem) {
      out.push(XuLocalStore.cloneNote(it))
    }
    out.sort((a, b) => b.updatedAt - a.updatedAt)
    return out
  }

  static async saveNote(item: XuNoteItem): Promise<void> {
    await XuLocalStore.ensureReady()
    const next: XuNoteItem[] = []
    let found = false
    for (const it of XuLocalStore.notesMem) {
      if (it.id === item.id) {
        next.push(XuLocalStore.cloneNote(item))
        found = true
      } else {
        next.push(XuLocalStore.cloneNote(it))
      }
    }
    if (!found) {
      next.push(XuLocalStore.cloneNote(item))
    }
    XuLocalStore.notesMem = next
    await XuLocalStore.putString(KEY_NOTES, XuLocalStore.serNotes(next))
    XuLocalStore.notifyChanged()
  }

  static async deleteNote(id: string): Promise<void> {
    await XuLocalStore.ensureReady()
    const next: XuNoteItem[] = []
    for (const it of XuLocalStore.notesMem) {
      if (it.id !== id) {
        next.push(XuLocalStore.cloneNote(it))
      }
    }
    XuLocalStore.notesMem = next
    await XuLocalStore.putString(KEY_NOTES, XuLocalStore.serNotes(next))
    XuLocalStore.notifyChanged()
  }

  static async findNote(id: string): Promise<XuNoteItem | undefined> {
    await XuLocalStore.ensureReady()
    for (const it of XuLocalStore.notesMem) {
      if (it.id === id) {
        return XuLocalStore.cloneNote(it)
      }
    }
    return undefined
  }

  static async loadMoods(): Promise<XuMoodItem[]> {
    await XuLocalStore.ensureReady()
    const out: XuMoodItem[] = []
    for (const it of XuLocalStore.moodsMem) {
      const m = XuMoodItem.create(it.dateKey, it.mood, it.energy)
      m.updatedAt = it.updatedAt
      out.push(m)
    }
    return out
  }

  static async saveMood(item: XuMoodItem): Promise<void> {
    await XuLocalStore.ensureReady()
    const next: XuMoodItem[] = []
    let found = false
    for (const it of XuLocalStore.moodsMem) {
      if (it.dateKey === item.dateKey) {
        const m = XuMoodItem.create(item.dateKey, item.mood, item.energy)
        m.updatedAt = item.updatedAt
        next.push(m)
        found = true
      } else {
        const m = XuMoodItem.create(it.dateKey, it.mood, it.energy)
        m.updatedAt = it.updatedAt
        next.push(m)
      }
    }
    if (!found) {
      const m = XuMoodItem.create(item.dateKey, item.mood, item.energy)
      m.updatedAt = item.updatedAt
      next.push(m)
    }
    XuLocalStore.moodsMem = next
    await XuLocalStore.putString(KEY_MOOD, XuLocalStore.serMoods(next))
    XuLocalStore.notifyChanged()
  }

  static async todayMood(todayKey: string): Promise<XuMoodItem | undefined> {
    const list = await XuLocalStore.loadMoods()
    for (const it of list) {
      if (it.dateKey === todayKey) {
        return it
      }
    }
    return undefined
  }

  static async loadStats(): Promise<XuAppStats> {
    const s = new XuAppStats()
    await XuLocalStore.ensureReady()
    const today = XuDateHelper.todayKey()
    const habits = await XuLocalStore.loadHabits()
    let checkTotal = 0
    let todayCount = 0
    let maxStreak = 0
    for (const h of habits) {
      checkTotal += h.streak
      if (h.checkedToday(today)) {
        todayCount++
      }
      if (h.streak > maxStreak) {
        maxStreak = h.streak
      }
    }
    s.habitCheckTotal = checkTotal
    s.habitTodayCount = todayCount
    s.habitStreakDays = maxStreak
    const agenda = await XuLocalStore.loadAgenda()
    s.agendaTotal = agenda.length
    for (const a of agenda) {
      if (a.done) {
        s.agendaDone++
      }
    }
    const notes = await XuLocalStore.loadNotes()
    s.noteCount = notes.length
    const first = await XuLocalStore.getString(KEY_FIRST, '')
    if (first.length === 0) {
      await XuLocalStore.putString(KEY_FIRST, `${Date.now()}`)
      s.usedDays = 1
    } else {
      const start = parseInt(first, 10)
      const diff = Date.now() - start
      s.usedDays = Math.max(1, Math.floor(diff / 86400000) + 1)
    }
    return s
  }

  static async remindEnabled(): Promise<boolean> {
    const v = await XuLocalStore.getString(KEY_REMIND, '1')
    return v !== '0'
  }

  static async setRemindEnabled(on: boolean): Promise<void> {
    await XuLocalStore.putString(KEY_REMIND, on ? '1' : '0')
  }

  static async setColorMode(mode: string): Promise<void> {
    if (mode === 'dark') {
      await XuLocalStore.putString(KEY_DARK, '1')
      Theme.setColorMode('dark')
      Theme.setForcedDark(true)
    } else if (mode === 'system') {
      await XuLocalStore.putString(KEY_DARK, '2')
      Theme.setColorMode('system')
      Theme.setForcedDark(false)
    } else {
      await XuLocalStore.putString(KEY_DARK, '0')
      Theme.setColorMode('light')
      Theme.setForcedDark(false)
    }
    AppStorage.setOrCreate('xuThemeTick', Date.now())
  }

  static async colorMode(): Promise<string> {
    const v = await XuLocalStore.getString(KEY_DARK, '0')
    if (v === '1') {
      return 'dark'
    }
    if (v === '2') {
      return 'system'
    }
    return 'light'
  }

  static async clearCache(): Promise<void> {
    AppStorage.setOrCreate('localCacheEpoch', Date.now())
  }

  private static esc(s: string): string {
    return s.replace(/\t/g, ' ').replace(/\n/g, '\\n')
  }

  private static unesc(s: string): string {
    return s.replace(/\\n/g, '\n')
  }

  private static serAgenda(items: XuAgendaItem[]): string {
    const lines: string[] = []
    for (const it of items) {
      lines.push(`${it.id}\t${it.kind}\t${XuLocalStore.esc(it.title)}\t${XuLocalStore.esc(it.remark)}\t${it.dateKey}\t${it.timeText}\t${it.priority}\t${it.done ? '1' : '0'}\t${it.remindOn ? '1' : '0'}\t${it.createdAt}\t${it.updatedAt}`)
    }
    return lines.join('\n')
  }

  private static parseAgenda(raw: string): XuAgendaItem[] {
    const out: XuAgendaItem[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const trimmed = line.replace(/\r/g, '')
      if (trimmed.length === 0) {
        continue
      }
      const p = trimmed.split('\t')
      if (p.length < 11) {
        continue
      }
      const it = new XuAgendaItem()
      it.id = p[0]
      it.kind = p[1]
      it.title = XuLocalStore.unesc(p[2])
      it.remark = XuLocalStore.unesc(p[3])
      it.dateKey = p[4]
      it.timeText = p[5]
      it.priority = p[6]
      it.done = p[7] === '1'
      it.remindOn = p[8] === '1'
      it.createdAt = Number.parseInt(p[9], 10)
      it.updatedAt = Number.parseInt(p[10], 10)
      if (Number.isNaN(it.createdAt)) {
        it.createdAt = 0
      }
      if (Number.isNaN(it.updatedAt)) {
        it.updatedAt = 0
      }
      out.push(it)
    }
    return out
  }

  private static serHabits(items: XuHabitItem[]): string {
    const lines: string[] = []
    for (const it of items) {
      lines.push(`${it.id}\t${XuLocalStore.esc(it.title)}\t${XuLocalStore.esc(it.remark)}\t${it.streak}\t${it.lastCheck}\t${it.createdAt}`)
    }
    return lines.join('\n')
  }

  private static parseHabits(raw: string): XuHabitItem[] {
    const out: XuHabitItem[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const trimmed = line.replace(/\r/g, '')
      if (trimmed.length === 0) {
        continue
      }
      const p = trimmed.split('\t')
      if (p.length < 6) {
        continue
      }
      const h = XuHabitItem.create(XuLocalStore.unesc(p[1]), XuLocalStore.unesc(p[2]))
      h.id = p[0]
      h.streak = parseInt(p[3], 10)
      if (Number.isNaN(h.streak)) {
        h.streak = 0
      }
      h.lastCheck = p[4]
      h.createdAt = parseInt(p[5], 10)
      if (Number.isNaN(h.createdAt)) {
        h.createdAt = 0
      }
      out.push(h)
    }
    return out
  }

  private static serNotes(items: XuNoteItem[]): string {
    const lines: string[] = []
    for (const it of items) {
      lines.push(`${it.id}\t${XuLocalStore.esc(it.title)}\t${XuLocalStore.esc(it.body)}\t${it.tags}\t${it.createdAt}\t${it.updatedAt}`)
    }
    return lines.join('\n')
  }

  private static parseNotes(raw: string): XuNoteItem[] {
    const out: XuNoteItem[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const trimmed = line.replace(/\r/g, '')
      if (trimmed.length === 0) {
        continue
      }
      const p = trimmed.split('\t')
      if (p.length < 6) {
        continue
      }
      const n = XuNoteItem.create(XuLocalStore.unesc(p[1]), XuLocalStore.unesc(p[2]), p[3])
      n.id = p[0]
      n.createdAt = parseInt(p[4], 10)
      n.updatedAt = parseInt(p[5], 10)
      out.push(n)
    }
    return out
  }

  private static serMoods(items: XuMoodItem[]): string {
    const lines: string[] = []
    for (const it of items) {
      lines.push(`${it.dateKey}\t${it.mood}\t${it.energy}\t${it.updatedAt}`)
    }
    return lines.join('\n')
  }

  private static parseMoods(raw: string): XuMoodItem[] {
    const out: XuMoodItem[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const trimmed = line.replace(/\r/g, '')
      if (trimmed.length === 0) {
        continue
      }
      const p = trimmed.split('\t')
      if (p.length < 4) {
        continue
      }
      const m = XuMoodItem.create(p[0], p[1], parseInt(p[2], 10))
      m.updatedAt = parseInt(p[3], 10)
      out.push(m)
    }
    return out
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (XuLocalStore.pref === null) {
      return fallback
    }
    try {
      const v = await XuLocalStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (XuLocalStore.pref === null) {
      return
    }
    try {
      await XuLocalStore.pref.put(key, value)
      await XuLocalStore.pref.flush()
    } catch {
      // ignore
    }
  }
}
