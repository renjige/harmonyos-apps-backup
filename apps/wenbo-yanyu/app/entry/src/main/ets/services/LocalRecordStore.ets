import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  LocalStats,
  PolishRecord,
  SummaryRecord
} from '../models/LanguageCraftModels'
import { AppRefresh } from './AppRefresh'
import { AppStoreContext } from './AppStoreContext'

class PolishRecordFile {
  items: PolishRecord[] = []
}

class SummaryRecordFile {
  items: SummaryRecord[] = []
}

/** 润色 / 摘要历史 — Preferences 本机存储 */
export class LocalRecordStore {
  private static readonly STORE: string = 'yanyu_records'
  private static readonly KEY_POLISH: string = 'polish_items'
  private static readonly KEY_SUMMARY: string = 'summary_items'
  private static readonly POLISH_MAX: number = 20
  private static prefs: preferences.Preferences | null = null

  static async init(context: common.Context): Promise<void> {
    AppStoreContext.bind(context)
    if (LocalRecordStore.prefs !== null) {
      return
    }
    LocalRecordStore.prefs = await preferences.getPreferences(context, LocalRecordStore.STORE)
  }

  private static async ensureReady(): Promise<boolean> {
    if (LocalRecordStore.prefs !== null) {
      return true
    }
    const ctx = AppStoreContext.get()
    if (ctx === null) {
      return false
    }
    try {
      LocalRecordStore.prefs = await preferences.getPreferences(ctx, LocalRecordStore.STORE)
      return LocalRecordStore.prefs !== null
    } catch {
      return false
    }
  }

  static async addPolish(record: PolishRecord): Promise<void> {
    const file = await LocalRecordStore.readPolishFile()
    const filtered: PolishRecord[] = []
    for (const row of file.items) {
      if (row.id !== record.id) {
        filtered.push(row)
      }
    }
    filtered.unshift(record)
    const trimmed: PolishRecord[] = []
    for (let i = 0; i < filtered.length && i < LocalRecordStore.POLISH_MAX; i++) {
      trimmed.push(filtered[i])
    }
    file.items = trimmed
    await LocalRecordStore.writePolishFile(file)
    AppRefresh.bumpRecord()
  }

  static async addSummary(record: SummaryRecord): Promise<void> {
    const file = await LocalRecordStore.readSummaryFile()
    const filtered: SummaryRecord[] = []
    for (const row of file.items) {
      if (row.id !== record.id) {
        filtered.push(row)
      }
    }
    filtered.unshift(record)
    file.items = filtered
    await LocalRecordStore.writeSummaryFile(file)
    AppRefresh.bumpRecord()
  }

  static async listPolish(): Promise<PolishRecord[]> {
    const file = await LocalRecordStore.readPolishFile()
    return file.items
  }

  static async listSummary(): Promise<SummaryRecord[]> {
    const file = await LocalRecordStore.readSummaryFile()
    return file.items
  }

  static async removePolish(id: string): Promise<void> {
    const file = await LocalRecordStore.readPolishFile()
    const next: PolishRecord[] = []
    for (const row of file.items) {
      if (row.id !== id) {
        next.push(row)
      }
    }
    file.items = next
    await LocalRecordStore.writePolishFile(file)
    AppRefresh.bumpRecord()
  }

  static async removeSummary(id: string): Promise<void> {
    const file = await LocalRecordStore.readSummaryFile()
    const next: SummaryRecord[] = []
    for (const row of file.items) {
      if (row.id !== id) {
        next.push(row)
      }
    }
    file.items = next
    await LocalRecordStore.writeSummaryFile(file)
    AppRefresh.bumpRecord()
  }

  static async stats(): Promise<LocalStats> {
    const polish = await LocalRecordStore.listPolish()
    const summary = await LocalRecordStore.listSummary()
    const s = new LocalStats()
    s.polishCount = polish.length
    s.summaryCount = summary.length
    return s
  }

  static newId(prefix: string): string {
    return `${prefix}_${Date.now()}`
  }

  static nowLabel(): string {
    const d = new Date()
    const y = d.getFullYear()
    const mo = d.getMonth() + 1
    const day = d.getDate()
    const h = d.getHours()
    const mi = d.getMinutes()
    const moStr = mo < 10 ? `0${mo}` : `${mo}`
    const dayStr = day < 10 ? `0${day}` : `${day}`
    const hStr = h < 10 ? `0${h}` : `${h}`
    const miStr = mi < 10 ? `0${mi}` : `${mi}`
    return `${y}-${moStr}-${dayStr} ${hStr}:${miStr}`
  }

  private static async readPolishFile(): Promise<PolishRecordFile> {
    const file = new PolishRecordFile()
    const ready = await LocalRecordStore.ensureReady()
    if (!ready || LocalRecordStore.prefs === null) {
      return file
    }
    const text = await LocalRecordStore.prefs.get(LocalRecordStore.KEY_POLISH, '[]') as string
    try {
      const parsed = JSON.parse(text) as PolishRecord[]
      if (Array.isArray(parsed)) {
        file.items = parsed
      }
    } catch {
      file.items = []
    }
    return file
  }

  private static async writePolishFile(file: PolishRecordFile): Promise<void> {
    const ready = await LocalRecordStore.ensureReady()
    if (!ready || LocalRecordStore.prefs === null) {
      return
    }
    await LocalRecordStore.prefs.put(LocalRecordStore.KEY_POLISH, JSON.stringify(file.items))
    await LocalRecordStore.prefs.flush()
  }

  private static async readSummaryFile(): Promise<SummaryRecordFile> {
    const file = new SummaryRecordFile()
    const ready = await LocalRecordStore.ensureReady()
    if (!ready || LocalRecordStore.prefs === null) {
      return file
    }
    const text = await LocalRecordStore.prefs.get(LocalRecordStore.KEY_SUMMARY, '[]') as string
    try {
      const parsed = JSON.parse(text) as SummaryRecord[]
      if (Array.isArray(parsed)) {
        file.items = parsed
      }
    } catch {
      file.items = []
    }
    return file
  }

  private static async writeSummaryFile(file: SummaryRecordFile): Promise<void> {
    const ready = await LocalRecordStore.ensureReady()
    if (!ready || LocalRecordStore.prefs === null) {
      return
    }
    await LocalRecordStore.prefs.put(LocalRecordStore.KEY_SUMMARY, JSON.stringify(file.items))
    await LocalRecordStore.prefs.flush()
  }
}
