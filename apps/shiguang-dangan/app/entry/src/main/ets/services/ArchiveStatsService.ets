import {
  ArchiveStats, MonthlyBar, ReviewSummary, TimelineNode
} from '../models/ArchiveModels'
import { DashboardSummary, AchievementDef, WeeklyActivityBar } from '../models/LifeModels'
import { DateHelper } from './DateHelper'
import { ArchiveStore } from './ArchiveStore'
import { LifeStore } from './LifeStore'
import { LifeStorePhase3 } from './LifeStorePhase3'
import { AchievementService } from './AchievementService'

export class ArchiveStatsService {
  static async computeStats(): Promise<ArchiveStats> {
    const stats = new ArchiveStats()
    const archives = await ArchiveStore.loadArchives()
    const nodes = await ArchiveStore.loadNodes()
    const categories = await ArchiveStore.loadCategories()
    stats.totalArchives = archives.length
    stats.totalNodes = nodes.length

    const catCount: Map<string, number> = new Map()
    for (const a of archives) {
      const prev = catCount.get(a.categoryKey) ?? 0
      catCount.set(a.categoryKey, prev + 1)
    }
    let topKey = ''
    let topVal = 0
    catCount.forEach((count: number, key: string) => {
      if (count > topVal) {
        topVal = count
        topKey = key
      }
    })
    stats.topCategory = topKey
    stats.topCategoryLabel = ArchiveStore.categoryLabel(categories, topKey)

    const yearCount: Map<string, number> = new Map()
    for (const n of nodes) {
      const y = DateHelper.yearFromKey(n.dateKey)
      if (y.length > 0) {
        const prev = yearCount.get(y) ?? 0
        yearCount.set(y, prev + 1)
      }
    }
    let richYear = ''
    let richCount = 0
    yearCount.forEach((count: number, year: string) => {
      if (count > richCount) {
        richCount = count
        richYear = year
      }
    })
    stats.richestYear = richYear
    stats.richestYearCount = richCount

    let pending = 0
    for (const a of archives) {
      if (a.status === 'pending') {
        pending++
      }
    }
    stats.pendingCount = pending

    stats.monthlyBars = ArchiveStatsService.buildMonthlyBars(nodes)

    if (archives.length > 0) {
      let sum = 0
      for (const a of archives) {
        let nodeCount = 0
        for (const n of nodes) {
          if (n.archiveId === a.id) {
            nodeCount++
          }
        }
        sum += ArchiveStore.completionPercent(a, nodeCount)
      }
      stats.completionAvg = Math.round(sum / archives.length)
    }

    return stats
  }

  static buildMonthlyBars(nodes: TimelineNode[]): MonthlyBar[] {
    const monthKeys = DateHelper.lastNMonths(6)
    monthKeys.reverse()
    const bars: MonthlyBar[] = []
    for (const mk of monthKeys) {
      let count = 0
      for (const n of nodes) {
        if (n.dateKey.startsWith(mk)) {
          count++
        }
      }
      const parts = mk.split('-')
      const label = parts.length >= 2 ? `${parseInt(parts[1], 10)}月` : mk
      bars.push(MonthlyBar.make(label, count))
    }
    return bars
  }

  static async buildReview(): Promise<ReviewSummary> {
    const stats = await ArchiveStatsService.computeStats()
    const archives = await ArchiveStore.loadArchives()
    const review = new ReviewSummary()
    review.title = '时光回顾'

    if (stats.totalArchives === 0) {
      review.body = '你还没有创建任何档案。从一份成长经历或家庭记忆开始，把重要时刻整理成可回顾的人生轨迹。'
      review.highlights = ['创建第一份档案', '添加关键时间节点', '用标签串联主题']
      return review
    }

    const parts: string[] = []
    parts.push(`你已整理 ${stats.totalArchives} 份档案、${stats.totalNodes} 个时间节点。`)
    if (stats.topCategoryLabel.length > 0) {
      parts.push(`最常记录的类别是「${stats.topCategoryLabel}」。`)
    }
    if (stats.richestYear.length > 0) {
      parts.push(`${stats.richestYear} 年留下了 ${stats.richestYearCount} 个节点，是你记录最丰富的一年。`)
    }
    if (stats.pendingCount > 0) {
      parts.push(`还有 ${stats.pendingCount} 份档案待完善，补全摘要将让回顾更完整。`)
    }
    parts.push(`档案平均完成度 ${stats.completionAvg}%。`)
    review.body = parts.join('')

    const highlights: string[] = []
    if (stats.richestYear.length > 0) {
      highlights.push(`${stats.richestYear} 年 · ${stats.richestYearCount} 个节点`)
    }
    if (stats.topCategoryLabel.length > 0) {
      highlights.push(`主题偏向 · ${stats.topCategoryLabel}`)
    }
    highlights.push(`完成度 · ${stats.completionAvg}%`)
    if (archives.length > 0) {
      highlights.push(`最近档案 · ${archives[0].title}`)
    }
    review.highlights = highlights
    return review
  }

  static async buildReviewToday(): Promise<ReviewSummary> {
    const review = new ReviewSummary()
    review.title = '今日回顾'
    const today = DateHelper.todayKey()
    const nodes = await ArchiveStore.nodesOnDate(today)
    const planProgress = await LifeStore.todayPlanProgress()
    const parts: string[] = []
    parts.push(`${DateHelper.displayDate(today)} · ${DateHelper.formatWeekday(new Date())}`)
    if (nodes.length > 0) {
      parts.push(`今天记录了 ${nodes.length} 个时间节点。`)
    } else {
      parts.push('今天还没有新的节点记录，不妨写下一件值得记住的事。')
    }
    if (planProgress.total > 0) {
      parts.push(`计划进度 ${planProgress.done}/${planProgress.total}。`)
    }
    review.body = parts.join('')
    const highlights: string[] = []
    for (let i = 0; i < nodes.length && i < 3; i++) {
      highlights.push(nodes[i].title)
    }
    if (highlights.length === 0) {
      highlights.push('写下今日时光')
    }
    review.highlights = highlights
    return review
  }

