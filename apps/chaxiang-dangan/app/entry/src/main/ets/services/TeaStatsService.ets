import { DateFormatUtil } from '../components/design-system/DateFormatUtil'
import {
  AchievementDef,
  MonthBar,
  OrganizeHint,
  TeaStats,
  TeaTypeDef,
  TimelineMark,
  TypeShare
} from '../models/TeaModels'
import { TeaStore } from './TeaStore'

export class TeaStatsService {
  static compute(): TeaStats {
    const s = new TeaStats()
    s.teaCount = TeaStore.teas().length
    s.tastingCount = TeaStore.tastings().length
    s.albumCount = TeaStore.albums().length
    s.listCount = TeaStore.lists().length
    let fav = 0
    for (const t of TeaStore.teas()) {
      if (t.stockStatus === 'collected' || t.stockStatus === 'sipping') {
        fav += 1
      }
    }
    s.favoriteCount = fav
    const days: string[] = []
    for (const r of TeaStore.tastings()) {
      let seen = false
      for (const d of days) {
        if (d === r.dateKey) {
          seen = true
        }
      }
      if (!seen && r.dateKey.length > 0) {
        days.push(r.dateKey)
      }
    }
    s.dayCount = days.length
    return s
  }

  static typeShares(): TypeShare[] {
    const out: TypeShare[] = []
    for (const def of TeaTypeDef.six()) {
      const row = new TypeShare()
      row.key = def.key
      row.name = def.name
      row.count = TeaStore.teasByType(def.key).length
      out.push(row)
    }
    const untyped = new TypeShare()
    untyped.key = ''
    untyped.name = '未分类'
    for (const t of TeaStore.teas()) {
      if (t.typeKey.length === 0) {
        untyped.count += 1
      }
    }
    out.push(untyped)
    return out
  }

  static monthBars(): MonthBar[] {
    const now = new Date()
    const out: MonthBar[] = []
    for (let i = 5; i >= 0; i--) {
      const d = new Date(now.getFullYear(), now.getMonth() - i, 1)
      const prefix = `${d.getFullYear()}-${DateFormatUtil.pad2(d.getMonth() + 1)}`
      const bar = new MonthBar()
      bar.label = `${d.getMonth() + 1}月`
      bar.value = 0
      for (const r of TeaStore.tastings()) {
        if (r.dateKey.indexOf(prefix) === 0) {
          bar.value += 1
        }
      }
      out.push(bar)
    }
    return out
  }

  static timeline(): TimelineMark[] {
    const marks: TimelineMark[] = []
    const teas = TeaStore.teas().slice()
    teas.sort((a, b) => a.createdAt - b.createdAt)
    if (teas.length > 0) {
      const first = teas[0]
      const m = new TimelineMark()
      m.id = 'first_tea'
      m.dateKey = first.collectedAt.length > 0 ? first.collectedAt : DateFormatUtil.formatDate(new Date(first.createdAt))
      m.title = '第一款茶档案'
      m.body = first.name
      marks.push(m)
    }
    const sips = TeaStore.tastings().slice()
    sips.sort((a, b) => a.createdAt - b.createdAt)
    if (sips.length > 0) {
      const first = sips[0]
      const tea = TeaStore.findTea(first.teaId)
      const m = new TimelineMark()
      m.id = 'first_sip'
      m.dateKey = first.dateKey
      m.title = '第一次品饮记录'
      m.body = tea !== null ? tea.name : '一款茶'
      marks.push(m)
    }
    if (sips.length >= 50) {
      const m = new TimelineMark()
      m.id = 'sip_50'
      m.dateKey = sips[49].dateKey
      m.title = '累计品饮 50 次'
      m.body = '茶生活慢慢铺开'
      marks.push(m)
    }
    if (TeaStore.albums().length > 0) {
      const a = TeaStore.albums()[TeaStore.albums().length - 1]
      const m = new TimelineMark()
      m.id = 'album'
      m.dateKey = DateFormatUtil.formatDate(new Date(a.createdAt))
      m.title = '创建主题册'
      m.body = a.name
      marks.push(m)
    }
    marks.sort((a, b) => b.dateKey.localeCompare(a.dateKey))
    return marks
  }

  static yearAgoSnippet(): string {
    const today = new Date()
    const past = new Date(today.getFullYear() - 1, today.getMonth(), today.getDate())
    const key = DateFormatUtil.formatDate(past)
    for (const r of TeaStore.tastings()) {
      if (r.dateKey === key) {
        const tea = TeaStore.findTea(r.teaId)
        const name = tea !== null ? tea.name : '一款茶'
        return `一年前今天，你记录了「${name}」。`
      }
    }
    for (const t of TeaStore.teas()) {
      if (t.collectedAt === key) {
        return `一年前今天，你为「${t.name}」建立了档案。`
      }
    }
    if (TeaStore.teas().length === 0) {
      return '从第一款茶开始，茶香档案会记住你的日子。'
    }
    return '今天也适合记下一杯茶。'
  }

  static organizeHints(): OrganizeHint[] {
    const hints: OrganizeHint[] = []
    for (const t of TeaStore.teas()) {
      if (t.typeKey.length === 0) {
        const h = new OrganizeHint()
        h.teaId = t.id
        h.title = t.name
        h.reason = '还没有分类'
        hints.push(h)
      } else if (t.tagIds.length === 0) {
        const h = new OrganizeHint()
        h.teaId = t.id
        h.title = t.name
        h.reason = '还没有标签'
        hints.push(h)
      } else if (t.origin.length === 0 || t.yearText.length === 0) {
        const h = new OrganizeHint()
        h.teaId = t.id
        h.title = t.name
        h.reason = '档案还可以更完整'
        hints.push(h)
      } else if (TeaStore.tastingsOfTea(t.id).length === 0) {
        const h = new OrganizeHint()
        h.teaId = t.id
        h.title = t.name
        h.reason = '还没有品饮记录'
        hints.push(h)
      }
    }
    return hints
  }

  static unlockedAchievements(): string[] {
    const ids: string[] = []
    const stats = TeaStatsService.compute()
    if (stats.tastingCount >= 1) {
      ids.push('first_sip')
    }
    if (TeaStatsService.longestStreak() >= 7) {
      ids.push('week_7')
    }
    if (stats.teaCount >= 10) {
      ids.push('teas_10')
    }
    if (stats.tastingCount >= 100) {
      ids.push('sip_100')
    }
    if (stats.albumCount >= 5) {
      ids.push('albums_5')
    }
    return ids
  }

  static longestStreak(): number {
    const keys: string[] = []
    for (const r of TeaStore.tastings()) {
      if (r.dateKey.length > 0 && keys.indexOf(r.dateKey) < 0) {
        keys.push(r.dateKey)
      }
    }
    keys.sort()
    if (keys.length === 0) {
      return 0
    }
    let best = 1
    let cur = 1
    for (let i = 1; i < keys.length; i++) {
      const prev = DateFormatUtil.parseDate(keys[i - 1])
      const now = DateFormatUtil.parseDate(keys[i])
      const diff = Math.round((now.getTime() - prev.getTime()) / 86400000)
      if (diff === 1) {
        cur += 1
        if (cur > best) {
          best = cur
        }
      } else {
        cur = 1
      }
    }
    return best
  }

  static catalog(): AchievementDef[] {
    return AchievementDef.catalog()
  }
}
