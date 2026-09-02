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
    return item
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

export class PlayerLine {
  name: string = ''
  position: string = ''
}

export class BarChartItem {
  value: number = 0
  label: string = ''
}

export class TeamItemWire {
  id: string = ''
  title: string = ''
  sport: string = ''
  summary: string = ''
  description: string = ''
  body: string = ''
  coverKey: string = ''
  status: string = ''
  leagueName: string = ''
  statsLabel: string = ''
  statsValue: string = ''
  featured: boolean = false
  region: string = ''
  styleTag: string = ''
  stadium: string = ''
  honors: string = ''
  roster: string = ''
  attackNote: string = ''
  defenseNote: string = ''
  historyNote: string = ''
  goalsFor: string = ''
  goalsAgainst: string = ''
  homeRecord: string = ''
  awayRecord: string = ''
  attackIndex: number = 0
  defenseIndex: number = 0
  newsTitle: string = ''
  newsBody: string = ''
}

export class TeamItem {
  id: string = ''
  title: string = ''
  sport: string = ''
  summary: string = ''
  description: string = ''
  body: string = ''
  coverKey: string = ''
  status: string = ''
  leagueName: string = ''
  statsLabel: string = ''
  statsValue: string = ''
  featured: boolean = false
  region: string = ''
  styleTag: string = ''
  stadium: string = ''
  honors: string = ''
  roster: string = ''
  attackNote: string = ''
  defenseNote: string = ''
  historyNote: string = ''
  goalsFor: string = ''
  goalsAgainst: string = ''
  homeRecord: string = ''
  awayRecord: string = ''
  attackIndex: number = 0
  defenseIndex: number = 0
  newsTitle: string = ''
  newsBody: string = ''

  static fromWire(w: TeamItemWire): TeamItem {
    const item = new TeamItem()
    item.id = w.id
    item.title = w.title
    item.sport = w.sport ?? ''
    item.summary = w.summary ?? ''
    item.description = w.description ?? w.summary ?? ''
    item.body = w.body ?? w.description ?? w.summary ?? ''
    item.coverKey = w.coverKey ?? ''
    item.status = w.status ?? ''
    item.leagueName = w.leagueName ?? ''
    item.statsLabel = w.statsLabel ?? ''
    item.statsValue = w.statsValue ?? ''
    item.featured = w.featured === true
    item.region = w.region ?? ''
    item.styleTag = w.styleTag ?? ''
    item.stadium = w.stadium ?? ''
    item.honors = w.honors ?? ''
    item.roster = w.roster ?? ''
    item.attackNote = w.attackNote ?? ''
    item.defenseNote = w.defenseNote ?? ''
    item.historyNote = w.historyNote ?? ''
    item.goalsFor = w.goalsFor ?? ''
    item.goalsAgainst = w.goalsAgainst ?? ''
    item.homeRecord = w.homeRecord ?? ''
    item.awayRecord = w.awayRecord ?? ''
    item.attackIndex = w.attackIndex ?? 0
    item.defenseIndex = w.defenseIndex ?? 0
    item.newsTitle = w.newsTitle ?? ''
    item.newsBody = w.newsBody ?? ''
    return item
  }

  regionLabel(): string {
    if (this.region === 'international') {
      return '国际球队'
    }
    if (this.region === 'domestic') {
      return '国内球队'
    }
    return '联赛球队'
  }

  styleTagLabel(): string {
    if (this.styleTag === 'attack') {
      return '强攻型球队'
    }
    if (this.styleTag === 'defense') {
      return '防守型球队'
    }
    if (this.styleTag === 'young') {
      return '年轻阵容'
    }
    if (this.styleTag === 'giant') {
      return '传统豪门'
    }
    if (this.styleTag === 'darkhorse') {
      return '黑马球队'
    }
    return ''
  }

