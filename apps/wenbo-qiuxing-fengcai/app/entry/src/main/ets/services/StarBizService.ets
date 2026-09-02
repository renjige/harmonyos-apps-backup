import { HttpClient } from './HttpClient'
import {
  AthleteItem,
  AthleteItemWire,
  AthleteListPayload,
  CreateFavoriteBody,
  CreateReminderBody,
  DeleteOkPayload,
  EventItem,
  EventItemWire,
  EventListPayload,
  FavoriteItem,
  FavoriteItemWire,
  FavoriteListPayload,
  KpiItem,
  KpiItemWire,
  KpiListPayload,
  MessageItem,
  MessageItemWire,
  MessageListPayload,
  ReminderItem,
  ReminderItemWire,
  ReminderListPayload
} from '../models/StarModels'

export class StarBizService {
  static lastError: string = ''

  private static currentUsername(): string {
    const u = AppStorage.get<string>('currentUsername')
    return u !== undefined && u !== null ? u : ''
  }

  private static mapAthletes(wires: AthleteItemWire[]): AthleteItem[] {
    const out: AthleteItem[] = []
    for (const w of wires) {
      out.push(AthleteItem.fromWire(w))
    }
    return out
  }

  private static mapEvents(wires: EventItemWire[]): EventItem[] {
    const out: EventItem[] = []
    for (const w of wires) {
      out.push(EventItem.fromWire(w))
    }
    return out
  }

  static async loadAthletes(sport: string, featured: boolean): Promise<AthleteItem[]> {
    StarBizService.lastError = ''
    let path = '/biz/sports-profiles/athletes'
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
    const res = await HttpClient.get<AthleteListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return StarBizService.mapAthletes(res.data.list)
    }
    StarBizService.lastError = res.message.length > 0 ? res.message : '加载球星失败'
    return []
  }

  static async findAthlete(id: string): Promise<AthleteItem | undefined> {
    StarBizService.lastError = ''
    const res = await HttpClient.get<AthleteItemWire>(`/biz/sports-profiles/athletes/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return AthleteItem.fromWire(res.data)
    }
    StarBizService.lastError = res.message.length > 0 ? res.message : '球星不存在'
    return undefined
  }

  static async loadEvents(sport: string, athleteId: string, status: string): Promise<EventItem[]> {
    StarBizService.lastError = ''
    let path = '/biz/sports-profiles/events'
    const params: string[] = []
    if (sport.length > 0) {
      params.push(`sport=${encodeURIComponent(sport)}`)
    }
    if (athleteId.length > 0) {
      params.push(`athleteId=${encodeURIComponent(athleteId)}`)
    }
    if (params.length > 0) {
      path = `${path}?${params.join('&')}`
    }
    const res = await HttpClient.get<EventListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      let list = StarBizService.mapEvents(res.data.list)
      if (status.length > 0) {
        list = list.filter((item: EventItem) => item.status === status)
      }
      list.sort((a: EventItem, b: EventItem) => a.startAt.localeCompare(b.startAt))
      return list
    }
    StarBizService.lastError = res.message.length > 0 ? res.message : '加载赛事失败'
    return []
  }

  static async findEvent(id: string): Promise<EventItem | undefined> {
    const res = await HttpClient.get<EventItemWire>(`/biz/sports-profiles/events/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return EventItem.fromWire(res.data)
    }
    return undefined
  }

  static async loadFavorites(username: string): Promise<FavoriteItem[]> {
    StarBizService.lastError = ''
    const uid = username.length > 0 ? username : StarBizService.currentUsername()
    if (uid.length === 0) {
      return []
    }
    const res = await HttpClient.get<FavoriteListPayload>(
      `/biz/sports-profiles/favorites?username=${encodeURIComponent(uid)}`
    )
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: FavoriteItem[] = []
      for (const w of res.data.list) {
        out.push(FavoriteItem.fromWire(w))
      }
      return out
    }
    StarBizService.lastError = res.message.length > 0 ? res.message : '加载关注失败'
    return []
  }

  static async createFavorite(targetId: string, targetTitle: string): Promise<FavoriteItem | undefined> {
    StarBizService.lastError = ''
    const body = new CreateFavoriteBody()
    body.targetType = 'athlete'
    body.targetId = targetId
    body.targetTitle = targetTitle
    body.username = StarBizService.currentUsername()
    const res = await HttpClient.post<FavoriteItemWire>('/biz/sports-profiles/favorites', body)
    if (res.code === 0 && res.data !== undefined) {
      return FavoriteItem.fromWire(res.data)
    }
    StarBizService.lastError = res.message.length > 0 ? res.message : '关注失败'
    return undefined
  }

  static async removeFavorite(id: string): Promise<boolean> {
    StarBizService.lastError = ''
    const res = await HttpClient.delete<DeleteOkPayload>(`/biz/sports-profiles/favorites/${id}`)
    if (res.code === 0) {
      return true
    }
    StarBizService.lastError = res.message.length > 0 ? res.message : '取消关注失败'
    return false
  }

  static async loadReminders(username: string): Promise<ReminderItem[]> {
    const uid = username.length > 0 ? username : StarBizService.currentUsername()
    if (uid.length === 0) {
      return []
    }
    const res = await HttpClient.get<ReminderListPayload>(
      `/biz/sports-profiles/reminders?username=${encodeURIComponent(uid)}`
    )
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: ReminderItem[] = []
      for (const w of res.data.list) {
        out.push(ReminderItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async createReminder(
    event: EventItem,
    athlete: AthleteItem,
    remindMinutes: number
  ): Promise<ReminderItem | undefined> {
    StarBizService.lastError = ''
    const body = new CreateReminderBody()
    body.eventId = event.id
    body.eventTitle = event.title
    body.athleteId = athlete.id
    body.athleteName = athlete.title
    body.remindMinutes = remindMinutes
    body.startAt = event.startAt
    body.username = StarBizService.currentUsername()
    const res = await HttpClient.post<ReminderItemWire>('/biz/sports-profiles/reminders', body)
    if (res.code === 0 && res.data !== undefined) {
      return ReminderItem.fromWire(res.data)
    }
    StarBizService.lastError = res.message.length > 0 ? res.message : '设置提醒失败'
    return undefined
  }

  static async removeReminder(id: string): Promise<boolean> {
    const res = await HttpClient.delete<DeleteOkPayload>(`/biz/sports-profiles/reminders/${id}`)
    return res.code === 0
  }

  static async loadKpis(): Promise<KpiItem[]> {
    const res = await HttpClient.get<KpiListPayload>('/biz/sports-profiles/kpis')
    if (res.code === 0 && res.data !== undefined && res.data.items !== undefined) {
      const out: KpiItem[] = []
      for (const w of res.data.items) {
        out.push(KpiItem.fromWire(w))
      }
      return out
    }
    return []
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

  static async loadFollowedEvents(favorites: FavoriteItem[]): Promise<EventItem[]> {
    const merged: EventItem[] = []
    const seen: string[] = []
    for (const fav of favorites) {
      if (fav.targetType !== 'athlete') {
        continue
      }
      const events = await StarBizService.loadEvents('', fav.targetId, 'upcoming')
      for (const ev of events) {
        let exists = false
        for (const id of seen) {
          if (id === ev.id) {
            exists = true
            break
          }
        }
        if (!exists) {
          seen.push(ev.id)
          merged.push(ev)
        }
      }
    }
    return merged
  }
}
