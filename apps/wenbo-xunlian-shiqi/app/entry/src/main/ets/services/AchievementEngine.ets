import { AchievementItem, TrainingSummary } from '../models/TrainingModels'
import { TrainingAnalytics } from './TrainingAnalytics'
import { TrainingStore } from './TrainingStore'
import { FunQuestStore } from './FunQuestStore'
import { FunQuestService } from './FunQuestService'

export class AchievementEngine {
  static evaluate(): AchievementItem[] {
    const summary = TrainingAnalytics.summarize()
    const defs = AchievementEngine.definitions()
    const out: AchievementItem[] = []
    for (const def of defs) {
      const copy = new AchievementItem()
      copy.id = def.id
      copy.title = def.title
      copy.description = def.description
      copy.emoji = def.emoji
      copy.unlocked = AchievementEngine.check(def.id, summary)
      if (copy.unlocked) {
        copy.unlockedAt = AchievementEngine.unlockDate(def.id)
      }
      out.push(copy)
    }
    return out
  }

  static unlockedCount(): number {
    let n = 0
    for (const a of AchievementEngine.evaluate()) {
      if (a.unlocked) {
        n += 1
      }
    }
    return n
  }

  static detectNewUnlock(beforeIds: string[]): AchievementItem | null {
    const after = AchievementEngine.evaluate()
    for (const a of after) {
      if (!a.unlocked) {
        continue
      }
      let wasUnlocked = false
      for (const id of beforeIds) {
        if (id === a.id) {
          wasUnlocked = true
          break
        }
      }
      if (!wasUnlocked) {
        return a
      }
    }
    return null
  }

  static unlockedIds(): string[] {
    const ids: string[] = []
    for (const a of AchievementEngine.evaluate()) {
      if (a.unlocked) {
        ids.push(a.id)
      }
    }
    return ids
  }

  private static definitions(): AchievementItem[] {
    const items: AchievementItem[] = []
    const a1 = new AchievementItem()
    a1.id = 'first_record'
    a1.title = '活力新人'
    a1.description = '完成第一次训练记录'
    a1.emoji = '🏅'
    items.push(a1)
    const a2 = new AchievementItem()
    a2.id = 'streak_7'
    a2.title = '坚持达人'
    a2.description = '连续 7 天有训练记录'
    a2.emoji = '🔥'
    items.push(a2)
    const a3 = new AchievementItem()
    a3.id = 'pioneer'
    a3.title = '训练先锋'
    a3.description = '完成首个训练挑战'
    a3.emoji = '🏅'
    items.push(a3)
    const a4 = new AchievementItem()
    a4.id = 'sessions_30'
    a4.title = '三十次'
    a4.description = '累计训练 30 次'
    a4.emoji = '🏆'
    items.push(a4)
    const a5 = new AchievementItem()
    a5.id = 'streak_21'
    a5.title = '廿一日'
    a5.description = '连续 21 天有训练记录'
    a5.emoji = '🏆'
    items.push(a5)
    const a6 = new AchievementItem()
    a6.id = 'streak_100'
    a6.title = '百日坚持'
    a6.description = '累计训练天数达到 100 天'
    a6.emoji = '🏆'
    items.push(a6)
    return items
  }

  private static check(id: string, summary: TrainingSummary): boolean {
    if (id === 'first_record') {
      return summary.totalCount >= 1
    }
    if (id === 'streak_7') {
      return summary.streakDays >= 7
    }
    if (id === 'pioneer') {
      return AchievementEngine.hasFinishedQuest()
    }
    if (id === 'sessions_30') {
      return summary.totalCount >= 30
    }
    if (id === 'streak_21') {
      return summary.streakDays >= 21
    }
    if (id === 'streak_100') {
      return summary.totalDays >= 100
    }
    return false
  }

  private static hasFinishedQuest(): boolean {
    for (const q of FunQuestStore.list()) {
      if (q.status === 'done') {
        return true
      }
      if (FunQuestService.progress(q).done) {
        return true
      }
    }
    return false
  }

  private static unlockDate(id: string): string {
    const list = TrainingStore.list()
    if (list.length === 0) {
      return ''
    }
    if (id === 'first_record') {
      return list[list.length - 1].recordDate
    }
    return list[0].recordDate
  }
}
