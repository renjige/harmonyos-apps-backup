import {
  AchievementDef,
  AchievementState,
  AchievementProgress,
  DimensionOption,
  DimensionStat,
  MonthReport,
  TrendPoint,
  VitalityRecord,
  WeekCompare,
  DashboardStats,
  YearReport,
  TodayProgress,
  VitalityPlan,
  PrescriptionStats
} from '../models/VitalityModels'
import { DateHelper } from './DateHelper'
import { VitalityStore } from './VitalityStore'
import { PrescriptionService } from './PrescriptionService'

export class StatsService {
  static async streakDays(): Promise<number> {
    let streak = 0
    const cursor = new Date()
    const todayKey = DateHelper.todayKey()
    const todayRec = await VitalityStore.recordForDate(todayKey)
    if (todayRec === undefined || !todayRec.isComplete()) {
      cursor.setDate(cursor.getDate() - 1)
    }
    for (let i = 0; i < 366; i++) {
      const k = DateHelper.keyFromDate(cursor)
      const r = await VitalityStore.recordForDate(k)
      if (r !== undefined && r.isComplete()) {
        streak++
        cursor.setDate(cursor.getDate() - 1)
      } else {
        break
      }
    }
    return streak
  }

  static async totalCheckIns(): Promise<number> {
    const list = await VitalityStore.loadAll()
    let c = 0
    for (const r of list) {
      if (r.isComplete()) {
        c++
      }
    }
    return c
  }

  static async weekCheckInCount(): Promise<number> {
    const monday = DateHelper.mondayKey(DateHelper.todayKey())
    const today = DateHelper.todayKey()
    const list = await VitalityStore.recordsInRange(monday, today)
    return list.length
  }

  /** 本周打卡日内的处方完成统计（与打卡计划同周期） */
  static async weekPrescriptionStats(): Promise<PrescriptionStats> {
    const monday = DateHelper.mondayKey(DateHelper.todayKey())
    const today = DateHelper.todayKey()
    const actions = await VitalityStore.loadActions()
    const s = new PrescriptionStats()
    for (const a of actions) {
      if (a.dateKey >= monday && a.dateKey <= today) {
        s.total++
        if (a.done) {
          s.done++
        }
      }
    }
    return s
  }

  /** 今日处方完成统计（计划卡片默认用此项，避免历史累计永远 100%） */
  static async todayPrescriptionStats(): Promise<PrescriptionStats> {
    const today = DateHelper.todayKey()
    const actions = await VitalityStore.actionsForDate(today)
    const s = new PrescriptionStats()
    s.total = actions.length
    for (const a of actions) {
      if (a.done) {
        s.done++
      }
    }
    return s
  }

  static async dashboardStats(): Promise<DashboardStats> {
    const today = DateHelper.todayKey()
    const todayRec = await VitalityStore.recordForDate(today)
    if (todayRec !== undefined && todayRec.isComplete()) {
      await PrescriptionService.ensureFor(todayRec)
    }
    const s = new DashboardStats()
    s.totalRecords = await StatsService.totalCheckIns()
    s.monthRecords = await StatsService.monthCheckInCount()
    const weekRx = await StatsService.weekPrescriptionStats()
    const todayRx = await StatsService.todayPrescriptionStats()
    if (todayRx.total > 0) {
      s.prescriptionDone = todayRx.done
      s.prescriptionTotal = todayRx.total
    } else if (weekRx.total > 0) {
      s.prescriptionDone = weekRx.done
      s.prescriptionTotal = weekRx.total
    }
    s.favoriteCount = await VitalityStore.favoriteCount()
    const notes = await VitalityStore.loadNotes()
    s.noteCount = notes.length
    return s
  }

  static prescriptionRatePercent(done: number, total: number): number {
    if (total === 0) {
      return 0
    }
    return Math.round((done / total) * 100)
  }

  static async currentMonthInsight(): Promise<string> {
    const d = new Date()
    const y = d.getFullYear()
    const m = d.getMonth() + 1
    const keys = DateHelper.monthKeys(y, m)
    if (keys.length === 0) {
      return '完成首次打卡后，这里会生成本月活力洞察。'
    }
    const records = await VitalityStore.recordsInRange(keys[0], keys[keys.length - 1])
    if (records.length === 0) {
      return `${DateHelper.currentMonthLabel()}还没有打卡记录，今日 3 秒记录即可开启洞察。`
    }
    let exSum = 0
    let moodSum = 0
    let enSum = 0
    for (const r of records) {
      exSum += StatsService.dimensionScore('exercise', r.exerciseKey)
      moodSum += StatsService.dimensionScore('mood', r.moodKey)
      enSum += StatsService.dimensionScore('energy', r.energyKey)
    }
    const n = records.length
    const exAvg = exSum / n
    const moodAvg = moodSum / n
    const enAvg = enSum / n
    let weak = '精力'
    let weakVal = enAvg
    if (exAvg < weakVal) {
      weak = '运动'
      weakVal = exAvg
    }
    if (moodAvg < weakVal) {
      weak = '心情'
    }
    let scoreSum = 0
    for (const r of records) {
      scoreSum += r.vitalityScore()
    }
    const avgScore = Math.round(scoreSum / n)
    return `${DateHelper.currentMonthLabel()}已打卡 ${n} 天，平均活力 ${avgScore} 分。「${weak}」维度相对偏低，建议优先完成处方里的恢复类行动。`
  }

