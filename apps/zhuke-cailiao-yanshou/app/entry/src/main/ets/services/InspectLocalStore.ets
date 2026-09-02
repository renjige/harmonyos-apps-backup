import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { InspectRecord, InspectStats, InspectWire, PhotoList } from '../models/InspectModels'
import { Theme } from '../components/design-system/Theme'
import { ThemeAppearance } from './ThemeAppearance'

const STORE = 'zhuke_inspect_local'
const KEY_RECORDS = 'records'
const KEY_ONBOARD = 'onboardingDone'
const KEY_NOTIFY = 'notifyEnabled'
const KEY_APPEARANCE = 'appearance'
const KEY_DEFAULT_CAT = 'defaultCategory'
const KEY_DEFAULT_UNIT = 'defaultUnit'
const KEY_DEFAULT_PROJECT = 'defaultProject'

export class InspectLocalStore {
  private static pref: preferences.Preferences | null = null
  private static cache: InspectRecord[] = []

  static async init(context: common.Context): Promise<void> {
    try {
      InspectLocalStore.pref = await preferences.getPreferences(context, STORE)
      const rawValue = await InspectLocalStore.pref.get(KEY_RECORDS, '')
      const raw: string = typeof rawValue === 'string' ? rawValue : ''
      InspectLocalStore.cache = InspectLocalStore.parseRecords(raw)
      InspectLocalStore.publishHomeStats()
      const onboardValue = await InspectLocalStore.pref.get(KEY_ONBOARD, false)
      AppStorage.setOrCreate(KEY_ONBOARD, onboardValue === true)
      const notifyValue = await InspectLocalStore.pref.get(KEY_NOTIFY, true)
      AppStorage.setOrCreate(KEY_NOTIFY, notifyValue !== false)
      const appearValue = await InspectLocalStore.pref.get(KEY_APPEARANCE, 'system')
      const appear: string = typeof appearValue === 'string' ? appearValue : 'system'
      AppStorage.setOrCreate(KEY_APPEARANCE, appear)
      InspectLocalStore.applyAppearance(appear)
      const mode = appear === 'light' || appear === 'dark' ? appear : 'system'
      AppStorage.setOrCreate('colorMode', mode)
      const catValue = await InspectLocalStore.pref.get(KEY_DEFAULT_CAT, '瓷砖')
      const cat: string = typeof catValue === 'string' && catValue.length > 0 ? catValue : '瓷砖'
      AppStorage.setOrCreate(KEY_DEFAULT_CAT, cat)
      const unitValue = await InspectLocalStore.pref.get(KEY_DEFAULT_UNIT, '箱')
      const unit: string = typeof unitValue === 'string' && unitValue.length > 0 ? unitValue : '箱'
      AppStorage.setOrCreate(KEY_DEFAULT_UNIT, unit)
      const projectValue = await InspectLocalStore.pref.get(KEY_DEFAULT_PROJECT, '')
      const project: string = typeof projectValue === 'string' ? projectValue : ''
      AppStorage.setOrCreate(KEY_DEFAULT_PROJECT, project)
    } catch {
      InspectLocalStore.cache = []
      AppStorage.setOrCreate(KEY_ONBOARD, false)
      AppStorage.setOrCreate(KEY_NOTIFY, true)
      AppStorage.setOrCreate(KEY_APPEARANCE, 'system')
      AppStorage.setOrCreate(KEY_DEFAULT_CAT, '瓷砖')
      AppStorage.setOrCreate(KEY_DEFAULT_UNIT, '箱')
      AppStorage.setOrCreate(KEY_DEFAULT_PROJECT, '')
    }
  }

  static records(): InspectRecord[] {
    const out: InspectRecord[] = []
    for (const row of InspectLocalStore.cache) {
      out.push(InspectLocalStore.clone(row))
    }
    return out
  }

  static findById(id: string): InspectRecord | null {
    for (const row of InspectLocalStore.cache) {
      if (row.id === id) {
        return InspectLocalStore.clone(row)
      }
    }
    return null
  }

  static async save(row: InspectRecord): Promise<InspectRecord> {
    const now = InspectLocalStore.nowStamp()
    const copy = InspectLocalStore.clone(row)
    if (copy.id.length === 0) {
      copy.id = `ma_${Date.now()}`
      copy.createdAt = now
    }
    copy.updatedAt = now
    const next: InspectRecord[] = []
    let replaced = false
    for (const item of InspectLocalStore.cache) {
      if (item.id === copy.id) {
        next.push(copy)
        replaced = true
      } else {
        next.push(item)
      }
    }
    if (!replaced) {
      next.unshift(copy)
    }
    InspectLocalStore.cache = next
    await InspectLocalStore.persist()
    InspectLocalStore.bumpTick()
    return InspectLocalStore.clone(copy)
  }

