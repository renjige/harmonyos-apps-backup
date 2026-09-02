import { AchievementDef, AchievementState } from '../models/JujiaModels'
import { JujiaLocalStore } from './JujiaLocalStore'
import { TaskLocalStore } from './TaskLocalStore'
import { ItemService } from './ItemService'
import { MemoService } from './MemoService'
import { FavoriteService } from './FavoriteService'
import { CheckInService } from './CheckInService'
import { TaskDates } from '../models/FamilyTaskModels'
import { TaskService } from './TaskService'

export class AchievementService {
  static defs(): AchievementDef[] {
    const out: AchievementDef[] = []
    const codes = ['first_task', 'first_item', 'first_memo', 'streak_7', 'tasks_50', 'fav_5']
    const titles = ['首次计划', '首次登记物品', '首次备忘', '连续 7 天', '完成 50 项', '收藏达人']
    const descs = [
      '创建第一条家庭计划',
      '登记第一件家庭物品',
      '写下第一条家庭备忘',
      '连续 7 天完成至少 1 项计划',
      '累计完成 50 项家庭计划',
      '收藏 5 条常用内容'
    ]
    const icons = ['check', 'biz', 'message', 'calendar', 'chart', 'star']
    for (let i = 0; i < codes.length; i++) {
      const d = new AchievementDef()
      d.code = codes[i]
      d.title = titles[i]
      d.description = descs[i]
      d.iconName = icons[i]
      out.push(d)
    }
    return out
  }

  static isUnlocked(code: string): boolean {
    for (const row of JujiaLocalStore.achievements()) {
      if (row.code === code && row.unlockedAt.length > 0) {
        return true
      }
    }
    return false
  }

  static async evaluate(): Promise<string[]> {
    const unlocked: string[] = []
    const tasks = TaskLocalStore.tasks()
    let doneTotal = 0
    for (const t of tasks) {
      if (t.completed) {
        doneTotal += 1
      }
    }
    if (tasks.length >= 1) {
      unlocked.push(...(await AchievementService.unlockIf('first_task')))
    }
    if ((await ItemService.countAll()) >= 1) {
      unlocked.push(...(await AchievementService.unlockIf('first_item')))
    }
    if ((await MemoService.countAll()) >= 1) {
      unlocked.push(...(await AchievementService.unlockIf('first_memo')))
    }
    if (CheckInService.streakDays() >= 7) {
      unlocked.push(...(await AchievementService.unlockIf('streak_7')))
    }
    if (doneTotal >= 50) {
      unlocked.push(...(await AchievementService.unlockIf('tasks_50')))
    }
    if (FavoriteService.countAll() >= 5) {
      unlocked.push(...(await AchievementService.unlockIf('fav_5')))
    }
    return unlocked
  }

  private static async unlockIf(code: string): Promise<string[]> {
    if (AchievementService.isUnlocked(code)) {
      return []
    }
    const rows = JujiaLocalStore.achievements().slice()
    const st = new AchievementState()
    st.code = code
    st.unlockedAt = JujiaLocalStore.nowIso()
    rows.push(st)
    await JujiaLocalStore.saveAchievements(rows)
    const out: string[] = []
    out.push(code)
    return out
  }

  static unlockedCount(): number {
    let n = 0
    for (const d of AchievementService.defs()) {
      if (AchievementService.isUnlocked(d.code)) {
        n += 1
      }
    }
    return n
  }

  static weekDoneCount(): number {
    const all = TaskLocalStore.tasks()
    const week = TaskService.weekRows(all, TaskDates.today())
    return TaskService.doneCount(week)
  }
}
