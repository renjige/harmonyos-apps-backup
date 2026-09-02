import {
  DayScorePoint, EmotionCount, HighlightDay, MonthlyReportData, MoodStats
} from '../models/MoodModels'
import { EmotionCatalog } from '../models/EmotionCatalog'
import { DateHelper } from './DateHelper'
import { MoodStore } from './MoodStore'

export class MonthlyReportService {
  static async buildReport(year: number, month: number): Promise<MonthlyReportData> {
    const report = new MonthlyReportData()
    report.year = year
    report.month = month
    const records = await MoodStore.recordsInMonth(year, month)
    report.recordDays = records.length

    let scoreSum = 0
    const countMap: Map<string, number> = new Map()
    for (const r of records) {
      scoreSum += r.score
      for (const eid of r.emotions) {
        const prev = countMap.get(eid) ?? 0
        countMap.set(eid, prev + 1)
      }
    }
    report.avgScore = records.length > 0 ? Math.round((scoreSum / records.length) * 10) / 10 : 0

    const emotionCounts: EmotionCount[] = []
    countMap.forEach((count: number, id: string) => {
      const ec = new EmotionCount()
      ec.id = id
      ec.label = EmotionCatalog.labelOf(id)
      ec.color = EmotionCatalog.colorOf(id)
      ec.count = count
      emotionCounts.push(ec)
    })
    emotionCounts.sort((a, b) => b.count - a.count)
    report.emotionCounts = emotionCounts

    const points: DayScorePoint[] = []
    const days = DateHelper.daysInMonth(year, month)
    for (let day = 1; day <= days; day++) {
      const key = DateHelper.dateKey(year, month, day)
      const p = new DayScorePoint()
      p.day = day
      p.dateKey = key
      let found = false
      for (const r of records) {
        if (r.dateKey === key) {
          p.score = r.score
          p.color = EmotionCatalog.colorOf(r.primaryEmotionId())
          found = true
          break
        }
      }
      if (!found) {
        p.score = 0
      }
      points.push(p)
    }
    report.scorePoints = points

    const sorted = records.slice()
    sorted.sort((a, b) => b.score - a.score)
    const highlights: HighlightDay[] = []
    for (let i = 0; i < sorted.length && i < 3; i++) {
      const r = sorted[i]
      const h = new HighlightDay()
      h.dateKey = r.dateKey
      h.score = r.score
      h.diary = r.diary
      h.imagePath = r.imagePath
      h.emotions = r.emotions.slice()
      highlights.push(h)
    }
    report.highlights = highlights
    report.monthlyMessage = MonthlyReportService.composeMessage(report)
    return report
  }

  static async overallStats(): Promise<MoodStats> {
    const list = await MoodStore.loadAll()
    const stats = new MoodStats()
    stats.totalDays = list.length
    const countMap: Map<string, number> = new Map()
    for (const r of list) {
      for (const eid of r.emotions) {
        const prev = countMap.get(eid) ?? 0
        countMap.set(eid, prev + 1)
      }
    }
    const emotionCounts: EmotionCount[] = []
    countMap.forEach((count: number, id: string) => {
      const ec = new EmotionCount()
      ec.id = id
      ec.label = EmotionCatalog.labelOf(id)
      ec.color = EmotionCatalog.colorOf(id)
      ec.count = count
      emotionCounts.push(ec)
    })
    emotionCounts.sort((a, b) => b.count - a.count)
    stats.emotionCounts = emotionCounts
    return stats
  }

  private static composeMessage(report: MonthlyReportData): string {
    if (report.recordDays === 0) {
      return '这个月还没有留下月痕。从今日起，用一两句话记录心情，月末这里会为你汇总温柔的故事。'
    }
    let topLabel = '平静'
    if (report.emotionCounts.length > 0) {
      topLabel = report.emotionCounts[0].label
    }
    if (report.avgScore >= 8) {
      return `这个月你记录了 ${report.recordDays} 天，「${topLabel}」常伴左右。能量均值 ${report.avgScore} 分，像被月光轻轻托住——请把这份明亮留到下一程。`
    }
    if (report.avgScore >= 5) {
      return `${DateHelper.monthLabel(report.year, report.month)}，你用心留下了 ${report.recordDays} 道月痕。「${topLabel}」出现最多。起伏都是生活纹理，继续温柔地看见自己。`
    }
    return `这个月或许不太轻松，但你仍坚持记录了 ${report.recordDays} 天。请记得：低落的夜晚也会过去，月缺终有再圆时。`
  }
}
