import { GrowthStat } from '../models/ThinkModels'

/** 思考工坊统计写入 AppStorage，供 ThinkPage @StorageLink 实时刷新 */
export class GrowthStatHub {
  static initDefaults(): void {
    AppStorage.setOrCreate('tbSparkCount', 0)
    AppStorage.setOrCreate('tbNoteCount', 0)
    AppStorage.setOrCreate('tbBreakCount', 0)
    AppStorage.setOrCreate('tbStreakDays', 0)
    AppStorage.setOrCreate('tbGoalCount', 0)
    AppStorage.setOrCreate('tbReviewCount', 0)
    AppStorage.setOrCreate('tbOpinionCount', 0)
  }

  static apply(g: GrowthStat): void {
    AppStorage.setOrCreate('tbSparkCount', g.sparks)
    AppStorage.setOrCreate('tbNoteCount', g.notes)
    AppStorage.setOrCreate('tbBreakCount', g.breakdowns)
    AppStorage.setOrCreate('tbStreakDays', g.streak)
    AppStorage.setOrCreate('tbGoalCount', g.goals)
    AppStorage.setOrCreate('tbReviewCount', g.reviews)
    AppStorage.setOrCreate('tbOpinionCount', g.opinions)
  }
}
