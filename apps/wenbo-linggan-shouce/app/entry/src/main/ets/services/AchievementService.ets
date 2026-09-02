import { AchievementItem, StatsData } from '../models/InspirationModels'
import { InspirationBizService } from './InspirationBizService'

/** 成就规则 — 基于真实 stats + 打卡记录，无假数据 */
export class AchievementService {
  static async evaluate(userId: string): Promise<AchievementItem[]> {
    const stats = await InspirationBizService.loadStats(userId)
    const checkIns = await InspirationBizService.loadCheckIns(userId)
    const streak = AchievementService.computeStreak(InspirationBizService.checkInDates(checkIns))
    const defs: AchievementItem[] = []

    const mk = (id: string, title: string, desc: string, unlocked: boolean, icon: string): AchievementItem => {
      const a = new AchievementItem()
      a.id = id
      a.title = title
      a.description = desc
      a.unlocked = unlocked
      a.iconName = icon
      return a
    }

    defs.push(mk('first_inspiration', '灵感启程', '写下第一条灵感记录', stats.inspirationCount >= 1, 'book'))
    defs.push(mk('ten_inspirations', '记录达人', '累计 10 条灵感', stats.inspirationCount >= 10, 'book'))
    defs.push(mk('first_board', '画板玩家', '创建第一本画板', stats.boardCount >= 1, 'photo'))
    defs.push(mk('first_plan', '计划推手', '创建第一项创意计划', stats.planCount >= 1, 'calendar'))
    defs.push(mk('five_favorites', '收藏策展', '收藏 5 条灵感', stats.favoriteCount >= 5, 'heart'))
    defs.push(mk('streak_3', '连续创作 3 天', '坚持打卡 3 天', streak >= 3, 'ai'))
    defs.push(mk('streak_7', '连续创作 7 天', '坚持打卡 7 天', streak >= 7, 'ai'))
    defs.push(mk('streak_30', '连续创作 30 天', '坚持打卡 30 天', streak >= 30, 'ai'))
    return defs
  }

  static computeStreak(dates: string[]): number {
    if (dates.length === 0) {
      return 0
    }
    const sorted: string[] = []
    for (const d of dates) {
      if (d.length >= 10) {
        sorted.push(d.slice(0, 10))
      }
    }
    sorted.sort((a, b) => b.localeCompare(a))
    const unique: string[] = []
    for (const d of sorted) {
      let exists = false
      for (const u of unique) {
        if (u === d) {
          exists = true
          break
        }
      }
      if (!exists) {
        unique.push(d)
      }
    }
    const today = new Date().toISOString().slice(0, 10)
    let streak = 0
    let cursor = today
    for (const d of unique) {
      if (d === cursor) {
        streak += 1
        cursor = AchievementService.prevDay(cursor)
      } else if (streak === 0 && d === AchievementService.prevDay(today)) {
        cursor = d
        streak += 1
        cursor = AchievementService.prevDay(cursor)
      } else {
        break
      }
    }
    return streak
  }

  private static prevDay(iso: string): string {
    const parts = iso.split('-')
    const y = Number(parts[0])
    const m = Number(parts[1])
    const d = Number(parts[2])
    const dt = new Date(y, m - 1, d)
    dt.setDate(dt.getDate() - 1)
    const mm = dt.getMonth() + 1
    const dd = dt.getDate()
    return `${dt.getFullYear()}-${mm < 10 ? '0' : ''}${mm}-${dd < 10 ? '0' : ''}${dd}`
  }

  static weekSummary(stats: StatsData, streak: number): string {
    return `本周创作概览：灵感 ${stats.inspirationCount} 条 · 画板 ${stats.boardCount} 本 · 计划 ${stats.planCount} 项 · 连续打卡 ${streak} 天。继续把创意收进手册吧。`
  }
}
