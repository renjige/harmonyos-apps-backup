import { StatsService } from './StatsService'
import { TrainingStore } from './TrainingStore'
import { WorkoutStore } from './WorkoutStore'

export class FitDataNotify {
  static async syncStats(): Promise<void> {
    await WorkoutStore.ensurePref()
    const totals = await StatsService.totals()
    const unlocked = await WorkoutStore.loadUnlockedAchievements()
    let chDone = 0
    const ch = await TrainingStore.loadChallenges()
    for (const c of ch) {
      if (c.done) {
        chDone++
      }
    }
    const goalsDone = unlocked.length + chDone
    AppStorage.setOrCreate('fitTotalWorkouts', totals.totalWorkouts)
    AppStorage.setOrCreate('fitStreakDays', totals.streakDays)
    AppStorage.setOrCreate('fitTotalMinutes', totals.totalMinutes)
    AppStorage.setOrCreate('fitTodayMinutes', totals.todayMinutes)
    AppStorage.setOrCreate('fitChallengeDone', goalsDone)
    const cur = AppStorage.get<number>('fitDataEpoch')
    const n = cur !== undefined ? cur : 0
    AppStorage.setOrCreate('fitDataEpoch', n + 1)
  }

  static bump(): void {
    void FitDataNotify.syncStats()
  }
}
