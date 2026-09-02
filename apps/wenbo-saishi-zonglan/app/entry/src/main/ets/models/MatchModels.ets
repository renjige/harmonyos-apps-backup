export class MatchItemWire {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  status: string = ''
  sport: string = ''
  category: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  leagueId: string = ''
  leagueName: string = ''
  homeTeam: string = ''
  awayTeam: string = ''
  homeScore: number | undefined = undefined
  awayScore: number | undefined = undefined
  startAt: string = ''
  endAt: string = ''
  venue: string = ''
  featured: boolean = false
  statsLabel: string = ''
  statsValue: string = ''
  remark: string = ''
}

export class MatchItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  status: string = ''
  sport: string = ''
  category: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  leagueId: string = ''
  leagueName: string = ''
  homeTeam: string = ''
  awayTeam: string = ''
  homeScore: number = -1
  awayScore: number = -1
  startAt: string = ''
  endAt: string = ''
  venue: string = ''
  featured: boolean = false
  statsLabel: string = ''
  statsValue: string = ''
  remark: string = ''

  static fromWire(w: MatchItemWire): MatchItem {
    const item = new MatchItem()
    item.id = w.id
    item.title = w.title
    item.subtitle = w.subtitle ?? ''
    item.status = w.status ?? 'upcoming'
    item.sport = w.sport ?? w.category ?? ''
    item.category = w.category ?? w.sport ?? ''
    item.summary = w.summary ?? ''
    item.body = w.body ?? ''
    item.description = w.description ?? w.body ?? w.summary ?? ''
    item.coverKey = w.coverKey ?? ''
    item.leagueId = w.leagueId ?? ''
    item.leagueName = w.leagueName ?? w.subtitle ?? ''
    item.homeTeam = w.homeTeam ?? ''
    item.awayTeam = w.awayTeam ?? ''
    if (w.homeScore !== undefined && w.homeScore !== null) {
      item.homeScore = w.homeScore
    }
    if (w.awayScore !== undefined && w.awayScore !== null) {
      item.awayScore = w.awayScore
    }
    item.startAt = w.startAt ?? ''
    item.endAt = w.endAt ?? ''
    item.venue = w.venue ?? ''
    item.featured = w.featured === true
    item.statsLabel = w.statsLabel ?? ''
    item.statsValue = w.statsValue ?? ''
    item.remark = w.remark ?? ''
    MatchItem.applyEffectiveStatus(item)
    return item
  }

  static applyEffectiveStatus(item: MatchItem): void {
    if (item.status === 'finished') {
      return
    }
    const startMs = MatchItem.parseIsoMs(item.startAt)
    if (startMs <= 0) {
      return
    }
    const nowMs = Date.now()
    let endMs = MatchItem.parseIsoMs(item.endAt)
    if (endMs <= 0 || endMs <= startMs) {
      endMs = startMs + 2 * 60 * 60 * 1000
    }
    if (nowMs >= endMs) {
      item.status = 'finished'
      return
    }
    if (nowMs >= startMs && item.status === 'upcoming') {
      item.status = 'live'
    }
  }

  private static parseIsoMs(iso: string): number {
    if (iso.length === 0) {
      return 0
    }
    const ms = Date.parse(iso)
    if (Number.isNaN(ms)) {
      return 0
    }
    return ms
  }

  statusLabel(): string {
    if (this.status === 'live') {
      return '进行中'
    }
    if (this.status === 'finished') {
      return '已结束'
    }
    return '未开始'
  }

  sportLabel(): string {
    if (this.sport === 'football') {
      return '足球'
    }
    if (this.sport === 'basketball') {
      return '篮球'
    }
    if (this.sport === 'tennis') {
      return '网球'
    }
    if (this.sport === 'esports') {
      return '电竞'
    }
    if (this.sport === 'other') {
      return '其他'
    }
    return '赛事'
  }

  scoreText(): string {
    if (this.homeScore >= 0 && this.awayScore >= 0) {
      return `${this.homeScore} : ${this.awayScore}`
    }
    return 'VS'
  }

  timeLabel(): string {
    if (this.startAt.length >= 16) {
      return this.startAt.slice(5, 16).replace('T', ' ')
    }
    if (this.startAt.length >= 10) {
      return this.startAt.slice(0, 10)
    }
    return ''
  }

  dateIso(): string {
    if (this.startAt.length >= 10) {
      return this.startAt.slice(0, 10)
    }
    return ''
  }

  shareText(): string {
    const parts: string[] = []
    parts.push(this.title)
    if (this.leagueName.length > 0) {
      parts.push(this.leagueName)
    }
    if (this.timeLabel().length > 0) {
      parts.push(this.timeLabel())
    }
    if (this.venue.length > 0) {
      parts.push(this.venue)
    }
    return parts.join(' · ')
  }
}

