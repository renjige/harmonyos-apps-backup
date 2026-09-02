import { ChallengeProgress, FeelingStat, MonthlyReportSnapshot, PersonalBestItem, SessionCompareHint, SportChallenge, SportRecord, SportSummary, TypeMixItem, WeekCompare } from '../models/SportModels'
import { SportStore } from './SportStore'
import { ProfileStore } from './ProfileStore'

export class SportAnalytics {
  static summarize(): SportSummary {
    const summary = new SportSummary()
    const records = SportStore.list()
    const now = new Date()
    const monthKey = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`
    summary.monthTrend = [0, 0, 0, 0, 0, 0]
    summary.weekTrend = [0, 0, 0, 0, 0, 0, 0]

    for (const r of records) {
      summary.totalSessions += 1
      summary.totalDurationMin += r.durationMin
      summary.totalDistanceKm += r.distanceKm
      if (r.distanceKm > summary.bestDistanceKm) {
        summary.bestDistanceKm = r.distanceKm
      }
      if (r.recordDate.startsWith(monthKey)) {
        summary.monthSessions += 1
        summary.monthDurationMin += r.durationMin
        summary.monthDistanceKm += r.distanceKm
      }
      const monthIdx = SportAnalytics.monthBucket(r.recordDate)
      if (monthIdx >= 0 && monthIdx < 6) {
        summary.monthTrend[monthIdx] += 1
      }
      const weekIdx = SportAnalytics.weekDayIndex(r.recordDate)
      if (weekIdx >= 0 && weekIdx < 7) {
        summary.weekTrend[weekIdx] += 1
      }
    }

    summary.streakDays = SportAnalytics.computeStreak()
    summary.typeMix = SportAnalytics.typeMix(records)
    return summary
  }

  static mixWithPercent(): TypeMixItem[] {
    return SportAnalytics.typeMix(SportStore.list())
  }

  static feelingStats(): FeelingStat[] {
    const labels = ['轻松', '正常', '吃力', '比赛日']
    const counts: number[] = [0, 0, 0, 0]
    let total = 0
    for (const r of SportStore.list()) {
      const f = r.feeling.length > 0 ? r.feeling : '正常'
      let idx = 1
      for (let i = 0; i < labels.length; i++) {
        if (labels[i] === f) {
          idx = i
          break
        }
      }
      counts[idx] += 1
      total += 1
    }
    const out: FeelingStat[] = []
    for (let i = 0; i < labels.length; i++) {
      const s = new FeelingStat()
      s.label = labels[i]
      s.count = counts[i]
      s.percent = total > 0 ? Math.round((counts[i] / total) * 100) : 0
      out.push(s)
    }
    return out
  }

  static monthlyReport(): MonthlyReportSnapshot {
    const snap = new MonthlyReportSnapshot()
    const now = new Date()
    const monthKey = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`
    snap.monthLabel = `${now.getFullYear()} 年 ${now.getMonth() + 1} 月`
    let bestDist = 0
    const mixMap: TypeMixItem[] = []
    for (const r of SportStore.list()) {
      if (!r.recordDate.startsWith(monthKey)) {
        continue
      }
      snap.sessions += 1
      snap.durationMin += r.durationMin
      snap.distanceKm += r.distanceKm
      if (r.distanceKm > bestDist) {
        bestDist = r.distanceKm
        snap.bestDistanceKm = r.distanceKm
        snap.bestDate = r.recordDate
      }
      let hit = false
      for (const m of mixMap) {
        if (m.sportType === r.sportType) {
          m.sessions += 1
          hit = true
          break
        }
      }
      if (!hit) {
        const item = new TypeMixItem()
        item.sportType = r.sportType
        item.sessions = 1
        mixMap.push(item)
      }
    }
    if (snap.sessions > 0) {
      snap.avgDurationMin = Math.round(snap.durationMin / snap.sessions)
    }
    mixMap.sort((a: TypeMixItem, b: TypeMixItem) => b.sessions - a.sessions)
    if (mixMap.length > 0) {
      snap.topSport = mixMap[0].sportType
    }
    if (snap.sessions === 0) {
      snap.highlights.push('本月还没有训练记录，去「记录」页开启第一笔。')
      return snap
    }
    snap.highlights.push(`共完成 ${snap.sessions} 次训练，累计 ${snap.durationMin} 分钟。`)
    if (snap.distanceKm > 0) {
      snap.highlights.push(`总里程 ${snap.distanceKm.toFixed(1)} km，最佳单次 ${snap.bestDistanceKm.toFixed(1)} km（${snap.bestDate}）。`)
    }
    if (snap.topSport.length > 0) {
      snap.highlights.push(`练得最多的是「${snap.topSport}」，可对照问卷看配比是否均衡。`)
    }
    const cmp = SportAnalytics.weekCompare()
    if (cmp.deltaSessions > 0) {
      snap.highlights.push(`本周比上周多 ${cmp.deltaSessions} 次，节奏向上。`)
    }
    return snap
  }

