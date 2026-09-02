import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  BundleWire,
  LocalBundle,
  RenoDates,
  RenoExpense,
  RenoInspect,
  RenoMaterial,
  RenoNote,
  RenoProject,
  RenoTask
} from '../models/RenoModels'

const STORE = 'reno_assist_local'
const KEY_BUNDLE = 'bundle'
const KEY_ONBOARD = 'onboardingDone'
const KEY_NOTIFY = 'notifyEnabled'

export class RenoLocalStore {
  private static pref: preferences.Preferences | null = null
  private static cache: LocalBundle = new LocalBundle()

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      RenoLocalStore.pref = await preferences.getPreferences(context, STORE)
      const rawValue = await RenoLocalStore.pref.get(KEY_BUNDLE, '')
      const raw: string = typeof rawValue === 'string' ? rawValue : ''
      RenoLocalStore.cache = RenoLocalStore.parseBundle(raw)
      await RenoLocalStore.purgeDemoRecords()
      const onboardValue = await RenoLocalStore.pref.get(KEY_ONBOARD, false)
      AppStorage.setOrCreate(KEY_ONBOARD, onboardValue === true)
      const notifyValue = await RenoLocalStore.pref.get(KEY_NOTIFY, true)
      AppStorage.setOrCreate(KEY_NOTIFY, notifyValue !== false)
    } catch {
      RenoLocalStore.cache = new LocalBundle()
      AppStorage.setOrCreate(KEY_ONBOARD, false)
      AppStorage.setOrCreate(KEY_NOTIFY, true)
    }
  }

  static snapshot(): LocalBundle {
    return RenoLocalStore.cache
  }

  static projects(): RenoProject[] {
    return RenoLocalStore.cache.projects
  }

  static tasks(): RenoTask[] {
    return RenoLocalStore.cache.tasks
  }

  static materials(): RenoMaterial[] {
    return RenoLocalStore.cache.materials
  }

  static notes(): RenoNote[] {
    return RenoLocalStore.cache.notes
  }

  static inspections(): RenoInspect[] {
    return RenoLocalStore.cache.inspections
  }

  static expenses(): RenoExpense[] {
    return RenoLocalStore.cache.expenses
  }

  static currentId(): string {
    return RenoLocalStore.cache.currentId
  }

  static async setCurrent(id: string): Promise<void> {
    RenoLocalStore.cache.currentId = id
    await RenoLocalStore.persist()
  }

  static async persist(): Promise<void> {
    const wire = new BundleWire()
    wire.projects = RenoLocalStore.cache.projects
    wire.tasks = RenoLocalStore.cache.tasks
    wire.materials = RenoLocalStore.cache.materials
    wire.notes = RenoLocalStore.cache.notes
    wire.inspections = RenoLocalStore.cache.inspections
    wire.expenses = RenoLocalStore.cache.expenses
    wire.currentId = RenoLocalStore.cache.currentId
    await RenoLocalStore.putString(KEY_BUNDLE, JSON.stringify(wire))
  }

  static async setOnboardingDone(): Promise<void> {
    AppStorage.setOrCreate(KEY_ONBOARD, true)
    await RenoLocalStore.putBool(KEY_ONBOARD, true)
  }

  static async setNotifyEnabled(enabled: boolean): Promise<void> {
    AppStorage.setOrCreate(KEY_NOTIFY, enabled)
    await RenoLocalStore.putBool(KEY_NOTIFY, enabled)
  }

  static nowIso(): string {
    return new Date().toISOString()
  }

  static newId(prefix: string): string {
    return `${prefix}_${Date.now()}`
  }

  static async replaceAll(next: LocalBundle): Promise<void> {
    RenoLocalStore.cache = next
    await RenoLocalStore.persist()
    RenoLocalStore.bumpRev()
  }

  static async clearAll(): Promise<void> {
    RenoLocalStore.cache = new LocalBundle()
    await RenoLocalStore.persist()
    RenoLocalStore.bumpRev()
  }

  static bumpRev(): void {
    const n = (AppStorage.get<number>('renoRev') ?? 0) + 1
    AppStorage.setOrCreate('renoRev', n)
  }

  static async seedWelcomeSamples(): Promise<void> {
    return
  }

  static async purgeDemoRecords(): Promise<void> {
    const dropIds: string[] = []
    const keptProjects: RenoProject[] = []
    for (const row of RenoLocalStore.cache.projects) {
      if (row.isSample || row.id.indexOf('sample_') === 0 || row.title.indexOf('云栖雅苑') >= 0) {
        dropIds.push(row.id)
      } else {
        keptProjects.push(row)
      }
    }
    if (dropIds.length === 0) {
      return
    }
    const next = new LocalBundle()
    next.projects = keptProjects
    const tasks: RenoTask[] = []
    for (const row of RenoLocalStore.cache.tasks) {
      if (!RenoLocalStore.inDrop(row.projectId, row.id, dropIds)) {
        tasks.push(row)
      }
    }
    next.tasks = tasks
    const materials: RenoMaterial[] = []
    for (const row of RenoLocalStore.cache.materials) {
      if (!RenoLocalStore.inDrop(row.projectId, row.id, dropIds)) {
        materials.push(row)
      }
    }
    next.materials = materials
    const notes: RenoNote[] = []
    for (const row of RenoLocalStore.cache.notes) {
      if (!RenoLocalStore.inDrop(row.projectId, row.id, dropIds)) {
        notes.push(row)
      }
    }
    next.notes = notes
    const inspections: RenoInspect[] = []
    for (const row of RenoLocalStore.cache.inspections) {
      if (!RenoLocalStore.inDrop(row.projectId, row.id, dropIds)) {
        inspections.push(row)
      }
    }
    next.inspections = inspections
    const expenses: RenoExpense[] = []
    for (const row of RenoLocalStore.cache.expenses) {
      if (!RenoLocalStore.inDrop(row.projectId, row.id, dropIds)) {
        expenses.push(row)
      }
    }
    next.expenses = expenses
    next.currentId = ''
    for (const row of keptProjects) {
      if (row.id === RenoLocalStore.cache.currentId) {
        next.currentId = row.id
      }
    }
    if (next.currentId.length === 0 && keptProjects.length > 0) {
      next.currentId = keptProjects[0].id
    }
    await RenoLocalStore.replaceAll(next)
  }

  private static inDrop(projectId: string, id: string, dropIds: string[]): boolean {
    if (id.indexOf('sample_') === 0) {
      return true
    }
    for (const drop of dropIds) {
      if (projectId === drop) {
        return true
      }
    }
    return false
  }

  static mapProject(raw: RenoProject): RenoProject {
    const row = new RenoProject()
    row.id = raw.id ?? ''
    row.title = raw.title ?? ''
    row.houseType = raw.houseType ?? '三室两厅'
    row.startDate = raw.startDate ?? ''
    row.stage = raw.stage ?? '拆改'
    row.progress = raw.progress ?? 0
    row.budget = raw.budget ?? ''
    row.remark = raw.remark ?? ''
    row.status = raw.status ?? 'active'
    row.userId = raw.userId ?? 'local'
    row.updatedAt = raw.updatedAt ?? ''
    row.isSample = raw.isSample === true
    return row
  }

  static mapTask(raw: RenoTask): RenoTask {
    const row = new RenoTask()
    row.id = raw.id ?? ''
    row.title = raw.title ?? ''
    row.stage = raw.stage ?? ''
    row.status = raw.status ?? 'todo'
    row.remindAt = raw.remindAt ?? ''
    row.remark = raw.remark ?? ''
    row.projectId = raw.projectId ?? ''
    row.date = raw.date ?? ''
    row.userId = raw.userId ?? 'local'
    row.updatedAt = raw.updatedAt ?? ''
    return row
  }

  static mapMaterial(raw: RenoMaterial): RenoMaterial {
    const row = new RenoMaterial()
    row.id = raw.id ?? ''
    row.title = raw.title ?? ''
    row.brand = raw.brand ?? ''
    row.model = raw.model ?? ''
    row.spec = raw.spec ?? ''
    row.qty = raw.qty ?? ''
    row.room = raw.room ?? ''
    row.status = raw.status ?? 'pending'
    row.remark = raw.remark ?? ''
    row.projectId = raw.projectId ?? ''
    row.userId = raw.userId ?? 'local'
    row.updatedAt = raw.updatedAt ?? ''
    return row
  }

  static mapNote(raw: RenoNote): RenoNote {
    const row = new RenoNote()
    row.id = raw.id ?? ''
    row.title = raw.title ?? ''
    row.body = raw.body ?? ''
    row.kind = raw.kind ?? '普通记录'
    row.date = raw.date ?? ''
    row.stage = raw.stage ?? ''
    row.photoUri = raw.photoUri ?? ''
    row.remark = raw.remark ?? ''
    row.projectId = raw.projectId ?? ''
    row.userId = raw.userId ?? 'local'
    row.updatedAt = raw.updatedAt ?? ''
    return row
  }

  static mapInspect(raw: RenoInspect): RenoInspect {
    const row = new RenoInspect()
    row.id = raw.id ?? ''
    row.title = raw.title ?? ''
    row.category = raw.category ?? ''
    row.result = raw.result ?? 'pending'
    row.remark = raw.remark ?? ''
    row.itemKey = raw.itemKey ?? ''
    row.projectId = raw.projectId ?? ''
    row.userId = raw.userId ?? 'local'
    row.coverKey = raw.coverKey ?? ''
    row.body = raw.body ?? ''
    row.updatedAt = raw.updatedAt ?? ''
    return row
  }

  static mapExpense(raw: RenoExpense): RenoExpense {
    const row = new RenoExpense()
    row.id = raw.id ?? ''
    row.title = raw.title ?? ''
    row.amount = raw.amount ?? ''
    row.category = raw.category ?? '材料'
    row.date = raw.date ?? ''
    row.remark = raw.remark ?? ''
    row.projectId = raw.projectId ?? ''
    row.userId = raw.userId ?? 'local'
    row.updatedAt = raw.updatedAt ?? ''
    return row
  }

  private static parseBundle(raw: string): LocalBundle {
    const empty = new LocalBundle()
    if (raw.length === 0) {
      return empty
    }
    try {
      const parsed = JSON.parse(raw) as BundleWire
      const out = new LocalBundle()
      out.currentId = parsed.currentId ?? ''
      if (parsed.projects !== undefined) {
        const mapped: RenoProject[] = []
        for (const row of parsed.projects) {
          mapped.push(RenoLocalStore.mapProject(row))
        }
        out.projects = mapped
      }
      if (parsed.tasks !== undefined) {
        const mapped: RenoTask[] = []
        for (const row of parsed.tasks) {
          mapped.push(RenoLocalStore.mapTask(row))
        }
        out.tasks = mapped
      }
      if (parsed.materials !== undefined) {
        const mapped: RenoMaterial[] = []
        for (const row of parsed.materials) {
          mapped.push(RenoLocalStore.mapMaterial(row))
        }
        out.materials = mapped
      }
      if (parsed.notes !== undefined) {
        const mapped: RenoNote[] = []
        for (const row of parsed.notes) {
          mapped.push(RenoLocalStore.mapNote(row))
        }
        out.notes = mapped
      }
      if (parsed.inspections !== undefined) {
        const mapped: RenoInspect[] = []
        for (const row of parsed.inspections) {
          mapped.push(RenoLocalStore.mapInspect(row))
        }
        out.inspections = mapped
      }
      if (parsed.expenses !== undefined) {
        const mapped: RenoExpense[] = []
        for (const row of parsed.expenses) {
          mapped.push(RenoLocalStore.mapExpense(row))
        }
        out.expenses = mapped
      }
      return out
    } catch {
      return empty
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (RenoLocalStore.pref === null) {
      return
    }
    try {
      await RenoLocalStore.pref.put(key, value)
      await RenoLocalStore.pref.flush()
    } catch {
    }
  }

  private static async putBool(key: string, value: boolean): Promise<void> {
    if (RenoLocalStore.pref === null) {
      return
    }
    try {
      await RenoLocalStore.pref.put(key, value)
      await RenoLocalStore.pref.flush()
    } catch {
    }
  }
}