export class TeamItemWire {
  id: string = ''
  title: string = ''
  sport: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  leagueName: string = ''
  statsLabel: string = ''
  statsValue: string = ''
  featured: boolean = false
  status: string = ''
}

export class TeamItem {
  id: string = ''
  title: string = ''
  sport: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  leagueName: string = ''
  statsLabel: string = ''
  statsValue: string = ''
  featured: boolean = false
  status: string = ''

  static fromWire(w: TeamItemWire): TeamItem {
    const item = new TeamItem()
    item.id = w.id
    item.title = w.title
    item.sport = w.sport ?? ''
    item.summary = w.summary ?? ''
    item.body = w.body ?? ''
    item.description = w.description ?? w.body ?? w.summary ?? ''
    item.coverKey = w.coverKey ?? ''
    item.leagueName = w.leagueName ?? ''
    item.statsLabel = w.statsLabel ?? ''
    item.statsValue = w.statsValue ?? ''
    item.featured = w.featured === true
    item.status = w.status ?? ''
    return item
  }

  sportLabel(): string {
    if (this.sport === 'football') {
      return '足球'
    }
    if (this.sport === 'basketball') {
      return '篮球'
    }
    if (this.sport === 'tennis') {
      return '网球'
    }
    if (this.sport === 'esports') {
      return '电竞'
    }
    return '赛事'
  }
}

export class LeagueItemWire {
  id: string = ''
  title: string = ''
  sport: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  statsLabel: string = ''
  statsValue: string = ''
  status: string = ''
}

export class LeagueItem {
  id: string = ''
  title: string = ''
  sport: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  statsLabel: string = ''
  statsValue: string = ''
  status: string = ''

  static fromWire(w: LeagueItemWire): LeagueItem {
    const item = new LeagueItem()
    item.id = w.id
    item.title = w.title
    item.sport = w.sport ?? ''
    item.summary = w.summary ?? ''
    item.body = w.body ?? ''
    item.description = w.description ?? w.body ?? w.summary ?? ''
    item.coverKey = w.coverKey ?? ''
    item.statsLabel = w.statsLabel ?? ''
    item.statsValue = w.statsValue ?? ''
    item.status = w.status ?? ''
    return item
  }

  sportLabel(): string {
    if (this.sport === 'football') {
      return '足球'
    }
    if (this.sport === 'basketball') {
      return '篮球'
    }
    if (this.sport === 'tennis') {
      return '网球'
    }
    if (this.sport === 'esports') {
      return '电竞'
    }
    if (this.sport === 'other') {
      return '综合'
    }
    return '赛事'
  }
}

export class FavoriteItemWire {
  id: string = ''
  title: string = ''
  targetType: string = ''
  targetId: string = ''
  targetTitle: string = ''
  userId: string = ''
  status: string = ''
}

export class FavoriteItem {
  id: string = ''
  title: string = ''
  targetType: string = ''
  targetId: string = ''
  targetTitle: string = ''
  userId: string = ''
  status: string = ''

  static fromWire(w: FavoriteItemWire): FavoriteItem {
    const item = new FavoriteItem()
    item.id = w.id
    item.title = w.title ?? w.targetTitle ?? ''
    item.targetType = w.targetType ?? ''
    item.targetId = w.targetId ?? ''
    item.targetTitle = w.targetTitle ?? w.title ?? ''
    item.userId = w.userId ?? ''
    item.status = w.status ?? 'active'
    return item
  }

