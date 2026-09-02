import { FunQuest, FunQuestDraft, FunQuestFormResult, FunQuestProgress } from '../models/TrainingModels'
import { DateHelper } from './DateHelper'
import { TrainingStore } from './TrainingStore'

export class FunQuestService {
  static readonly THEMES: string[] = ['晨光跑', '雨后骑', '力量日', '拉伸夜', '随心练']
  static readonly KINDS: string[] = ['sessions', 'minutes', 'types', 'days']

  static emptyDraft(): FunQuestDraft {
    const d = new FunQuestDraft()
    d.title = '本周三次随心练'
    d.theme = '随心练'
    d.sportType = '全部'
    d.targetKind = 'sessions'
    d.targetValue = '3'
    return d
  }

  static copy(src: FunQuestDraft): FunQuestDraft {
    const d = new FunQuestDraft()
    d.title = src.title
    d.theme = src.theme
    d.sportType = src.sportType
    d.targetKind = src.targetKind
    d.targetValue = src.targetValue
    d.note = src.note
    return d
  }

  static toDraft(q: FunQuest): FunQuestDraft {
    const d = new FunQuestDraft()
    d.title = q.title
    d.theme = q.theme
    d.sportType = q.sportType
    d.targetKind = q.targetKind
    d.targetValue = `${q.targetValue}`
    d.note = q.note
    return d
  }

  static create(draft: FunQuestDraft): FunQuestFormResult {
    const res = new FunQuestFormResult()
    const title = draft.title.trim()
    if (title.length < 2) {
      res.message = '请填写至少 2 字的挑战标题'
      return res
    }
    const n = parseInt(draft.targetValue, 10)
    if (isNaN(n) || n <= 0 || n > 366) {
      res.message = '目标数值请填 1～366'
      return res
    }
    const q = new FunQuest()
    q.id = `fq_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    q.title = title
    q.theme = draft.theme
    q.sportType = draft.sportType.trim().length > 0 ? draft.sportType.trim() : '全部'
    q.targetKind = draft.targetKind
    q.targetValue = n
    q.weekStart = DateHelper.mondayKey()
    q.note = draft.note.trim()
    q.status = 'active'
    q.createdAt = new Date().toISOString()
    res.ok = true
    res.quest = q
    return res
  }

  static update(id: string, draft: FunQuestDraft, createdAt: string, weekStart: string, status: string): FunQuestFormResult {
    const res = FunQuestService.create(draft)
    if (!res.ok) {
      return res
    }
    res.quest.id = id
    res.quest.createdAt = createdAt
    res.quest.weekStart = weekStart
    res.quest.status = status
    return res
  }

  static kindLabel(kind: string): string {
    if (kind === 'minutes') {
      return '累计分钟'
    }
    if (kind === 'types') {
      return '尝试类型数'
    }
    if (kind === 'days') {
      return '有记录的天数'
    }
    return '完成次数'
  }

  static fromHall(key: string): FunQuest {
    const q = new FunQuest()
    q.id = `fq_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    q.theme = '随心练'
    q.sportType = '全部'
    q.targetKind = 'days'
    q.weekStart = DateHelper.todayKey()
    q.status = 'active'
    q.createdAt = new Date().toISOString()
    if (key === 'd21') {
      q.title = '21天习惯挑战'
      q.targetValue = 21
      q.note = '从今天起，按「有训练记录的自然日」累计到 21 天。'
    } else if (key === 'd30') {
      q.title = '月度坚持挑战'
      q.targetValue = 30
      q.note = '一个月里尽量让更多日期亮起来，休息日也可以写放松记录。'
    } else {
      q.title = '7天训练挑战'
      q.targetValue = 7
      q.note = '任意训练类型都计入。完成可点亮「活力新人」相关成长节点。'
    }
    return q
  }

  static progress(quest: FunQuest): FunQuestProgress {
    const p = new FunQuestProgress()
    p.target = quest.targetValue
    const records = TrainingStore.list()
    let sessions = 0
    let minutes = 0
    const types: string[] = []
    for (const r of records) {
      if (r.recordDate < quest.weekStart) {
        continue
      }
      if (quest.sportType !== '全部' && r.trainingType !== quest.sportType) {
        continue
      }
      sessions += 1
      minutes += r.durationMin
      let hit = false
      for (const t of types) {
        if (t === r.trainingType) {
          hit = true
          break
        }
      }
      if (!hit) {
        types.push(r.trainingType)
      }
    }
    if (quest.targetKind === 'minutes') {
      p.current = minutes
      p.unit = '分钟'
    } else if (quest.targetKind === 'types') {
      p.current = types.length
      p.unit = '种'
    } else if (quest.targetKind === 'days') {
      p.current = FunQuestService.distinctDays(quest)
      p.unit = '天'
    } else {
      p.current = sessions
      p.unit = '次'
    }
    p.percent = p.target <= 0 ? 0 : Math.min(100, Math.floor(p.current * 100 / p.target))
    p.done = quest.status === 'done' || p.current >= p.target
    return p
  }

  private static distinctDays(quest: FunQuest): number {
    const dates: string[] = []
    for (const r of TrainingStore.list()) {
      if (r.recordDate < quest.weekStart) {
        continue
      }
      if (quest.sportType !== '全部' && r.trainingType !== quest.sportType) {
        continue
      }
      let hit = false
      for (const d of dates) {
        if (d === r.recordDate) {
          hit = true
          break
        }
      }
      if (!hit && r.recordDate.length > 0) {
        dates.push(r.recordDate)
      }
    }
    return dates.length
  }
}
