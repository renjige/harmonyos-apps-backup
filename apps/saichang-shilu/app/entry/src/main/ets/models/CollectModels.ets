export class CollectItem {
  kind: string = 'moment'
  id: string = ''
  title: string = ''
  sub: string = ''
  body: string = ''
  extra: string = ''
  tags: string = ''
  refMatchId: string = ''
  createdAt: number = 0

  static create(kind: string): CollectItem {
    const it = new CollectItem()
    it.kind = kind
    it.id = `${kind}_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    it.createdAt = Date.now()
    return it
  }
}

export class DashStats {
  matches: number = 0
  moments: number = 0
  recaps: number = 0
  collections: number = 0
  teams: number = 0
  players: number = 0
  notes: number = 0
  want: number = 0
  weekMatches: number = 0
  weekRecaps: number = 0
  weekMoments: number = 0
}

export class NamedChip {
  id: string = ''
  label: string = ''

  static of(id: string, label: string): NamedChip {
    const c = new NamedChip()
    c.id = id
    c.label = label
    return c
  }
}

export class WatchStatus {
  static all(): NamedChip[] {
    const out: NamedChip[] = []
    out.push(NamedChip.of('want', '待看'))
    out.push(NamedChip.of('watched', '已看'))
    out.push(NamedChip.of('focus', '重点关注'))
    return out
  }

  static label(id: string): string {
    const n = WatchStatus.normalize(id)
    if (n === 'want') {
      return '待看'
    }
    if (n === 'focus') {
      return '重点关注'
    }
    return '已看'
  }

  /** 统一状态码：兼容中文标签、空串、空格 */
  static normalize(raw: string): string {
    const s = raw.trim()
    if (s === 'want' || s === '待看' || s === '未看') {
      return 'want'
    }
    if (s === 'focus' || s === '重点' || s === '重点关注') {
      return 'focus'
    }
    if (s === 'watched' || s === '已看' || s === '看过') {
      return 'watched'
    }
    if (s.length === 0) {
      return 'want'
    }
    return 'watched'
  }

  static isPending(id: string): boolean {
    const n = WatchStatus.normalize(id)
    return n === 'want' || n === 'focus'
  }
}

export class NoteCat {
  static all(): string[] {
    return ['赛前期待', '比赛感受', '赛后总结', '球迷随笔', '体育感悟']
  }
}

export class TagLib {
  static preset(): string[] {
    return ['经典', '逆转', '决赛', '加时', '绝杀', '黑马', '复盘', '季后赛']
  }
}

export class RecapPhase {
  id: string = ''
  label: string = ''
  text: string = ''

  static template(): RecapPhase[] {
    const ids: string[][] = [
      ['open', '开场'],
      ['first', '上半场'],
      ['mid', '中场'],
      ['second', '下半场'],
      ['clutch', '关键时刻'],
      ['end', '结束']
    ]
    const out: RecapPhase[] = []
    for (const row of ids) {
      const p = new RecapPhase()
      p.id = row[0]
      p.label = row[1]
      out.push(p)
    }
    return out
  }

  static pack(list: RecapPhase[]): string {
    const parts: string[] = []
    for (const p of list) {
      parts.push(`${p.id}~${p.text.replace(/~/g, ' ').replace(/;/g, '，')}`)
    }
    return parts.join(';;')
  }

  static unpack(raw: string): RecapPhase[] {
    const base = RecapPhase.template()
    if (raw.length === 0) {
      return base
    }
    const chunks = raw.split(';;')
    for (const c of chunks) {
      const p = c.split('~')
      if (p.length < 2) {
        continue
      }
      for (const b of base) {
        if (b.id === p[0]) {
          b.text = p[1]
        }
      }
    }
    return base
  }
}

export class DailyPrompt {
  static today(): string {
    const list: string[] = [
      '今天看完比赛，哪个瞬间最让你印象深刻？',
      '本场最值得写进复盘的转折是什么？',
      '有哪位球员的表现值得单独记一笔？',
      '这场如果重来一次，你会关注哪个细节？',
      '用三个标签概括你刚看完的比赛。',
      '把今晚的情绪写成一条球迷随笔。',
      '收藏一场你会反复提起的经典。'
    ]
    const i = new Date().getDate() % list.length
    return list[i]
  }
}

export class AvatarPalette {
  static colors(): string[] {
    return ['#007AFF', '#FF6B35', '#0F766E', '#7C3AED', '#BE123C', '#1A1A2E']
  }
}

export class AchieveItem {
  id: string = ''
  title: string = ''
  done: boolean = false
  emoji: string = ''
}

export class TimelineEntry {
  id: string = ''
  title: string = ''
  sub: string = ''
  date: string = ''
  kind: string = 'match'
}

export class TimelineGroup {
  monthLabel: string = ''
  entries: TimelineEntry[] = []
}

export class SeasonReport {
  year: number = 0
  matches: number = 0
  recaps: number = 0
  moments: number = 0
  notes: number = 0
  teams: number = 0
  players: number = 0
  albums: number = 0
  topSport: string = ''
  topTag: string = ''
  wantCount: number = 0
  focusCount: number = 0
  summary: string = ''
}

export class SearchHit {
  id: string = ''
  kind: string = ''
  title: string = ''
  sub: string = ''
  refId: string = ''
}

export class StatusCounts {
  want: number = 0
  watched: number = 0
  focus: number = 0
  all: number = 0

  /** 待看清单口径：待看 + 重点关注 */
  pending(): number {
    return this.want + this.focus
  }
}

export class CollectKindMeta {
  id: string = ''
  label: string = ''
  hint: string = ''
  accent: string = ''

  static all(): CollectKindMeta[] {
    const out: CollectKindMeta[] = []
    const m1 = new CollectKindMeta()
    m1.id = 'team'
    m1.label = '球队档案'
    m1.hint = '收藏常看的球队与理由'
    m1.accent = '#007AFF'
    out.push(m1)
    const m2 = new CollectKindMeta()
    m2.id = 'player'
    m2.label = '球员档案'
    m2.hint = '记录观察对象与精彩表现'
    m2.accent = '#FF6B35'
    out.push(m2)
    const m3 = new CollectKindMeta()
    m3.id = 'album'
    m3.label = '专题收藏'
    m3.hint = '经典/决赛/逆转等主题夹'
    m3.accent = '#0F766E'
    out.push(m3)
    const m4 = new CollectKindMeta()
    m4.id = 'perf'
    m4.label = '表现卡'
    m4.hint = '某场比赛的球员星级评价'
    m4.accent = '#7C3AED'
    out.push(m4)
    return out
  }

  static of(id: string): CollectKindMeta {
    for (const m of CollectKindMeta.all()) {
      if (m.id === id) {
        return m
      }
    }
    const fallback = new CollectKindMeta()
    fallback.id = id
    fallback.label = '收藏'
    fallback.hint = ''
    fallback.accent = '#007AFF'
    return fallback
  }
}
