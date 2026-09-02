import { StoryBeat } from '../models/TrainingModels'
import { TrainingStore } from './TrainingStore'
import { FunQuestStore } from './FunQuestStore'
import { PracticeHubStore } from './PracticeHubStore'

export class StoryService {
  static beats(): StoryBeat[] {
    const out: StoryBeat[] = []
    const list = TrainingStore.list()
    if (list.length > 0) {
      const first = list[list.length - 1]
      const b = new StoryBeat()
      b.title = '第一次记录训练'
      b.dateKey = first.recordDate
      b.detail = `${first.trainingType} · ${first.durationMin} 分钟`
      out.push(b)
    }
    if (list.length >= 10) {
      const b = new StoryBeat()
      b.title = '完成 10 次训练'
      b.dateKey = list[list.length - 10].recordDate
      b.detail = '节奏已经像在讲一个自己的运动故事'
      out.push(b)
    }
    if (list.length >= 30) {
      const b = new StoryBeat()
      b.title = '累计 30 次'
      b.dateKey = list[0].recordDate
      b.detail = '活力积分和徽章墙会一起亮起来'
      out.push(b)
    }
    for (const q of FunQuestStore.list()) {
      if (q.status === 'done') {
        const b = new StoryBeat()
        b.title = '完成首个挑战'
        b.dateKey = q.weekStart
        b.detail = q.title
        out.push(b)
        break
      }
    }
    for (const p of PracticeHubStore.listPlans()) {
      if (p.status === 'done') {
        const b = new StoryBeat()
        b.title = '完成一套计划'
        b.dateKey = p.createdAt.length >= 10 ? p.createdAt.substring(0, 10) : ''
        b.detail = p.title
        out.push(b)
        break
      }
    }
    return out
  }
}
