import { NoteItem } from '../models/SlipModels'
import { MoodCatalog } from './MoodCatalog'
import { SlipDateUtil } from './SlipDateUtil'
import { SlipStore } from './SlipStore'

export class EmotionPoint {
  label: string = ''
  value: number = 0
}

export class TagWeight {
  tag: string = ''
  count: number = 0
}

export class WeeklyReport {
  periodLabel: string = ''
  recordCount: number = 0
  topEmotions: string[] = []
  topTags: string[] = []
  themes: string[] = []
  summary: string = ''
}

/** 规则化智慧洞察：情绪趋势、标签云、主题归纳、每周札报（不调用大模型） */
export class InsightService {
  static itemsInPeriod(weekMode: boolean): NoteItem[] {
    const all = SlipStore.sorted()
    const days = weekMode ? 6 : 29
    const out: NoteItem[] = []
    for (const n of all) {
      if (SlipDateUtil.inLastDays(n.noteDate, days)) {
        out.push(n)
      }
    }
    return out
  }

  static emotionTrend(weekMode: boolean): EmotionPoint[] {
    const items = InsightService.itemsInPeriod(weekMode)
    const bag = new EmotionBag()
    for (const n of items) {
      for (const e of MoodCatalog.parseEmotions(n.mood)) {
        bag.add(e)
      }
    }
    const points: EmotionPoint[] = []
    for (const m of MoodCatalog.all()) {
      const p = new EmotionPoint()
      p.label = m.label
      p.value = bag.countOf(m.id)
      points.push(p)
    }
    return points
  }

  static tagCloud(weekMode: boolean): TagWeight[] {
    const items = InsightService.itemsInPeriod(weekMode)
    const keys: string[] = []
    const vals: number[] = []
    for (const n of items) {
      for (const t of n.tagList()) {
        let i = 0
        let found = false
        while (i < keys.length) {
          if (keys[i] === t) {
            vals[i] = vals[i] + 1
            found = true
          }
          i += 1
        }
        if (!found) {
          keys.push(t)
          vals.push(1)
        }
      }
    }
    const out: TagWeight[] = []
    let i = 0
    while (i < keys.length) {
      const tw = new TagWeight()
      tw.tag = keys[i]
      tw.count = vals[i]
      out.push(tw)
      i += 1
    }
    return InsightService.sortTags(out)
  }

  static themes(weekMode: boolean): string[] {
    const items = InsightService.itemsInPeriod(weekMode)
    const themes: string[] = []
    const workTags = ['工作', '考试']
    const relationTags = ['重逢', '追逐']
    const growthTags = ['飞翔', '旅行']
    let work = 0
    let relation = 0
    let growth = 0
    let anxiety = 0
    for (const n of items) {
      for (const t of n.tagList()) {
        if (workTags.indexOf(t) >= 0) {
          work += 1
        }
        if (relationTags.indexOf(t) >= 0) {
          relation += 1
        }
        if (growthTags.indexOf(t) >= 0) {
          growth += 1
        }
      }
      if (n.mood.indexOf('anxious') >= 0 || n.mood.indexOf('fear') >= 0) {
        anxiety += 1
      }
    }
    if (work >= 2) {
      themes.push('工作压力')
    }
    if (relation >= 2) {
      themes.push('人际关系')
    }
    if (growth >= 2) {
      themes.push('自我成长')
    }
    if (anxiety >= 2) {
      themes.push('内在不安')
    }
    if (themes.length === 0 && items.length > 0) {
      themes.push('潜意识探索')
    }
    return themes.slice(0, 3)
  }

  static buildWeeklyReport(): WeeklyReport {
    const report = new WeeklyReport()
    report.periodLabel = '近 7 天'
    const items = InsightService.itemsInPeriod(true)
    report.recordCount = items.length
    const trend = InsightService.emotionTrend(true)
    const emoLabels: string[] = []
    let i = 0
    while (i < trend.length && emoLabels.length < 3) {
      if (trend[i].value > 0) {
        emoLabels.push(trend[i].label)
      }
      i += 1
    }
    report.topEmotions = emoLabels
    const tags = InsightService.tagCloud(true)
    const tagNames: string[] = []
    let j = 0
    while (j < tags.length && tagNames.length < 4) {
      tagNames.push(tags[j].tag)
      j += 1
    }
    report.topTags = tagNames
    report.themes = InsightService.themes(true)
    if (items.length === 0) {
      report.summary = '本周尚未记录梦境，睡前写下一段碎片，智慧洞察会轻轻亮起。'
      return report
    }
    const themeText = report.themes.length > 0 ? report.themes.join(' · ') : '潜意识探索'
    report.summary = `本周 ${items.length} 条梦境札记，情绪以「${emoLabels.length > 0 ? emoLabels[0] : '安宁'}」为主，主题倾向 ${themeText}。`
    return report
  }

  private static sortTags(list: TagWeight[]): TagWeight[] {
    const work: TagWeight[] = []
    for (const t of list) {
      work.push(t)
    }
    const out: TagWeight[] = []
    while (work.length > 0) {
      let best: TagWeight | undefined = undefined
      for (const t of work) {
        if (best === undefined || t.count > best.count) {
          best = t
        }
      }
      if (best === undefined) {
        break
      }
      out.push(best)
      const next: TagWeight[] = []
      for (const t of work) {
        if (t.tag !== best.tag) {
          next.push(t)
        }
      }
      work.length = 0
      for (const t of next) {
        work.push(t)
      }
    }
    return out
  }
}

class EmotionBag {
  keys: string[] = []
  vals: number[] = []

  add(id: string): void {
    let i = 0
    while (i < this.keys.length) {
      if (this.keys[i] === id) {
        this.vals[i] = this.vals[i] + 1
        return
      }
      i += 1
    }
    this.keys.push(id)
    this.vals.push(1)
  }

  countOf(id: string): number {
    let i = 0
    while (i < this.keys.length) {
      if (this.keys[i] === id) {
        return this.vals[i]
      }
      i += 1
    }
    return 0
  }
}