  static async buildReviewWeek(): Promise<ReviewSummary> {
    const review = new ReviewSummary()
    review.title = '本周回顾'
    const nodes = await ArchiveStore.loadNodes()
    const weekStart = DateHelper.daysAgoKey(6)
    const today = DateHelper.todayKey()
    let weekCount = 0
    for (const n of nodes) {
      if (n.dateKey >= weekStart && n.dateKey <= today) {
        weekCount++
      }
    }
    review.body = `近 7 天共记录 ${weekCount} 个时间节点。坚持整理，让回忆更有脉络。`
    const highlights: string[] = []
    highlights.push(`本周节点 · ${weekCount}`)
    const streak = await ArchiveStore.computeStreakDays()
    highlights.push(`连续记录 · ${streak} 天`)
    review.highlights = highlights
    return review
  }

  static async buildReviewMonth(): Promise<ReviewSummary> {
    const review = new ReviewSummary()
    review.title = '本月回顾'
    const nodes = await ArchiveStore.loadNodes()
    const mk = DateHelper.monthKey(new Date())
    let monthCount = 0
    for (const n of nodes) {
      if (n.dateKey.startsWith(mk)) {
        monthCount++
      }
    }
    const stats = await ArchiveStatsService.computeStats()
    review.body = `${DateHelper.displayMonthYear(new Date())}共 ${monthCount} 个节点，`
      + `累计 ${stats.totalArchives} 份档案。`
    review.highlights = [
      `本月节点 · ${monthCount}`,
      `档案总数 · ${stats.totalArchives}`,
      `平均完成度 · ${stats.completionAvg}%`
    ]
    return review
  }

  static async buildReviewYear(): Promise<ReviewSummary> {
    const review = new ReviewSummary()
    review.title = '年度回顾'
    const nodes = await ArchiveStore.loadNodes()
    const year = `${new Date().getFullYear()}`
    let yearCount = 0
    for (const n of nodes) {
      if (n.dateKey.startsWith(year)) {
        yearCount++
      }
    }
    const stats = await ArchiveStatsService.computeStats()
    const albums = await LifeStorePhase3.loadThemeAlbums()
    const checklist = await LifeStorePhase3.loadChecklist()
    let chkDone = 0
    for (const c of checklist) {
      if (c.status === 'done') {
        chkDone++
      }
    }
    review.body = `${year} 年共记录 ${yearCount} 个节点，`
      + `整理 ${stats.totalArchives} 份档案，`
      + `主题册 ${albums.length} 本，人生清单完成 ${chkDone} 项。`
    review.highlights = [
      `${year} 节点 · ${yearCount}`,
      `档案 · ${stats.totalArchives}`,
      `主题册 · ${albums.length}`,
      `清单完成 · ${chkDone}`
    ]
    return review
  }

  static async buildWeeklyActivityBars(): Promise<WeeklyActivityBar[]> {
    const bars: WeeklyActivityBar[] = []
    const allNodes = await ArchiveStore.loadNodes()
    const allArchives = await ArchiveStore.loadArchives()
    for (let i = 6; i >= 0; i--) {
      const dk = DateHelper.daysAgoKey(i)
      const d = new Date()
      d.setDate(d.getDate() - i)
      const label = DateHelper.weekdayShort(d)
      let nodeCnt = 0
      for (const n of allNodes) {
        if (n.dateKey === dk) {
          nodeCnt++
        }
      }
      let archiveCnt = 0
      for (const a of allArchives) {
        if (DateHelper.keyFromDate(new Date(a.createdAt)) === dk) {
          archiveCnt++
        }
      }
      const habits = await LifeStore.habitNamesOnDate(dk)
      const plansDone = await LifeStorePhase3.countPlanDoneOnDate(dk)
      bars.push(WeeklyActivityBar.make(label, nodeCnt + archiveCnt + habits.length + plansDone))
    }
    return bars
  }

  static async buildDashboardSummary(): Promise<DashboardSummary> {
    const dash = new DashboardSummary()
    dash.streakDays = await ArchiveStore.computeStreakDays()
    const planProgress = await LifeStore.todayPlanProgress()
    dash.todayPlanDone = planProgress.done
    dash.todayPlanTotal = planProgress.total
    dash.favoriteCount = await ArchiveStore.countFavorites()
    dash.achievementUnlocked = await AchievementService.unlockedCount()
    dash.achievementTotal = AchievementDef.catalog().length

    const today = new Date()
    const day = today.getDate()
    const month = today.getMonth() + 1
    const onThisDay = await ArchiveStore.nodesOnDayMonth(day, month)
    const pastNodes: TimelineNode[] = []
    const todayKey = DateHelper.todayKey()
    for (const n of onThisDay) {
      if (n.dateKey !== todayKey) {
        pastNodes.push(n)
      }
    }
    if (pastNodes.length > 0) {
      dash.onThisDayTitle = '往年今日'
      const first = pastNodes[0]
      dash.onThisDayBody = `${DateHelper.displayDate(first.dateKey)} · ${first.title}`
    } else {
      dash.onThisDayTitle = '往年今日'
      dash.onThisDayBody = '暂无往年同日的记录，开始写下第一个故事吧'
    }
    return dash
  }
}
