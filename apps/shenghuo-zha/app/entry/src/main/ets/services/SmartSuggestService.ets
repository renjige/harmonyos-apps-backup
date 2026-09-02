import { LifeNoteItem, LifeTodayMemo } from '../models/LifeModels'

class KeywordRule {
  keyword: string = ''
  tag: string = ''

  static create(keyword: string, tag: string): KeywordRule {
    const r = new KeywordRule()
    r.keyword = keyword
    r.tag = tag
    return r
  }
}

export class SmartSuggestService {
  private static rules(): KeywordRule[] {
    const list: KeywordRule[] = []
    list.push(KeywordRule.create('旅行', '旅行'))
    list.push(KeywordRule.create('出差', '旅行'))
    list.push(KeywordRule.create('美食', '美食'))
    list.push(KeywordRule.create('早餐', '美食'))
    list.push(KeywordRule.create('午餐', '美食'))
    list.push(KeywordRule.create('晚餐', '美食'))
    list.push(KeywordRule.create('咖啡', '日常'))
    list.push(KeywordRule.create('茶', '日常'))
    list.push(KeywordRule.create('读书', '阅读'))
    list.push(KeywordRule.create('阅读', '阅读'))
    list.push(KeywordRule.create('运动', '运动'))
    list.push(KeywordRule.create('跑步', '运动'))
    list.push(KeywordRule.create('健身', '运动'))
    list.push(KeywordRule.create('工作', '工作'))
    list.push(KeywordRule.create('会议', '工作'))
    list.push(KeywordRule.create('家人', '家庭'))
    list.push(KeywordRule.create('孩子', '家庭'))
    list.push(KeywordRule.create('宠物', '萌宠'))
    list.push(KeywordRule.create('猫', '萌宠'))
    list.push(KeywordRule.create('狗', '萌宠'))
    list.push(KeywordRule.create('电影', '娱乐'))
    list.push(KeywordRule.create('音乐', '娱乐'))
    list.push(KeywordRule.create('购物', '生活'))
    list.push(KeywordRule.create('心情', '感悟'))
    list.push(KeywordRule.create('感恩', '感悟'))
    return list
  }

  static suggestTags(text: string, existing: string[]): string[] {
    const found: string[] = []
    const lower = text.toLowerCase()
    const rules = SmartSuggestService.rules()
    for (const rule of rules) {
      if (lower.indexOf(rule.keyword) >= 0) {
        let dup = false
        for (const e of existing) {
          if (e === rule.tag) {
            dup = true
            break
          }
        }
        if (!dup) {
          let inFound = false
          for (const f of found) {
            if (f === rule.tag) {
              inFound = true
              break
            }
          }
          if (!inFound) {
            found.push(rule.tag)
          }
        }
      }
    }
    return found
  }

  static mergeTags(existing: string[], suggested: string[], custom: string[]): string[] {
    const out: string[] = []
    const all: string[] = []
    for (const t of existing) {
      all.push(t)
    }
    for (const t of suggested) {
      all.push(t)
    }
    for (const t of custom) {
      const trimmed = t.trim()
      if (trimmed.length > 0) {
        all.push(trimmed)
      }
    }
    for (const t of all) {
      let dup = false
      for (const o of out) {
        if (o === t) {
          dup = true
          break
        }
      }
      if (!dup) {
        out.push(t)
      }
    }
    return out
  }

  static todayMemo(noteCount: number, streakDays: number): LifeTodayMemo {
    const d = new Date()
    const hour = d.getHours()
    const month = d.getMonth() + 1
    let greeting = '记录今天的小确幸'
    if (hour < 6) {
      greeting = '夜深了，把今天的感受写下来吧'
    } else if (hour < 11) {
      greeting = '早安，用一段文字开启温暖一天'
    } else if (hour < 14) {
      greeting = '午间片刻，适合记下此刻心情'
    } else if (hour < 18) {
      greeting = '下午时光，留一点生活痕迹'
    } else {
      greeting = '傍晚了，回顾今天值得记住的事'
    }
    if (month >= 3 && month <= 5) {
      greeting = `${greeting} · 春日和煦`
    } else if (month >= 6 && month <= 8) {
      greeting = `${greeting} · 夏日悠长`
    } else if (month >= 9 && month <= 11) {
      greeting = `${greeting} · 秋意渐浓`
    } else {
      greeting = `${greeting} · 冬日温暖`
    }
    let hint = '点击右下角 + 开始记录'
    if (noteCount === 0) {
      hint = '写下第一条生活札，开启你的时光轴'
    } else if (streakDays >= 7) {
      hint = `已连续记录 ${streakDays} 天，继续保持`
    } else if (streakDays >= 3) {
      hint = `已连续 ${streakDays} 天，养成记录习惯中`
    } else {
      hint = `已有 ${noteCount} 条记录，今天也写一点吧`
    }
    return LifeTodayMemo.create(greeting, hint)
  }

  static extractFromNotes(notes: LifeNoteItem[]): string[] {
    const freq: Map<string, number> = new Map()
    for (const n of notes) {
      for (const t of n.tags) {
        const prev = freq.get(t)
        if (prev === undefined) {
          freq.set(t, 1)
        } else {
          freq.set(t, prev + 1)
        }
      }
    }
    const sorted: string[] = []
    freq.forEach((_c: number, name: string) => { sorted.push(name) })
    sorted.sort((a, b) => {
      const ca = freq.get(a) ?? 0
      const cb = freq.get(b) ?? 0
      return cb - ca
    })
    const top: string[] = []
    for (let i = 0; i < sorted.length && i < 5; i++) {
      top.push(sorted[i])
    }
    return top
  }
}
