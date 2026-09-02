import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { Observation, UserProfile } from '../models/ObservationModels'
import { BarChartItem } from '../components/design-system/AppChart'

const STORE = 'insect_journal_v1'
const KEY_OBS = 'observations'
const KEY_PROFILE = 'profile'

export class NameCount {
  name: string = ''
  count: number = 0
}

export class ObservationStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      ObservationStore.pref = await preferences.getPreferences(context, STORE)
    } catch {
      ObservationStore.pref = null
    }
  }

  static async loadAll(): Promise<Observation[]> {
    const raw = await ObservationStore.getString(KEY_OBS, '')
    return ObservationStore.parse(raw)
  }

  static async findById(id: string): Promise<Observation | undefined> {
    const list = await ObservationStore.loadAll()
    for (const o of list) {
      if (o.id === id) {
        return o
      }
    }
    return undefined
  }

  static async save(item: Observation): Promise<void> {
    item.updatedAt = Date.now()
    const list = await ObservationStore.loadAll()
    const next: Observation[] = []
    let found = false
    for (const o of list) {
      if (o.id === item.id) {
        next.push(item)
        found = true
      } else {
        next.push(o)
      }
    }
    if (!found) {
      next.push(item)
    }
    next.sort((a, b) => b.createdAt - a.createdAt)
    await ObservationStore.persist(next)
  }

  static async remove(id: string): Promise<void> {
    const list = await ObservationStore.loadAll()
    const next: Observation[] = []
    for (const o of list) {
      if (o.id !== id) {
        next.push(o)
      }
    }
    await ObservationStore.persist(next)
  }

  static async clearAll(): Promise<void> {
    await ObservationStore.putString(KEY_OBS, '')
  }

  static async filtered(query: string, favoriteOnly: boolean, tag: string): Promise<Observation[]> {
    const list = await ObservationStore.loadAll()
    const q = query.trim()
    const out: Observation[] = []
    for (const o of list) {
      if (favoriteOnly && !o.isFavorite) {
        continue
      }
      if (tag.length > 0) {
        let hit = false
        for (const t of o.tags) {
          if (t === tag) {
            hit = true
          }
        }
        if (!hit) {
          continue
        }
      }
      if (q.length > 0 && o.name.indexOf(q) < 0 && o.behavior.indexOf(q) < 0) {
        continue
      }
      out.push(o)
    }
    return out
  }

  static async recent(limit: number): Promise<Observation[]> {
    const list = await ObservationStore.loadAll()
    const out: Observation[] = []
    for (const o of list) {
      if (out.length < limit) {
        out.push(o)
      }
    }
    return out
  }

  static async statsCount(): Promise<number> {
    const list = await ObservationStore.loadAll()
    return list.length
  }

  static async statsDays(): Promise<number> {
    const list = await ObservationStore.loadAll()
    const seen: string[] = []
    for (const o of list) {
      let has = false
      for (const d of seen) {
        if (d === o.date) {
          has = true
        }
      }
      if (!has) {
        seen.push(o.date)
      }
    }
    return seen.length
  }

  static async statsKinds(): Promise<number> {
    const list = await ObservationStore.loadAll()
    const seen: string[] = []
    for (const o of list) {
      const n = o.name.trim()
      if (n.length === 0) {
        continue
      }
      let has = false
      for (const s of seen) {
        if (s === n) {
          has = true
        }
      }
      if (!has) {
        seen.push(n)
      }
    }
    return seen.length
  }

  static async monthBars(): Promise<BarChartItem[]> {
    const list = await ObservationStore.loadAll()
    const now = new Date()
    const items: BarChartItem[] = []
    for (let offset = 5; offset >= 0; offset--) {
      const d = new Date(now.getFullYear(), now.getMonth() - offset, 1)
      const key = ObservationStore.monthKey(d)
      let count = 0
      for (const o of list) {
        if (o.date.indexOf(key) === 0) {
          count++
        }
      }
      const bar = new BarChartItem()
      bar.label = `${d.getMonth() + 1}月`
      bar.value = count
      items.push(bar)
    }
    return items
  }

  static async topNames(limit: number): Promise<NameCount[]> {
    const list = await ObservationStore.loadAll()
    const names: string[] = []
    const counts: number[] = []
    for (const o of list) {
      const n = o.name.trim()
      if (n.length === 0) {
        continue
      }
      let idx = -1
      let i = 0
      for (const exist of names) {
        if (exist === n) {
          idx = i
        }
        i++
      }
      if (idx < 0) {
        names.push(n)
        counts.push(1)
      } else {
        let j = 0
        const nextCounts: number[] = []
        for (const c of counts) {
          nextCounts.push(j === idx ? c + 1 : c)
          j++
        }
        counts.length = 0
        for (const c of nextCounts) {
          counts.push(c)
        }
      }
    }
    const pairs: NameCount[] = []
    let ni = 0
    for (const n of names) {
      const row = new NameCount()
      row.name = n
      let ci = 0
      for (const c of counts) {
        if (ci === ni) {
          row.count = c
        }
        ci++
      }
      pairs.push(row)
      ni++
    }
    pairs.sort((a, b) => b.count - a.count)
    const out: NameCount[] = []
    for (const p of pairs) {
      if (out.length < limit) {
        out.push(p)
      }
    }
    return out
  }

  static async loadProfile(): Promise<UserProfile> {
    const raw = await ObservationStore.getString(KEY_PROFILE, '')
    const p = new UserProfile()
    if (raw.length === 0) {
      return p
    }
    const parts = raw.split('\t')
    if (parts.length >= 1 && parts[0].length > 0) {
      p.nickname = parts[0]
    }
    if (parts.length >= 2 && parts[1].length > 0) {
      p.themeMode = parts[1]
    }
    return p
  }

  static async saveProfile(profile: UserProfile): Promise<void> {
    await ObservationStore.putString(KEY_PROFILE, `${profile.nickname}\t${profile.themeMode}`)
  }

  static async exportJson(): Promise<string> {
    const list = await ObservationStore.loadAll()
    const lines: string[] = []
    lines.push('{"app":"昆虫观察簿","notes":[')
    let i = 0
    for (const o of list) {
      const name = ObservationStore.esc(o.name)
      const loc = ObservationStore.esc(o.location)
      const beh = ObservationStore.esc(o.behavior)
      const tags = ObservationStore.esc(o.tagsJoined())
      const comma = i < list.length - 1 ? ',' : ''
      lines.push(`{"id":"${o.id}","name":"${name}","date":"${o.date}","time":"${o.time}","location":"${loc}","weather":"${o.weather}","behavior":"${beh}","tags":"${tags}","favorite":${o.isFavorite ? 'true' : 'false'}}${comma}`)
      i++
    }
    lines.push(']}')
    return lines.join('')
  }

  static async exportCsv(): Promise<string> {
    const list = await ObservationStore.loadAll()
    const lines: string[] = []
    lines.push('id,name,date,time,location,weather,behavior,tags,favorite')
    for (const o of list) {
      lines.push(`${o.id},${ObservationStore.csv(o.name)},${o.date},${o.time},${ObservationStore.csv(o.location)},${o.weather},${ObservationStore.csv(o.behavior)},${ObservationStore.csv(o.tagsJoined())},${o.isFavorite ? '1' : '0'}`)
    }
    return lines.join('\n')
  }

  private static monthKey(d: Date): string {
    const m = d.getMonth() + 1
    const mm = m < 10 ? `0${m}` : `${m}`
    return `${d.getFullYear()}-${mm}`
  }

  private static esc(text: string): string {
    return text.replace(/\\/g, '\\\\').replace(/"/g, '\\"')
  }

  private static csv(text: string): string {
    const t = text.replace(/"/g, '""')
    return `"${t}"`
  }

  private static persist(items: Observation[]): Promise<void> {
    const lines: string[] = []
    for (const o of items) {
      lines.push(ObservationStore.serialize(o))
    }
    return ObservationStore.putString(KEY_OBS, lines.join('\n'))
  }

  private static serialize(o: Observation): string {
    const name = o.name.replace(/\t/g, ' ').replace(/\n/g, ' ')
    const loc = o.location.replace(/\t/g, ' ').replace(/\n/g, ' ')
    const beh = o.behavior.replace(/\t/g, ' ').replace(/\n/g, ' ')
    const tags = o.tags.join('|').replace(/\t/g, ' ')
    const fav = o.isFavorite ? '1' : '0'
    return [o.id, name, o.photoUri, loc, `${o.latitude}`, `${o.longitude}`, o.date, o.time, o.weather, beh, tags, fav, `${o.createdAt}`, `${o.updatedAt}`].join('\t')
  }

  private static parse(raw: string): Observation[] {
    const out: Observation[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 14) {
        continue
      }
      const o = new Observation()
      o.id = parts[0]
      o.name = parts[1]
      o.photoUri = parts[2]
      o.location = parts[3]
      o.latitude = Number.parseFloat(parts[4])
      o.longitude = Number.parseFloat(parts[5])
      o.date = parts[6]
      o.time = parts[7]
      o.weather = parts[8]
      o.behavior = parts[9]
      if (parts[10].length > 0) {
        o.tags = parts[10].split('|')
      }
      o.isFavorite = parts[11] === '1'
      o.createdAt = Number.parseInt(parts[12], 10)
      o.updatedAt = Number.parseInt(parts[13], 10)
      out.push(o)
    }
    out.sort((a, b) => b.createdAt - a.createdAt)
    return out
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (ObservationStore.pref === null) {
      return fallback
    }
    try {
      const v = await ObservationStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (ObservationStore.pref === null) {
      return
    }
    try {
      await ObservationStore.pref.put(key, value)
      await ObservationStore.pref.flush()
    } catch {
    }
  }
}
