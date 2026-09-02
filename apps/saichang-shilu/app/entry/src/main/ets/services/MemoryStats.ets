import { SportRecord, SportTypeOption } from '../models/SportRecord'
import { TagStat } from '../models/SportExtra'
import {
  AchieveItem,
  CollectItem,
  DashStats,
  SearchHit,
  SeasonReport,
  StatusCounts,
  TimelineEntry,
  TimelineGroup,
  WatchStatus
} from '../models/CollectModels'
import { RecordStore } from './RecordStore'
import { CollectStore } from './CollectStore'

export class MemoryStats {
  static async dash(): Promise<DashStats> {
    const s = new DashStats()
    const matches = await RecordStore.loadAll()
    const items = await CollectStore.loadAll()
    s.matches = matches.length
    const week = MemoryStats.weekStart()
    for (const m of matches) {
      if (WatchStatus.isPending(m.status)) {
        s.want++
      }
      if (m.recapSummary.length > 0 || m.recapPhases.length > 0) {
        s.recaps++
        if (m.updatedAt >= week) {
          s.weekRecaps++
        }
      }
      if (m.createdAt >= week) {
        s.weekMatches++
      }
    }
    for (const it of items) {
      if (it.kind === 'moment') {
        s.moments++
        if (it.createdAt >= week) {
          s.weekMoments++
        }
      } else if (it.kind === 'team') {
        s.teams++
      } else if (it.kind === 'player') {
        s.players++
      } else if (it.kind === 'note') {
        s.notes++
      } else if (it.kind === 'album') {
        s.collections++
      }
    }
    return s
  }

  static async statusCounts(): Promise<StatusCounts> {
    const s = new StatusCounts()
    const list = await RecordStore.loadAll()
    s.all = list.length
    for (const it of list) {
      const st = WatchStatus.normalize(it.status)
      it.status = st
      if (st === 'want') {
        s.want++
      } else if (st === 'focus') {
        s.focus++
      } else {
        s.watched++
      }
    }
    return s
  }

  static weekStart(): number {
    const d = new Date()
    const day = d.getDay()
    const diff = day === 0 ? 6 : day - 1
    d.setHours(0, 0, 0, 0)
    d.setDate(d.getDate() - diff)
    return d.getTime()
  }

  static achievements(s: DashStats): AchieveItem[] {
    const defs: string[][] = [
      ['first', '初次观赛', '🏅', s.matches >= 1 ? '1' : '0'],
      ['ten', '十场记录', '🔟', s.matches >= 10 ? '1' : '0'],
      ['fan', '观赛达人', '⭐', s.matches >= 30 ? '1' : '0'],
      ['classic', '经典收藏家', '📌', s.collections + s.moments >= 5 ? '1' : '0'],
      ['recap', '复盘达人', '📝', s.recaps >= 5 ? '1' : '0'],
      ['hundred', '百场纪念', '💯', s.matches >= 100 ? '1' : '0']
    ]
    const out: AchieveItem[] = []
    for (const row of defs) {
      const a = new AchieveItem()
      a.id = row[0]
      a.title = row[1]
      a.emoji = row[2]
      a.done = row[3] === '1'
      out.push(a)
    }
    return out
  }

  static async buildTimeline(): Promise<TimelineGroup[]> {
    const matches = await RecordStore.loadAll()
    const items = await CollectStore.loadAll()
    const bucket = new Map<string, TimelineEntry[]>()

    for (const m of matches) {
      const key = MemoryStats.monthKey(m.date)
      const e = new TimelineEntry()
      e.id = m.id
      e.kind = 'match'
      e.title = m.title.length > 0 ? m.title : '未命名赛事'
      e.sub = `${SportTypeOption.emojiOf(m.sportType)} ${m.date} · ${m.homeTeam} vs ${m.opponent}`
      e.date = m.date
      MemoryStats.pushBucket(bucket, key, e)
    }
    for (const it of items) {
      const d = new Date(it.createdAt)
      const key = MemoryStats.monthKeyFromDate(d)
      const e = new TimelineEntry()
      e.id = it.id
      e.kind = it.kind
      e.title = it.title
      e.sub = it.sub.length > 0 ? it.sub : it.body.substring(0, 40)
      e.date = MemoryStats.formatDate(d)
      MemoryStats.pushBucket(bucket, key, e)
    }

    const keys: string[] = []
    bucket.forEach((_v, k) => { keys.push(k) })
    keys.sort((a, b) => b.localeCompare(a))

    const groups: TimelineGroup[] = []
    for (const k of keys) {
      const g = new TimelineGroup()
      g.monthLabel = k
      g.entries = bucket.get(k) ?? []
      groups.push(g)
    }
    return groups
  }

