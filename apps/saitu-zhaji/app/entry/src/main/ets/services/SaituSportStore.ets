import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { SportAlbum, SportEvent, SportFollow, SportStats, TrainingLog } from '../models/SaituSportModels'

const STORE = 'saitu_zhaji_sport_v1'
const KEY_EVENTS = 'events'
const KEY_ALBUMS = 'albums'
const KEY_FOLLOWS = 'follows'
const KEY_TRAININGS = 'trainings'

export class SaituSportStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      SaituSportStore.pref = await preferences.getPreferences(context, STORE)
    } catch {
      SaituSportStore.pref = null
    }
  }

  static async loadEvents(): Promise<SportEvent[]> {
    const list = SaituSportStore.parseEvents(await SaituSportStore.getString(KEY_EVENTS, ''))
    list.sort((a, b) => b.eventDate.localeCompare(a.eventDate))
    return list
  }

  static async saveEvent(item: SportEvent): Promise<void> {
    item.updatedAt = Date.now()
    const list = await SaituSportStore.loadEvents()
    const next: SportEvent[] = []
    let found = false
    for (const it of list) {
      if (it.id === item.id) {
        next.push(item)
        found = true
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.push(item)
    }
    await SaituSportStore.persistEvents(next)
  }

  static async deleteEvent(id: string): Promise<void> {
    const list = await SaituSportStore.loadEvents()
    const next: SportEvent[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await SaituSportStore.persistEvents(next)
  }

  static async findEvent(id: string): Promise<SportEvent | undefined> {
    const list = await SaituSportStore.loadEvents()
    for (const it of list) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static async loadAlbums(): Promise<SportAlbum[]> {
    const list = SaituSportStore.parseAlbums(await SaituSportStore.getString(KEY_ALBUMS, ''))
    list.sort((a, b) => b.createdAt - a.createdAt)
    return list
  }

  static async saveAlbum(item: SportAlbum): Promise<void> {
    const list = await SaituSportStore.loadAlbums()
    const next: SportAlbum[] = []
    let found = false
    for (const it of list) {
      if (it.id === item.id) {
        next.push(item)
        found = true
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.push(item)
    }
    await SaituSportStore.persistAlbums(next)
  }

  static async deleteAlbum(id: string): Promise<void> {
    const list = await SaituSportStore.loadAlbums()
    const next: SportAlbum[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await SaituSportStore.persistAlbums(next)
    const events = await SaituSportStore.loadEvents()
    for (const e of events) {
      if (e.albumId === id) {
        e.albumId = ''
        await SaituSportStore.saveEvent(e)
      }
    }
  }

  static async findAlbum(id: string): Promise<SportAlbum | undefined> {
    const list = await SaituSportStore.loadAlbums()
    for (const it of list) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static async loadFollows(): Promise<SportFollow[]> {
    const list = SaituSportStore.parseFollows(await SaituSportStore.getString(KEY_FOLLOWS, ''))
    list.sort((a, b) => b.createdAt - a.createdAt)
    return list
  }

  static async saveFollow(item: SportFollow): Promise<void> {
    const list = await SaituSportStore.loadFollows()
    const next: SportFollow[] = []
    let found = false
    for (const it of list) {
      if (it.id === item.id) {
        next.push(item)
        found = true
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.push(item)
    }
    await SaituSportStore.persistFollows(next)
  }

  static async deleteFollow(id: string): Promise<void> {
    const list = await SaituSportStore.loadFollows()
    const next: SportFollow[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await SaituSportStore.persistFollows(next)
  }

  static async stats(): Promise<SportStats> {
    const events = await SaituSportStore.loadEvents()
    const albums = await SaituSportStore.loadAlbums()
    const follows = await SaituSportStore.loadFollows()
    const trainings = await SaituSportStore.loadTrainings()
    const s = new SportStats()
    s.albums = albums.length
    s.follows = follows.length
    s.trainings = trainings.length
    for (const e of events) {
      if (e.kind === 'note') {
        s.notes++
      } else if (e.kind === 'review') {
        s.reviews++
      } else if (e.kind === 'plan') {
        s.plans++
        if (e.status === 'pending') {
          s.pendingPlans++
        }
      } else {
        s.records++
      }
    }
    return s
  }

  static async clearAll(): Promise<void> {
    await SaituSportStore.putString(KEY_EVENTS, '')
    await SaituSportStore.putString(KEY_ALBUMS, '')
    await SaituSportStore.putString(KEY_FOLLOWS, '')
    await SaituSportStore.putString(KEY_TRAININGS, '')
  }

  static async loadTrainings(): Promise<TrainingLog[]> {
    const list = SaituSportStore.parseTrainings(await SaituSportStore.getString(KEY_TRAININGS, ''))
    list.sort((a, b) => b.logDate.localeCompare(a.logDate))
    return list
  }

  static async saveTraining(item: TrainingLog): Promise<void> {
    item.updatedAt = Date.now()
    const list = await SaituSportStore.loadTrainings()
    const next: TrainingLog[] = []
    let found = false
    for (const it of list) {
      if (it.id === item.id) {
        next.push(item)
        found = true
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.push(item)
    }
    await SaituSportStore.persistTrainings(next)
  }

  static async deleteTraining(id: string): Promise<void> {
    const list = await SaituSportStore.loadTrainings()
    const next: TrainingLog[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await SaituSportStore.persistTrainings(next)
  }

  static async findTraining(id: string): Promise<TrainingLog | undefined> {
    const list = await SaituSportStore.loadTrainings()
    for (const it of list) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static async findFollow(id: string): Promise<SportFollow | undefined> {
    const list = await SaituSportStore.loadFollows()
    for (const it of list) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static async eventsMatchingName(name: string): Promise<SportEvent[]> {
    const q = name.trim().toLowerCase()
    if (q.length === 0) {
      return []
    }
    const events = await SaituSportStore.loadEvents()
    const out: SportEvent[] = []
    for (const e of events) {
      const hay = `${e.title} ${e.homeName} ${e.awayName} ${e.tags} ${e.body}`.toLowerCase()
      if (hay.indexOf(q) >= 0) {
        out.push(e)
      }
    }
    return out
  }

  private static persistEvents(items: SportEvent[]): Promise<void> {
    const lines: string[] = []
    for (const it of items) {
      const imgs = it.images.join('|')
      lines.push([
        it.id, SaituSportStore.esc(it.title), it.eventDate, it.sportType, it.kind, it.status,
        SaituSportStore.esc(it.highlight), SaituSportStore.esc(it.body), it.tags.replace(/\t/g, ' '),
        it.albumId, `${it.createdAt}`, `${it.updatedAt}`, it.favorite ? '1' : '0',
        SaituSportStore.esc(it.homeName), SaituSportStore.esc(it.awayName),
        it.homeScore, it.awayScore, it.watchMode, `${it.mood}`, imgs,
        SaituSportStore.esc(it.reviewScene), SaituSportStore.esc(it.reviewKeyMoment),
        SaituSportStore.esc(it.reviewEmotion), SaituSportStore.esc(it.reviewTakeaway)
      ].join('\t'))
    }
    return SaituSportStore.putString(KEY_EVENTS, lines.join('\n'))
  }

  private static persistAlbums(items: SportAlbum[]): Promise<void> {
    const lines: string[] = []
    for (const it of items) {
      lines.push([it.id, SaituSportStore.esc(it.title), SaituSportStore.esc(it.description), `${it.createdAt}`].join('\t'))
    }
    return SaituSportStore.putString(KEY_ALBUMS, lines.join('\n'))
  }

  private static persistFollows(items: SportFollow[]): Promise<void> {
    const lines: string[] = []
    for (const it of items) {
      lines.push([it.id, SaituSportStore.esc(it.name), it.role, SaituSportStore.esc(it.note), `${it.createdAt}`].join('\t'))
    }
    return SaituSportStore.putString(KEY_FOLLOWS, lines.join('\n'))
  }

  private static parseEvents(raw: string): SportEvent[] {
    const out: SportEvent[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const p = line.split('\t')
      if (p.length < 12) {
        continue
      }
      const e = new SportEvent()
      e.id = p[0]
      e.title = SaituSportStore.unesc(p[1])
      e.eventDate = p[2]
      e.sportType = p[3]
      e.kind = p[4]
      e.status = p[5]
      e.highlight = SaituSportStore.unesc(p[6])
      e.body = SaituSportStore.unesc(p[7])
      e.tags = p[8]
      e.albumId = p[9]
      e.createdAt = parseInt(p[10], 10)
      e.updatedAt = parseInt(p[11], 10)
      if (p.length >= 13) {
        e.favorite = p[12] === '1'
      }
      if (p.length >= 24) {
        e.homeName = SaituSportStore.unesc(p[13])
        e.awayName = SaituSportStore.unesc(p[14])
        e.homeScore = p[15]
        e.awayScore = p[16]
        e.watchMode = p[17]
        e.mood = parseInt(p[18], 10)
        e.images = p[19].length > 0 ? p[19].split('|') : []
        e.reviewScene = SaituSportStore.unesc(p[20])
        e.reviewKeyMoment = SaituSportStore.unesc(p[21])
        e.reviewEmotion = SaituSportStore.unesc(p[22])
        e.reviewTakeaway = SaituSportStore.unesc(p[23])
      }
      out.push(e)
    }
    return out
  }

  private static parseAlbums(raw: string): SportAlbum[] {
    const out: SportAlbum[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const p = line.split('\t')
      if (p.length < 4) {
        continue
      }
      const a = new SportAlbum()
      a.id = p[0]
      a.title = SaituSportStore.unesc(p[1])
      a.description = SaituSportStore.unesc(p[2])
      a.createdAt = parseInt(p[3], 10)
      out.push(a)
    }
    return out
  }

  private static parseFollows(raw: string): SportFollow[] {
    const out: SportFollow[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const p = line.split('\t')
      if (p.length < 5) {
        continue
      }
      const f = new SportFollow()
      f.id = p[0]
      f.name = SaituSportStore.unesc(p[1])
      f.role = p[2]
      f.note = SaituSportStore.unesc(p[3])
      f.createdAt = parseInt(p[4], 10)
      out.push(f)
    }
    return out
  }

  private static esc(v: string): string {
    return v.replace(/\n/g, '\\n').replace(/\t/g, ' ')
  }

  private static unesc(v: string): string {
    return v.replace(/\\n/g, '\n')
  }

  private static async persistTrainings(items: TrainingLog[]): Promise<void> {
    const lines: string[] = []
    for (const it of items) {
      lines.push([
        it.id, SaituSportStore.esc(it.title), it.logDate, it.sportType,
        `${it.durationMin}`, `${it.intensity}`, it.journeyId,
        SaituSportStore.esc(it.body), `${it.createdAt}`, `${it.updatedAt}`
      ].join('\t'))
    }
    await SaituSportStore.putString(KEY_TRAININGS, lines.join('\n'))
  }

  private static parseTrainings(raw: string): TrainingLog[] {
    const out: TrainingLog[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const p = line.split('\t')
      if (p.length < 10) {
        continue
      }
      const t = new TrainingLog()
      t.id = p[0]
      t.title = SaituSportStore.unesc(p[1])
      t.logDate = p[2]
      t.sportType = p[3]
      t.durationMin = parseInt(p[4], 10)
      t.intensity = parseInt(p[5], 10)
      t.journeyId = p[6]
      t.body = SaituSportStore.unesc(p[7])
      t.createdAt = parseInt(p[8], 10)
      t.updatedAt = parseInt(p[9], 10)
      out.push(t)
    }
    return out
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (SaituSportStore.pref === null) {
      return fallback
    }
    try {
      const v = await SaituSportStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (SaituSportStore.pref === null) {
      return
    }
    try {
      await SaituSportStore.pref.put(key, value)
      await SaituSportStore.pref.flush()
    } catch {
      // ignore
    }
  }
}
