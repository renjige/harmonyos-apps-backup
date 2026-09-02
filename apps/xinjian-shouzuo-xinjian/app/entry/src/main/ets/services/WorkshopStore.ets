import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'

const TAG = 'WorkshopStore'
const STORE_NAME = 'workshop_local'
const KEY_COSTS = 'wsCosts'
const KEY_CHECKLIST = 'wsChecklist'
const KEY_ELAPSED = 'wsElapsedSec'
const KEY_RUNNING = 'wsTimerRunning'
const KEY_TIMER_BASE = 'wsTimerBase'
const KEY_CM_TEXT = 'wsCmText'

export class CostItem {
  id: string = ''
  name: string = ''
  amountFen: number = 0
}

export class ChecklistItem {
  id: string = ''
  text: string = ''
  done: boolean = false
}

/** 工坊本地工具（Preferences 持久化，杀进程后仍保留） */
export class WorkshopStore {
  private static pref: preferences.Preferences | null = null
  private static ready: boolean = false

  static isReady(): boolean {
    return WorkshopStore.ready
  }

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      WorkshopStore.pref = await preferences.getPreferences(context, STORE_NAME)
      const costsValue = await WorkshopStore.pref.get(KEY_COSTS, '')
      const checklistValue = await WorkshopStore.pref.get(KEY_CHECKLIST, '')
      const elapsedValue = await WorkshopStore.pref.get(KEY_ELAPSED, 0)
      const runningValue = await WorkshopStore.pref.get(KEY_RUNNING, false)
      const baseValue = await WorkshopStore.pref.get(KEY_TIMER_BASE, 0)
      const cmValue = await WorkshopStore.pref.get(KEY_CM_TEXT, '15')
      AppStorage.setOrCreate(KEY_COSTS, typeof costsValue === 'string' ? costsValue : '')
      AppStorage.setOrCreate(KEY_CHECKLIST, typeof checklistValue === 'string' ? checklistValue : '')
      AppStorage.setOrCreate(KEY_ELAPSED, typeof elapsedValue === 'number' ? elapsedValue : 0)
      AppStorage.setOrCreate(KEY_RUNNING, runningValue === true)
      AppStorage.setOrCreate(KEY_TIMER_BASE, typeof baseValue === 'number' ? baseValue : 0)
      AppStorage.setOrCreate(KEY_CM_TEXT, typeof cmValue === 'string' && cmValue.length > 0 ? cmValue : '15')
      WorkshopStore.ready = true
      hilog.info(0x0000, TAG, 'workshop data restored')
    } catch {
      AppStorage.setOrCreate(KEY_COSTS, '')
      AppStorage.setOrCreate(KEY_CHECKLIST, '')
      AppStorage.setOrCreate(KEY_ELAPSED, 0)
      AppStorage.setOrCreate(KEY_RUNNING, false)
      AppStorage.setOrCreate(KEY_TIMER_BASE, 0)
      AppStorage.setOrCreate(KEY_CM_TEXT, '15')
      WorkshopStore.ready = true
      hilog.error(0x0000, TAG, 'workshop init failed, using defaults')
    }
  }

  private static async persistString(key: string, value: string): Promise<void> {
    AppStorage.setOrCreate(key, value)
    if (WorkshopStore.pref === null) {
      return
    }
    await WorkshopStore.pref.put(key, value)
    await WorkshopStore.pref.flush()
  }

  private static async persistNumber(key: string, value: number): Promise<void> {
    AppStorage.setOrCreate(key, value)
    if (WorkshopStore.pref === null) {
      return
    }
    await WorkshopStore.pref.put(key, value)
    await WorkshopStore.pref.flush()
  }

  private static async persistBool(key: string, value: boolean): Promise<void> {
    AppStorage.setOrCreate(key, value)
    if (WorkshopStore.pref === null) {
      return
    }
    await WorkshopStore.pref.put(key, value)
    await WorkshopStore.pref.flush()
  }

  static timerRunning(): boolean {
    return AppStorage.get<boolean>(KEY_RUNNING) === true
  }

  static elapsedSec(): number {
    const v = AppStorage.get<number>(KEY_ELAPSED)
    return v !== undefined && v !== null ? v : 0
  }

  static cmText(): string {
    const v = AppStorage.get<string>(KEY_CM_TEXT)
    return v !== undefined && v !== null && v.length > 0 ? v : '15'
  }

  static async saveCmText(text: string): Promise<void> {
    await WorkshopStore.persistString(KEY_CM_TEXT, text)
  }

  static async startOrResume(): Promise<void> {
    const elapsed = WorkshopStore.elapsedSec()
    await WorkshopStore.persistBool(KEY_RUNNING, true)
    await WorkshopStore.persistNumber(KEY_TIMER_BASE, Date.now() - elapsed * 1000)
  }

  static async pause(): Promise<void> {
    const sec = WorkshopStore.tickSync()
    await WorkshopStore.persistNumber(KEY_ELAPSED, sec)
    await WorkshopStore.persistBool(KEY_RUNNING, false)
  }

  static async reset(): Promise<void> {
    await WorkshopStore.persistBool(KEY_RUNNING, false)
    await WorkshopStore.persistNumber(KEY_ELAPSED, 0)
    await WorkshopStore.persistNumber(KEY_TIMER_BASE, 0)
  }

  static tickSync(): number {
    if (!WorkshopStore.timerRunning()) {
      return WorkshopStore.elapsedSec()
    }
    const base = AppStorage.get<number>(KEY_TIMER_BASE) ?? Date.now()
    const sec = Math.floor((Date.now() - base) / 1000)
    AppStorage.setOrCreate(KEY_ELAPSED, sec)
    return sec
  }

  static async tick(): Promise<number> {
    const sec = WorkshopStore.tickSync()
    if (WorkshopStore.timerRunning()) {
      await WorkshopStore.persistNumber(KEY_ELAPSED, sec)
    }
    return sec
  }

  static format(sec: number): string {
    const h = Math.floor(sec / 3600)
    const m = Math.floor((sec % 3600) / 60)
    const s = sec % 60
    const hh = h < 10 ? `0${h}` : `${h}`
    const mm = m < 10 ? `0${m}` : `${m}`
    const ss = s < 10 ? `0${s}` : `${s}`
    return `${hh}:${mm}:${ss}`
  }

  static costs(): CostItem[] {
    const raw = AppStorage.get<string>(KEY_COSTS) ?? ''
    if (raw.length === 0) {
      return []
    }
    const rows = raw.split('\n')
    const out: CostItem[] = []
    for (const row of rows) {
      const parts = row.split('|')
      if (parts.length < 3) {
        continue
      }
      const item = new CostItem()
      item.id = parts[0]
      item.name = parts[1]
      const parsed = parseInt(parts[2])
      item.amountFen = parsed === parsed ? parsed : 0
      out.push(item)
    }
    return out
  }

  static async saveCosts(items: CostItem[]): Promise<void> {
    const lines: string[] = []
    for (const item of items) {
      lines.push(`${item.id}|${item.name}|${item.amountFen}`)
    }
    await WorkshopStore.persistString(KEY_COSTS, lines.join('\n'))
  }

  static totalFen(items: CostItem[]): number {
    let sum = 0
    for (const item of items) {
      sum += item.amountFen
    }
    return sum
  }

  static yuanLabel(fen: number): string {
    const y = Math.floor(fen / 100)
    const f = fen % 100
    const ff = f < 10 ? `0${f}` : `${f}`
    return `${y}.${ff} 元`
  }

  static checklist(): ChecklistItem[] {
    const raw = AppStorage.get<string>(KEY_CHECKLIST) ?? ''
    if (raw.length === 0) {
      return []
    }
    const rows = raw.split('\n')
    const out: ChecklistItem[] = []
    for (const row of rows) {
      const parts = row.split('|')
      if (parts.length < 3) {
        continue
      }
      const item = new ChecklistItem()
      item.id = parts[0]
      item.text = parts[1]
      item.done = parts[2] === '1'
      out.push(item)
    }
    return out
  }

  static async saveChecklist(items: ChecklistItem[]): Promise<void> {
    const lines: string[] = []
    for (const item of items) {
      lines.push(`${item.id}|${item.text}|${item.done ? '1' : '0'}`)
    }
    await WorkshopStore.persistString(KEY_CHECKLIST, lines.join('\n'))
  }

  static parseCmInput(text: string): number {
    const trimmed = text.trim()
    if (trimmed.length === 0) {
      return 0
    }
    let num = parseFloat(trimmed)
    if (num !== num || num <= 0) {
      num = parseInt(trimmed)
    }
    if (num !== num || num <= 0) {
      return 0
    }
    return num
  }
}
