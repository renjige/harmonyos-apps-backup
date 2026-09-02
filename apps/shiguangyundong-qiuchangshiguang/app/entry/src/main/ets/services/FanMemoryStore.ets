import { FanEntry, FanHubItem, FanKind, FanMilestone, FanScenario, FanStats, FanTypeCount } from '../models/FanModels'
import { SessionStore } from './SessionStore'
import { DateFormatUtil } from '../components/design-system/DateFormatUtil'

/** 球迷拾光本机库：Preferences + flush，不申请相册/定位/运动健康权限 */
export class FanMemoryStore {
  static listAll(): FanEntry[] {
    return FanMemoryStore.parse(AppStorage.get<string>('fanEntries') ?? '')
  }

  static listByKind(kind: string): FanEntry[] {
    const out: FanEntry[] = []
    const all = FanMemoryStore.listAll()
    for (let i = 0; i < all.length; i++) {
      if (all[i].kind === kind) {
        out.push(all[i])
      }
    }
    return out
  }

  static find(id: string): FanEntry | undefined {
    const all = FanMemoryStore.listAll()
    for (let i = 0; i < all.length; i++) {
      if (all[i].id === id) {
        return all[i]
      }
    }
    return undefined
  }

  static async save(entry: FanEntry): Promise<void> {
    const now = Date.now()
    if (entry.id.length === 0) {
      entry.id = `fan_${now}_${Math.floor(Math.random() * 100000)}`
      entry.createdAt = now
    }
    entry.updatedAt = now
    const next: FanEntry[] = []
    let found = false
    const all = FanMemoryStore.listAll()
    for (let i = 0; i < all.length; i++) {
      if (all[i].id === entry.id) {
        next.push(entry)
        found = true
      } else {
        next.push(all[i])
      }
    }
    if (!found) {
      next.unshift(entry)
    }
    await SessionStore.saveFanEntries(FanMemoryStore.serialize(next))
    AppStorage.setOrCreate('fanEpoch', Date.now())
  }

  static async remove(id: string): Promise<void> {
    const next: FanEntry[] = []
    const all = FanMemoryStore.listAll()
    for (let i = 0; i < all.length; i++) {
      if (all[i].id !== id) {
        next.push(all[i])
      }
    }
    await SessionStore.saveFanEntries(FanMemoryStore.serialize(next))
    AppStorage.setOrCreate('fanEpoch', Date.now())
  }

  static async ensureChallenges(): Promise<void> {
    if (FanMemoryStore.listByKind(FanKind.CHALLENGE).length > 0) {
      return
    }
    const titles: string[] = ['观看 10 场比赛', '了解 5 位球员', '收藏 3 支球队', '写下 3 条复盘', '记录 5 个精彩瞬间']
    const bodies: string[] = [
      '用观赛记录累计 10 场，养成看球习惯',
      '在球员档案写下至少 5 位关注球员',
      '球队收藏夹达到 3 支',
      '完成 3 篇比赛复盘笔记',
      '精彩瞬间库达到 5 条'
    ]
    const all = FanMemoryStore.listAll()
    const now = Date.now()
    for (let i = 0; i < titles.length; i++) {
      const e = new FanEntry()
      e.id = `fan_ch_${now}_${i}`
      e.kind = FanKind.CHALLENGE
      e.title = titles[i]
      e.body = bodies[i]
      e.status = 'todo'
      e.dateLabel = DateFormatUtil.formatDate(new Date())
      e.createdAt = now
      e.updatedAt = now
      all.push(e)
    }
    await SessionStore.saveFanEntries(FanMemoryStore.serialize(all))
    AppStorage.setOrCreate('fanEpoch', Date.now())
  }

