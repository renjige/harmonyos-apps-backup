import { MathLocalStore } from './MathLocalStore'

export class TodayStats {
  todayStars: number = 0
  totalStars: number = 0
  todayDone: number = 0
  todayAcc: number = 0
}

export class MathRefresh {
  static bump(): void {
    MathRefresh.publishStats()
    const n = (AppStorage.get<number>('mathHomeTick') ?? 0) + 1
    AppStorage.setOrCreate('mathHomeTick', n)
    const epoch = (AppStorage.get<number>('mathStatsEpoch') ?? 0) + 1
    AppStorage.setOrCreate('mathStatsEpoch', epoch)
  }

  static readTodayStats(): TodayStats {
    const bundle = MathLocalStore.snapshot()
    const today = MathLocalStore.today()
    const out = new TodayStats()
    out.totalStars = bundle.stars
    let correct = 0
    for (const s of bundle.sessions) {
      if (s.date === today) {
        out.todayStars += (s.stars > 0 ? s.stars : 0)
        out.todayDone += s.total
        correct += s.correct
      }
    }
    if (out.todayDone > 0) {
      out.todayAcc = Math.round((correct / out.todayDone) * 100)
    }
    return out
  }

  static publishStats(): void {
    const s = MathRefresh.readTodayStats()
    AppStorage.setOrCreate('mathTodayStars', s.todayStars)
    AppStorage.setOrCreate('mathTotalStars', s.totalStars)
    AppStorage.setOrCreate('mathTodayDone', s.todayDone)
    AppStorage.setOrCreate('mathTodayAcc', s.todayAcc)
  }
}
