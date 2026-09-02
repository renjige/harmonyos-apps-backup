import { AchievementItem } from '../models/ZhixingModels'
import { ZhixingStore } from './ZhixingStore'

export class AchievementService {
  private static defs(): AchievementItem[] {
    const list: AchievementItem[] = []
    const a1 = new AchievementItem()
    a1.id = 'first_card'
    a1.title = '首张卡片'
    a1.desc = '创建第一张知识卡片'
    a1.target = 1
    list.push(a1)
    const a2 = new AchievementItem()
    a2.id = 'cards_10'
    a2.title = '卡片达人'
    a2.desc = '累计 10 张知识内容'
    a2.target = 10
    list.push(a2)
    const a3 = new AchievementItem()
    a3.id = 'streak_7'
    a3.title = '连续一周'
    a3.desc = '任一习惯连续打卡 7 天'
    a3.target = 7
    list.push(a3)
    const a4 = new AchievementItem()
    a4.id = 'plan_done_3'
    a4.title = '计划执行者'
    a4.desc = '完成 3 个学习计划'
    a4.target = 3
    list.push(a4)
    const a5 = new AchievementItem()
    a5.id = 'favorite_5'
    a5.title = '收藏达人'
    a5.desc = '收藏 5 条知识内容'
    a5.target = 5
    list.push(a5)
    const a6 = new AchievementItem()
    a6.id = 'log_10'
    a6.title = '行动记录者'
    a6.desc = '写下 10 条行动日志'
    a6.target = 10
    list.push(a6)
    return list
  }

  static async listWithProgress(): Promise<AchievementItem[]> {
    const ov = await ZhixingStore.overview()
    const unlocked = await AchievementService.loadUnlocked()
    const defs = AchievementService.defs()
    const out: AchievementItem[] = []
    for (const d of defs) {
      const copy = new AchievementItem()
      copy.id = d.id
      copy.title = d.title
      copy.desc = d.desc
      copy.target = d.target
      copy.progress = AchievementService.calcProgress(d.id, ov.notes + ov.cards + ov.digests,
        ov.favorites, ov.donePlans, ov.streak, ov.logs)
      copy.unlocked = unlocked.indexOf(d.id) >= 0
      copy.unlockedAt = copy.unlocked ? 1 : 0
      if (!copy.unlocked && copy.progress >= copy.target) {
        copy.unlocked = true
        await AchievementService.unlock(d.id)
      }
      out.push(copy)
    }
    return out
  }

  static async unlockedCount(): Promise<number> {
    const list = await AchievementService.listWithProgress()
    let n = 0
    for (const a of list) {
      if (a.unlocked) {
        n++
      }
    }
    return n
  }

  static async syncUnlocks(): Promise<void> {
    await AchievementService.listWithProgress()
  }

  private static calcProgress(id: string, knowTotal: number, fav: number, donePlans: number,
    streak: number, logs: number): number {
    if (id === 'first_card') {
      return knowTotal > 0 ? 1 : 0
    }
    if (id === 'cards_10') {
      return knowTotal
    }
    if (id === 'streak_7') {
      return streak
    }
    if (id === 'plan_done_3') {
      return donePlans
    }
    if (id === 'favorite_5') {
      return fav
    }
    if (id === 'log_10') {
      return logs
    }
    return 0
  }

  private static async loadUnlocked(): Promise<string[]> {
    const raw = await ZhixingStore.getAchievementRaw()
    if (raw.length === 0) {
      return []
    }
    return raw.split(',')
  }

  private static async unlock(id: string): Promise<void> {
    const cur = await AchievementService.loadUnlocked()
    if (cur.indexOf(id) >= 0) {
      return
    }
    cur.push(id)
    await ZhixingStore.saveAchievementRaw(cur.join(','))
  }
}