  static async touchStreak(): Promise<number> {
    const today = DateFormatUtil.formatDate(new Date())
    const last = AppStorage.get<string>('fanStreakDay') ?? ''
    let count = Number.parseInt(AppStorage.get<string>('fanStreakCount') ?? '0', 10)
    if (Number.isNaN(count) || count < 0) {
      count = 0
    }
    if (last === today) {
      return count
    }
    const yest = DateFormatUtil.formatDate(DateFormatUtil.addDays(DateFormatUtil.todayStart(), -1))
    if (last === yest) {
      count = count + 1
    } else {
      count = 1
    }
    await SessionStore.saveStreak(today, `${count}`)
    return count
  }

  static stats(): FanStats {
    const s = new FanStats()
    const all = FanMemoryStore.listAll()
    s.totalRecords = all.length
    for (let i = 0; i < all.length; i++) {
      const k = all[i].kind
      if (k === FanKind.MATCH) {
        s.matchCount++
      } else if (k === FanKind.JOURNAL) {
        s.journalCount++
      } else if (k === FanKind.TEAM) {
        s.teamCount++
      } else if (k === FanKind.REVIEW) {
        s.reviewCount++
      } else if (k === FanKind.HIGHLIGHT) {
        s.highlightCount++
      } else if (k === FanKind.WATCHLIST) {
        s.watchCount++
      } else if (k === FanKind.PLAYER) {
        s.playerCount++
      } else if (k === FanKind.KNOWLEDGE) {
        s.knowledgeCount++
      } else if (k === FanKind.CHALLENGE) {
        s.challengeTotal++
        if (all[i].status === 'done') {
          s.challengeDone++
        }
      } else if (k === FanKind.EVENT) {
        s.eventCount++
      } else if (k === FanKind.ALBUM) {
        s.albumCount++
      }
    }
    const streak = Number.parseInt(AppStorage.get<string>('fanStreakCount') ?? '0', 10)
    s.streakDays = Number.isNaN(streak) ? 0 : streak
    return s
  }

  static hubItems(): FanHubItem[] {
    return FanMemoryStore.hubOf(FanKind.all())
  }

  static hubPrimary(): FanHubItem[] {
    return FanMemoryStore.hubOf(FanKind.primary())
  }

  static hubTools(): FanHubItem[] {
    return FanMemoryStore.hubOf(FanKind.tools())
  }

  private static hubOf(kinds: string[]): FanHubItem[] {
    const s = FanMemoryStore.stats()
    const out: FanHubItem[] = []
    for (let i = 0; i < kinds.length; i++) {
      const k = kinds[i]
      const item = new FanHubItem()
      item.kind = k
      item.title = FanKind.titleOf(k)
      item.hint = FanKind.hintOf(k)
      item.coverKey = FanKind.coverOf(k)
      item.count = FanMemoryStore.countOf(s, k)
      out.push(item)
    }
    return out
  }

  private static countOf(s: FanStats, kind: string): number {
    if (kind === FanKind.MATCH) {
      return s.matchCount
    }
    if (kind === FanKind.JOURNAL) {
      return s.journalCount
    }
    if (kind === FanKind.TEAM) {
      return s.teamCount
    }
    if (kind === FanKind.REVIEW) {
      return s.reviewCount
    }
    if (kind === FanKind.HIGHLIGHT) {
      return s.highlightCount
    }
    if (kind === FanKind.WATCHLIST) {
      return s.watchCount
    }
    if (kind === FanKind.PLAYER) {
      return s.playerCount
    }
    if (kind === FanKind.KNOWLEDGE) {
      return s.knowledgeCount
    }
    if (kind === FanKind.CHALLENGE) {
      return s.challengeTotal
    }
    if (kind === FanKind.EVENT) {
      return s.eventCount
    }
    if (kind === FanKind.ALBUM) {
      return s.albumCount
    }
    return 0
  }

  static calendarItems(): FanEntry[] {
    const out: FanEntry[] = []
    const all = FanMemoryStore.listAll()
    for (let i = 0; i < all.length; i++) {
      const k = all[i].kind
      if (k === FanKind.EVENT || k === FanKind.WATCHLIST || k === FanKind.MATCH) {
        if (all[i].dateLabel.length > 0) {
          out.push(all[i])
        }
      }
    }
    out.sort((a: FanEntry, b: FanEntry) => {
      if (a.dateLabel < b.dateLabel) {
        return -1
      }
      if (a.dateLabel > b.dateLabel) {
        return 1
      }
      return 0
    })
    return out
  }

