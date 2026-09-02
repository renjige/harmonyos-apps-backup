import { InsightBundle, KnowledgeCardItem, SlotBar, StudySession, TimelineItem } from '../models/StudyModels'
import { StudyStore } from './StudyStore'

export class StudyInsightService {
  static build(sessions: StudySession[], cards: KnowledgeCardItem[], notesCount: number, rangeDays: number): InsightBundle {
    const b = new InsightBundle()
    const since = Date.now() - rangeDays * 24 * 60 * 60 * 1000
    let minutes = 0
    const dayKeys: string[] = []
    let evening = 0
    let morning = 0
    let afternoon = 0
    for (const s of sessions) {
      if (s.endedAt < since) {
        continue
      }
      minutes += s.minutes
      const k = StudyStore.dateKey(s.endedAt)
      let seen = false
      for (const e of dayKeys) {
        if (e === k) {
          seen = true
        }
      }
      if (!seen) {
        dayKeys.push(k)
      }
      const h = StudyStore.hourOf(s.endedAt)
      if (h < 12) {
        morning += s.minutes
      } else if (h < 18) {
        afternoon += s.minutes
      } else {
        evening += s.minutes
      }
    }
    b.totalMinutes = minutes
    b.studyDays = dayKeys.length
    b.cardCount = cards.length
    b.noteCount = notesCount
    b.streak = StudyStore.streakDays(sessions)
    if (evening >= morning && evening >= afternoon && evening > 0) {
      b.peakHint = '你通常在晚上学习更投入'
    } else if (morning >= afternoon && morning > 0) {
      b.peakHint = '你通常在上午更容易进入专注'
    } else if (afternoon > 0) {
      b.peakHint = '你通常在下午完成更多专注时长'
    } else {
      b.peakHint = '完成第一段专注后，这里会看见你的活跃时段'
    }
    let reviewNeed = 0
    for (const c of cards) {
      if (!c.isMastered()) {
        reviewNeed++
      }
    }
    if (minutes === 0) {
      b.advice = '从 15 分钟开始。看见第一段时长，热力图就会亮起来。'
    } else if (b.streak >= 3 && reviewNeed > 0) {
      b.advice = `已连续 ${b.streak} 天。建议抽一张需复习的知识卡片，把时长变成记得住的要点。`
    } else if (b.streak >= 3) {
      b.advice = `已连续 ${b.streak} 天。保持当前节奏即可，不必加长到让自己抗拒。`
    } else if (reviewNeed > 0) {
      b.advice = `有 ${reviewNeed} 张卡片待复习。先复习一张，再开始新的专注。`
    } else {
      b.advice = '把今天的笔记拆成一张卡片，下次复习会更轻。'
    }
    return b
  }

  static timeline(sessions: StudySession[], notesTitle: string[], notesTime: number[],
    cardsTitle: string[], cardsTime: number[]): TimelineItem[] {
    const out: TimelineItem[] = []
    for (const s of sessions) {
      const t = new TimelineItem()
      t.id = s.id
      t.kind = 'session'
      t.title = s.completed ? `完成 ${s.minutes} 分钟专注` : `记录 ${s.minutes} 分钟`
      t.subtitle = `计划 ${s.plannedMinutes} 分钟`
      t.timeLabel = StudyStore.timeLabel(s.endedAt)
      t.at = s.endedAt
      out.push(t)
    }
    for (let i = 0; i < notesTitle.length; i++) {
      const t = new TimelineItem()
      t.id = `note_${i}`
      t.kind = 'note'
      t.title = notesTitle[i]
      t.subtitle = '学习笔记'
      t.timeLabel = StudyStore.timeLabel(notesTime[i])
      t.at = notesTime[i]
      out.push(t)
    }
    for (let i = 0; i < cardsTitle.length; i++) {
      const t = new TimelineItem()
      t.id = `card_${i}`
      t.kind = 'card'
      t.title = cardsTitle[i]
      t.subtitle = '知识卡片'
      t.timeLabel = StudyStore.timeLabel(cardsTime[i])
      t.at = cardsTime[i]
      out.push(t)
    }
    out.sort((a: TimelineItem, b: TimelineItem) => {
      return b.at - a.at
    })
    const capped: TimelineItem[] = []
    for (let i = 0; i < out.length && i < 20; i++) {
      capped.push(out[i])
    }
    return capped
  }

  static hourBars(sessions: StudySession[], rangeDays: number): SlotBar[] {
    const labels: string[] = ['清晨', '上午', '下午', '晚上']
    const sums: number[] = [0, 0, 0, 0]
    const since = Date.now() - rangeDays * 24 * 60 * 60 * 1000
    for (const s of sessions) {
      if (s.endedAt < since) {
        continue
      }
      const h = StudyStore.hourOf(s.endedAt)
      if (h < 8) {
        sums[0] = sums[0] + s.minutes
      } else if (h < 12) {
        sums[1] = sums[1] + s.minutes
      } else if (h < 18) {
        sums[2] = sums[2] + s.minutes
      } else {
        sums[3] = sums[3] + s.minutes
      }
    }
    const items: SlotBar[] = []
    for (let i = 0; i < 4; i++) {
      const b = new SlotBar()
      b.label = labels[i]
      b.value = sums[i]
      items.push(b)
    }
    return items
  }

  static exportText(bundle: InsightBundle, rangeDays: number): string {
    const range = rangeDays === 7 ? '近 7 天' : '近 30 天'
    return `学见学习报告（${range}）\n` +
      `总时长：${bundle.totalMinutes} 分钟\n` +
      `学习天数：${bundle.studyDays}\n` +
      `知识卡片：${bundle.cardCount}\n` +
      `连续天数：${bundle.streak}\n` +
      `${bundle.peakHint}\n` +
      `${bundle.advice}\n`
  }
}
