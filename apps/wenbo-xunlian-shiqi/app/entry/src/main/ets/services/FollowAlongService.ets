import { TrainingDraft } from '../models/TrainingModels'
import { MoveItem } from '../models/TrainingModels'
import { PracticeHubStore } from './PracticeHubStore'
import { DateHelper } from './DateHelper'

const QUEUE_KEY = 'followAlongQueue'

/** 跟练清单与完成后预填训练日志 */
export class FollowAlongService {
  static listQueueIds(): string[] {
    const raw = AppStorage.get<string>(QUEUE_KEY) ?? ''
    if (raw.length === 0) {
      return []
    }
    const parts = raw.split(',')
    const out: string[] = []
    for (const p of parts) {
      if (p.length > 0) {
        out.push(p)
      }
    }
    return out
  }

  static resolveQueue(): MoveItem[] {
    const ids = FollowAlongService.listQueueIds()
    const out: MoveItem[] = []
    for (const id of ids) {
      const m = PracticeHubStore.findMove(id)
      if (m !== null) {
        out.push(m)
      }
    }
    return out
  }

  static async addToQueue(moveId: string): Promise<boolean> {
    const ids = FollowAlongService.listQueueIds()
    for (const id of ids) {
      if (id === moveId) {
        return false
      }
    }
    if (ids.length >= 5) {
      return false
    }
    ids.push(moveId)
    FollowAlongService.persistQueue(ids)
    return true
  }

  static async removeFromQueue(moveId: string): Promise<void> {
    const next: string[] = []
    for (const id of FollowAlongService.listQueueIds()) {
      if (id !== moveId) {
        next.push(id)
      }
    }
    FollowAlongService.persistQueue(next)
  }

  static clearQueue(): void {
    AppStorage.setOrCreate(QUEUE_KEY, '')
  }

  static persistQueue(ids: string[]): void {
    AppStorage.setOrCreate(QUEUE_KEY, ids.join(','))
  }

  static draftAfterSession(moves: MoveItem[], totalMinutes: number): TrainingDraft {
    const d = new TrainingDraft()
    d.recordDate = DateHelper.todayKey()
    d.trainingType = '跟练组合'
    d.durationMin = `${totalMinutes > 0 ? totalMinutes : 1}`
    d.feeling = '刚好'
    d.intensity = '中'
    d.completeStatus = '已完成'
    const titles: string[] = []
    for (const m of moves) {
      titles.push(m.title)
    }
    d.note = `跟练完成：${titles.join(' → ')}`
    d.harvest = '通过跟练模式完成一组动作，可在动作图鉴继续收藏或调整组合。'
    return d
  }
}