  static albumMembers(albumTitle: string): FanEntry[] {
    const out: FanEntry[] = []
    if (albumTitle.length === 0) {
      return out
    }
    const all = FanMemoryStore.listAll()
    for (let i = 0; i < all.length; i++) {
      const it = all[i]
      if (it.kind === FanKind.ALBUM) {
        continue
      }
      if (it.extra === albumTitle) {
        out.push(it)
      }
    }
    return out
  }

  static challengeHint(title: string): string {
    const s = FanMemoryStore.stats()
    if (title.indexOf('10 场') >= 0 || title.indexOf('10场') >= 0) {
      return `当前观赛 ${s.matchCount} / 10`
    }
    if (title.indexOf('5 位') >= 0 || title.indexOf('5位') >= 0) {
      return `当前球员档案 ${s.playerCount} / 5`
    }
    if (title.indexOf('3 支') >= 0 || title.indexOf('3支') >= 0) {
      return `当前球队 ${s.teamCount} / 3`
    }
    if (title.indexOf('复盘') >= 0) {
      return `当前复盘 ${s.reviewCount} / 3`
    }
    if (title.indexOf('瞬间') >= 0) {
      return `当前瞬间 ${s.highlightCount} / 5`
    }
    return `累计记录 ${s.totalRecords} 条`
  }

  static statusLabel(kind: string, status: string): string {
    if (kind === FanKind.WATCHLIST) {
      if (status === 'watched') {
        return '已观看'
      }
      if (status === 'starred') {
        return '已收藏'
      }
      return '待观看'
    }
    if (kind === FanKind.TEAM) {
      if (status === 'follow') {
        return '关注中'
      }
      if (status === 'classic') {
        return '经典球队'
      }
      return '喜欢'
    }
    if (kind === FanKind.CHALLENGE) {
      return status === 'done' ? '已完成' : '进行中'
    }
    if (kind === FanKind.KNOWLEDGE) {
      if (status === 'history') {
        return '球队历史'
      }
      if (status === 'player') {
        return '球员故事'
      }
      return '比赛规则'
    }
    if (kind === FanKind.JOURNAL) {
      if (status === 'analysis') {
        return '比赛分析'
      }
      if (status === 'story') {
        return '球迷故事'
      }
      return '看球感受'
    }
    if (status.length > 0) {
      return status
    }
    return ''
  }

  static insightLines(): string[] {
    const s = FanMemoryStore.stats()
    const lines: string[] = []
    if (s.totalRecords === 0) {
      lines.push('从观赛记录或球迷日志开始，建立你的赛事记忆库')
      lines.push('完成挑战任务，养成持续记录习惯')
      return lines
    }
    lines.push(`已积累 ${s.totalRecords} 条记忆 · 连续使用 ${s.streakDays} 天`)
    if (s.matchCount > 0) {
      lines.push(`观赛 ${s.matchCount} 场 · 复盘 ${s.reviewCount} 篇 · 瞬间 ${s.highlightCount} 条`)
    }
    if (s.challengeTotal > 0) {
      lines.push(`球迷挑战 ${s.challengeDone}/${s.challengeTotal} 已完成`)
    }
    if (s.watchCount > 0) {
      lines.push(`比赛清单 ${s.watchCount} 条 · 可在清单中标记已看并写观赛记录`)
    }
    return lines
  }

