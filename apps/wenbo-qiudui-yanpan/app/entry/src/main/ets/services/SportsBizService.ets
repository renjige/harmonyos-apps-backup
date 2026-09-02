import { HttpClient } from './HttpClient'
import {
  CalendarDay,
  CalendarPayload,
  CreateFavoriteBody,
  CreateReminderBody,
  FavoriteItem,
  FavoriteItemWire,
  FavoriteListPayload,
  LeagueItem,
  LeagueItemWire,
  LeagueListPayload,
  MatchItem,
  MatchItemWire,
  MatchListPayload,
  MessageItem,
  MessageListPayload,
  ReminderItem,
  ReminderItemWire,
  ReminderListPayload,
  TeamItem,
  TeamItemWire,
  TeamListPayload,
  StandingItem,
  StandingListPayload,
  KpiListPayload,
  KpiItem,
  FollowWidgetPayload
} from '../models/MatchModels'
import { FollowWidgetSync } from './FollowWidgetSync'

export class SportsBizService {
  static lastError: string = ''

  private static currentUsername(): string {
    const u = AppStorage.get<string>('currentUsername')
    return u !== undefined && u !== null ? u : ''
  }

  static async loadMatches(sport: string, featured: boolean, status: string): Promise<MatchItem[]> {
    SportsBizService.lastError = ''
    let path = '/biz/sports-events/matches'
    const params: string[] = []
    if (sport.length > 0) {
      params.push(`sport=${encodeURIComponent(sport)}`)
    }
    if (featured) {
      params.push('featured=true')
    }
    if (status.length > 0) {
      params.push(`status=${encodeURIComponent(status)}`)
    }
    if (params.length > 0) {
      path = `${path}?${params.join('&')}`
    }
    const res = await HttpClient.get<MatchListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: MatchItem[] = []
      for (const w of res.data.list) {
        out.push(MatchItem.fromWire(w))
      }
      return out
    }
    SportsBizService.lastError = res.message.length > 0 ? res.message : '加载比赛失败'
    return []
  }

  static async findMatch(id: string): Promise<MatchItem | undefined> {
    SportsBizService.lastError = ''
    const res = await HttpClient.get<MatchItemWire>(`/biz/sports-events/matches/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return MatchItem.fromWire(res.data)
    }
    SportsBizService.lastError = res.message.length > 0 ? res.message : '比赛不存在'
    return undefined
  }

  static async loadTeams(sport: string, featured: boolean): Promise<TeamItem[]> {
    let path = '/biz/sports-events/teams'
    const params: string[] = []
    if (sport.length > 0) {
      params.push(`sport=${encodeURIComponent(sport)}`)
    }
    if (featured) {
      params.push('featured=true')
    }
    if (params.length > 0) {
      path = `${path}?${params.join('&')}`
    }
    const res = await HttpClient.get<TeamListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: TeamItem[] = []
      for (const w of res.data.list) {
        out.push(TeamItem.fromWire(w))
      }
      return out
    }
    SportsBizService.lastError = res.message.length > 0 ? res.message : '加载球队失败'
    return []
  }

  static async loadFeaturedTeams(): Promise<TeamItem[]> {
    return SportsBizService.loadTeams('', true)
  }

  static async loadMatchesForTeam(teamName: string): Promise<MatchItem[]> {
    const all = await SportsBizService.loadMatches('', false, '')
    const out: MatchItem[] = []
    for (const m of all) {
      if (m.homeTeam === teamName || m.awayTeam === teamName) {
        out.push(m)
      }
    }
    return out
  }

  static async loadUpcomingForTeam(teamName: string): Promise<MatchItem | undefined> {
    const list = await SportsBizService.loadMatchesForTeam(teamName)
    for (const m of list) {
      if (m.status === 'upcoming' || m.status === 'live') {
        return m
      }
    }
    return undefined
  }

  static async loadTeamsBySport(sport: string): Promise<TeamItem[]> {
    return SportsBizService.loadTeams(sport, false)
  }

  static async findTeam(id: string): Promise<TeamItem | undefined> {
    const res = await HttpClient.get<TeamItemWire>(`/biz/sports-events/teams/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return TeamItem.fromWire(res.data)
    }
    return undefined
  }

  static async loadLeagues(sport: string): Promise<LeagueItem[]> {
    let path = '/biz/sports-events/leagues'
    if (sport.length > 0) {
      path = `${path}?sport=${encodeURIComponent(sport)}`
    }
    const res = await HttpClient.get<LeagueListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: LeagueItem[] = []
      for (const w of res.data.list) {
        out.push(LeagueItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async findLeague(id: string): Promise<LeagueItem | undefined> {
    const res = await HttpClient.get<LeagueItemWire>(`/biz/sports-events/leagues/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return LeagueItem.fromWire(res.data)
    }
    return undefined
  }

  static async loadCalendar(month: string): Promise<CalendarDay[]> {
    let path = '/biz/sports-events/calendar'
    if (month.length > 0) {
      path = `${path}?month=${encodeURIComponent(month)}`
    }
    const res = await HttpClient.get<CalendarPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.days !== undefined) {
      const out: CalendarDay[] = []
      for (const w of res.data.days) {
        out.push(CalendarDay.fromWire(w))
      }
      return out
    }
    return []
  }

  static async countTodayMatches(): Promise<number> {
    const all = await SportsBizService.loadMatches('', false, '')
    const today = SportsBizService.todayIso()
    let count = 0
    for (const m of all) {
      if (m.dateIso() === today) {
        count += 1
      }
    }
    return count
  }

  static async loadFavorites(username: string): Promise<FavoriteItem[]> {
    const uid = username.length > 0 ? username : SportsBizService.currentUsername()
    if (uid.length === 0) {
      return []
    }
    const path = `/biz/sports-events/favorites?username=${encodeURIComponent(uid)}`
    const res = await HttpClient.get<FavoriteListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: FavoriteItem[] = []
      for (const w of res.data.list) {
        out.push(FavoriteItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async createFavorite(targetType: string, targetId: string, targetTitle: string): Promise<FavoriteItem | undefined> {
    SportsBizService.lastError = ''
    const body = new CreateFavoriteBody()
    body.targetType = targetType
    body.targetId = targetId
    body.targetTitle = targetTitle
    body.username = SportsBizService.currentUsername()
    const res = await HttpClient.post<FavoriteItemWire>('/biz/sports-events/favorites', body)
    if (res.code === 0 && res.data !== undefined) {
      const row = FavoriteItem.fromWire(res.data)
      await SportsBizService.syncFollowWidget()
      return row
    }
    SportsBizService.lastError = res.message.length > 0 ? res.message : '关注失败'
    return undefined
  }

  static async removeFavorite(id: string): Promise<boolean> {
    SportsBizService.lastError = ''
    const res = await HttpClient.delete<object>(`/biz/sports-events/favorites/${id}`)
    if (res.code === 0) {
      await SportsBizService.syncFollowWidget()
      return true
    }
    SportsBizService.lastError = res.message.length > 0 ? res.message : '取消关注失败'
    return false
  }

  static async loadReminders(username: string): Promise<ReminderItem[]> {
    const uid = username.length > 0 ? username : SportsBizService.currentUsername()
    if (uid.length === 0) {
      return []
    }
    const path = `/biz/sports-events/reminders?username=${encodeURIComponent(uid)}`
    const res = await HttpClient.get<ReminderListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: ReminderItem[] = []
      for (const w of res.data.list) {
        out.push(ReminderItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async createReminder(matchId: string, matchTitle: string, remindMinutes: number, startAt: string): Promise<ReminderItem | undefined> {
    SportsBizService.lastError = ''
    const body = new CreateReminderBody()
    body.matchId = matchId
    body.matchTitle = matchTitle
    body.remindMinutes = remindMinutes
    body.startAt = startAt
    body.username = SportsBizService.currentUsername()
    const res = await HttpClient.post<ReminderItemWire>('/biz/sports-events/reminders', body)
    if (res.code === 0 && res.data !== undefined) {
      return ReminderItem.fromWire(res.data)
    }
    SportsBizService.lastError = res.message.length > 0 ? res.message : '设置提醒失败'
    return undefined
  }

  static async removeReminder(id: string): Promise<boolean> {
    SportsBizService.lastError = ''
    const res = await HttpClient.delete<object>(`/biz/sports-events/reminders/${id}`)
    if (res.code === 0) {
      return true
    }
    SportsBizService.lastError = res.message.length > 0 ? res.message : '取消提醒失败'
    return false
  }

  static async loadMessages(): Promise<MessageItem[]> {
    const res = await HttpClient.get<MessageListPayload>('/messages')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: MessageItem[] = []
      for (const w of res.data.list) {
        out.push(MessageItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static todayIso(): string {
    const d = new Date()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms: string = m < 10 ? `0${m}` : `${m}`
    const ds: string = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${ms}-${ds}`
  }

  static monthKey(year: number, month: number): string {
    const ms: string = month < 10 ? `0${month}` : `${month}`
    return `${year}-${ms}`
  }

  static async findTeamByTitle(title: string): Promise<TeamItem | undefined> {
    const all = await SportsBizService.loadTeams('', false)
    for (const row of all) {
      if (row.title === title) {
        return row
      }
    }
    return undefined
  }

  static async loadStandings(league: string, sport: string): Promise<StandingItem[]> {
    let path = '/biz/sports-events/standings'
    const params: string[] = []
    if (league.length > 0) {
      params.push(`league=${encodeURIComponent(league)}`)
    }
    if (sport.length > 0) {
      params.push(`sport=${encodeURIComponent(sport)}`)
    }
    if (params.length > 0) {
      path = `${path}?${params.join('&')}`
    }
    const res = await HttpClient.get<StandingListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: StandingItem[] = []
      for (const w of res.data.list) {
        out.push(StandingItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async findStanding(teamTitle: string): Promise<StandingItem | undefined> {
    const list = await SportsBizService.loadStandings('', '')
    for (const row of list) {
      if (row.teamName === teamTitle) {
        return row
      }
    }
    return undefined
  }

  static async loadHeadToHead(home: string, away: string): Promise<MatchItem[]> {
    if (home.length === 0 || away.length === 0) {
      return []
    }
    const path = `/biz/sports-events/head-to-head?home=${encodeURIComponent(home)}&away=${encodeURIComponent(away)}`
    const res = await HttpClient.get<MatchListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: MatchItem[] = []
      for (const w of res.data.list) {
        out.push(MatchItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async buildFollowWidgetPayload(): Promise<FollowWidgetPayload> {
    const data = new FollowWidgetPayload()
    if (SportsBizService.currentUsername().length === 0) {
      return data
    }
    const favs = await SportsBizService.loadFavorites('')
    const names: string[] = []
    for (const fav of favs) {
      if (fav.targetType === 'team' && fav.targetTitle.length > 0) {
        names.push(fav.targetTitle)
      }
    }
    if (names.length === 0) {
      return data
    }
    data.count = `${names.length}`
    data.title = names[0]
    const shown: string[] = []
    for (const name of names) {
      if (shown.length < 3) {
        shown.push(name)
      }
    }
    data.preview = shown.join('、')
    const team = await SportsBizService.findTeamByTitle(names[0])
    const next = await SportsBizService.loadUpcomingForTeam(names[0])
    const form: string = team !== undefined ? team.formStatus() : ''
    if (next !== undefined) {
      data.status = form.length > 0 ? `${form} · 下一场 ${next.title}` : `下一场 ${next.title}`
    } else if (form.length > 0 && team !== undefined) {
      data.status = `${team.statsLabel} ${form}`
    } else {
      data.status = '打开应用查看球队资料'
    }
    return data
  }

  static async loadKpis(): Promise<KpiItem[]> {
    const res = await HttpClient.get<KpiListPayload>('/biz/sports-events/kpis')
    if (res.code === 0 && res.data !== undefined && res.data.items !== undefined) {
      const out: KpiItem[] = []
      for (const w of res.data.items) {
        out.push(KpiItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async loadMatchesForLeague(leagueTitle: string): Promise<MatchItem[]> {
    const all = await SportsBizService.loadMatches('', false, '')
    const out: MatchItem[] = []
    for (const m of all) {
      if (SportsBizService.leagueMatch(m.leagueName, leagueTitle)) {
        out.push(m)
      }
    }
    return out
  }

  static leagueMatch(matchLeague: string, leagueTitle: string): boolean {
    if (matchLeague.length === 0 || leagueTitle.length === 0) {
      return false
    }
    if (matchLeague === leagueTitle) {
      return true
    }
    if (matchLeague.indexOf(leagueTitle) >= 0 || leagueTitle.indexOf(matchLeague) >= 0) {
      return true
    }
    const shortA = leagueTitle.replace(' 赛季', '').substring(0, 6)
    return matchLeague.indexOf(shortA) >= 0
  }

  static async loadStandingsForLeague(leagueTitle: string): Promise<StandingItem[]> {
    const all = await SportsBizService.loadStandings('', '')
    const out: StandingItem[] = []
    for (const row of all) {
      if (SportsBizService.leagueMatch(row.leagueName, leagueTitle)) {
        out.push(row)
      }
    }
    out.sort((a: StandingItem, b: StandingItem) => a.rank - b.rank)
    return out
  }

  static async syncFollowWidget(): Promise<void> {
    const data = await SportsBizService.buildFollowWidgetPayload()
    await FollowWidgetSync.push(data)
  }
}