  static async remove(id: string): Promise<boolean> {
    const next: InspectRecord[] = []
    let found = false
    for (const item of InspectLocalStore.cache) {
      if (item.id === id) {
        found = true
      } else {
        next.push(item)
      }
    }
    if (!found) {
      return false
    }
    InspectLocalStore.cache = next
    await InspectLocalStore.persist()
    InspectLocalStore.bumpTick()
    return true
  }

  static async clearAll(): Promise<void> {
    InspectLocalStore.cache = []
    await InspectLocalStore.persist()
    InspectLocalStore.bumpTick()
  }

  static async setOnboardingDone(): Promise<void> {
    AppStorage.setOrCreate(KEY_ONBOARD, true)
    await InspectLocalStore.putBool(KEY_ONBOARD, true)
  }

  static async setNotifyEnabled(value: boolean): Promise<void> {
    AppStorage.setOrCreate(KEY_NOTIFY, value)
    await InspectLocalStore.putBool(KEY_NOTIFY, value)
  }

  static async setAppearance(value: string): Promise<void> {
    AppStorage.setOrCreate(KEY_APPEARANCE, value)
    const mode = value === 'light' || value === 'dark' ? value : 'system'
    AppStorage.setOrCreate('colorMode', mode)
    InspectLocalStore.applyAppearance(value)
    ThemeAppearance.bumpEpoch()
    InspectLocalStore.bumpTick()
    const tick = AppStorage.get<number>('inspectTick')
    AppStorage.setOrCreate('colorModeTick', tick !== undefined ? tick : 1)
    await InspectLocalStore.putString(KEY_APPEARANCE, value)
  }

  static async setDefaultCategory(value: string): Promise<void> {
    AppStorage.setOrCreate(KEY_DEFAULT_CAT, value)
    await InspectLocalStore.putString(KEY_DEFAULT_CAT, value)
  }

  static async setDefaultUnit(value: string): Promise<void> {
    AppStorage.setOrCreate(KEY_DEFAULT_UNIT, value)
    await InspectLocalStore.putString(KEY_DEFAULT_UNIT, value)
  }

  static async setDefaultProject(value: string): Promise<void> {
    AppStorage.setOrCreate(KEY_DEFAULT_PROJECT, value)
    await InspectLocalStore.putString(KEY_DEFAULT_PROJECT, value)
  }

  static stats(): InspectStats {
    const s = new InspectStats()
    const today = InspectLocalStore.today()
    const month = today.slice(0, 7)
    for (const row of InspectLocalStore.cache) {
      s.allTotal += 1
      const day = row.createdAt.slice(0, 10)
      const ym = row.createdAt.slice(0, 7)
      if (row.result === 'pass') {
        s.allPass += 1
      } else if (row.result === 'fail') {
        s.allFail += 1
      } else {
        s.allPending += 1
      }
      if (day === today || row.arrivalDate === today) {
        s.todayTotal += 1
        if (row.result === 'pass') {
          s.todayDone += 1
        } else if (row.result === 'fail') {
          s.todayFail += 1
        } else {
          s.todayPending += 1
        }
      }
      if (ym === month) {
        s.monthTotal += 1
        if (row.result === 'pass') {
          s.monthPass += 1
        } else if (row.result === 'fail') {
          s.monthFail += 1
        } else {
          s.monthPending += 1
        }
      }
    }
    if (s.monthTotal > 0) {
      s.passRate = Math.round((s.monthPass * 100) / s.monthTotal)
    }
    return s
  }

  static today(): string {
    return InspectLocalStore.formatDay(new Date())
  }