  static scenarios(): FanScenario[] {
    const out: FanScenario[] = []
    const s1 = new FanScenario()
    s1.id = 'post_match'
    s1.title = '赛后全套复盘'
    s1.subtitle = '一次向导生成观赛+瞬间+复盘'
    s1.coverKey = 'banner_hot'
    out.push(s1)
    const s2 = new FanScenario()
    s2.id = 'growth_report'
    s2.title = '球迷成长报告'
    s2.subtitle = '类型分布 · 里程碑 · 活跃日历'
    s2.coverKey = 'hero_court'
    out.push(s2)
    const s3 = new FanScenario()
    s3.id = 'season_album'
    s3.title = '赛季专题合集'
    s3.subtitle = '创建收藏册并收录经典比赛'
    s3.coverKey = 'case_weekend'
    out.push(s3)
    const s4 = new FanScenario()
    s4.id = 'next_match'
    s4.title = '安排下一场观赛'
    s4.subtitle = '赛事日历 + 比赛清单联动'
    s4.coverKey = 'cat_football'
    out.push(s4)
    return out
  }

  static typeCounts(): FanTypeCount[] {
    const s = FanMemoryStore.stats()
    const pairs: FanTypeCount[] = []
    const add = (label: string, value: number): void => {
      if (value <= 0) {
        return
      }
      const row = new FanTypeCount()
      row.label = label
      row.value = value
      pairs.push(row)
    }
    add('观赛', s.matchCount)
    add('日志', s.journalCount)
    add('复盘', s.reviewCount)
    add('瞬间', s.highlightCount)
    add('球队', s.teamCount)
    add('球员', s.playerCount)
    add('清单', s.watchCount)
    add('合集', s.albumCount)
    pairs.sort((a: FanTypeCount, b: FanTypeCount) => {
      if (a.value > b.value) {
        return -1
      }
      if (a.value < b.value) {
        return 1
      }
      return 0
    })
    const out: FanTypeCount[] = []
    for (let i = 0; i < pairs.length && i < 5; i++) {
      out.push(pairs[i])
    }
    return out
  }

  static milestones(): FanMilestone[] {
    const s = FanMemoryStore.stats()
    const out: FanMilestone[] = []
    const row = (id: string, title: string, hint: string, ok: boolean, progress: string): void => {
      const m = new FanMilestone()
      m.id = id
      m.title = title
      m.hint = hint
      m.unlocked = ok
      m.progress = progress
      out.push(m)
    }
    row('m1', '初识球迷', '写下第一条记忆', s.totalRecords >= 1, `${s.totalRecords}/1`)
    row('m2', '观赛达人', '累计 5 场观赛记录', s.matchCount >= 5, `${s.matchCount}/5`)
    row('m3', '复盘高手', '完成 3 篇复盘笔记', s.reviewCount >= 3, `${s.reviewCount}/3`)
    row('m4', '球队收藏家', '收藏 3 支球队', s.teamCount >= 3, `${s.teamCount}/3`)
    row('m5', '七日连记', '连续 7 天打开拾光', s.streakDays >= 7, `${s.streakDays}/7`)
    row('m6', '记忆万卷', '累计 20 条球迷记忆', s.totalRecords >= 20, `${s.totalRecords}/20`)
    return out
  }

  static monthlyRecapLines(): string[] {
    const now = new Date()
    const ym = `${now.getFullYear()}-${FanMemoryStore.pad2(now.getMonth() + 1)}`
    let monthTotal = 0
    let monthMatch = 0
    let monthReview = 0
    const all = FanMemoryStore.listAll()
    for (let i = 0; i < all.length; i++) {
      const d = all[i].dateLabel
      if (d.length >= 7 && d.substring(0, 7) === ym) {
        monthTotal++
        if (all[i].kind === FanKind.MATCH) {
          monthMatch++
        }
        if (all[i].kind === FanKind.REVIEW) {
          monthReview++
        }
      }
    }
    const lines: string[] = []
    lines.push(`${now.getMonth() + 1} 月已记录 ${monthTotal} 条记忆`)
    if (monthMatch > 0 || monthReview > 0) {
      lines.push(`其中观赛 ${monthMatch} 场 · 复盘 ${monthReview} 篇`)
    }
    const activeDays = FanMemoryStore.activeDaysInMonth(now.getFullYear(), now.getMonth() + 1).length
    if (activeDays > 0) {
      lines.push(`本月有 ${activeDays} 天留下过球迷记忆`)
    }
    if (monthTotal === 0) {
      lines.push('试试「赛后全套复盘」向导，一次生成多条关联记忆')
    }
    return lines
  }

