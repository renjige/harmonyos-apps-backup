import { AdvancedFilter, WorkbenchStats } from '../models/GrowthModels'
import { InsightEntry } from '../models/InsightModels'
import { DateHelper } from './DateHelper'
import { GrowthStore } from './GrowthStore'
import { InsightStore } from './InsightStore'

export class WorkbenchService {
  static async loadStats(): Promise<WorkbenchStats> {
    const s = new WorkbenchStats()
    const all = await InsightStore.loadAll()
    s.total = all.length
    const stars = await InsightStore.starred()
    s.starCount = stars.length
    s.streak = await InsightStore.streakDays()
    const plan = await GrowthStore.syncPlanFromEntries()
    s.planDone = plan.doneCount()
    s.planTotal = 3
    s.checkedIn = await GrowthStore.isCheckedInToday()
    const today = DateHelper.todayKey()
    const keys = DateHelper.lastNDays(7)
    let weekWrite = 0
    let todayWritten = false
    let pending = 0
    let judged = 0
    let hit = 0
    for (const n of all) {
      for (const k of keys) {
        if (n.dateKey === k) {
          weekWrite++
        }
      }
      if (n.dateKey === today) {
        todayWritten = true
      }
      if (n.verdict === 'pending' || (n.frameKind === 'judge' && n.verdict.length === 0)) {
        pending++
      }
      if (n.verdict === 'hit' || n.verdict === 'miss' || n.verdict === 'revised') {
        judged++
        if (n.verdict === 'hit') {
          hit++
        }
      }
    }
    s.weekWrite = weekWrite
    s.todayWritten = todayWritten
    s.pendingJudge = pending
    s.hitRate = judged > 0 ? Math.round((hit / judged) * 100) : 0
    const ach = await GrowthStore.unlockedIds()
    s.achievementCount = ach.length
    return s
  }

  static async filterEntries(f: AdvancedFilter): Promise<InsightEntry[]> {
    let list = await InsightStore.loadAll()
    if (f.keyword.trim().length > 0) {
      list = await InsightStore.search(f.keyword.trim())
    }
    const out: InsightEntry[] = []
    for (const n of list) {
      if (f.starredOnly && !n.starred) {
        continue
      }
      if (f.frameKind.length > 0 && n.frameKind !== f.frameKind) {
        continue
      }
      if (f.notebookId.length > 0 && n.notebookId !== f.notebookId) {
        continue
      }
      if (f.monthKey.length > 0 && DateHelper.monthKey(n.dateKey) !== f.monthKey) {
        continue
      }
      if (f.verdict.length > 0 && n.verdict !== f.verdict) {
        continue
      }
      out.push(n)
    }
    return out
  }

  static async favoritesBundle(): Promise<InsightEntry[]> {
    const all = await InsightStore.loadAll()
    const out: InsightEntry[] = []
    for (const n of all) {
      if (n.starred || n.pinned) {
        out.push(n)
      }
    }
    const quotes = await InsightStore.quotes()
    for (const q of quotes) {
      let dup = false
      for (const x of out) {
        if (x.id === q.id) {
          dup = true
        }
      }
      if (!dup) {
        out.push(q)
      }
    }
    const pending = await InsightStore.judgments()
    for (const j of pending) {
      if (j.verdict === 'pending' || j.verdict.length === 0) {
        let dup = false
        for (const x of out) {
          if (x.id === j.id) {
            dup = true
          }
        }
        if (!dup) {
          out.push(j)
        }
      }
    }
    return out
  }
}