  static async buildSeasonReport(year?: number): Promise<SeasonReport> {
    const y = year ?? new Date().getFullYear()
    const prefix = `${y}-`
    const report = new SeasonReport()
    report.year = y
    const matches = await RecordStore.loadAll()
    const items = await CollectStore.loadAll()
    const tagMap = new Map<string, number>()
    const sportMap = new Map<string, number>()

    for (const m of matches) {
      if (m.date.indexOf(prefix) !== 0) {
        continue
      }
      report.matches++
      const st = WatchStatus.normalize(m.status)
      if (st === 'want') {
        report.wantCount++
      }
      if (st === 'focus') {
        report.focusCount++
      }
      if (m.recapSummary.length > 0 || m.recapPhases.length > 0) {
        report.recaps++
      }
      const sp = sportMap.get(m.sportType) ?? 0
      sportMap.set(m.sportType, sp + 1)
      MemoryStats.countTags(tagMap, m.tagsPacked)
    }
    for (const it of items) {
      const d = new Date(it.createdAt)
      if (d.getFullYear() !== y) {
        continue
      }
      if (it.kind === 'moment') {
        report.moments++
      } else if (it.kind === 'note') {
        report.notes++
      } else if (it.kind === 'team') {
        report.teams++
      } else if (it.kind === 'player') {
        report.players++
      } else if (it.kind === 'album') {
        report.albums++
      }
      MemoryStats.countTags(tagMap, it.tags)
    }

    report.topSport = MemoryStats.topKey(sportMap, SportTypeOption.labelOf)
    report.topTag = MemoryStats.topKey(tagMap, (k: string) => k)
    report.summary =
      `${y} 年你记录了 ${report.matches} 场赛事，` +
      `完成 ${report.recaps} 次复盘，写下 ${report.moments} 条瞬间与 ${report.notes} 篇笔记。` +
      (report.topSport.length > 0 ? `最常记录的是 ${report.topSport}。` : '')
    return report
  }

  static async unifiedSearch(q: string): Promise<SearchHit[]> {
    const k = q.trim().toLowerCase()
    if (k.length === 0) {
      return []
    }
    const out: SearchHit[] = []
    const matches = await RecordStore.loadAll()
    for (const m of matches) {
      const blob = `${m.title}${m.homeTeam}${m.opponent}${m.tagsPacked}${m.note}`.toLowerCase()
      if (blob.indexOf(k) >= 0) {
        const h = new SearchHit()
        h.id = `m_${m.id}`
        h.refId = m.id
        h.kind = 'match'
        h.title = m.title
        h.sub = `${m.date} · ${m.homeTeam} vs ${m.opponent}`
        out.push(h)
      }
    }
    const items = await CollectStore.loadAll()
    for (const it of items) {
      const blob = `${it.title}${it.sub}${it.body}${it.tags}`.toLowerCase()
      if (blob.indexOf(k) >= 0) {
        const h = new SearchHit()
        h.id = `c_${it.id}`
        h.refId = it.id
        h.kind = it.kind
        h.title = it.title
        h.sub = it.sub.length > 0 ? it.sub : it.body.substring(0, 48)
        out.push(h)
      }
    }
    return out
  }

  static async buildTagStats(): Promise<TagStat[]> {
    const tagMap = new Map<string, number>()
    const matches = await RecordStore.loadAll()
    const items = await CollectStore.loadAll()
    for (const m of matches) {
      MemoryStats.countTags(tagMap, m.tagsPacked)
    }
    for (const it of items) {
      MemoryStats.countTags(tagMap, it.tags)
    }
    const out: TagStat[] = []
    tagMap.forEach((count, tag) => {
      const row = new TagStat()
      row.tag = tag
      row.count = count
      out.push(row)
    })
    out.sort((a, b) => b.count - a.count)
    return out
  }

  static async pinnedMatches(): Promise<SportRecord[]> {
    const all = await RecordStore.loadAll()
    const out: SportRecord[] = []
    for (const m of all) {
      if (m.pinned) {
        out.push(m)
      }
    }
    return out
  }

  static searchMatches(list: SportRecord[], q: string): SportRecord[] {
    const k = q.trim().toLowerCase()
    if (k.length === 0) {
      return list
    }
    const out: SportRecord[] = []
    for (const it of list) {
      const blob = `${it.title}${it.homeTeam}${it.opponent}${it.tagsPacked}${it.note}${it.location}`.toLowerCase()
      if (blob.indexOf(k) >= 0) {
        out.push(it)
      }
    }
    return out
  }

  static searchItems(list: CollectItem[], q: string): CollectItem[] {
    const k = q.trim().toLowerCase()
    if (k.length === 0) {
      return list
    }
    const out: CollectItem[] = []
    for (const it of list) {
      const blob = `${it.title}${it.sub}${it.body}${it.tags}${it.extra}`.toLowerCase()
      if (blob.indexOf(k) >= 0) {
        out.push(it)
      }
    }
    return out
  }

  private static pushBucket(map: Map<string, TimelineEntry[]>, key: string, e: TimelineEntry): void {
    const cur = map.get(key)
    if (cur === undefined) {
      const next: TimelineEntry[] = [e]
      map.set(key, next)
      return
    }
    cur.push(e)
    map.set(key, cur)
  }

  private static monthKey(dateStr: string): string {
    if (dateStr.length >= 7) {
      return dateStr.substring(0, 7)
    }
    return dateStr
  }

  private static monthKeyFromDate(d: Date): string {
    const y = d.getFullYear()
    const m = d.getMonth() + 1
    const ms = m < 10 ? `0${m}` : `${m}`
    return `${y}-${ms}`
  }

  private static formatDate(d: Date): string {
    const y = d.getFullYear()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${y}-${ms}-${ds}`
  }

  private static countTags(map: Map<string, number>, raw: string): void {
    if (raw.length === 0) {
      return
    }
    const parts = raw.split(',')
    for (const t of parts) {
      if (t.length === 0) {
        continue
      }
      const prev = map.get(t) ?? 0
      map.set(t, prev + 1)
    }
  }

  private static topKey(map: Map<string, number>, labelOf: (k: string) => string): string {
    let best = ''
    let max = 0
    map.forEach((count, key) => {
      if (count > max) {
        max = count
        best = labelOf(key)
      }
    })
    return best
  }
}