  static activeDaysInMonth(year: number, month: number): number[] {
    const ym = `${year}-${FanMemoryStore.pad2(month)}`
    const daySet: number[] = []
    const all = FanMemoryStore.listAll()
    for (let i = 0; i < all.length; i++) {
      const d = all[i].dateLabel
      if (d.length >= 10 && d.substring(0, 7) === ym) {
        const day = Number.parseInt(d.substring(8, 10), 10)
        if (!Number.isNaN(day) && daySet.indexOf(day) < 0) {
          daySet.push(day)
        }
      }
    }
    daySet.sort((a: number, b: number) => a - b)
    return daySet
  }

  static async savePostMatchBundle(
    matchTitle: string,
    dateLabel: string,
    matchBody: string,
    highlightTitle: string,
    highlightBody: string,
    reviewTitle: string,
    reviewBody: string
  ): Promise<void> {
    const m = new FanEntry()
    m.kind = FanKind.MATCH
    m.title = matchTitle
    m.dateLabel = dateLabel
    m.body = matchBody
    m.rating = 3
    await FanMemoryStore.save(m)

    const h = new FanEntry()
    h.kind = FanKind.HIGHLIGHT
    h.title = highlightTitle.length > 0 ? highlightTitle : `${matchTitle} · 精彩瞬间`
    h.dateLabel = dateLabel
    h.body = highlightBody
    h.extra = matchTitle
    await FanMemoryStore.save(h)

    const r = new FanEntry()
    r.kind = FanKind.REVIEW
    r.title = reviewTitle.length > 0 ? reviewTitle : `${matchTitle} · 赛后复盘`
    r.dateLabel = dateLabel
    r.body = reviewBody
    r.extra = matchTitle
    await FanMemoryStore.save(r)
  }

  static exportAllText(): string {
    const items = FanMemoryStore.timeline(0)
    if (items.length === 0) {
      return '还没有球迷记忆。可在拾光 Tab 使用场景向导开始创作。'
    }
    const blocks: string[] = []
    blocks.push('—— 球场拾光 · 全部记忆导出 ——')
    blocks.push(`共 ${items.length} 条 · 导出时间 ${DateFormatUtil.formatDate(new Date())}`)
    blocks.push('')
    for (let i = 0; i < items.length; i++) {
      blocks.push(FanMemoryStore.exportText(items[i]))
      blocks.push('')
    }
    return blocks.join('\n')
  }

  private static pad2(n: number): string {
    return n < 10 ? `0${n}` : `${n}`
  }

  static timeline(limit: number = 0): FanEntry[] {
    const all = FanMemoryStore.listAll()
    const sorted = FanMemoryStore.sortByDate(all)
    if (limit > 0 && sorted.length > limit) {
      const out: FanEntry[] = []
      for (let i = 0; i < limit; i++) {
        out.push(sorted[i])
      }
      return out
    }
    return sorted
  }

  static search(query: string): FanEntry[] {
    const q = query.trim()
    if (q.length === 0) {
      return FanMemoryStore.timeline(0)
    }
    const lower = q.toLowerCase()
    const out: FanEntry[] = []
    const all = FanMemoryStore.listAll()
    for (let i = 0; i < all.length; i++) {
      const e = all[i]
      if (FanMemoryStore.containsQuery(e, lower)) {
        out.push(e)
      }
    }
    return FanMemoryStore.sortByDate(out)
  }

  static related(entry: FanEntry): FanEntry[] {
    const out: FanEntry[] = []
    const all = FanMemoryStore.listAll()
    for (let i = 0; i < all.length; i++) {
      const it = all[i]
      if (it.id === entry.id) {
        continue
      }
      if (entry.extra.length > 0 && it.extra === entry.extra) {
        out.push(it)
        continue
      }
      if (entry.dateLabel.length > 0 && it.dateLabel === entry.dateLabel) {
        out.push(it)
      }
    }
    return out
  }

