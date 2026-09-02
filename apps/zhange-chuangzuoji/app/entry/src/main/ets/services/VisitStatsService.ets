import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'

const STORE = 'zhange_stats_v1'
const KEY_VISITS = 'visit_count'
const KEY_DETAIL_VIEWS = 'detail_view_count'

export class VisitStatsService {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      VisitStatsService.pref = await preferences.getPreferences(context, STORE)
    } catch {
      VisitStatsService.pref = null
    }
  }

  static async recordVisit(): Promise<void> {
    const n = await VisitStatsService.getCount()
    await VisitStatsService.putCount(n + 1)
  }

  static async recordDetailView(): Promise<void> {
    const n = await VisitStatsService.getDetailViewCount()
    await VisitStatsService.putDetailViewCount(n + 1)
  }

  static async getDetailViewCount(): Promise<number> {
    if (VisitStatsService.pref === null) {
      return 0
    }
    try {
      const v = await VisitStatsService.pref.get(KEY_DETAIL_VIEWS, 0)
      return typeof v === 'number' ? v : parseInt(`${v}`, 10)
    } catch {
      return 0
    }
  }

  static async getCount(): Promise<number> {
    if (VisitStatsService.pref === null) {
      return 0
    }
    try {
      const v = await VisitStatsService.pref.get(KEY_VISITS, 0)
      return typeof v === 'number' ? v : parseInt(`${v}`, 10)
    } catch {
      return 0
    }
  }

  private static async putCount(n: number): Promise<void> {
    await VisitStatsService.putNumber(KEY_VISITS, n)
  }

  private static async putDetailViewCount(n: number): Promise<void> {
    await VisitStatsService.putNumber(KEY_DETAIL_VIEWS, n)
  }

  private static async putNumber(key: string, n: number): Promise<void> {
    if (VisitStatsService.pref === null) {
      return
    }
    try {
      await VisitStatsService.pref.put(key, n)
      await VisitStatsService.pref.flush()
    } catch {
      // ignore
    }
  }
}
