import { DailyPlan, DestItem } from '../models/ScenicModels'

/** 规则模板行程：目的地字段 + 天数 + 偏好，无大模型 */
export class TripPlanner {
  static build(dest: DestItem, days: number, preference: string): DailyPlan[] {
    let n = days
    if (n < 1) {
      n = 1
    }
    if (n > 7) {
      n = 7
    }
    const out: DailyPlan[] = []
    const mornings: string[] = TripPlanner.splitSpots(dest.morningPlan, dest.spots, '上午慢走')
    const afternoons: string[] = TripPlanner.splitSpots(dest.afternoonPlan, dest.spots, '下午把步子放慢')
    const evenings: string[] = TripPlanner.splitSpots(dest.eveningPlan, dest.tips, '晚上把一天收住')
    const extra = TripPlanner.prefHint(preference)
    for (let d = 1; d <= n; d++) {
      const p = new DailyPlan()
      p.day = d
      p.morning = TripPlanner.pick(mornings, d - 1) + extra
      p.afternoon = TripPlanner.pick(afternoons, d)
      p.evening = TripPlanner.pick(evenings, d + 1)
      out.push(p)
    }
    return out
  }

  static serialize(plans: DailyPlan[]): string {
    let s = ''
    for (const p of plans) {
      if (s.length > 0) {
        s += '\n'
      }
      s += `${p.day}||${p.morning}||${p.afternoon}||${p.evening}`
    }
    return s
  }

  static parse(raw: string): DailyPlan[] {
    const out: DailyPlan[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const parts = line.split('||')
      if (parts.length >= 4) {
        const p = new DailyPlan()
        p.day = Number.parseInt(parts[0]) || 1
        p.morning = parts[1]
        p.afternoon = parts[2]
        p.evening = parts[3]
        out.push(p)
      }
    }
    return out
  }

  private static splitSpots(primary: string, spots: string, fallback: string): string[] {
    const out: string[] = []
    if (primary.length > 0) {
      out.push(primary)
    }
    if (spots.length > 0) {
      const bits = spots.split(',')
      for (const b of bits) {
        const t = b.trim()
        if (t.length > 0) {
          out.push(`把时间交给「${t}」`)
        }
      }
    }
    if (out.length === 0) {
      out.push(fallback)
    }
    return out
  }

  private static pick(list: string[], index: number): string {
    if (list.length === 0) {
      return '把这一段留白'
    }
    let i = index % list.length
    if (i < 0) {
      i = 0
    }
    return list[i]
  }

  private static prefHint(preference: string): string {
    if (preference === 'nature') {
      return ' · 多留一点给风和树'
    }
    if (preference === 'history') {
      return ' · 把讲解听完再走'
    }
    if (preference === 'food') {
      return ' · 正餐留给本地馆子'
    }
    return ''
  }
}
