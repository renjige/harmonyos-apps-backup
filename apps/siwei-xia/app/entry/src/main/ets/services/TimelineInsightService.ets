import { TimelineEvent, WeekInsight } from '../models/SparkLinkModels'
import { ThoughtCard } from '../models/ThoughtModels'
import { ThoughtStore } from './ThoughtStore'
import { ThinkStore } from './ThinkStore'
import { SparkBridge } from './SparkBridge'
import { DateHelper } from './DateHelper'

const WEEK_MS = 7 * 86400000

export class TimelineInsightService {
  static async weekInsight(): Promise<WeekInsight> {
    const now = Date.now()
    const since = now - WEEK_MS
    const cards = await ThoughtStore.loadActive()
    const insight = new WeekInsight()
    insight.linked = await SparkBridge.linkedCount()
    const g = await ThinkStore.growth()
    insight.streak = g.streak

    const tagCount: string[] = []
    const tagNum: number[] = []
    for (const c of cards) {
      if (c.createdAt >= since) {
        insight.sparkNew = insight.sparkNew + 1
      }
      const tags = c.tags()
      if (tags.length === 0) {
        TimelineInsightService.bumpTag(tagCount, tagNum, '未分类')
      } else {
        for (const t of tags) {
          TimelineInsightService.bumpTag(tagCount, tagNum, t)
        }
      }
    }

    const notes = await ThinkStore.loadNotes()
    const breaks = await ThinkStore.loadBreaks()
    const opinions = await ThinkStore.loadOpinions()
    for (const it of notes) {
      if (it.createdAt >= since) {
        insight.thinkNew = insight.thinkNew + 1
      }
    }
    for (const it of breaks) {
      if (it.createdAt >= since) {
        insight.thinkNew = insight.thinkNew + 1
      }
    }
    for (const it of opinions) {
      if (it.createdAt >= since) {
        insight.thinkNew = insight.thinkNew + 1
      }
    }

    let top = '未分类'
    let topN = 0
    for (let i = 0; i < tagCount.length; i++) {
      if (tagNum[i] > topN) {
        topN = tagNum[i]
        top = tagCount[i]
      }
    }
    insight.topTag = top
    insight.summary =
      `本周新灵感 ${insight.sparkNew} 条，思考加工 ${insight.thinkNew} 条，${insight.linked} 条已建立匣格链路。`
    return insight
  }

  static async timeline(limit: number): Promise<TimelineEvent[]> {
    const out: TimelineEvent[] = []
    const cards = await ThoughtStore.loadActive()
    for (const c of cards) {
      const e = new TimelineEvent()
      e.id = `sp_${c.id}`
      e.kind = 'spark'
      e.title = c.titleLine()
      e.subtitle = c.tagLine()
      e.at = c.createdAt
      e.cardId = c.id
      out.push(e)
    }
    const notes = await ThinkStore.loadNotes()
    for (const n of notes) {
      const e = new TimelineEvent()
      e.id = `nt_${n.id}`
      e.kind = 'note'
      e.title = n.title
      e.subtitle = n.category
      e.at = n.createdAt
      out.push(e)
    }
    const breaks = await ThinkStore.loadBreaks()
    for (const b of breaks) {
      const e = new TimelineEvent()
      e.id = `bk_${b.id}`
      e.kind = 'break'
      e.title = b.question
      e.subtitle = '问题拆解'
      e.at = b.createdAt
      out.push(e)
    }
    const opinions = await ThinkStore.loadOpinions()
    for (const o of opinions) {
      const e = new TimelineEvent()
      e.id = `op_${o.id}`
      e.kind = 'opinion'
      e.title = o.title
      e.subtitle = '观点卡片'
      e.at = o.createdAt
      out.push(e)
    }
    TimelineInsightService.sortDesc(out)
    if (out.length > limit) {
      return out.slice(0, limit)
    }
    return out
  }

  private static sortDesc(list: TimelineEvent[]): void {
    for (let i = 0; i < list.length; i++) {
      for (let j = i + 1; j < list.length; j++) {
        if (list[j].at > list[i].at) {
          const tmp = list[i]
          list[i] = list[j]
          list[j] = tmp
        }
      }
    }
  }

  private static bumpTag(names: string[], counts: number[], name: string): void {
    for (let i = 0; i < names.length; i++) {
      if (names[i] === name) {
        counts[i] = counts[i] + 1
        return
      }
    }
    names.push(name)
    counts.push(1)
  }

  static kindLabel(kind: string): string {
    if (kind === 'spark') {
      return '灵感'
    }
    if (kind === 'break') {
      return '拆解'
    }
    if (kind === 'note') {
      return '笔记'
    }
    if (kind === 'opinion') {
      return '观点'
    }
    return '记录'
  }
}