  parseRoster(): PlayerLine[] {
    const out: PlayerLine[] = []
    if (this.roster.length === 0) {
      return out
    }
    const parts = this.roster.split(';')
    for (const part of parts) {
      const text = part.trim()
      if (text.length === 0) {
        continue
      }
      const line = new PlayerLine()
      const sep = text.indexOf('·')
      if (sep > 0) {
        line.name = text.substring(0, sep)
        line.position = text.substring(sep + 1)
      } else {
        line.name = text
        line.position = '核心'
      }
      out.push(line)
    }
    return out
  }

  gfgaText(): string {
    if (this.goalsFor.length > 0 || this.goalsAgainst.length > 0) {
      return `进 ${this.goalsFor.length > 0 ? this.goalsFor : '—'} / 失 ${this.goalsAgainst.length > 0 ? this.goalsAgainst : '—'}`
    }
    return ''
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
    return '综合'
  }

  formStatus(): string {
    if (this.statsValue.length > 0) {
      return this.statsValue
    }
    return '数据整理中'
  }

  shareText(): string {
    const parts: string[] = []
    parts.push(this.title)
    if (this.leagueName.length > 0) {
      parts.push(this.leagueName)
    }
    parts.push(this.sportLabel())
    if (this.statsLabel.length > 0 && this.statsValue.length > 0) {
      parts.push(`${this.statsLabel} ${this.statsValue}`)
    }
    return parts.join(' · ')
  }
}

export class LeagueItemWire {
  id: string = ''
  title: string = ''
  sport: string = ''
  summary: string = ''
  description: string = ''
  body: string = ''
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
    return '综合'
  }
}

export class KpiItemWire {
  key: string = ''
  label: string = ''
  value: number = 0
}

export class KpiItem {
  key: string = ''
  label: string = ''
  value: number = 0

  static fromWire(w: KpiItemWire): KpiItem {
    const item = new KpiItem()
    item.key = w.key ?? ''
    item.label = w.label ?? ''
    item.value = w.value ?? 0
    return item
  }
}

export class KpiListPayload {
  items: KpiItemWire[] = []
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

  remindLabel(): string {
    return `提前 ${this.remindMinutes} 分钟`
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

  rankText(): string {
    if (this.rank > 0) {
      return `第 ${this.rank} 名`
    }
    return '未上榜'
  }

  winRateText(): string {
    if (this.played <= 0) {
      return '—'
    }
    const pct = Math.round((this.win / this.played) * 100)
    return `胜率 ${pct}%`
  }
}

export class StandingListPayload {
  list: StandingItemWire[] = []
}

export class FollowWidgetPayload {
  title: string = '球队研判'
  count: string = '0'
  preview: string = '尚未关注球队'
  status: string = '关注后，卡片将显示近期状态'
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

  static teamCategories(): SportCategory[] {
    const out: SportCategory[] = []
    const all = new SportCategory()
    all.key = ''
    all.label = '全部'
    out.push(all)
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
    return out
  }

  static regionCategories(): SportCategory[] {
    const out: SportCategory[] = []
    const all = new SportCategory()
    all.key = ''
    all.label = '全部'
    out.push(all)
    const domestic = new SportCategory()
    domestic.key = 'domestic'
    domestic.label = '国内球队'
    out.push(domestic)
    const international = new SportCategory()
    international.key = 'international'
    international.label = '国际球队'
    out.push(international)
    const league = new SportCategory()
    league.key = 'league'
    league.label = '联赛球队'
    out.push(league)
    return out
  }

  static styleTagCategories(): SportCategory[] {
    const out: SportCategory[] = []
    const all = new SportCategory()
    all.key = ''
    all.label = '全部标签'
    out.push(all)
    const attack = new SportCategory()
    attack.key = 'attack'
    attack.label = '强攻型'
    out.push(attack)
    const defense = new SportCategory()
    defense.key = 'defense'
    defense.label = '防守型'
    out.push(defense)
    const young = new SportCategory()
    young.key = 'young'
    young.label = '年轻阵容'
    out.push(young)
    const giant = new SportCategory()
    giant.key = 'giant'
    giant.label = '传统豪门'
    out.push(giant)
    const darkhorse = new SportCategory()
    darkhorse.key = 'darkhorse'
    darkhorse.label = '黑马'
    out.push(darkhorse)
    return out
  }
}
