import { CauseOption, SubjectOption, SuggestionCard, WeakPoint, WrongEntry } from '../models/WrongModels'
import { BarChartItem } from '../components/design-system/AppChart'

export class CatalogOptions {
  static subjects(): SubjectOption[] {
    const list: SubjectOption[] = []
    list.push(SubjectOption.of('math', '数学'))
    list.push(SubjectOption.of('chinese', '语文'))
    list.push(SubjectOption.of('english', '英语'))
    list.push(SubjectOption.of('physics', '物理'))
    list.push(SubjectOption.of('chemistry', '化学'))
    list.push(SubjectOption.of('biology', '生物'))
    list.push(SubjectOption.of('history', '历史'))
    list.push(SubjectOption.of('geography', '地理'))
    list.push(SubjectOption.of('politics', '政治'))
    list.push(SubjectOption.of('other', '其他'))
    return list
  }

  static causes(): CauseOption[] {
    const list: CauseOption[] = []
    list.push(CauseOption.of('concept', '概念不清'))
    list.push(CauseOption.of('careless', '粗心大意'))
    list.push(CauseOption.of('misread', '审题错误'))
    list.push(CauseOption.of('method', '方法不当'))
    list.push(CauseOption.of('other', '其他'))
    return list
  }

  static subjectLabel(code: string): string {
    const all = CatalogOptions.subjects()
    for (const s of all) {
      if (s.code === code) {
        return s.label
      }
    }
    return '其他'
  }

  static causeLabel(code: string): string {
    const all = CatalogOptions.causes()
    for (const c of all) {
      if (c.code === code) {
        return c.label
      }
    }
    return '其他'
  }

  static statusLabel(status: string): string {
    if (status === 'mastered') {
      return '已掌握'
    }
    return '待复习'
  }
}

