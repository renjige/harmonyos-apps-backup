import { JournalItem } from '../models/JournalModels'
import { JournalBizService } from './JournalBizService'
import { MoodCatalog } from './MoodCatalog'
import { LifeListCodec } from './LifeListCodec'

export class MoodStat {
  key: string = ''
  label: string = ''
  count: number = 0
}

export class LifeInsightSnapshot {
  monthLabel: string = ''
  diaryCount: number = 0
  moodCount: number = 0
  habitDoneDays: number = 0
  habitTotalDays: number = 0
  listDone: number = 0
  listTotal: number = 0
  growthScore: number = 0
  narrative: string = ''
  moodStats: MoodStat[] = []
  topTag: string = ''
}

/** 生活洞察：融合札记、心情、打卡、清单，生成月度成长摘要（非通用日记） */
export class LifeInsightService {
  static async build(userId: string): Promise<LifeInsightSnapshot> {
    const snap = new LifeInsightSnapshot()
    const now = new Date()
    const year = now.getFullYear()
    const month = now.getMonth() + 1
    const mm = month < 10 ? `0${month}` : `${month}`
    snap.monthLabel = `${year} 年 ${month} 月`

    const diaries = await JournalBizService.loadDiaries(userId)
    const moods = await JournalBizService.loadByKind(userId, 'moodlog')
    const habits = await JournalBizService.loadByKind(userId, 'habit')
    const checks = await JournalBizService.loadByKind(userId, 'checkin')
    const lists = await JournalBizService.loadByKind(userId, 'list')

    const prefix = `${year}-${mm}`
    snap.diaryCount = LifeInsightService.countByMonth(diaries, prefix)
    snap.moodCount = LifeInsightService.countByMonth(moods, prefix)

    const daysInMonth = new Date(year, month, 0).getDate()
    snap.habitTotalDays = habits.length * daysInMonth
    snap.habitDoneDays = LifeInsightService.countCheckinsInMonth(checks, prefix)
    snap.listTotal = LifeInsightService.countListItems(lists)
    snap.listDone = LifeInsightService.countListDone(lists)

    snap.moodStats = LifeInsightService.moodDistribution(moods, prefix)
    snap.topTag = LifeInsightService.topTag(diaries, prefix)
    snap.growthScore = LifeInsightService.calcScore(snap)
    snap.narrative = LifeInsightService.buildNarrative(snap)
    return snap
  }

  private static countByMonth(items: JournalItem[], prefix: string): number {
    let n = 0
    for (let i = 0; i < items.length; i++) {
      if (items[i].recordDate.startsWith(prefix) || items[i].createdAt.startsWith(prefix)) {
        n++
      }
    }
    return n
  }

  private static countCheckinsInMonth(checks: JournalItem[], prefix: string): number {
    let n = 0
    for (let i = 0; i < checks.length; i++) {
      if (checks[i].recordDate.startsWith(prefix)) {
        n++
      }
    }
    return n
  }

  private static countListItems(lists: JournalItem[]): number {
    let total = 0
    for (let i = 0; i < lists.length; i++) {
      total += LifeListCodec.decode(lists[i].body).length
    }
    return total
  }

  private static countListDone(lists: JournalItem[]): number {
    let done = 0
    for (let i = 0; i < lists.length; i++) {
      const lines = LifeListCodec.decode(lists[i].body)
      for (let j = 0; j < lines.length; j++) {
        if (lines[j].done) {
          done++
        }
      }
    }
    return done
  }

  private static moodDistribution(moods: JournalItem[], prefix: string): MoodStat[] {
    const out: MoodStat[] = []
    const options = MoodCatalog.options()
    for (let i = 0; i < options.length; i++) {
      let count = 0
      for (let j = 0; j < moods.length; j++) {
        if (!moods[j].recordDate.startsWith(prefix)) {
          continue
        }
        const key = moods[j].category.length > 0 ? moods[j].category : 'calm'
        if (key === options[i].key) {
          count++
        }
      }
      if (count > 0) {
        const stat = new MoodStat()
        stat.key = options[i].key
        stat.label = options[i].label
        stat.count = count
        out.push(stat)
      }
    }
    return out
  }

  private static topTag(diaries: JournalItem[], prefix: string): string {
    const tagNames: string[] = []
    const tagCounts: number[] = []
    for (let i = 0; i < diaries.length; i++) {
      if (!diaries[i].recordDate.startsWith(prefix) && !diaries[i].createdAt.startsWith(prefix)) {
        continue
      }
      for (let j = 0; j < diaries[i].tags.length; j++) {
        const tag = diaries[i].tags[j]
        let idx = -1
        for (let k = 0; k < tagNames.length; k++) {
          if (tagNames[k] === tag) {
            idx = k
            break
          }
        }
        if (idx >= 0) {
          tagCounts[idx] = tagCounts[idx] + 1
        } else {
          tagNames.push(tag)
          tagCounts.push(1)
        }
      }
    }
    let best = ''
    let bestN = 0
    for (let i = 0; i < tagNames.length; i++) {
      if (tagCounts[i] > bestN) {
        bestN = tagCounts[i]
        best = tagNames[i]
      }
    }
    return best
  }

  private static calcScore(snap: LifeInsightSnapshot): number {
    let score = snap.diaryCount * 8 + snap.moodCount * 6
    if (snap.habitTotalDays > 0) {
      score += Math.round((snap.habitDoneDays / snap.habitTotalDays) * 40)
    }
    if (snap.listTotal > 0) {
      score += Math.round((snap.listDone / snap.listTotal) * 20)
    }
    if (score > 100) {
      return 100
    }
    return score
  }

  private static buildNarrative(snap: LifeInsightSnapshot): string {
    if (snap.diaryCount === 0 && snap.moodCount === 0 && snap.habitDoneDays === 0) {
      return '本月还没有足够数据。写札记、记录心情或完成打卡后，这里会自动生成你的生活洞察摘要。'
    }
    let text = `${snap.monthLabel}，你写下 ${snap.diaryCount} 篇札记`
    if (snap.moodCount > 0) {
      text += `、记录 ${snap.moodCount} 次心情`
    }
    if (snap.habitDoneDays > 0) {
      text += `、完成 ${snap.habitDoneDays} 次习惯打卡`
    }
    if (snap.listTotal > 0) {
      text += `、清单完成 ${snap.listDone}/${snap.listTotal} 项`
    }
    text += '。'
    if (snap.topTag.length > 0) {
      text += ` 本月最常出现的主题是「${snap.topTag}」。`
    }
    if (snap.moodStats.length > 0) {
      let top = snap.moodStats[0]
      for (let i = 1; i < snap.moodStats.length; i++) {
        if (snap.moodStats[i].count > top.count) {
          top = snap.moodStats[i]
        }
      }
      text += ` 情绪轨迹以「${top.label}」为主，建议保持记录节奏，让回顾更有温度。`
    } else {
      text += ' 坚持记录，月度洞察会越来越清晰。'
    }
    return text
  }
}
