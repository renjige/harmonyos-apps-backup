import { FamilyStatsSnapshot } from '../models/JujiaModels'
import { JujiaLocalStore } from './JujiaLocalStore'
import { MemberService } from './MemberService'
import { TaskLocalStore } from './TaskLocalStore'
import { TaskService } from './TaskService'
import { FavoriteService } from './FavoriteService'
import { CheckInService } from './CheckInService'
import { AchievementService } from './AchievementService'

/** 看板统计优先读本机缓存，避免登录后云端拉取阻塞或覆盖导致概览空白。 */
export class FamilyStatsService {
  static snapshot(): FamilyStatsSnapshot {
    const snap = new FamilyStatsSnapshot()
    const tasks = TaskLocalStore.tasks()
    snap.taskTotal = tasks.length
    snap.taskDone = TaskService.doneCount(tasks)
    snap.itemTotal = JujiaLocalStore.items().length
    snap.memoTotal = JujiaLocalStore.memos().length
    snap.checklistTotal = JujiaLocalStore.checklists().length
    snap.diaryTotal = JujiaLocalStore.diaries().length
    snap.maintenanceTotal = JujiaLocalStore.maintenanceJobs().length
    snap.memberTotal = MemberService.list().length
    snap.favoriteTotal = FavoriteService.countAll()
    snap.streakDays = CheckInService.streakDays()
    snap.weekDone = AchievementService.weekDoneCount()
    return snap
  }
}
