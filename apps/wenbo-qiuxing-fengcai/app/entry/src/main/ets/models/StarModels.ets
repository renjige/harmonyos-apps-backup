import { EventStatusUtil } from '../services/EventStatusUtil'

export class AthleteItemWire {
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
  nationality: string = ''
  birthYear: number | undefined = undefined
  team: string = ''
  position: string = ''
  tags: string = ''
  achievements: string = ''
  statsLabel: string = ''
  statsValue: string = ''
  featured: boolean = false
}

export class AthleteItem {
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
  nationality: string = ''
  birthYear: number = 0
  team: string = ''
  position: string = ''
  tags: string[] = []
  achievements: string = ''
  statsLabel: string = ''
  statsValue: string = ''
  featured: boolean = false

  static fromWire(w: AthleteItemWire): AthleteItem {
    const item = new AthleteItem()
    item.id = w.id
    item.title = w.title
    item.subtitle = w.subtitle ?? ''
    item.status = w.status ?? 'active'
    item.sport = w.sport ?? w.category ?? ''
    item.category = w.category ?? w.sport ?? ''
    item.summary = w.summary ?? ''
    item.body = w.body ?? ''
    item.description = w.description ?? w.body ?? w.summary ?? ''
    item.coverKey = w.coverKey ?? ''
    item.nationality = w.nationality ?? ''
    if (w.birthYear !== undefined && w.birthYear !== null) {
      item.birthYear = w.birthYear
    }
    item.team = w.team ?? ''
    item.position = w.position ?? ''
    item.tags = AthleteItem.parseTags(w.tags ?? '')
    item.achievements = w.achievements ?? ''
    item.statsLabel = w.statsLabel ?? ''
    item.statsValue = w.statsValue ?? ''
    item.featured = w.featured === true
    return item
  }

  private static parseTags(raw: string): string[] {
    const out: string[] = []
    if (raw.length === 0) {
      return out
    }
    const parts = raw.split(',')
    for (const part of parts) {
      const trimmed = part.trim()
      if (trimmed.length > 0) {
        out.push(trimmed)
      }
    }
    return out
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
    if (this.sport === 'racing') {
      return '赛车'
    }
    if (this.sport === 'other') {
      return '其他'
    }
    return '体育'
  }

  metaLine(): string {
    const parts: string[] = []
    if (this.team.length > 0) {
      parts.push(this.team)
    }
    if (this.position.length > 0) {
      parts.push(this.position)
    }
    if (this.nationality.length > 0) {
      parts.push(this.nationality)
    }
    return parts.join(' · ')
  }

  shareText(): string {
    const parts: string[] = []
    parts.push(this.title)
    parts.push(this.sportLabel())
    if (this.team.length > 0) {
      parts.push(this.team)
    }
    if (this.summary.length > 0) {
      parts.push(this.summary)
    }
    parts.push('来自「球星风采」')
    return parts.join(' · ')
  }
}

export class EventItemWire {
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
  athleteId: string = ''
  athleteName: string = ''
  opponent: string = ''
  leagueName: string = ''
  startAt: string = ''
  endAt: string = ''
  venue: string = ''
  featured: boolean = false
}

export class EventItem {
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
  athleteId: string = ''
  athleteName: string = ''
  opponent: string = ''
  leagueName: string = ''
  startAt: string = ''
  endAt: string = ''
  venue: string = ''
  featured: boolean = false

