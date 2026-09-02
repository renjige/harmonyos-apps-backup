import { TaskLocalStore } from './TaskLocalStore'
import { JujiaLocalStore } from './JujiaLocalStore'
import { TaskService } from './TaskService'
import { TaskDates } from '../models/FamilyTaskModels'
import { CheckInService } from './CheckInService'
import { FavoriteService } from './FavoriteService'
import { AchievementService } from './AchievementService'

export class ReviewService {
  static weekSummary(): string {
    const all = TaskLocalStore.tasks()
    const today = TaskDates.today()
    const week = TaskService.weekRows(all, today)
    const done = TaskService.doneCount(week)
    const total = week.length
    const items = JujiaLocalStore.items().length
    const memos = JujiaLocalStore.memos().length
    const diaries = JujiaLocalStore.diaries().length
    const streak = CheckInService.streakDays()
    const fav = FavoriteService.countAll()
    const ach = AchievementService.unlockedCount()
    if (total === 0 && items === 0 && memos === 0) {
      return '本周还没有记录。从一条计划或一件物品开始，为家庭生活盖章。'
    }
    let rate = 0
    if (total > 0) {
      rate = Math.round((done * 100) / total)
    }
    return `本周完成 ${done}/${total} 项计划（${rate}%）。登记物品 ${items} 件、备忘 ${memos} 条、日记 ${diaries} 篇。连续完成 ${streak} 天，收藏 ${fav} 条，解锁成就 ${ach} 个。`
  }

  static monthHeadline(): string {
    const all = TaskLocalStore.tasks()
    let done = 0
    for (const row of all) {
      if (row.completed) {
        done += 1
      }
    }
    return `累计完成 ${done} 项家庭计划，生活更有序。`
  }
}