  private static dimensionScore(kind: string, key: string): number {
    let list = DimensionOption.exerciseOptions()
    if (kind === 'mood') {
      list = DimensionOption.moodOptions()
    } else if (kind === 'energy') {
      list = DimensionOption.energyOptions()
    }
    for (const o of list) {
      if (o.key === key) {
        return o.score
      }
    }
    return 2
  }

  static async monthCheckInCount(): Promise<number> {
    const d = new Date()
    const y = d.getFullYear()
    const m = d.getMonth() + 1
    const keys = DateHelper.monthKeys(y, m)
    const list = await VitalityStore.recordsInRange(keys[0], keys[keys.length - 1])
    return list.length
  }

  static async monthCheckInRate(): Promise<number> {
    const d = new Date()
    const day = d.getDate()
    const count = await StatsService.monthCheckInCount()
    if (day === 0) {
      return 0
    }
    return Math.round((count / day) * 100)
  }

  static async trendPoints(days: number): Promise<TrendPoint[]> {
    const keys = DateHelper.lastNDays(days)
    keys.reverse()
    const out: TrendPoint[] = []
    for (const k of keys) {
      const p = new TrendPoint()
      p.dateKey = k
      p.label = DateHelper.displayShort(k)
      const r = await VitalityStore.recordForDate(k)
      p.score = r !== undefined && r.isComplete() ? r.vitalityScore() : 0
      out.push(p)
    }
    return out
  }

  static async dimensionStats(startKey: string, endKey: string): Promise<DimensionStat[]> {
    const records = await VitalityStore.recordsInRange(startKey, endKey)
    const total = records.length
    const moodMap: Map<string, number> = new Map()
    for (const r of records) {
      const c = moodMap.get(r.moodKey) ?? 0
      moodMap.set(r.moodKey, c + 1)
    }
    const out: DimensionStat[] = []
    for (const o of DimensionOption.moodOptions()) {
      const s = new DimensionStat()
      s.key = o.key
      s.label = o.label
      s.count = moodMap.get(o.key) ?? 0
      s.ratio = total > 0 ? s.count / total : 0
      if (s.count > 0) {
        out.push(s)
      }
    }
    return out
  }

  static async lastMonthReport(): Promise<MonthReport | undefined> {
    const now = new Date()
    const last = new Date(now.getFullYear(), now.getMonth() - 1, 1)
    const y = last.getFullYear()
    const m = last.getMonth() + 1
    const keys = DateHelper.monthKeys(y, m)
    if (keys.length === 0) {
      return undefined
    }
    const records = await VitalityStore.recordsInRange(keys[0], keys[keys.length - 1])
    if (records.length === 0) {
      return undefined
    }
    const report = new MonthReport()
    report.monthLabel = `${y}年${m}月`
    report.checkInDays = records.length
    let sum = 0
    const moodCount: Map<string, number> = new Map()
    for (const r of records) {
      sum += r.vitalityScore()
      const c = moodCount.get(r.moodKey) ?? 0
      moodCount.set(r.moodKey, c + 1)
    }
    report.avgScore = Math.round(sum / records.length)
    let topKey = 'calm'
    let topC = 0
    moodCount.forEach((count: number, key: string) => {
      if (count > topC) {
        topC = count
        topKey = key
      }
    })
    report.topMood = DimensionOption.labelFor('mood', topKey)
    report.summary =
      `${report.monthLabel}共打卡 ${report.checkInDays} 天，平均活力 ${report.avgScore} 分，心情以「${report.topMood}」为主。`
    return report
  }

