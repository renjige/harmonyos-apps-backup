import { AchievementDef } from '../models/LifeModels'
import { ArchiveStore } from './ArchiveStore'
import { LifeStore } from './LifeStore'
import { LifeStorePhase3 } from './LifeStorePhase3'

export class AchievementService {
  static async checkAndUnlock(): Promise<string[]> {
    const unlocked = await LifeStore.loadUnlockedAchievements()
    const newly: string[] = []

    const archives = await ArchiveStore.loadArchives()
    const nodes = await ArchiveStore.loadNodes()
    const favCount = await ArchiveStore.countFavorites()
    const streak = await ArchiveStore.computeStreakDays()
    const doneTasks = await LifeStore.countDonePlanTasks()
    const habits = await LifeStore.loadHabits()
    const albums = await LifeStorePhase3.loadThemeAlbums()
    const chkDone = await LifeStorePhase3.countChecklistDone()
    const experiences = await LifeStorePhase3.loadExperiences()

    let maxHabitStreak = 0
    for (const h of habits) {
      const hs = await LifeStore.getHabitStreak(h.id)
      if (hs > maxHabitStreak) {
        maxHabitStreak = hs
      }
    }

    const checks: string[] = []
    if (archives.length >= 1) {
      checks.push('first_archive')
    }
    if (nodes.length >= 1) {
      checks.push('first_node')
    }
    if (streak >= 7) {
      checks.push('streak_7')
    }
    if (streak >= 30) {
      checks.push('streak_30')
    }
    if (doneTasks >= 5) {
      checks.push('plans_5')
    }
    if (maxHabitStreak >= 7) {
      checks.push('habit_7')
    }
    if (favCount >= 10) {
      checks.push('fav_10')
    }
    if (archives.length >= 10) {
      checks.push('archive_10')
    }
    if (albums.length >= 1) {
      checks.push('theme_album_1')
    }
    if (chkDone >= 5) {
      checks.push('checklist_5')
    }
    if (experiences.length >= 3) {
      checks.push('experience_3')
    }

    for (const id of checks) {
      if (!unlocked.includes(id)) {
        await LifeStore.unlockAchievement(id)
        newly.push(id)
      }
    }
    return newly
  }

  static async isUnlocked(id: string): Promise<boolean> {
    const list = await LifeStore.loadUnlockedAchievements()
    return list.includes(id)
  }

  static async listAll(): Promise<AchievementDef[]> {
    const catalog = AchievementDef.catalog()
    const unlocked = await LifeStore.loadUnlockedAchievements()
    const out: AchievementDef[] = []
    for (const def of catalog) {
      const copy = AchievementDef.make(def.id, def.title, def.description, def.emoji)
      if (unlocked.includes(def.id)) {
        out.push(copy)
      } else {
        out.push(copy)
      }
    }
    return out
  }

  static async unlockedCount(): Promise<number> {
    const list = await LifeStore.loadUnlockedAchievements()
    return list.length
  }
}
