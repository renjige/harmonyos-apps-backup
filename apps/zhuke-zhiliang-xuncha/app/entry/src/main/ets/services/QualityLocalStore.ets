import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  InspectionItem,
  InspectionRecord,
  IssueRecord,
  LocalBundle,
  NoticeItem,
  ProjectItem,
  QualityStats,
  QualityDates,
  RectifyRecord,
  UserProfile
} from '../models/QualityModels'

const STORE = 'site_quality_local'
const KEY_BUNDLE = 'bundle'
const KEY_NOTIFY = 'notifyEnabled'

export class QualityLocalStore {
  private static pref: preferences.Preferences | null = null
  private static cache: LocalBundle = new LocalBundle()

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      QualityLocalStore.pref = await preferences.getPreferences(context, STORE)
      const rawValue = await QualityLocalStore.pref.get(KEY_BUNDLE, '')
      const raw: string = typeof rawValue === 'string' ? rawValue : ''
      QualityLocalStore.cache = QualityLocalStore.parseBundle(raw)
      if (QualityLocalStore.stripLegacySamples(QualityLocalStore.cache)) {
        await QualityLocalStore.persist()
      }
      const notifyValue = await QualityLocalStore.pref.get(KEY_NOTIFY, true)
      AppStorage.setOrCreate(KEY_NOTIFY, notifyValue !== false)
    } catch {
      QualityLocalStore.cache = new LocalBundle()
      AppStorage.setOrCreate(KEY_NOTIFY, true)
    }
  }

  static snapshot(): LocalBundle {
    return QualityLocalStore.cache
  }

  static async persist(): Promise<void> {
    if (QualityLocalStore.pref === null) {
      return
    }
    try {
      await QualityLocalStore.pref.put(KEY_BUNDLE, JSON.stringify(QualityLocalStore.cache))
      await QualityLocalStore.pref.flush()
    } catch {
    }
  }

  static async setNotifyEnabled(enabled: boolean): Promise<void> {
    AppStorage.setOrCreate(KEY_NOTIFY, enabled)
    if (QualityLocalStore.pref === null) {
      return
    }
    try {
      await QualityLocalStore.pref.put(KEY_NOTIFY, enabled)
      await QualityLocalStore.pref.flush()
    } catch {
    }
  }

  static async saveProfile(profile: UserProfile): Promise<void> {
    QualityLocalStore.cache.profile = profile
    await QualityLocalStore.persist()
  }

  static async saveAll(bundle: LocalBundle): Promise<void> {
    QualityLocalStore.cache = bundle
    await QualityLocalStore.persist()
  }

  static newId(prefix: string): string {
    return `${prefix}_${Date.now()}`
  }

  static nowIso(): string {
    const d = new Date()
    return `${d.getFullYear()}-${QualityDates.pad(d.getMonth() + 1)}-${QualityDates.pad(d.getDate())}T${QualityDates.pad(d.getHours())}:${QualityDates.pad(d.getMinutes())}:${QualityDates.pad(d.getSeconds())}`
  }

  static stats(): QualityStats {
    const today = QualityDates.today()
    const month = QualityDates.monthPrefix()
    const s = new QualityStats()
    for (const row of QualityLocalStore.cache.inspections) {
      if (row.inspectDate === today) {
        s.todayInspect += 1
      }
      if (row.inspectDate.indexOf(month) === 0) {
        s.monthInspect += 1
      }
    }
    for (const row of QualityLocalStore.cache.issues) {
      const foundDay = row.foundAt.length >= 10 ? row.foundAt.substring(0, 10) : ''
      if (foundDay === today) {
        s.foundToday += 1
      }
      if (row.status === '整改中') {
        s.rectifying += 1
      }
      if (row.status === '已完成') {
        s.closed += 1
      }
      if (foundDay.indexOf(month) === 0) {
        s.monthFound += 1
      }
      if (row.status === '已完成' && foundDay.indexOf(month) === 0) {
        s.monthClosed += 1
      }
    }
    return s
  }

  static projectIssueCount(projectId: string, status: string): number {
    let n = 0
    for (const row of QualityLocalStore.cache.issues) {
      if (row.projectId === projectId && (status.length === 0 || row.status === status)) {
        n += 1
      }
    }
    return n
  }

  static parseItems(json: string): InspectionItem[] {
    const out: InspectionItem[] = []
    if (json.length === 0) {
      return out
    }
    try {
      const parsed = JSON.parse(json) as InspectionItem[]
      for (const row of parsed) {
        const item = new InspectionItem()
        item.id = row.id ?? ''
        item.title = row.title ?? ''
        item.status = row.status ?? 'ok'
        out.push(item)
      }
    } catch {
    }
    return out
  }

  static stringifyItems(items: InspectionItem[]): string {
    return JSON.stringify(items)
  }

  static parsePhotos(json: string): string[] {
    const out: string[] = []
    if (json.length === 0) {
      return out
    }
    try {
      const parsed = JSON.parse(json) as string[]
      for (const row of parsed) {
        if (row.length > 0) {
          out.push(row)
        }
      }
    } catch {
    }
    return out
  }

  private static isLegacyDemoProject(row: ProjectItem): boolean {
    return row.isSample || row.id.indexOf('sq_proj_') === 0 || row.summary.indexOf('示例数据') >= 0
  }

  private static isLegacyDemoInspection(row: InspectionRecord): boolean {
    return row.isSample || row.id.indexOf('ins_') === 0
  }

  private static isLegacyDemoIssue(row: IssueRecord): boolean {
    return row.isSample || row.id.indexOf('iss_') === 0 || row.description.indexOf('示例数据') >= 0
  }

  private static stripLegacySamples(bundle: LocalBundle): boolean {
    let changed = false
    const projects: ProjectItem[] = []
    for (const row of bundle.projects) {
      if (!QualityLocalStore.isLegacyDemoProject(row)) {
        projects.push(row)
      } else {
        changed = true
      }
    }
    const inspections: InspectionRecord[] = []
    for (const row of bundle.inspections) {
      if (!QualityLocalStore.isLegacyDemoInspection(row)) {
        inspections.push(row)
      } else {
        changed = true
      }
    }
    const issues: IssueRecord[] = []
    const issueIds: string[] = []
    for (const row of bundle.issues) {
      if (!QualityLocalStore.isLegacyDemoIssue(row)) {
        issues.push(row)
      } else {
        changed = true
        issueIds.push(row.id)
      }
    }
    const rectifies: RectifyRecord[] = []
    for (const row of bundle.rectifies) {
      let drop = false
      for (const id of issueIds) {
        if (row.issueId === id) {
          drop = true
          break
        }
      }
      if (!drop) {
        rectifies.push(row)
      } else {
        changed = true
      }
    }
    const notices: NoticeItem[] = []
    for (const row of bundle.notices) {
      if (row.title.indexOf('示例') >= 0) {
        changed = true
      } else {
        notices.push(row)
      }
    }
    if (!changed) {
      return false
    }
    bundle.projects = projects
    bundle.inspections = inspections
    bundle.issues = issues
    bundle.rectifies = rectifies
    bundle.notices = notices
    return true
  }

  private static parseBundle(raw: string): LocalBundle {
    if (raw.length === 0) {
      return new LocalBundle()
    }
    try {
      const parsed = JSON.parse(raw) as LocalBundle
      const out = new LocalBundle()
      if (parsed.projects !== undefined) {
        out.projects = parsed.projects
      }
      if (parsed.inspections !== undefined) {
        out.inspections = parsed.inspections
      }
      if (parsed.issues !== undefined) {
        out.issues = parsed.issues
      }
      if (parsed.rectifies !== undefined) {
        out.rectifies = parsed.rectifies
      }
      if (parsed.notices !== undefined) {
        out.notices = parsed.notices
      }
      if (parsed.profile !== undefined) {
        const p = new UserProfile()
        p.displayName = parsed.profile.displayName ?? p.displayName
        p.roleTitle = parsed.profile.roleTitle ?? p.roleTitle
        out.profile = p
      }
      return out
    } catch {
      return new LocalBundle()
    }
  }
}
