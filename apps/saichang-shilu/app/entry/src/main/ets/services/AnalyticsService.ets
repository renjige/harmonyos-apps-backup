import { SportRecord } from '../models/SportRecord'
import {
  HeatDay,
  PlayerStatRow,
  PredictionRow,
  PredictionSummary,
  ResultOption,
  StreakInfo,
  TeamStatRow,
  VenueStatRow
} from '../models/SportExtra'
import { CollectItem, WatchStatus } from '../models/CollectModels'
import { RecordStore } from './RecordStore'
import { CollectStore } from './CollectStore'

export class AnalyticsService {
  static async playerStats(): Promise<PlayerStatRow[]> {
    const matches = await RecordStore.loadAll()
    const items = await CollectStore.loadAll()
    const map = new Map<string, PlayerStatRow>()

    for (const m of matches) {
      const name = m.mvpName.trim()
      if (name.length === 0) {
        continue
      }
      let row = map.get(name)
      if (row === undefined) {
        row = new PlayerStatRow()
        row.name = name
        map.set(name, row)
      }
      row.mvpCount++
      if (m.date > row.lastDate) {
        row.lastDate = m.date
      }
    }

    for (const it of items) {
      if (it.kind !== 'player' && it.kind !== 'perf') {
        continue
      }
      const name = it.title.trim()
      if (name.length === 0) {
        continue
      }
      let row = map.get(name)
      if (row === undefined) {
        row = new PlayerStatRow()
        row.name = name
        map.set(name, row)
      }
      if (it.kind === 'perf') {
        row.perfCount++
        const score = parseInt(it.extra, 10)
        if (score > 0) {
          const total = row.avgPerf * (row.perfCount - 1) + score
          row.avgPerf = Math.round((total / row.perfCount) * 10) / 10
        }
      }
      const d = AnalyticsService.dateFromTs(it.createdAt)
      if (d > row.lastDate) {
        row.lastDate = d
      }
    }

    const out: PlayerStatRow[] = []
    map.forEach((row) => { out.push(row) })
    out.sort((a, b) => b.mvpCount + b.perfCount - (a.mvpCount + a.perfCount))
    return out
  }

  static async teamStats(): Promise<TeamStatRow[]> {
    const matches = await RecordStore.loadAll()
    const teams = await CollectStore.loadKind('team')
    const map = new Map<string, TeamStatRow>()

    for (const m of matches) {
      const names: string[] = []
      if (m.homeTeam.trim().length > 0) {
        names.push(m.homeTeam.trim())
      }
      if (m.opponent.trim().length > 0) {
        names.push(m.opponent.trim())
      }
      for (const name of names) {
        let row = map.get(name)
        if (row === undefined) {
          row = new TeamStatRow()
          row.name = name
          map.set(name, row)
        }
        row.matchCount++
        if (m.rating > 0) {
          const total = row.avgRating * (row.matchCount - 1) + m.rating
          row.avgRating = Math.round((total / row.matchCount) * 10) / 10
        }
        if (m.result === 'win' && name === m.homeTeam) {
          row.wins++
        }
        if (m.date > row.lastDate) {
          row.lastDate = m.date
        }
      }
    }

    for (const t of teams) {
      const name = t.title.trim()
      if (name.length === 0) {
        continue
      }
      if (map.get(name) === undefined) {
        const row = new TeamStatRow()
        row.name = name
        row.lastDate = AnalyticsService.dateFromTs(t.createdAt)
        map.set(name, row)
      }
    }

    const out: TeamStatRow[] = []
    map.forEach((row) => { out.push(row) })
    out.sort((a, b) => b.matchCount - a.matchCount)
    return out
  }

  static async activityHeat(): Promise<HeatDay[]> {
    const matches = await RecordStore.loadAll()
    const items = await CollectStore.loadAll()
    const counts = new Map<string, number>()

    for (const m of matches) {
      const c = counts.get(m.date) ?? 0
      counts.set(m.date, c + 1)
    }
    for (const it of items) {
      const d = AnalyticsService.dateFromTs(it.createdAt)
      const c = counts.get(d) ?? 0
      counts.set(d, c + 1)
    }

    const out: HeatDay[] = []
    const now = new Date()
    for (let i = 89; i >= 0; i--) {
      const d = new Date(now.getFullYear(), now.getMonth(), now.getDate() - i)
      const key = SportRecord.formatDate(d)
      const h = new HeatDay()
      h.dateKey = key
      h.count = counts.get(key) ?? 0
      out.push(h)
    }
    return out
  }

