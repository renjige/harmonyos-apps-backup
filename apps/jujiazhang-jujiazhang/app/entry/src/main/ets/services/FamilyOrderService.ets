import { FamilyStatsService } from './FamilyStatsService'
import { CheckInService } from './CheckInService'

/** 家庭有序指数：综合计划/物品/备忘/清单/日记/家人等模块参与度。 */
export class FamilyOrderService {
  static score(): number {
    const snap = FamilyStatsService.snapshot()
    let s = 0
    if (snap.taskTotal > 0) {
      s += 12
    }
    if (snap.itemTotal > 0) {
      s += 18
    }
    if (snap.memoTotal > 0) {
      s += 14
    }
    if (snap.checklistTotal > 0) {
      s += 14
    }
    if (snap.diaryTotal > 0) {
      s += 10
    }
    if (snap.maintenanceTotal > 0) {
      s += 8
    }
    if (snap.memberTotal > 0) {
      s += 8
    }
    if (snap.favoriteTotal > 0) {
      s += 6
    }
    const streak = CheckInService.streakDays()
    if (streak >= 3) {
      s += 10
    } else if (streak > 0) {
      s += 5
    }
    return s > 100 ? 100 : s
  }

  static headline(score: number): string {
    if (score >= 80) {
      return '家庭运转井然有序'
    }
    if (score >= 50) {
      return '多模块协同中，继续加油'
    }
    if (score >= 20) {
      return '试试生活场景包，快速搭建家庭体系'
    }
    return '从场景包或物品登记开始'
  }

  static moduleHint(): string {
    return '指数由计划、物品、备忘、清单、日记与家人模块共同构成，非单一待办完成率。'
  }
}
