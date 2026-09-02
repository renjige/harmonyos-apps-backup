import { BarChartItem } from '../components/design-system/AppChart'
import {
  CraftAchievement,
  CraftDashboardStats,
  CraftTimelineEvent
} from '../models/CraftLocalModels'
import { HandcraftWork, HandcraftInspiration } from '../models/HandcraftModels'
import { HandcraftBizService, WorkListFilter } from './HandcraftBizService'
import { CraftLocalStore } from './CraftLocalStore'
import { CraftPlan } from '../models/CraftLocalModels'

export class CraftStatsService {
  static async loadDashboard(username: string): Promise<CraftDashboardStats> {
    const stats = new CraftDashboardStats()
    stats.streakDays = CraftLocalStore.streakDays()
    stats.todayCheckedIn = CraftLocalStore.hasCheckInToday()
    const plans = CraftLocalStore.plans()
    let done = 0
    let total = 0
    for (const plan of plans) {
      total += plan.tasks.length
      done += plan.completedCount()
    }
    stats.planDone = done
    stats.planTotal = total
    if (username.length === 0) {
      return stats
    }
    const filter = new WorkListFilter()
    filter.userId = username
    const works = await HandcraftBizService.loadWorks(filter)
    const inspirations = await HandcraftBizService.loadInspirations(true)
    const favorites = await HandcraftBizService.loadFavorites()
    stats.workCount = works.length
    stats.inspirationCount = inspirations.length
    stats.favoriteCount = favorites.length
    await CraftStatsService.evaluateAchievements(stats)
    return stats
  }

  static activePlan(): CraftPlan | undefined {
    const plans = CraftLocalStore.plans()
    if (plans.length === 0) {
      return undefined
    }
    return plans[0]
  }

  static async timeline(username: string, limit: number): Promise<CraftTimelineEvent[]> {
    const out: CraftTimelineEvent[] = []
    for (const c of CraftLocalStore.checkIns()) {
      const e = new CraftTimelineEvent()
      e.id = `ci_${c.date}`
      e.kind = '打卡'
      e.title = c.note.length > 0 ? c.note : '今日创作打卡'
      e.at = c.date
      e.refId = c.date
      out.push(e)
    }
    if (username.length > 0) {
      const filter = new WorkListFilter()
      filter.userId = username
      const works = await HandcraftBizService.loadWorks(filter)
      for (const w of works) {
        const e = new CraftTimelineEvent()
        e.id = `w_${w.id}`
        e.kind = '作品'
        e.title = w.title
        e.at = w.createdAt.length > 10 ? w.createdAt.slice(0, 10) : CraftLocalStore.todayLabel()
        e.refId = w.id
        out.push(e)
      }
      const insList = await HandcraftBizService.loadInspirations(true)
      for (const ins of insList) {
        const e = new CraftTimelineEvent()
        e.id = `i_${ins.id}`
        e.kind = '灵感'
        e.title = ins.title
        e.at = ins.createdAt.length > 10 ? ins.createdAt.slice(0, 10) : CraftLocalStore.todayLabel()
        e.refId = ins.id
        out.push(e)
      }
    }
    out.sort((a, b) => (a.at < b.at ? 1 : -1))
    const limited: CraftTimelineEvent[] = []
    const max = out.length < limit ? out.length : limit
    for (let i = 0; i < max; i++) {
      limited.push(out[i])
    }
    return limited
  }

  static async weekBarItems(username: string): Promise<BarChartItem[]> {
    const items: BarChartItem[] = []
    const labels = ['一', '二', '三', '四', '五', '六', '日']
    const counts: number[] = [0, 0, 0, 0, 0, 0, 0]
    if (username.length > 0) {
      const filter = new WorkListFilter()
      filter.userId = username
      const works = await HandcraftBizService.loadWorks(filter)
      for (const w of works) {
        if (w.createdAt.length < 10) {
          continue
        }
        const d = new Date(w.createdAt.slice(0, 10))
        const dow = d.getDay()
        const idx = dow === 0 ? 6 : dow - 1
        counts[idx] += 1
      }
    }
    for (let i = 0; i < 7; i++) {
      const item = new BarChartItem()
      item.label = labels[i]
      item.value = counts[i]
      items.push(item)
    }
    return items
  }

  static achievements(stats: CraftDashboardStats): CraftAchievement[] {
    const unlocked = CraftLocalStore.unlockedAchievementIds()
    const defs: CraftAchievement[] = []
    const a1 = new CraftAchievement()
    a1.id = 'first_work'
    a1.title = '初次记录'
    a1.summary = '完成第一件作品记录'
    a1.unlocked = unlocked.includes(a1.id)
    defs.push(a1)
    const a2 = new CraftAchievement()
    a2.id = 'works_3'
    a2.title = '创作达人'
    a2.summary = '累计记录 3 件作品'
    a2.unlocked = unlocked.includes(a2.id)
    defs.push(a2)
    const a3 = new CraftAchievement()
    a3.id = 'works_10'
    a3.title = '心笺匠人'
    a3.summary = '累计记录 10 件作品'
    a3.unlocked = unlocked.includes(a3.id)
    defs.push(a3)
    const a4 = new CraftAchievement()
    a4.id = 'streak_7'
    a4.title = '连续一周'
    a4.summary = '连续打卡 7 天'
    a4.unlocked = unlocked.includes(a4.id)
    defs.push(a4)
    const a5 = new CraftAchievement()
    a5.id = 'favorites_5'
    a5.title = '收藏达人'
    a5.summary = '收藏 5 篇课堂教程'
    a5.unlocked = unlocked.includes(a5.id)
    defs.push(a5)
    const a6 = new CraftAchievement()
    a6.id = 'checkin_first'
    a6.title = '今日开工'
    a6.summary = '完成首次创作打卡'
    a6.unlocked = unlocked.includes(a6.id)
    defs.push(a6)
    return defs
  }

  static async evaluateAchievements(stats: CraftDashboardStats): Promise<void> {
    if (stats.workCount >= 1) {
      await CraftLocalStore.unlockAchievement('first_work')
    }
    if (stats.workCount >= 3) {
      await CraftLocalStore.unlockAchievement('works_3')
    }
    if (stats.workCount >= 10) {
      await CraftLocalStore.unlockAchievement('works_10')
    }
    if (stats.streakDays >= 7) {
      await CraftLocalStore.unlockAchievement('streak_7')
    }
    if (stats.favoriteCount >= 5) {
      await CraftLocalStore.unlockAchievement('favorites_5')
    }
    if (stats.todayCheckedIn || CraftLocalStore.checkIns().length > 0) {
      await CraftLocalStore.unlockAchievement('checkin_first')
    }
  }

  static weekReviewText(username: string, stats: CraftDashboardStats): string {
    const lines: string[] = []
    lines.push('【手作心笺 · 本周回顾】')
    lines.push(`作品 ${stats.workCount} 件 · 灵感 ${stats.inspirationCount} 条 · 收藏 ${stats.favoriteCount} 篇`)
    lines.push(`创作打卡连续 ${stats.streakDays} 天`)
    if (stats.planTotal > 0) {
      lines.push(`计划进度 ${stats.planDone}/${stats.planTotal}`)
    }
    if (username.length === 0) {
      lines.push('登录后可同步云端作品与灵感数据')
    }
    return lines.join('\n')
  }
}