  static formatDay(d: Date): string {
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms: string = m < 10 ? `0${m}` : `${m}`
    const ds: string = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${ms}-${ds}`
  }

  static displayTime(iso: string): string {
    if (iso.length < 16) {
      return iso
    }
    const month = iso.slice(5, 7)
    const day = iso.slice(8, 10)
    const hm = iso.slice(11, 16)
    return `${month}月${day}日 ${hm}`
  }

  static photosOf(row: InspectRecord): string[] {
    return PhotoList.split(row.photosCsv)
  }

  private static applyAppearance(value: string): void {
    const sysDark = AppStorage.get<boolean>('systemIsDark') === true
    if (value === 'dark') {
      Theme.setColorMode('dark')
      Theme.setForcedDark(true)
    } else if (value === 'light') {
      Theme.setColorMode('light')
      Theme.setForcedDark(false)
    } else {
      Theme.setColorMode('system')
      Theme.setForcedDark(sysDark)
    }
  }

  private static async persist(): Promise<void> {
    await InspectLocalStore.putString(KEY_RECORDS, InspectLocalStore.encodeCache())
  }

  private static encodeCache(): string {
    let json = '{"records":['
    const rows = InspectLocalStore.cache
    for (let i = 0; i < rows.length; i++) {
      if (i > 0) {
        json += ','
      }
      json += InspectLocalStore.encodeRow(rows[i])
    }
    json += ']}'
    return json
  }

  private static encodeRow(row: InspectRecord): string {
    return `{"id":${JSON.stringify(row.id)},"materialName":${JSON.stringify(row.materialName)},"category":${JSON.stringify(row.category)},"spec":${JSON.stringify(row.spec)},"quantity":${JSON.stringify(row.quantity)},"unit":${JSON.stringify(row.unit)},"supplier":${JSON.stringify(row.supplier)},"arrivalDate":${JSON.stringify(row.arrivalDate)},"checkAppearance":${JSON.stringify(row.checkAppearance)},"checkPacking":${JSON.stringify(row.checkPacking)},"checkQty":${JSON.stringify(row.checkQty)},"checkDocs":${JSON.stringify(row.checkDocs)},"result":${JSON.stringify(row.result)},"photosCsv":${JSON.stringify(row.photosCsv)},"remark":${JSON.stringify(row.remark)},"projectName":${JSON.stringify(row.projectName)},"batchNo":${JSON.stringify(row.batchNo)},"extraA":${JSON.stringify(row.extraA)},"extraB":${JSON.stringify(row.extraB)},"followUpNote":${JSON.stringify(row.followUpNote)},"followUpDone":${JSON.stringify(row.followUpDone)},"parentId":${JSON.stringify(row.parentId)},"createdAt":${JSON.stringify(row.createdAt)},"updatedAt":${JSON.stringify(row.updatedAt)}}`
  }

  static bumpTick(): void {
    const prev = AppStorage.get<number>('inspectTick')
    const n: number = prev !== undefined ? prev + 1 : 1
    AppStorage.setOrCreate('inspectTick', n)
    InspectLocalStore.publishHomeStats()
  }

  static publishHomeStats(): void {
    const s = InspectLocalStore.stats()
    AppStorage.setOrCreate('homeTodayTotal', s.todayTotal)
    AppStorage.setOrCreate('homeTodayDone', s.todayDone)
    AppStorage.setOrCreate('homeTodayPending', s.todayPending)
    let follow = 0
    for (const row of InspectLocalStore.cache) {
      if ((row.result === 'fail' || row.result === 'pending') && row.followUpDone !== '1') {
        follow += 1
      }
    }
    AppStorage.setOrCreate('homeFollowCount', follow)
  }

  static nowStamp(): string {
    const d = new Date()
    const hh = d.getHours()
    const mm = d.getMinutes()
    const ss = d.getSeconds()
    const hs: string = hh < 10 ? `0${hh}` : `${hh}`
    const ms: string = mm < 10 ? `0${mm}` : `${mm}`
    const sds: string = ss < 10 ? `0${ss}` : `${ss}`
    return `${InspectLocalStore.formatDay(d)}T${hs}:${ms}:${sds}`
  }

  private static parseRecords(raw: string): InspectRecord[] {
    if (raw.length === 0) {
      return []
    }
    try {
      const parsed = JSON.parse(raw) as InspectWire
      const out: InspectRecord[] = []
      if (parsed.records !== undefined) {
        for (const row of parsed.records) {
          out.push(InspectLocalStore.clone(row))
        }
      }
      return out
    } catch {
      return []
    }
  }

  static clone(row: InspectRecord): InspectRecord {
    const out = new InspectRecord()
    out.id = row.id ?? ''
    out.materialName = row.materialName ?? ''
    out.category = row.category ?? '其他'
    out.spec = row.spec ?? ''
    out.quantity = row.quantity ?? ''
    out.unit = row.unit ?? '箱'
    out.supplier = row.supplier ?? ''
    out.arrivalDate = row.arrivalDate ?? ''
    out.checkAppearance = row.checkAppearance ?? 'ok'
    out.checkPacking = row.checkPacking ?? 'ok'
    out.checkQty = row.checkQty ?? 'match'
    out.checkDocs = row.checkDocs ?? 'complete'
    out.result = row.result ?? ''
    out.photosCsv = row.photosCsv ?? ''
    out.remark = row.remark ?? ''
    out.projectName = row.projectName ?? ''
    out.batchNo = row.batchNo ?? ''
    out.extraA = row.extraA ?? 'ok'
    out.extraB = row.extraB ?? 'ok'
    out.followUpNote = row.followUpNote ?? ''
    out.followUpDone = row.followUpDone ?? ''
    out.parentId = row.parentId ?? ''
    out.createdAt = row.createdAt ?? ''
    out.updatedAt = row.updatedAt ?? ''
    return out
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (InspectLocalStore.pref === null) {
      return
    }
    try {
      await InspectLocalStore.pref.put(key, value)
      await InspectLocalStore.pref.flush()
    } catch {
    }
  }

  private static async putBool(key: string, value: boolean): Promise<void> {
    if (InspectLocalStore.pref === null) {
      return
    }
    try {
      await InspectLocalStore.pref.put(key, value)
      await InspectLocalStore.pref.flush()
    } catch {
    }
  }
}