  static async weekCompare(): Promise<WeekCompare> {
    const cmp = new WeekCompare()
    const thisKeys = DateHelper.lastNDays(7)
    thisKeys.reverse()
    const lastStart = new Date()
    lastStart.setDate(lastStart.getDate() - 13)
    const lastEnd = new Date()
    lastEnd.setDate(lastEnd.getDate() - 7)
    const lastRecords = await VitalityStore.recordsInRange(
      DateHelper.keyFromDate(lastStart), DateHelper.keyFromDate(lastEnd))
    const thisRecords = await VitalityStore.recordsInRange(thisKeys[0], thisKeys[thisKeys.length - 1])
    cmp.thisDays = thisRecords.length
    cmp.lastDays = lastRecords.length
    cmp.thisAvg = StatsService.avgScore(thisRecords)
    cmp.lastAvg = StatsService.avgScore(lastRecords)
    cmp.delta = cmp.thisAvg - cmp.lastAvg
    return cmp
  }

  private static avgScore(records: VitalityRecord[]): number {
    if (records.length === 0) {
      return 0
    }
    let s = 0
    for (const r of records) {
      s += r.vitalityScore()
    }
    return Math.round(s / records.length)
  }

  static async todayProgress(
    hasCheckedIn: boolean,
    prescriptionDone: number,
    prescriptionTotal: number,
    weekDone: number,
    weekGoal: number
  ): Promise<TodayProgress> {
    const p = new TodayProgress()
    p.checkedIn = hasCheckedIn
    p.prescriptionDone = prescriptionDone
    p.prescriptionTotal = prescriptionTotal
    p.weekDone = weekDone
    p.weekGoal = weekGoal >= 1 ? weekGoal : 5
    let score = 0
    if (hasCheckedIn) {
      score += 40
    }
    if (prescriptionTotal > 0) {
      score += Math.round((prescriptionDone / prescriptionTotal) * 35)
    }
    if (p.weekGoal > 0) {
      const w = weekDone > p.weekGoal ? p.weekGoal : weekDone
      score += Math.round((w / p.weekGoal) * 25)
    }
    if (score > 100) {
      score = 100
    }
    p.percent = score
    return p
  }

  static async yearReport(): Promise<YearReport | undefined> {
    const d = new Date()
    const y = d.getFullYear()
    const keys = DateHelper.monthKeys(y, 1)
    let allKeys: string[] = []
    for (let m = 1; m <= 12; m++) {
      const mk = DateHelper.monthKeys(y, m)
      for (const k of mk) {
        allKeys.push(k)
      }
    }
    if (allKeys.length === 0) {
      return undefined
    }
    allKeys.sort()
    const records = await VitalityStore.recordsInRange(allKeys[0], allKeys[allKeys.length - 1])
    if (records.length === 0) {
      return undefined
    }
    const report = new YearReport()
    report.year = y
    report.checkInDays = records.length
    let sum = 0
    const moodCount: Map<string, number> = new Map()
    for (const r of records) {
      sum += r.vitalityScore()
      const c = moodCount.get(r.moodKey) ?? 0
      moodCount.set(r.moodKey, c + 1)
    }
    report.avgScore = Math.round(sum / records.length)
    let topKey = 'calm'
    let topC = 0
    moodCount.forEach((count: number, key: string) => {
      if (count > topC) {
        topC = count
        topKey = key
      }
    })
    report.topMood = DimensionOption.labelFor('mood', topKey)
    report.summary =
      `${y} 年共打卡 ${report.checkInDays} 天，平均活力 ${report.avgScore} 分，心情以「${report.topMood}」为主。`
    return report
  }

  static async refreshPlanProgress(): Promise<void> {
    const today = DateHelper.todayKey()
    const todayRec = await VitalityStore.recordForDate(today)
    if (todayRec !== undefined && todayRec.isComplete()) {
      await PrescriptionService.ensureFor(todayRec)
    }
    const plans = await VitalityStore.loadPlans()
    const weekDone = await StatsService.weekCheckInCount()
    const todayRx = await StatsService.todayPrescriptionStats()
    const todayRate = StatsService.prescriptionRatePercent(todayRx.done, todayRx.total)
    for (const plan of plans) {
      if (plan.status !== 'active') {
        continue
      }
      if (plan.planType === 'checkin') {
        plan.currentValue = weekDone
      } else if (plan.planType === 'prescription') {
        plan.currentValue = todayRate
        if (plan.targetValue < 1 || plan.targetValue > 100) {
          plan.targetValue = 80
        }
      }
      await VitalityStore.savePlan(plan)
    }
  }
}

export class AchievementService {
  static definitions(): AchievementDef[] {
    const defs: AchievementDef[] = []
    const rows: string[][] = [
      ['first', '初出茅庐', '完成首次打卡', 'check'],
      ['streak7', '坚持一周', '连续打卡 7 天', 'ai'],
      ['streak14', '半月之约', '连续打卡 14 天', 'ai'],
      ['streak30', '满月勋章', '连续打卡 30 天', 'ai'],
      ['month25', '活力达人', '单月打卡满 25 天', 'chart'],
      ['recipe3', '行动派', '完成 3 条活力处方', 'check'],
      ['pin1', '高光收藏家', '收藏 1 个高光日', 'ai'],
      ['weeknote', '本周纪行人', '写下本周纪行一句', 'biz']
    ]
    for (const row of rows) {
      const d = new AchievementDef()
      d.id = row[0]
      d.title = row[1]
      d.description = row[2]
      d.iconName = row[3]
      defs.push(d)
    }
    return defs
  }