  static async streak(): Promise<StreakInfo> {
    const heat = await AnalyticsService.activityHeat()
    const info = new StreakInfo()
    const weekSet = new Set<string>()

    for (const h of heat) {
      if (h.count > 0) {
        info.activeDays++
        weekSet.add(AnalyticsService.weekKey(h.dateKey))
      }
    }

    const weeks: string[] = []
    weekSet.forEach((w) => { weeks.push(w) })
    weeks.sort()

    let longest = 0
    let run = 0
    let prev = -1
    for (let i = 0; i < weeks.length; i++) {
      const num = parseInt(weeks[i].replace(/-/g, ''), 10)
      if (prev >= 0 && num - prev <= 7) {
        run++
      } else {
        run = 1
      }
      if (run > longest) {
        longest = run
      }
      prev = num
    }
    info.longestWeeks = longest
    info.currentWeeks = run
    info.summary =
      `近 90 天活跃 ${info.activeDays} 天 · 最长连续 ${info.longestWeeks} 周有记录`
    return info
  }

  static matchesForTeam(name: string, list: SportRecord[]): SportRecord[] {
    const out: SportRecord[] = []
    for (const m of list) {
      if (m.homeTeam === name || m.opponent === name) {
        out.push(m)
      }
    }
    return out
  }

  static perfForPlayer(name: string, items: CollectItem[]): CollectItem[] {
    const out: CollectItem[] = []
    for (const it of items) {
      if ((it.kind === 'player' || it.kind === 'perf') && it.title === name) {
        out.push(it)
      }
    }
    return out
  }

  static async mvpLeaderboard(): Promise<PlayerStatRow[]> {
    const rows = await AnalyticsService.playerStats()
    const out: PlayerStatRow[] = []
    for (const row of rows) {
      if (row.mvpCount > 0) {
        out.push(row)
      }
    }
    out.sort((a, b) => b.mvpCount - a.mvpCount)
    return out
  }

  static async watchQueue(): Promise<SportRecord[]> {
    const all = await RecordStore.loadAll()
    const out: SportRecord[] = []
    for (const m of all) {
      if (WatchStatus.isPending(m.status)) {
        out.push(m)
      }
    }
    out.sort((a, b) => a.date.localeCompare(b.date))
    return out
  }

  static async venueStats(): Promise<VenueStatRow[]> {
    const matches = await RecordStore.loadAll()
    const map = new Map<string, VenueStatRow>()
    for (const m of matches) {
      const name = m.location.trim()
      if (name.length === 0) {
        continue
      }
      let row = map.get(name)
      if (row === undefined) {
        row = new VenueStatRow()
        row.name = name
        map.set(name, row)
      }
      row.matchCount++
      if (m.rating > 0) {
        const total = row.avgRating * (row.matchCount - 1) + m.rating
        row.avgRating = Math.round((total / row.matchCount) * 10) / 10
      }
      if (m.date > row.lastDate) {
        row.lastDate = m.date
      }
    }
    const out: VenueStatRow[] = []
    map.forEach((row) => { out.push(row) })
    out.sort((a, b) => b.matchCount - a.matchCount)
    return out
  }

  static scorePrediction(m: SportRecord): string {
    if (m.prediction.trim().length === 0) {
      return 'pending'
    }
    if (m.result.length === 0 || m.result === 'practice') {
      return 'pending'
    }
    const predicted = AnalyticsService.predictFromText(m.prediction)
    if (predicted.length === 0) {
      return 'unknown'
    }
    return predicted === m.result ? 'hit' : 'miss'
  }

