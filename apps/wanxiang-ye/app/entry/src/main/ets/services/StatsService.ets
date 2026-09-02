import { BarChartItem } from '../components/design-system/AppChart'
import { CategoryStat, DashboardStats } from '../models/UserKnowledgeModels'
import { UserDataStore } from './UserDataStore'
import { KnowledgeStore } from './KnowledgeStore'
import { SparkStore } from './SparkStore'
import { CheckInStore } from './CheckInStore'
import { ReviewStore } from './ReviewStore'
import { PlanStore } from './PlanStore'
import { KnowledgeCategory } from '../models/UserKnowledgeModels'
import { ReadingPlan } from '../models/UserKnowledgeModels'

export class StatsService {
  static async dashboard(): Promise<DashboardStats> {
    const s = new DashboardStats()
    s.readCount = await UserDataStore.getReadCount()
    s.favoriteCount = (await UserDataStore.getFavoriteIds()).length
    s.knowledgeCount = await KnowledgeStore.count()
    s.sparkCount = await SparkStore.count()
    s.streakDays = await CheckInStore.getStreakDays()
    s.reviewPending = await ReviewStore.pendingCount()
    s.todayRead = await CheckInStore.getTodayReadCount()
    const plan = await PlanStore.getActivePlan()
    s.planTarget = plan.targetCount
    s.planDone = plan.completedCount()
    s.planProgress = plan.progressPercent()
    return s
  }

  static async categoryBreakdown(): Promise<CategoryStat[]> {
    const list = await KnowledgeStore.listAll()
    const map: Map<string, number> = new Map()
    for (const item of list) {
      const key = item.categoryKey
      const prev = map.get(key)
      map.set(key, prev !== undefined ? prev + 1 : 1)
    }
    const out: CategoryStat[] = []
    for (const cat of KnowledgeCategory.all()) {
      const c = new CategoryStat()
      c.label = cat.label
      const cnt = map.get(cat.key)
      c.count = cnt !== undefined ? cnt : 0
      if (c.count > 0) {
        out.push(c)
      }
    }
    return out
  }

  static async weekReadBars(): Promise<BarChartItem[]> {
    const items: BarChartItem[] = []
    const labels: string[] = ['一', '二', '三', '四', '五', '六', '日']
    const dates = await CheckInStore.getDates()
    const now = new Date()
    const day = now.getDay()
    const diffToMon = day === 0 ? -6 : 1 - day
    const mon = new Date(now)
    mon.setDate(now.getDate() + diffToMon)
    for (let i = 0; i < 7; i++) {
      const d = new Date(mon)
      d.setDate(mon.getDate() + i)
      const key = ReadingPlan.dateKey(d)
      const item = new BarChartItem()
      item.label = labels[i]
      item.value = dates.indexOf(key) >= 0 ? 1 : 0
      items.push(item)
    }
    return items
  }
}