  static monthTrendValues(): number[] {
    return SportAnalytics.summarize().monthTrend
  }

  static personalBest(sportType: string): SportRecord | null {
    let best: SportRecord | null = null
    for (const r of SportStore.list()) {
      if (r.sportType !== sportType || r.distanceKm <= 0) {
        continue
      }
      if (best === null || r.distanceKm > best.distanceKm) {
        best = r
      }
    }
    return best
  }

  static personalBestDuration(sportType: string): SportRecord | null {
    let best: SportRecord | null = null
    for (const r of SportStore.list()) {
      if (r.sportType !== sportType) {
        continue
      }
      if (best === null || r.durationMin > best.durationMin) {
        best = r
      }
    }
    return best
  }

  static personalBestPace(sportType: string): SportRecord | null {
    let best: SportRecord | null = null
    for (const r of SportStore.list()) {
      if (r.sportType !== sportType || r.paceMinPerKm <= 0) {
        continue
      }
      if (best === null || r.paceMinPerKm < best.paceMinPerKm) {
        best = r
      }
    }
    return best
  }

  static sessionCompare(cur: SportRecord): SessionCompareHint {
    const hint = new SessionCompareHint()
    hint.sportType = cur.sportType
    const same: SportRecord[] = []
    for (const r of SportStore.list()) {
      if (r.sportType === cur.sportType) {
        same.push(r)
      }
    }
    same.sort((a: SportRecord, b: SportRecord) => b.recordDate.localeCompare(a.recordDate))
    let prev: SportRecord | null = null
    for (let i = 0; i < same.length; i++) {
      if (same[i].id === cur.id && i + 1 < same.length) {
        prev = same[i + 1]
        break
      }
    }
    if (prev === null) {
      hint.message = '这是该项目的首条记录，继续积累可对照进步。'
      return hint
    }
    hint.deltaDurationMin = cur.durationMin - prev.durationMin
    hint.deltaDistanceKm = cur.distanceKm - prev.distanceKm
    const parts: string[] = []
    if (hint.deltaDurationMin !== 0) {
      parts.push(`时长 ${hint.deltaDurationMin > 0 ? '+' : ''}${hint.deltaDurationMin} 分`)
    }
    if (Math.abs(hint.deltaDistanceKm) >= 0.1) {
      parts.push(`距离 ${hint.deltaDistanceKm > 0 ? '+' : ''}${hint.deltaDistanceKm.toFixed(1)} km`)
    }
    hint.message = parts.length > 0 ?
      `较上场（${prev.recordDate}）${parts.join(' · ')}` :
      `较上场（${prev.recordDate}）数据接近，可写清复盘要点。`
    return hint
  }

  static challengeProgress(ch: SportChallenge): ChallengeProgress {
    const p = new ChallengeProgress()
    for (const r of SportStore.list()) {
      if (r.recordDate < ch.startDate || r.recordDate > ch.endDate) {
        continue
      }
      if (ch.sportType !== '全部' && r.sportType !== ch.sportType) {
        continue
      }
      p.sessions += 1
      p.distanceKm += r.distanceKm
    }
    if (ch.targetSessions > 0) {
      const pct = Math.round((p.sessions / ch.targetSessions) * 100)
      p.sessionPct = pct > 100 ? 100 : pct
    }
    p.done = ch.status === 'done' || (ch.targetSessions > 0 && p.sessions >= ch.targetSessions)
    return p
  }

