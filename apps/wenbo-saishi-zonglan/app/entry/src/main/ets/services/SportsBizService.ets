import { HttpClient } from './HttpClient'
import { EmptyPayload } from '../models/ApiModels'
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
  StandingItem,
  StandingItemWire,
  StandingListPayload,
  TeamItem,
  TeamItemWire,
  TeamListPayload
} from '../models/MatchModels'
import {
  ActivityFeedItem,
  ActivityFeedListPayload,
  ActivityFeedWire,
  CreateViewingNoteBody,
  CreateViewingPlanBody,
  CreateWatchCheckinBody,
  UserStatsPayload,
  ViewingNoteItem,
  ViewingNoteListPayload,
  ViewingNoteWire,
  ViewingPlanItem,
  ViewingPlanListPayload,
  ViewingPlanWire,
  WatchCheckinItem,
  WatchCheckinListPayload,
  WatchCheckinWire
} from '../models/ViewingModels'

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
    if (params.length > 0) {
      path = `${path}?${params.join('&')}`
    }
    const res = await HttpClient.get<MatchListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: MatchItem[] = []
      for (const w of res.data.list) {
        out.push(MatchItem.fromWire(w))
      }
      if (status.length > 0) {
        return SportsBizService.filterByStatus(out, status)
      }
      return out
    }
    SportsBizService.lastError = res.message.length > 0 ? res.message : '加载比赛失败'
    return []
  }

  private static filterByStatus(items: MatchItem[], status: string): MatchItem[] {
    const out: MatchItem[] = []
    for (const m of items) {
      if (m.status === status) {
        out.push(m)
      }
    }
    return out
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

  static async loadTeams(sport: string): Promise<TeamItem[]> {
    let path = '/biz/sports-events/teams'
    if (sport.length > 0) {
      path = `${path}?sport=${encodeURIComponent(sport)}`
    }
    const res = await HttpClient.get<TeamListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: TeamItem[] = []
      for (const w of res.data.list) {
        out.push(TeamItem.fromWire(w))
      }
      return out
    }
    return []
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
      return FavoriteItem.fromWire(res.data)
    }
    SportsBizService.lastError = res.message.length > 0 ? res.message : '关注失败'
    return undefined
  }

  static async removeFavorite(id: string): Promise<boolean> {
    SportsBizService.lastError = ''
    const res = await HttpClient.delete<EmptyPayload>(`/biz/sports-events/favorites/${id}`)
    if (res.code === 0) {
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
      await SportsBizService.enrichReminders(out)
      return out
    }
    return []
  }

  private static async enrichReminders(list: ReminderItem[]): Promise<void> {
    for (const row of list) {
      if (row.targetType !== 'match' || row.targetId.length === 0) {
        continue
      }
      const match = await SportsBizService.findMatch(row.targetId)
      if (match !== undefined) {
        row.enrichFromMatch(match)
      }
    }
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
    const res = await HttpClient.delete<EmptyPayload>(`/biz/sports-events/reminders/${id}`)
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

  static async loadTeamUpcoming(teamTitle: string, limit: number): Promise<MatchItem[]> {
    if (teamTitle.length === 0) {
      return []
    }
    const all = await SportsBizService.loadMatches('', false, '')
    const out: MatchItem[] = []
    for (const m of all) {
      if (m.status === 'upcoming' || m.status === 'live') {
        if (m.homeTeam === teamTitle || m.awayTeam === teamTitle) {
          out.push(m)
        }
      }
    }
    out.sort((a: MatchItem, b: MatchItem) => a.startAt.localeCompare(b.startAt))
    return out.slice(0, limit)
  }

  static weekendMatches(all: MatchItem[]): MatchItem[] {
    const out: MatchItem[] = []
    const now = new Date()
    const day = now.getDay()
    const daysUntilSat = day === 6 ? 0 : day === 0 ? 6 : 6 - day
    const sat = new Date(now)
    sat.setDate(now.getDate() + daysUntilSat)
    const sun = new Date(sat)
    sun.setDate(sat.getDate() + 1)
    const satIso = SportsBizService.isoFromDate(sat)
    const sunIso = SportsBizService.isoFromDate(sun)
    for (const m of all) {
      const d = m.dateIso()
      if (d === satIso || d === sunIso) {
        if (m.status === 'upcoming' || m.status === 'live') {
          out.push(m)
        }
      }
    }
    out.sort((a: MatchItem, b: MatchItem) => a.startAt.localeCompare(b.startAt))
    return out
  }

  private static isoFromDate(d: Date): string {
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms: string = m < 10 ? `0${m}` : `${m}`
    const ds: string = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${ms}-${ds}`
  }

  static async loadViewingPlans(username: string): Promise<ViewingPlanItem[]> {
    const uid = username.length > 0 ? username : SportsBizService.currentUsername()
    if (uid.length === 0) {
      return []
    }
    const path = `/biz/sports-events/viewing-plans?username=${encodeURIComponent(uid)}`
    const res = await HttpClient.get<ViewingPlanListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: ViewingPlanItem[] = []
      for (const w of res.data.list) {
        out.push(ViewingPlanItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async createViewingPlan(body: CreateViewingPlanBody): Promise<ViewingPlanItem | undefined> {
    SportsBizService.lastError = ''
    body.username = SportsBizService.currentUsername()
    const res = await HttpClient.post<ViewingPlanWire>('/biz/sports-events/viewing-plans', body)
    if (res.code === 0 && res.data !== undefined) {
      return ViewingPlanItem.fromWire(res.data)
    }
    SportsBizService.lastError = res.message.length > 0 ? res.message : '创建计划失败'
    return undefined
  }

  static async loadViewingNotes(username: string): Promise<ViewingNoteItem[]> {
    const uid = username.length > 0 ? username : SportsBizService.currentUsername()
    if (uid.length === 0) {
      return []
    }
    const path = `/biz/sports-events/viewing-notes?username=${encodeURIComponent(uid)}`
    const res = await HttpClient.get<ViewingNoteListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: ViewingNoteItem[] = []
      for (const w of res.data.list) {
        out.push(ViewingNoteItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async createViewingNote(body: CreateViewingNoteBody): Promise<ViewingNoteItem | undefined> {
    SportsBizService.lastError = ''
    body.username = SportsBizService.currentUsername()
    const res = await HttpClient.post<ViewingNoteWire>('/biz/sports-events/viewing-notes', body)
    if (res.code === 0 && res.data !== undefined) {
      return ViewingNoteItem.fromWire(res.data)
    }
    SportsBizService.lastError = res.message.length > 0 ? res.message : '保存笔记失败'
    return undefined
  }

  static async loadWatchCheckins(username: string): Promise<WatchCheckinItem[]> {
    const uid = username.length > 0 ? username : SportsBizService.currentUsername()
    if (uid.length === 0) {
      return []
    }
    const path = `/biz/sports-events/watch-checkins?username=${encodeURIComponent(uid)}`
    const res = await HttpClient.get<WatchCheckinListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: WatchCheckinItem[] = []
      for (const w of res.data.list) {
        out.push(WatchCheckinItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async createWatchCheckin(body: CreateWatchCheckinBody): Promise<WatchCheckinItem | undefined> {
    SportsBizService.lastError = ''
    body.username = SportsBizService.currentUsername()
    if (body.watchedAt.length === 0) {
      body.watchedAt = new Date().toISOString()
    }
    const res = await HttpClient.post<WatchCheckinWire>('/biz/sports-events/watch-checkins', body)
    if (res.code === 0 && res.data !== undefined) {
      return WatchCheckinItem.fromWire(res.data)
    }
    SportsBizService.lastError = res.message.length > 0 ? res.message : '打卡失败'
    return undefined
  }

  static async loadUserStats(username: string): Promise<UserStatsPayload | undefined> {
    const uid = username.length > 0 ? username : SportsBizService.currentUsername()
    if (uid.length === 0) {
      return undefined
    }
    const path = `/biz/sports-events/user-stats?username=${encodeURIComponent(uid)}`
    const res = await HttpClient.get<UserStatsPayload>(path)
    if (res.code === 0 && res.data !== undefined) {
      return res.data
    }
    return undefined
  }

  static async loadActivityFeed(username: string, limit: number): Promise<ActivityFeedItem[]> {
    const uid = username.length > 0 ? username : SportsBizService.currentUsername()
    if (uid.length === 0) {
      return []
    }
    const path = `/biz/sports-events/activity-feed?username=${encodeURIComponent(uid)}&limit=${limit}`
    const res = await HttpClient.get<ActivityFeedListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: ActivityFeedItem[] = []
      for (const w of res.data.list) {
        out.push(ActivityFeedItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async search(keyword: string, sport: string): Promise<SearchBundle> {
    const bundle = new SearchBundle()
    if (keyword.trim().length === 0) {
      return bundle
    }
    let path = `/biz/sports-events/search?q=${encodeURIComponent(keyword.trim())}`
    if (sport.length > 0) {
      path = `${path}&sport=${encodeURIComponent(sport)}`
    }
    const res = await HttpClient.get<SearchResultWire>(path)
    if (res.code === 0 && res.data !== undefined) {
      if (res.data.matches !== undefined) {
        for (const w of res.data.matches) {
          bundle.matches.push(MatchItem.fromWire(w))
        }
      }
      if (res.data.teams !== undefined) {
        for (const w of res.data.teams) {
          bundle.teams.push(TeamItem.fromWire(w))
        }
      }
      if (res.data.leagues !== undefined) {
        for (const w of res.data.leagues) {
          bundle.leagues.push(LeagueItem.fromWire(w))
        }
      }
    }
    return bundle
  }

  static async loadTodayWatchList(): Promise<MatchItem[]> {
    const reminders = await SportsBizService.loadReminders('')
    const all = await SportsBizService.loadMatches('', false, '')
    const today = SportsBizService.todayIso()
    const out: MatchItem[] = []
    const seen: string[] = []
    for (const r of reminders) {
      if (r.startAt.length >= 10 && r.startAt.slice(0, 10) === today) {
        for (const m of all) {
          if (m.id === r.targetId && seen.indexOf(m.id) < 0) {
            out.push(m)
            seen.push(m.id)
          }
        }
      }
    }
    const plans = await SportsBizService.loadViewingPlans('')
    for (const p of plans) {
      if (p.status !== 'active') {
        continue
      }
      for (const mid of p.meta.matchIds) {
        if (seen.indexOf(mid) >= 0) {
          continue
        }
        for (const m of all) {
          if (m.id === mid && m.dateIso() === today) {
            out.push(m)
            seen.push(m.id)
          }
        }
      }
    }
    out.sort((a: MatchItem, b: MatchItem) => a.startAt.localeCompare(b.startAt))
    return out
  }

  static async findActivePlanForMatch(matchId: string): Promise<ViewingPlanItem | undefined> {
    const plans = await SportsBizService.loadViewingPlans('')
    for (const p of plans) {
      if (p.status !== 'active') {
        continue
      }
      for (const mid of p.meta.matchIds) {
        if (mid === matchId) {
          return p
        }
      }
    }
    return undefined
  }
}

export class SearchBundle {
  matches: MatchItem[] = []
  teams: TeamItem[] = []
  leagues: LeagueItem[] = []
}

class SearchResultWire {
  matches: MatchItemWire[] = []
  teams: TeamItemWire[] = []
  leagues: LeagueItemWire[] = []
}
