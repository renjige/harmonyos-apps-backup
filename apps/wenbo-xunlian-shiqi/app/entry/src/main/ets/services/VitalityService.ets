import { VitalityState } from '../models/TrainingModels'
import { VitalityStore } from './VitalityStore'
import { Theme } from '../components/design-system/Theme'
import { PracticeHubStore } from './PracticeHubStore'
import { FunQuestStore } from './FunQuestStore'
import { TrainingAnalytics } from './TrainingAnalytics'

export class VitalityService {
  static index(): number {
    const s = VitalityStore.get()
    let n = 0
    if (s.warmDone) {
      n += 28
    }
    if (s.trainDone) {
      n += 44
    }
    if (s.noteDone) {
      n += 28
    }
    return n
  }

  static taskRate(): number {
    const s = VitalityStore.get()
    let n = 0
    if (s.warmDone) {
      n += 1
    }
    if (s.trainDone) {
      n += 1
    }
    if (s.noteDone) {
      n += 1
    }
    return Math.floor(n * 100 / 3)
  }

  static async award(points: number): Promise<void> {
    const s = VitalityStore.get()
    s.points = s.points + points
    if (s.points > 99999) {
      s.points = 99999
    }
    await VitalityStore.save(s)
  }

  static async toggleWarm(): Promise<boolean> {
    const s = VitalityStore.get()
    if (s.warmDone) {
      return false
    }
    s.warmDone = true
    s.points += 5
    await VitalityStore.save(s)
    return true
  }

  static async toggleNote(): Promise<boolean> {
    const s = VitalityStore.get()
    if (s.noteDone) {
      return false
    }
    s.noteDone = true
    s.points += 5
    await VitalityStore.save(s)
    return true
  }

  static async markTrainDone(): Promise<void> {
    const s = VitalityStore.get()
    if (!s.trainDone) {
      s.trainDone = true
      s.points += 10
    } else {
      s.points += 10
    }
    await VitalityStore.save(s)
  }

  static async setSkin(id: string): Promise<boolean> {
    const s = VitalityStore.get()
    if (!VitalityService.skinUnlocked(id, s.points)) {
      return false
    }
    s.skinId = id
    await VitalityStore.save(s)
    Theme.applyBrandPrimary(VitalityService.skinHex(id))
    return true
  }

  static applyStoredSkin(): void {
    Theme.applyBrandPrimary(VitalityService.skinHex(VitalityStore.get().skinId))
  }

  static skinHex(id: string): string {
    if (id === 'grove') {
      return '#0F766E'
    }
    if (id === 'dusk') {
      return '#6D28D9'
    }
    return '#007AFF'
  }

  static skinUnlocked(id: string, points: number): boolean {
    if (id === 'dawn') {
      return true
    }
    if (id === 'grove') {
      return points >= 40
    }
    if (id === 'dusk') {
      return points >= 100
    }
    return false
  }

  static smartTip(): string {
    const summary = TrainingAnalytics.summarize()
    if (summary.todayCount === 0 && summary.streakDays === 0 && summary.totalCount === 0) {
      return '智慧建议：先到「玩法」Tab 试试「今天玩什么」或「呼吸放松」，不必从写计划开始。'
    }
    if (summary.todayCount === 0) {
      return '智慧建议：试试「动作跟练」或「周运动剧本」，用计时玩法开始今天的第一动。'
    }
    const quests = FunQuestStore.active()
    if (quests.length > 0) {
      return '智慧建议：挑战馆里还有进行中的挑战，完成一次跟练或记录会自动计入天数。'
    }
    if (summary.streakDays >= 3) {
      return '智慧建议：连续节奏很好。去「呼吸放松」做一组 4-7-8 收尾。'
    }
    const moves = PracticeHubStore.listMoves().length
    if (moves < 4) {
      return '智慧建议：去发现页复制热身/拉伸动作到图鉴，跟练模式会更好玩。'
    }
    return '智慧建议：写一条运动笔记，或查看成长页的热力日历与徽章。'
  }

  static copyState(): VitalityState {
    const s = VitalityStore.get()
    const n = new VitalityState()
    n.points = s.points
    n.skinId = s.skinId
    n.taskDate = s.taskDate
    n.warmDone = s.warmDone
    n.trainDone = s.trainDone
    n.noteDone = s.noteDone
    return n
  }
}
