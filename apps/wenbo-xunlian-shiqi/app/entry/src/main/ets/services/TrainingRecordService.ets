import { TrainingDraft, TrainingFormResult, TrainingRecord } from '../models/TrainingModels'
import { DateHelper } from './DateHelper'

export class TrainingRecordService {
  static readonly PRESET_TYPES: string[] = ['拉伸训练', '核心训练', '晨间活力', '跑步', '力量训练', '瑜伽', '有氧', '放松记录', '其他']
  static readonly FEELINGS: string[] = ['轻松', '刚好', '吃力']
  static readonly INTENSITIES: string[] = ['低', '中', '高']
  static readonly STATUSES: string[] = ['已完成', '部分完成', '未完成']

  static emptyDraft(): TrainingDraft {
    const d = new TrainingDraft()
    d.recordDate = DateHelper.todayKey()
    d.durationMin = '30'
    d.feeling = '刚好'
    d.intensity = '中'
    return d
  }

  static copy(src: TrainingDraft): TrainingDraft {
    const d = new TrainingDraft()
    d.trainingType = src.trainingType
    d.recordDate = src.recordDate
    d.durationMin = src.durationMin
    d.feeling = src.feeling
    d.intensity = src.intensity
    d.note = src.note
    d.harvest = src.harvest
    d.completeStatus = src.completeStatus
    return d
  }

  static create(draft: TrainingDraft): TrainingFormResult {
    const res = new TrainingFormResult()
    const mins = parseInt(draft.durationMin, 10)
    if (isNaN(mins) || mins <= 0) {
      res.message = '请输入有效的训练时长（分钟）'
      return res
    }
    if (mins > 600) {
      res.message = '单次时长请不超过 600 分钟'
      return res
    }
    if (draft.trainingType.trim().length === 0) {
      res.message = '请选择训练类型'
      return res
    }
    if (draft.recordDate.trim().length === 0) {
      res.message = '请选择训练日期'
      return res
    }
    const r = new TrainingRecord()
    r.id = `tr_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    r.trainingType = draft.trainingType.trim()
    r.recordDate = draft.recordDate.trim()
    r.durationMin = mins
    r.feeling = draft.feeling
    r.intensity = draft.intensity
    r.note = draft.note.trim()
    r.harvest = draft.harvest.trim()
    r.completeStatus = draft.completeStatus.trim().length > 0 ? draft.completeStatus.trim() : '已完成'
    r.createdAt = new Date().toISOString()
    res.ok = true
    res.record = r
    return res
  }

  static toDraft(record: TrainingRecord): TrainingDraft {
    const d = new TrainingDraft()
    d.trainingType = record.trainingType
    d.recordDate = record.recordDate
    d.durationMin = `${record.durationMin}`
    d.feeling = record.feeling.length > 0 ? record.feeling : '刚好'
    d.intensity = record.intensity.length > 0 ? record.intensity : '中'
    d.note = record.note
    d.harvest = record.harvest
    d.completeStatus = record.completeStatus.length > 0 ? record.completeStatus : '已完成'
    return d
  }

  static update(id: string, draft: TrainingDraft, createdAt: string): TrainingFormResult {
    const res = TrainingRecordService.create(draft)
    if (!res.ok) {
      return res
    }
    res.record.id = id
    res.record.createdAt = createdAt
    return res
  }
}