export class AnalyzeEngine {
  static todayStamp(): string {
    const d = new Date()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const mm = m < 10 ? `0${m}` : `${m}`
    const dd = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${mm}-${dd}`
  }

  static isToday(iso: string): boolean {
    if (iso.length < 10) {
      return false
    }
    return iso.substring(0, 10) === AnalyzeEngine.todayStamp()
  }

  static pendingCount(items: WrongEntry[]): number {
    let n = 0
    for (const e of items) {
      if (e.status !== 'mastered') {
        n += 1
      }
    }
    return n
  }

  static masteredCount(items: WrongEntry[]): number {
    let n = 0
    for (const e of items) {
      if (e.status === 'mastered') {
        n += 1
      }
    }
    return n
  }

  static todayCount(items: WrongEntry[]): number {
    let n = 0
    for (const e of items) {
      if (AnalyzeEngine.isToday(e.createdAt)) {
        n += 1
      }
    }
    return n
  }

  static subjectBars(items: WrongEntry[]): BarChartItem[] {
    const subjects = CatalogOptions.subjects()
    const bars: BarChartItem[] = []
    for (const s of subjects) {
      let n = 0
      for (const e of items) {
        if (e.subjectCode === s.code) {
          n += 1
        }
      }
      if (n > 0) {
        const bar = new BarChartItem()
        bar.label = s.label
        bar.value = n
        bars.push(bar)
      }
    }
    return bars
  }

  static weakPoints(items: WrongEntry[]): WeakPoint[] {
    const pending: WrongEntry[] = []
    for (const e of items) {
      if (e.status !== 'mastered' && e.knowledgeTag.length > 0) {
        pending.push(e)
      }
    }
    const points: WeakPoint[] = []
    for (const e of pending) {
      let found = false
      for (const p of points) {
        if (p.tag === e.knowledgeTag) {
          p.count += 1
          found = true
          break
        }
      }
      if (!found) {
        const p = new WeakPoint()
        p.tag = e.knowledgeTag
        p.count = 1
        points.push(p)
      }
    }
    points.sort((a: WeakPoint, b: WeakPoint) => b.count - a.count)
    const top: WeakPoint[] = []
    let i = 0
    for (const p of points) {
      if (i >= 6) {
        break
      }
      top.push(p)
      i += 1
    }
    return top
  }

  static weekBars(items: WrongEntry[]): BarChartItem[] {
    const labels: string[] = ['六天前', '五天前', '四天前', '三天前', '前天', '昨天', '今天']
    const keys: string[] = []
    const now = new Date()
    for (let offset = 6; offset >= 0; offset--) {
      const d = new Date()
      d.setTime(now.getTime() - offset * 86400000)
      const m = d.getMonth() + 1
      const day = d.getDate()
      const mm = m < 10 ? `0${m}` : `${m}`
      const dd = day < 10 ? `0${day}` : `${day}`
      keys.push(`${d.getFullYear()}-${mm}-${dd}`)
    }
    const counts: number[] = [0, 0, 0, 0, 0, 0, 0]
    for (const e of items) {
      if (e.createdAt.length < 10) {
        continue
      }
      const day = e.createdAt.substring(0, 10)
      for (let i = 0; i < keys.length; i++) {
        if (keys[i] === day) {
          counts[i] += 1
        }
      }
    }
    const bars: BarChartItem[] = []
    for (let i = 0; i < 7; i++) {
      const bar = new BarChartItem()
      bar.label = labels[i]
      bar.value = counts[i]
      bars.push(bar)
    }
    return bars
  }

  static suggestions(items: WrongEntry[]): SuggestionCard[] {
    const cards: SuggestionCard[] = []
    const pending = AnalyzeEngine.pendingCount(items)
    const weak = AnalyzeEngine.weakPoints(items)
    let concept = 0
    let careless = 0
    for (const e of items) {
      if (e.status === 'mastered') {
        continue
      }
      if (e.causeCode === 'concept') {
        concept += 1
      }
      if (e.causeCode === 'careless') {
        careless += 1
      }
    }
    if (items.length === 0) {
      const empty = new SuggestionCard()
      empty.title = '先记下第一道错题'
      empty.body = '游客可浏览学科导学。登录后拍照或手录一道题，分析页才会出现属于你的分布。'
      cards.push(empty)
      return cards
    }
    if (pending === 0) {
      const done = new SuggestionCard()
      done.title = '待复习已经清空'
      done.body = '隔一天再看已掌握的题干，能口述步骤就保持掌握；说不出就改回待复习。'
      cards.push(done)
    } else if (weak.length > 0) {
      const first = new SuggestionCard()
      first.title = `本周优先：${weak[0].tag}`
      first.body = `该标签出现 ${weak[0].count} 次。只留 1 道代表题，写清错因后再练 1 道同类题。`
      cards.push(first)
    }
    if (concept > careless && concept > 0) {
      const c = new SuggestionCard()
      c.title = '概念不清偏多'
      c.body = '先打开对应纠错方法卡，合上书默写定义，不要直接刷同类题。'
      cards.push(c)
    } else if (careless > 0) {
      const c = new SuggestionCard()
      c.title = '粗心可以用检查清单'
      c.body = '做完走三步：单位、正负号、是否抄错题。不必把整道计算重抄进错题本。'
      cards.push(c)
    }
    const extra = new SuggestionCard()
    extra.title = '周末只看待复习'
    extra.body = '在「我的」导出文本后，只打印待复习部分。做对的当场标记掌握。'
    cards.push(extra)
    return cards
  }

  static exportText(items: WrongEntry[]): string {
    let out = '文波错题析 · 错题本导出\n\n'
    for (const e of items) {
      const sub = CatalogOptions.subjectLabel(e.subjectCode)
      const cause = CatalogOptions.causeLabel(e.causeCode)
      const st = CatalogOptions.statusLabel(e.status)
      out += `【${sub} · ${st}】${e.stem}\n`
      out += `知识点：${e.knowledgeTag.length > 0 ? e.knowledgeTag : '未填'}\n`
      out += `错因：${cause}\n`
      out += `我的答案：${e.wrongAnswer}\n`
      out += `正确答案：${e.correctAnswer}\n`
      if (e.remark.length > 0) {
        out += `备注：${e.remark}\n`
      }
      out += '\n'
    }
    if (items.length === 0) {
      out += '（暂无错题）\n'
    }
    return out
  }
}
