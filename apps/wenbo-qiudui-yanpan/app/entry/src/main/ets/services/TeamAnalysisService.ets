import { BarChartItem, MatchItem, TeamItem } from '../models/MatchModels'

export class H2HStat {
  total: number = 0
  teamAWins: number = 0
  teamBWins: number = 0
  draws: number = 0
  trend: string = ''
  summary: string = '暂无已结束交锋'
}

export class TeamAnalysisService {
  static takeFirst(source: MatchItem[], limit: number): MatchItem[] {
    const out: MatchItem[] = []
    let n = 0
    for (const row of source) {
      if (n >= limit) {
        break
      }
      out.push(row)
      n += 1
    }
    return out
  }

  static finishedForTeam(teamTitle: string, matches: MatchItem[]): MatchItem[] {
    const out: MatchItem[] = []
    for (const m of matches) {
      if (m.status !== 'finished') {
        continue
      }
      if (m.homeScore < 0 || m.awayScore < 0) {
        continue
      }
      if (m.homeTeam === teamTitle || m.awayTeam === teamTitle) {
        out.push(m)
      }
    }
    return out
  }

  static resultLetter(teamTitle: string, m: MatchItem): string {
    const home = m.homeTeam === teamTitle
    const gf = home ? m.homeScore : m.awayScore
    const ga = home ? m.awayScore : m.homeScore
    if (gf > ga) {
      return 'W'
    }
    if (gf === ga) {
      return 'D'
    }
    return 'L'
  }

  static pointsFor(teamTitle: string, m: MatchItem): number {
    const letter = TeamAnalysisService.resultLetter(teamTitle, m)
    if (letter === 'W') {
      return 3
    }
    if (letter === 'D') {
      return 1
    }
    return 0
  }

  static goalsForMatch(teamTitle: string, m: MatchItem): number {
    if (m.homeTeam === teamTitle) {
      return m.homeScore
    }
    return m.awayScore
  }

  static formTrend(teamTitle: string, matches: MatchItem[]): string {
    const finished = TeamAnalysisService.finishedForTeam(teamTitle, matches)
    const picked = TeamAnalysisService.takeFirst(finished, 6)
    let trend = ''
    for (const m of picked) {
      trend = `${trend}${TeamAnalysisService.resultLetter(teamTitle, m)}`
    }
    if (trend.length === 0) {
      return '暂无已结束比赛'
    }
    return trend
  }

  static formBars(teamTitle: string, matches: MatchItem[]): BarChartItem[] {
    const finished = TeamAnalysisService.finishedForTeam(teamTitle, matches)
    const picked = TeamAnalysisService.takeFirst(finished, 6)
    const out: BarChartItem[] = []
    let idx = 1
    for (const m of picked) {
      const item = new BarChartItem()
      item.value = TeamAnalysisService.pointsFor(teamTitle, m)
      item.label = `${idx}${TeamAnalysisService.resultLetter(teamTitle, m)}`
      out.push(item)
      idx += 1
    }
    return out
  }

  static goalBars(teamTitle: string, matches: MatchItem[]): BarChartItem[] {
    const finished = TeamAnalysisService.finishedForTeam(teamTitle, matches)
    const picked = TeamAnalysisService.takeFirst(finished, 6)
    const out: BarChartItem[] = []
    let idx = 1
    for (const m of picked) {
      const item = new BarChartItem()
      item.value = TeamAnalysisService.goalsForMatch(teamTitle, m)
      item.label = `${idx}`
      out.push(item)
      idx += 1
    }
    return out
  }

  static summarizeH2H(teamA: string, teamB: string, matches: MatchItem[]): H2HStat {
    const stat = new H2HStat()
    let trend = ''
    for (const m of matches) {
      if (m.status !== 'finished' || m.homeScore < 0 || m.awayScore < 0) {
        continue
      }
      const involves = (m.homeTeam === teamA && m.awayTeam === teamB) ||
        (m.homeTeam === teamB && m.awayTeam === teamA)
      if (!involves) {
        continue
      }
      stat.total += 1
      if (m.homeScore === m.awayScore) {
        stat.draws += 1
        trend = `${trend}D`
      } else if (m.homeTeam === teamA && m.homeScore > m.awayScore) {
        stat.teamAWins += 1
        trend = `${trend}A`
      } else if (m.awayTeam === teamA && m.awayScore > m.homeScore) {
        stat.teamAWins += 1
        trend = `${trend}A`
      } else {
        stat.teamBWins += 1
        trend = `${trend}B`
      }
    }
    stat.trend = trend
    if (stat.total > 0) {
      stat.summary = `共 ${stat.total} 场 · ${teamA} ${stat.teamAWins} 胜 · ${teamB} ${stat.teamBWins} 胜 · ${stat.draws} 平`
    }
    return stat
  }

  static dailyTeam(teams: TeamItem[]): TeamItem | undefined {
    if (teams.length === 0) {
      return undefined
    }
    const mod = Date.now() % teams.length
    let cursor = 0
    for (const row of teams) {
      if (cursor === mod) {
        return row
      }
      cursor += 1
    }
    return undefined
  }

  static teamsWithNews(teams: TeamItem[]): TeamItem[] {
    const out: TeamItem[] = []
    for (const row of teams) {
      if (row.newsTitle.length > 0) {
        out.push(row)
      }
    }
    return out
  }

  static observeTheme(team: TeamItem): string {
    const tag = team.styleTagLabel()
    if (tag.length > 0) {
      return `今日主题：观察「${tag}」在攻防两端的取舍`
    }
    return '今日主题：对照近期战绩与主客场差异'
  }
}