  groupLabel(): string {
    if (this.targetType === 'match') {
      return '比赛'
    }
    if (this.targetType === 'team') {
      return '球队'
    }
    if (this.targetType === 'league') {
      return '联赛'
    }
    return '关注'
  }
}

export class ReminderItemWire {
  id: string = ''
  title: string = ''
  targetType: string = ''
  targetId: string = ''
  targetTitle: string = ''
  remindMinutes: number = 30
  startAt: string = ''
  userId: string = ''
  status: string = ''
}

export class ReminderItem {
  id: string = ''
  title: string = ''
  targetType: string = ''
  targetId: string = ''
  targetTitle: string = ''
  remindMinutes: number = 30
  startAt: string = ''
  userId: string = ''
  status: string = ''
  leagueName: string = ''
  venue: string = ''
  sport: string = ''
  matchStatus: string = ''

  static fromWire(w: ReminderItemWire): ReminderItem {
    const item = new ReminderItem()
    item.id = w.id
    item.title = w.title ?? w.targetTitle ?? ''
    item.targetType = w.targetType ?? 'match'
    item.targetId = w.targetId ?? ''
    item.targetTitle = w.targetTitle ?? w.title ?? ''
    item.remindMinutes = w.remindMinutes ?? 30
    item.startAt = w.startAt ?? ''
    item.userId = w.userId ?? ''
    item.status = w.status ?? 'scheduled'
    return item
  }

  displayTitle(): string {
    if (this.title.length > 0) {
      return this.title
    }
    if (this.targetTitle.length > 0) {
      return this.targetTitle
    }
    return '比赛提醒'
  }

  kickoffLabel(): string {
    if (this.startAt.length >= 16) {
      return this.startAt.slice(0, 16).replace('T', ' ')
    }
    if (this.startAt.length >= 10) {
      return this.startAt.slice(0, 10)
    }
    return '时间待定'
  }

  remindLabel(): string {
    return `提前 ${this.remindMinutes} 分钟`
  }

  enrichFromMatch(match: MatchItem): void {
    if (this.title.length === 0) {
      this.title = match.title
    }
    if (this.targetTitle.length === 0) {
      this.targetTitle = match.title
    }
    if (this.startAt.length === 0) {
      this.startAt = match.startAt
    }
    this.leagueName = match.leagueName
    this.venue = match.venue
    this.sport = match.sport
    this.matchStatus = match.status
  }
}

export class CalendarDayWire {
  date: string = ''
  count: number = 0
}

export class CalendarDay {
  date: string = ''
  count: number = 0

  static fromWire(w: CalendarDayWire): CalendarDay {
    const day = new CalendarDay()
    day.date = w.date
    day.count = w.count ?? 0
    return day
  }
}

export class MessageItemWire {
  id: string = ''
  title: string = ''
  body: string = ''
  type: string = ''
  read: boolean = false
  createdAt: string = ''
}

export class MessageItem {
  id: string = ''
  title: string = ''
  body: string = ''
  type: string = ''
  read: boolean = false
  createdAt: string = ''

  static fromWire(w: MessageItemWire): MessageItem {
    const item = new MessageItem()
    item.id = w.id
    item.title = w.title
    item.body = w.body ?? ''
    item.type = w.type ?? 'system'
    item.read = w.read === true
    item.createdAt = w.createdAt ?? ''
    return item
  }
}

export class TimelineEvent {
  time: string = ''
  text: string = ''
  side: string = ''

  static fromJsonObject(obj: object): TimelineEvent | undefined {
    const ev = new TimelineEvent()
    const raw = JSON.stringify(obj)
    const tMatch = raw.match(/"t"\s*:\s*"([^"]*)"/)
    const eMatch = raw.match(/"e"\s*:\s*"([^"]*)"/)
    const sMatch = raw.match(/"side"\s*:\s*"([^"]*)"/)
    if (tMatch !== null && tMatch.length > 1) {
      ev.time = tMatch[1]
    }
    if (eMatch !== null && eMatch.length > 1) {
      ev.text = eMatch[1]
    }
    if (sMatch !== null && sMatch.length > 1) {
      ev.side = sMatch[1]
    }
    if (ev.text.length === 0) {
      return undefined
    }
    return ev
  }

  static parseRemark(remark: string): TimelineEvent[] {
    const out: TimelineEvent[] = []
    if (remark.length < 2) {
      return out
    }
    try {
      const parsed: object = JSON.parse(remark) as object
      if (Array.isArray(parsed)) {
        for (let i = 0; i < parsed.length; i++) {
          const row = TimelineEvent.fromJsonObject(parsed[i] as object)
          if (row !== undefined) {
            out.push(row)
          }
        }
      }
    } catch {
      // ignore malformed timeline
    }
    return out
  }
}