  static async predictionLab(): Promise<PredictionSummary> {
    const matches = await RecordStore.loadAll()
    const summary = new PredictionSummary()
    for (const m of matches) {
      const outcome = AnalyticsService.scorePrediction(m)
      if (outcome === 'pending') {
        continue
      }
      summary.total++
      if (outcome === 'hit') {
        summary.hits++
      } else if (outcome === 'miss') {
        summary.misses++
      } else {
        summary.unknown++
      }
    }
    const scored = summary.hits + summary.misses
    if (scored > 0) {
      summary.ratePercent = Math.round((summary.hits / scored) * 100)
    }
    summary.headline = scored > 0 ?
      `预测命中率 ${summary.ratePercent}%（${summary.hits}/${scored}）` :
      '填写赛前预测并记录结果后可统计命中率'
    return summary
  }

  static async predictionRows(): Promise<PredictionRow[]> {
    const matches = await RecordStore.loadAll()
    const out: PredictionRow[] = []
    for (const m of matches) {
      if (m.prediction.trim().length === 0) {
        continue
      }
      const row = new PredictionRow()
      row.matchId = m.id
      row.title = m.title.length > 0 ? m.title : '未命名赛事'
      row.date = m.date
      row.prediction = m.prediction
      row.resultLabel = ResultOption.labelOf(m.result)
      row.outcome = AnalyticsService.scorePrediction(m)
      out.push(row)
    }
    out.sort((a, b) => b.date.localeCompare(a.date))
    return out
  }

  static async weeklyDigestText(): Promise<string> {
    const week = AnalyticsService.weekStartMs()
    const matches = await RecordStore.loadAll()
    const items = await CollectStore.loadAll()
    let weekMatches = 0
    let weekRecaps = 0
    let weekMoments = 0
    const titles: string[] = []
    for (const m of matches) {
      if (m.createdAt >= week || m.updatedAt >= week) {
        weekMatches++
        if (m.title.length > 0) {
          titles.push(m.title)
        }
        if (m.recapSummary.length > 0 || m.recapPhases.length > 0) {
          weekRecaps++
        }
      }
    }
    for (const it of items) {
      if (it.kind === 'moment' && it.createdAt >= week) {
        weekMoments++
      }
    }
    const lines: string[] = []
    lines.push('【赛场拾录 · 本周观赛周报】')
    lines.push('')
    lines.push(`本周新增/更新赛事 ${weekMatches} 场 · 复盘 ${weekRecaps} 次 · 瞬间 ${weekMoments} 条`)
    if (titles.length > 0) {
      lines.push('')
      lines.push('涉及赛事：')
      for (const t of titles) {
        lines.push(`· ${t}`)
      }
    }
    const pred = await AnalyticsService.predictionLab()
    if (pred.total > 0) {
      lines.push('')
      lines.push(pred.headline)
    }
    lines.push('')
    lines.push('—— 由赛场拾录自动生成 ——')
    return lines.join('\n')
  }

  private static predictFromText(text: string): string {
    const p = text
    if (p.indexOf('小胜') >= 0 || p.indexOf('大胜') >= 0 || p.indexOf('获胜') >= 0 ||
      p.indexOf('赢') >= 0 || p.indexOf('胜') >= 0) {
      return 'win'
    }
    if (p.indexOf('平局') >= 0 || p.indexOf('打平') >= 0 || p.indexOf('平') >= 0) {
      return 'draw'
    }
    if (p.indexOf('失利') >= 0 || p.indexOf('输球') >= 0 || p.indexOf('输') >= 0 ||
      p.indexOf('负') >= 0) {
      return 'lose'
    }
    return ''
  }

  private static weekStartMs(): number {
    const d = new Date()
    const day = d.getDay()
    const diff = day === 0 ? 6 : day - 1
    d.setHours(0, 0, 0, 0)
    d.setDate(d.getDate() - diff)
    return d.getTime()
  }

  private static dateFromTs(ts: number): string {
    return SportRecord.formatDate(new Date(ts))
  }

  private static weekKey(dateKey: string): string {
    const parts = dateKey.split('-')
    if (parts.length < 3) {
      return dateKey
    }
    const d = new Date(parseInt(parts[0], 10), parseInt(parts[1], 10) - 1, parseInt(parts[2], 10))
    const onejan = new Date(d.getFullYear(), 0, 1)
    const week = Math.ceil((((d.getTime() - onejan.getTime()) / 86400000) + onejan.getDay() + 1) / 7)
    return `${d.getFullYear()}-W${week}`
  }
}