  private static typeMix(records: SportRecord[]): TypeMixItem[] {
    const keys: string[] = []
    const counts: number[] = []
    for (const r of records) {
      let hit = false
      for (let i = 0; i < keys.length; i++) {
        if (keys[i] === r.sportType) {
          counts[i] += 1
          hit = true
          break
        }
      }
      if (!hit) {
        keys.push(r.sportType)
        counts.push(1)
      }
    }
    const out: TypeMixItem[] = []
    for (let i = 0; i < keys.length; i++) {
      const item = new TypeMixItem()
      item.sportType = keys[i]
      item.sessions = counts[i]
      out.push(item)
    }
    const total = records.length
    for (const item of out) {
      item.percent = total > 0 ? Math.round((item.sessions / total) * 100) : 0
    }
    out.sort((a: TypeMixItem, b: TypeMixItem) => b.sessions - a.sessions)
    return out
  }

  static monthProgressPercent(): number {
    const goal = ProfileStore.get().monthlyGoalSessions
    if (goal <= 0) {
      return 0
    }
    const s = SportAnalytics.summarize()
    const pct = Math.round((s.monthSessions / goal) * 100)
    return pct > 100 ? 100 : pct
  }

  static weekCompare(): WeekCompare {
    const cmp = new WeekCompare()
    const now = new Date()
    now.setHours(0, 0, 0, 0)
    for (const r of SportStore.list()) {
      const idx = SportAnalytics.weekDayIndex(r.recordDate)
      if (idx >= 0 && idx < 7) {
        cmp.thisWeekSessions += 1
        cmp.thisWeekDurationMin += r.durationMin
      }
      const lastIdx = SportAnalytics.daysAgoIndex(r.recordDate, 7)
      if (lastIdx >= 0 && lastIdx < 7) {
        cmp.lastWeekSessions += 1
        cmp.lastWeekDurationMin += r.durationMin
      }
    }
    cmp.deltaSessions = cmp.thisWeekSessions - cmp.lastWeekSessions
    return cmp
  }

  static personalBestList(limit: number = 4): PersonalBestItem[] {
    const out: PersonalBestItem[] = []
    for (const t of ['跑步', '骑行', '健身', '球类', '游泳', '其他']) {
      const distPb = SportAnalytics.personalBest(t)
      if (distPb !== null && distPb.distanceKm > 0) {
        const item = new PersonalBestItem()
        item.sportType = t
        item.metricLabel = '最佳距离'
        item.metricValue = `${distPb.distanceKm.toFixed(1)} km`
        item.distanceKm = distPb.distanceKm
        item.recordDate = distPb.recordDate
        out.push(item)
      }
      const durPb = SportAnalytics.personalBestDuration(t)
      if (durPb !== null && durPb.durationMin >= 30) {
        const item = new PersonalBestItem()
        item.sportType = t
        item.metricLabel = '最长时长'
        item.metricValue = `${durPb.durationMin} 分`
        item.durationMin = durPb.durationMin
        item.recordDate = durPb.recordDate
        out.push(item)
      }
      const pacePb = SportAnalytics.personalBestPace(t)
      if (pacePb !== null && pacePb.paceMinPerKm > 0) {
        const item = new PersonalBestItem()
        item.sportType = t
        item.metricLabel = '最佳配速'
        item.metricValue = `${pacePb.paceMinPerKm.toFixed(1)} 分/km`
        item.paceMinPerKm = pacePb.paceMinPerKm
        item.recordDate = pacePb.recordDate
        out.push(item)
      }
    }
    const trimmed: PersonalBestItem[] = []
    for (let i = 0; i < out.length && i < limit; i++) {
      trimmed.push(out[i])
    }
    return trimmed
  }