  static exportText(entry: FanEntry): string {
    const lines: string[] = []
    lines.push(`【${FanKind.titleOf(entry.kind)}】${entry.title}`)
    if (entry.dateLabel.length > 0) {
      lines.push(`日期：${entry.dateLabel}`)
    }
    if (entry.subtitle.length > 0) {
      lines.push(`备注：${entry.subtitle}`)
    }
    const status = FanMemoryStore.statusLabel(entry.kind, entry.status)
    if (status.length > 0) {
      lines.push(`状态：${status}`)
    }
    if (entry.body.length > 0) {
      lines.push('')
      lines.push(entry.body)
    }
    return lines.join('\n')
  }

  static async markWatchlistWatched(id: string): Promise<FanEntry | undefined> {
    const found = FanMemoryStore.find(id)
    if (found === undefined || found.kind !== FanKind.WATCHLIST) {
      return undefined
    }
    found.status = 'watched'
    await FanMemoryStore.save(found)
    return found
  }

  private static sortByDate(items: FanEntry[]): FanEntry[] {
    const out: FanEntry[] = []
    for (let i = 0; i < items.length; i++) {
      out.push(items[i])
    }
    out.sort((a: FanEntry, b: FanEntry) => {
      if (a.dateLabel > b.dateLabel) {
        return -1
      }
      if (a.dateLabel < b.dateLabel) {
        return 1
      }
      if (a.updatedAt > b.updatedAt) {
        return -1
      }
      if (a.updatedAt < b.updatedAt) {
        return 1
      }
      return 0
    })
    return out
  }

  private static containsQuery(e: FanEntry, lower: string): boolean {
    if (e.title.toLowerCase().indexOf(lower) >= 0) {
      return true
    }
    if (e.body.toLowerCase().indexOf(lower) >= 0) {
      return true
    }
    if (e.subtitle.toLowerCase().indexOf(lower) >= 0) {
      return true
    }
    if (e.extra.toLowerCase().indexOf(lower) >= 0) {
      return true
    }
    if (FanKind.titleOf(e.kind).toLowerCase().indexOf(lower) >= 0) {
      return true
    }
    return false
  }

  private static serialize(items: FanEntry[]): string {
    const lines: string[] = []
    for (let i = 0; i < items.length; i++) {
      const it = items[i]
      const title = FanMemoryStore.esc(it.title)
      const sub = FanMemoryStore.esc(it.subtitle)
      const body = FanMemoryStore.esc(it.body)
      const extra = FanMemoryStore.esc(it.extra)
      lines.push(
        `${it.id}\t${it.kind}\t${title}\t${sub}\t${it.dateLabel}\t${body}\t${extra}\t${it.rating}\t${it.status}\t${it.createdAt}\t${it.updatedAt}`
      )
    }
    return lines.join('\n')
  }

  private static parse(raw: string): FanEntry[] {
    const out: FanEntry[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i]
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 11) {
        continue
      }
      const e = new FanEntry()
      e.id = parts[0]
      e.kind = parts[1]
      e.title = FanMemoryStore.unesc(parts[2])
      e.subtitle = FanMemoryStore.unesc(parts[3])
      e.dateLabel = parts[4]
      e.body = FanMemoryStore.unesc(parts[5])
      e.extra = FanMemoryStore.unesc(parts[6])
      e.rating = Number.parseInt(parts[7], 10)
      if (Number.isNaN(e.rating)) {
        e.rating = 0
      }
      e.status = parts[8]
      e.createdAt = Number.parseInt(parts[9], 10)
      e.updatedAt = Number.parseInt(parts[10], 10)
      out.push(e)
    }
    return out
  }

  private static esc(text: string): string {
    return text.replace(/\t/g, ' ').replace(/\n/g, '\\n')
  }

  private static unesc(text: string): string {
    return text.replace(/\\n/g, '\n')
  }
}
