import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { DiagnoseReport } from '../models/DiagnoseModels'

const STORE_KEY = 'last_diagnose_report_v1'

/** JSON 持久化结构 */
class DiagnoseReportSnapshot {
  title: string = ''
  summary: string = ''
  strength: string = ''
  weakness: string = ''
  opportunity: string = ''
  threat: string = ''
  actions: string[] = []
  matchCategory: string = ''
  matchHint: string = ''
  scoreLabel: string = ''
  generatedAt: string = ''
}

/** 最近一次训练配比问卷报告（本地持久化） */
export class DiagnoseReportStore {
  private static pref: preferences.Preferences | null = null
  private static cached: DiagnoseReport | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      DiagnoseReportStore.pref = await preferences.getPreferences(context, 'sport_ui_cache_v1')
      const raw = await DiagnoseReportStore.pref.get(STORE_KEY, '')
      const text = typeof raw === 'string' ? raw : ''
      DiagnoseReportStore.cached = DiagnoseReportStore.parse(text)
      DiagnoseReportStore.syncAppStorage()
    } catch {
      DiagnoseReportStore.cached = null
    }
  }

  static latest(): DiagnoseReport | null {
    return DiagnoseReportStore.cached
  }

  static hasReport(): boolean {
    return DiagnoseReportStore.cached !== null && DiagnoseReportStore.cached.summary.length > 0
  }

  static async save(report: DiagnoseReport): Promise<void> {
    DiagnoseReportStore.cached = report
    DiagnoseReportStore.syncAppStorage()
    if (DiagnoseReportStore.pref === null) {
      return
    }
    await DiagnoseReportStore.pref.put(STORE_KEY, JSON.stringify(DiagnoseReportStore.serialize(report)))
    await DiagnoseReportStore.pref.flush()
  }

  private static syncAppStorage(): void {
    const r = DiagnoseReportStore.cached
    if (r === null) {
      AppStorage.setOrCreate('lastDiagnoseCategory', '')
      AppStorage.setOrCreate('lastDiagnoseScore', '')
      AppStorage.setOrCreate('lastDiagnoseAt', '')
    } else {
      AppStorage.setOrCreate('lastDiagnoseCategory', r.matchCategory)
      AppStorage.setOrCreate('lastDiagnoseScore', r.scoreLabel)
      AppStorage.setOrCreate('lastDiagnoseAt', r.generatedAt)
    }
    const epoch = (AppStorage.get<number>('diagnoseReportEpoch') ?? 0) + 1
    AppStorage.setOrCreate('diagnoseReportEpoch', epoch)
  }

  private static serialize(r: DiagnoseReport): DiagnoseReportSnapshot {
    const snap = new DiagnoseReportSnapshot()
    snap.title = r.title
    snap.summary = r.summary
    snap.strength = r.strength
    snap.weakness = r.weakness
    snap.opportunity = r.opportunity
    snap.threat = r.threat
    snap.actions = r.actions
    snap.matchCategory = r.matchCategory
    snap.matchHint = r.matchHint
    snap.scoreLabel = r.scoreLabel
    snap.generatedAt = r.generatedAt
    return snap
  }

  private static parse(text: string): DiagnoseReport | null {
    if (text.length === 0) {
      return null
    }
    try {
      const o = JSON.parse(text) as Record<string, string | string[]>
      const r = new DiagnoseReport()
      r.title = typeof o['title'] === 'string' ? o['title'] : '训练配比复盘'
      r.summary = typeof o['summary'] === 'string' ? o['summary'] : ''
      r.strength = typeof o['strength'] === 'string' ? o['strength'] : ''
      r.weakness = typeof o['weakness'] === 'string' ? o['weakness'] : ''
      r.opportunity = typeof o['opportunity'] === 'string' ? o['opportunity'] : ''
      r.threat = typeof o['threat'] === 'string' ? o['threat'] : ''
      r.matchCategory = typeof o['matchCategory'] === 'string' ? o['matchCategory'] : ''
      r.matchHint = typeof o['matchHint'] === 'string' ? o['matchHint'] : ''
      r.scoreLabel = typeof o['scoreLabel'] === 'string' ? o['scoreLabel'] : ''
      r.generatedAt = typeof o['generatedAt'] === 'string' ? o['generatedAt'] : ''
      const actionsRaw = o['actions']
      if (Array.isArray(actionsRaw)) {
        for (const line of actionsRaw) {
          if (typeof line === 'string') {
            r.actions.push(line)
          }
        }
      }
      return r.summary.length > 0 ? r : null
    } catch {
      return null
    }
  }
}