  static insightTip(): string {
    const s = SportAnalytics.summarize()
    const cmp = SportAnalytics.weekCompare()
    if (s.totalSessions === 0) {
      return '先完成 1 次记录，首页会自动生成周对比与个人最佳。'
    }
    if (cmp.deltaSessions > 0) {
      return `本周比上周多练 ${cmp.deltaSessions} 次，节奏在上升。`
    }
    if (cmp.deltaSessions < 0) {
      return `本周比上周少 ${Math.abs(cmp.deltaSessions)} 次，可设一个小挑战拉回状态。`
    }
    if (s.streakDays >= 3) {
      return `已连续 ${s.streakDays} 天有记录，保持比加量更重要。`
    }
    const mix = s.typeMix
    if (mix.length === 1) {
      return `目前只有「${mix[0].sportType}」，试试问卷推荐的项目配比。`
    }
    return '用复盘字段记录「下次重点」，比只记时长更有成长感。'
  }

  private static daysAgoIndex(dateKey: string, offsetDays: number): number {
    try {
      const parts = dateKey.split('-')
      if (parts.length < 3) {
        return -1
      }
      const y = parseInt(parts[0], 10)
      const m = parseInt(parts[1], 10) - 1
      const day = parseInt(parts[2], 10)
      const d = new Date(y, m, day)
      const now = new Date()
      now.setHours(0, 0, 0, 0)
      d.setHours(0, 0, 0, 0)
      const diffDays = Math.round((now.getTime() - d.getTime()) / 86400000)
      const start = offsetDays
      const end = offsetDays + 6
      if (diffDays < start || diffDays > end) {
        return -1
      }
      return end - diffDays
    } catch {
      return -1
    }
  }

  private static computeStreak(): number {
    const dates = SportStore.datesWithRecords()
    if (dates.length === 0) {
      return 0
    }
    dates.sort((a: string, b: string) => b.localeCompare(a))
    let streak = 0
    let cursor = new Date()
    cursor.setHours(0, 0, 0, 0)
    for (let i = 0; i < 365; i++) {
      const key = SportAnalytics.dateKey(cursor)
      let hit = false
      for (const d of dates) {
        if (d === key) {
          hit = true
          break
        }
      }
      if (!hit) {
        if (streak === 0 && i === 0) {
          cursor.setDate(cursor.getDate() - 1)
          continue
        }
        break
      }
      streak += 1
      cursor.setDate(cursor.getDate() - 1)
    }
    return streak
  }

  private static dateKey(d: Date): string {
    const y = d.getFullYear()
    const m = String(d.getMonth() + 1).padStart(2, '0')
    const day = String(d.getDate()).padStart(2, '0')
    return `${y}-${m}-${day}`
  }

  private static monthBucket(dateKey: string): number {
    try {
      const parts = dateKey.split('-')
      if (parts.length < 2) {
        return -1
      }
      const y = parseInt(parts[0], 10)
      const m = parseInt(parts[1], 10) - 1
      const d = new Date(y, m, 1)
      const now = new Date()
      const diff = (now.getFullYear() - d.getFullYear()) * 12 + (now.getMonth() - d.getMonth())
      if (diff < 0 || diff > 5) {
        return -1
      }
      return 5 - diff
    } catch {
      return -1
    }
  }

  private static weekDayIndex(dateKey: string): number {
    try {
      const parts = dateKey.split('-')
      if (parts.length < 3) {
        return -1
      }
      const y = parseInt(parts[0], 10)
      const m = parseInt(parts[1], 10) - 1
      const day = parseInt(parts[2], 10)
      const d = new Date(y, m, day)
      const now = new Date()
      now.setHours(0, 0, 0, 0)
      d.setHours(0, 0, 0, 0)
      const diffDays = Math.round((now.getTime() - d.getTime()) / 86400000)
      if (diffDays < 0 || diffDays > 6) {
        return -1
      }
      return 6 - diffDays
    } catch {
      return -1
    }
  }
}