  static titleFor(id: string): string {
    for (const d of AchievementService.definitions()) {
      if (d.id === id) {
        return d.title
      }
    }
    return '未知成就'
  }

  static descriptionFor(id: string): string {
    for (const d of AchievementService.definitions()) {
      if (d.id === id) {
        return d.description
      }
    }
    return ''
  }

  static async evaluateAndUnlock(): Promise<string[]> {
    const newly: string[] = []
    const unlocked = await VitalityStore.loadUnlockedAchievements()
    const total = await StatsService.totalCheckIns()
    const streak = await StatsService.streakDays()
    const monthCount = await StatsService.monthCheckInCount()
    const recipeDone = await VitalityStore.doneActionCount()
    const pins = await VitalityStore.loadPins()
    const hasWeek = await VitalityStore.hasAnyWeekly()

    const checks: string[][] = [
      ['first', total >= 1 ? '1' : '0'],
      ['streak7', streak >= 7 ? '1' : '0'],
      ['streak14', streak >= 14 ? '1' : '0'],
      ['streak30', streak >= 30 ? '1' : '0'],
      ['month25', monthCount >= 25 ? '1' : '0'],
      ['recipe3', recipeDone >= 3 ? '1' : '0'],
      ['pin1', pins.length >= 1 ? '1' : '0'],
      ['weeknote', hasWeek ? '1' : '0']
    ]

    for (const c of checks) {
      let already = false
      for (const u of unlocked) {
        if (u === c[0]) {
          already = true
        }
      }
      if (!already && c[1] === '1') {
        await VitalityStore.unlockAchievement(c[0])
        newly.push(c[0])
      }
    }
    return newly
  }

  static async allStates(): Promise<AchievementState[]> {
    const unlocked = await VitalityStore.loadUnlockedAchievements()
    const out: AchievementState[] = []
    for (const d of AchievementService.definitions()) {
      const s = new AchievementState()
      s.id = d.id
      s.title = d.title
      s.description = d.description
      s.unlocked = false
      for (const u of unlocked) {
        if (u === d.id) {
          s.unlocked = true
          s.unlockedAt = Date.now()
        }
      }
      out.push(s)
    }
    return out
  }

  static progressFor(id: string): AchievementProgress {
    const p = new AchievementProgress()
    p.id = id
    for (const d of AchievementService.definitions()) {
      if (d.id === id) {
        p.title = d.title
        p.description = d.description
        break
      }
    }
    if (id === 'first') {
      p.target = 1
      p.hint = '完成首次活力记录'
    } else if (id === 'streak7') {
      p.target = 7
      p.hint = '连续打卡 7 天'
    } else if (id === 'streak14') {
      p.target = 14
      p.hint = '连续打卡 14 天'
    } else if (id === 'streak30') {
      p.target = 30
      p.hint = '连续打卡 30 天'
    } else if (id === 'month25') {
      p.target = 25
      p.hint = '单月打卡 25 天'
    } else if (id === 'recipe3') {
      p.target = 3
      p.hint = '累计完成 3 条处方行动'
    } else if (id === 'pin1') {
      p.target = 1
      p.hint = '收藏 1 个高光日'
    } else {
      p.target = 1
      p.hint = '写下本周纪行一句'
    }
    return p
  }

  static async progressState(id: string): Promise<AchievementProgress> {
    const p = AchievementService.progressFor(id)
    const unlocked = await VitalityStore.loadUnlockedAchievements()
    for (const u of unlocked) {
      if (u === id) {
        p.unlocked = true
        p.current = p.target
        return p
      }
    }
    const total = await StatsService.totalCheckIns()
    const streak = await StatsService.streakDays()
    const monthCount = await StatsService.monthCheckInCount()
    const recipeDone = await VitalityStore.doneActionCount()
    const pins = await VitalityStore.loadPins()
    const hasWeek = await VitalityStore.hasAnyWeekly()
    if (id === 'first') {
      p.current = total
    } else if (id === 'streak7' || id === 'streak14' || id === 'streak30') {
      p.current = streak
    } else if (id === 'month25') {
      p.current = monthCount
    } else if (id === 'recipe3') {
      p.current = recipeDone
    } else if (id === 'pin1') {
      p.current = pins.length
    } else {
      p.current = hasWeek ? 1 : 0
    }
    return p
  }
}