  static fromWire(w: EventItemWire): EventItem {
    const item = new EventItem()
    item.id = w.id
    item.title = w.title
    item.subtitle = w.subtitle ?? ''
    item.status = EventStatusUtil.resolve(w.status ?? 'upcoming', w.startAt ?? '', w.endAt ?? '')
    item.sport = w.sport ?? w.category ?? ''
    item.category = w.category ?? w.sport ?? ''
    item.summary = w.summary ?? ''
    item.body = w.body ?? ''
    item.description = w.description ?? w.body ?? w.summary ?? ''
    item.coverKey = w.coverKey ?? ''
    item.athleteId = w.athleteId ?? ''
    item.athleteName = w.athleteName ?? ''
    item.opponent = w.opponent ?? ''
    item.leagueName = w.leagueName ?? w.subtitle ?? ''
    item.startAt = w.startAt ?? ''
    item.endAt = w.endAt ?? ''
    item.venue = w.venue ?? ''
    item.featured = w.featured === true
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

  timeLabel(): string {
    if (this.startAt.length >= 16) {
      return this.startAt.slice(5, 16).replace('T', ' ')
    }
    if (this.startAt.length >= 10) {
      return this.startAt.slice(0, 10)
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
    if (this.sport === 'racing') {
      return '赛车'
    }
    if (this.sport === 'other') {
      return '其他'
    }
    return '赛事'
  }

  countdownLabel(): string {
    if (this.status === 'finished') {
      return '已结束'
    }
    if (this.startAt.length < 16) {
      return this.timeLabel()
    }
    const stamp = Date.parse(this.startAt)
    if (stamp !== stamp) {
      return this.timeLabel()
    }
    const diff = stamp - Date.now()
    if (diff <= 0) {
      if (this.status === 'live') {
        return '正在进行'
      }
      return '已开赛'
    }
    const mins = Math.floor(diff / 60000)
    const hours = Math.floor(mins / 60)
    const days = Math.floor(hours / 24)
    if (days > 0) {
      return `${days} 天后开赛`
    }
    if (hours > 0) {
      return `${hours} 小时后开赛`
    }
    return `${mins} 分钟后开赛`
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
}

export class ReminderItemWire {
  id: string = ''
  title: string = ''
  targetType: string = ''
  targetId: string = ''
  targetTitle: string = ''
  athleteId: string = ''
  athleteName: string = ''
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
  athleteId: string = ''
  athleteName: string = ''
  remindMinutes: number = 30
  startAt: string = ''
  userId: string = ''
  status: string = ''

  static fromWire(w: ReminderItemWire): ReminderItem {
    const item = new ReminderItem()
    item.id = w.id
    item.title = w.title ?? w.targetTitle ?? ''
    item.targetType = w.targetType ?? 'event'
    item.targetId = w.targetId ?? ''
    item.targetTitle = w.targetTitle ?? w.title ?? ''
    item.athleteId = w.athleteId ?? ''
    item.athleteName = w.athleteName ?? ''
    item.remindMinutes = w.remindMinutes ?? 30
    item.startAt = w.startAt ?? ''
    item.userId = w.userId ?? ''
    item.status = w.status ?? 'scheduled'
    return item
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
    item.title = w.title ?? ''
    item.body = w.body ?? ''
    item.type = w.type ?? ''
    item.read = w.read === true
    item.createdAt = w.createdAt ?? ''
    return item
  }
}

export class AthleteListPayload {
  list: AthleteItemWire[] = []
}

export class EventListPayload {
  list: EventItemWire[] = []
}

export class FavoriteListPayload {
  list: FavoriteItemWire[] = []
}

export class ReminderListPayload {
  list: ReminderItemWire[] = []
}

export class MessageListPayload {
  list: MessageItemWire[] = []
}

export class CreateFavoriteBody {
  targetType: string = 'athlete'
  targetId: string = ''
  targetTitle: string = ''
  username: string = ''
}

export class CreateReminderBody {
  eventId: string = ''
  eventTitle: string = ''
  athleteId: string = ''
  athleteName: string = ''
  remindMinutes: number = 30
  startAt: string = ''
  username: string = ''
}

export class DeleteOkPayload {
  id: string = ''
}

export class HistoryEntry {
  id: string = ''
  title: string = ''
  kind: string = 'athlete'
  viewedAt: number = 0

  kindLabel(): string {
    if (this.kind === 'event') {
      return '赛事'
    }
    return '球星'
  }

  timeLabel(): string {
    const d = new Date(this.viewedAt)
    const m = d.getMonth() + 1
    const day = d.getDate()
    const h = d.getHours()
    const min = d.getMinutes()
    const mm = m < 10 ? `0${m}` : `${m}`
    const dd = day < 10 ? `0${day}` : `${day}`
    const hh = h < 10 ? `0${h}` : `${h}`
    const mi = min < 10 ? `0${min}` : `${min}`
    return `${mm}-${dd} ${hh}:${mi}`
  }
}

export class KpiItemWire {
  id: string = ''
  label: string = ''
  value: string = ''
  unit: string = ''
}

export class KpiItem {
  id: string = ''
  label: string = ''
  value: string = ''
  unit: string = ''

  static fromWire(w: KpiItemWire): KpiItem {
    const item = new KpiItem()
    item.id = w.id ?? ''
    item.label = w.label ?? ''
    item.value = w.value ?? ''
    item.unit = w.unit ?? ''
    return item
  }

  displayValue(): string {
    if (this.unit.length > 0) {
      return `${this.value}${this.unit}`
    }
    return this.value
  }
}

export class KpiListPayload {
  items: KpiItemWire[] = []
}

export class ScoutNote {
  athleteId: string = ''
  title: string = ''
  sport: string = ''
  techScore: number = 3
  formScore: number = 3
  note: string = ''
  updatedAt: number = 0

  scoreLine(): string {
    return `技术 ${this.techScore} · 状态 ${this.formScore}`
  }
}

export class WatchPlanItem {
  eventId: string = ''
  title: string = ''
  startAt: string = ''
  venue: string = ''
  athleteName: string = ''
  watched: boolean = false
  addedAt: number = 0
}

export class QuizChoice {
  id: string = ''
  text: string = ''
  correct: boolean = false
}

export class QuizQuestion {
  id: string = ''
  prompt: string = ''
  athleteId: string = ''
  choices: QuizChoice[] = []
}