export class StandingItemWire {
  id: string = ''
  title: string = ''
  leagueName: string = ''
  sport: string = ''
  rank: number = 0
  played: number = 0
  win: number = 0
  draw: number = 0
  loss: number = 0
  points: number = 0
  goalDiff: string = ''
  summary: string = ''
}

export class StandingItem {
  id: string = ''
  teamName: string = ''
  leagueName: string = ''
  sport: string = ''
  rank: number = 0
  played: number = 0
  win: number = 0
  draw: number = 0
  loss: number = 0
  points: number = 0
  goalDiff: string = ''
  summary: string = ''

  static fromWire(w: StandingItemWire): StandingItem {
    const item = new StandingItem()
    item.id = w.id
    item.teamName = w.title
    item.leagueName = w.leagueName ?? ''
    item.sport = w.sport ?? ''
    item.rank = w.rank ?? 0
    item.played = w.played ?? 0
    item.win = w.win ?? 0
    item.draw = w.draw ?? 0
    item.loss = w.loss ?? 0
    item.points = w.points ?? 0
    item.goalDiff = w.goalDiff ?? ''
    item.summary = w.summary ?? ''
    return item
  }

  recordText(): string {
    if (this.summary.length > 0) {
      return this.summary
    }
    return `${this.win}胜${this.draw}平${this.loss}负`
  }
}

export class StandingListPayload {
  list: StandingItemWire[] = []
}

export class MatchListPayload {
  list: MatchItemWire[] = []
}

export class TeamListPayload {
  list: TeamItemWire[] = []
}

export class LeagueListPayload {
  list: LeagueItemWire[] = []
}

export class FavoriteListPayload {
  list: FavoriteItemWire[] = []
}

export class ReminderListPayload {
  list: ReminderItemWire[] = []
}

export class CalendarPayload {
  days: CalendarDayWire[] = []
  total: number = 0
}

export class MessageListPayload {
  list: MessageItemWire[] = []
}

export class CreateFavoriteBody {
  targetType: string = ''
  targetId: string = ''
  targetTitle: string = ''
  username: string = ''

  toJsonString(): string {
    return `{"targetType":${JSON.stringify(this.targetType)},"targetId":${JSON.stringify(this.targetId)},"targetTitle":${JSON.stringify(this.targetTitle)},"username":${JSON.stringify(this.username)}}`
  }
}

export class CreateReminderBody {
  matchId: string = ''
  matchTitle: string = ''
  remindMinutes: number = 30
  startAt: string = ''
  username: string = ''

  toJsonString(): string {
    return `{"matchId":${JSON.stringify(this.matchId)},"matchTitle":${JSON.stringify(this.matchTitle)},"remindMinutes":${this.remindMinutes},"startAt":${JSON.stringify(this.startAt)},"username":${JSON.stringify(this.username)}}`
  }
}

export class SportCategory {
  key: string = ''
  label: string = ''

  static all(): SportCategory[] {
    const out: SportCategory[] = []
    const hot = new SportCategory()
    hot.key = ''
    hot.label = '热门'
    out.push(hot)
    const football = new SportCategory()
    football.key = 'football'
    football.label = '足球'
    out.push(football)
    const basketball = new SportCategory()
    basketball.key = 'basketball'
    basketball.label = '篮球'
    out.push(basketball)
    const tennis = new SportCategory()
    tennis.key = 'tennis'
    tennis.label = '网球'
    out.push(tennis)
    const esports = new SportCategory()
    esports.key = 'esports'
    esports.label = '电竞'
    out.push(esports)
    const other = new SportCategory()
    other.key = 'other'
    other.label = '其他'
    out.push(other)
    return out
  }
}
