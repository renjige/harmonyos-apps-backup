import { SportDraft, SportFormResult, SportRecord } from '../models/SportModels'

export class SportRecordService {
  static emptyDraft(): SportDraft {
    const d = new SportDraft()
    d.recordDate = SportRecordService.todayKey()
    d.sportType = '跑步'
    d.feeling = '正常'
    d.weather = '室内'
    return d
  }

  static todayKey(): string {
    const now = new Date()
    const y = now.getFullYear()
    const m = String(now.getMonth() + 1).padStart(2, '0')
    const day = String(now.getDate()).padStart(2, '0')
    return `${y}-${m}-${day}`
  }

  static addDays(base: string, days: number): string {
    const parts = base.split('-')
    if (parts.length < 3) {
      return base
    }
    const d = new Date(parseInt(parts[0], 10), parseInt(parts[1], 10) - 1, parseInt(parts[2], 10))
    d.setDate(d.getDate() + days)
    const y = d.getFullYear()
    const m = String(d.getMonth() + 1).padStart(2, '0')
    const day = String(d.getDate()).padStart(2, '0')
    return `${y}-${m}-${day}`
  }

  static fromRecord(record: SportRecord): SportDraft {
    const d = SportRecordService.cloneDraft(SportRecordService.emptyDraft())
    d.sportType = record.sportType
    d.recordDate = record.recordDate
    d.durationMin = record.durationMin > 0 ? `${record.durationMin}` : ''
    d.distanceKm = record.distanceKm > 0 ? `${record.distanceKm}` : ''
    d.heartRate = record.heartRate > 0 ? `${record.heartRate}` : ''
    d.calories = record.calories > 0 ? `${record.calories}` : ''
    d.tags = record.tags
    d.note = record.note
    d.feeling = record.feeling.length > 0 ? record.feeling : '正常'
    d.weather = record.weather.length > 0 ? record.weather : '室内'
    d.takeaway = record.takeaway
    d.nextFocus = record.nextFocus
    return d
  }

  static cloneDraft(source: SportDraft): SportDraft {
    const d = new SportDraft()
    d.sportType = source.sportType
    d.recordDate = source.recordDate
    d.durationMin = source.durationMin
    d.distanceKm = source.distanceKm
    d.heartRate = source.heartRate
    d.calories = source.calories
    d.tags = source.tags
    d.note = source.note
    d.feeling = source.feeling
    d.weather = source.weather
    d.takeaway = source.takeaway
    d.nextFocus = source.nextFocus
    return d
  }

  static create(draft: SportDraft): SportFormResult {
    return SportRecordService.applyDraft('', draft)
  }

  static applyDraft(existingId: string, draft: SportDraft): SportFormResult {
    const res = new SportFormResult()
    const duration = parseFloat(draft.durationMin)
    if (isNaN(duration) || duration <= 0) {
      res.message = '请填写有效运动时长（分钟）'
      return res
    }
    if (draft.recordDate.length < 8) {
      res.message = '请选择运动日期'
      return res
    }
    const record = new SportRecord()
    record.id = existingId.length > 0 ? existingId : `sp_${Date.now()}`
    record.sportType = draft.sportType
    record.recordDate = draft.recordDate
    record.durationMin = Math.round(duration)
    const dist = parseFloat(draft.distanceKm)
    record.distanceKm = isNaN(dist) ? 0 : dist
    if (record.distanceKm > 0 && record.durationMin > 0) {
      record.paceMinPerKm = record.durationMin / record.distanceKm
    }
    const hr = parseInt(draft.heartRate, 10)
    record.heartRate = isNaN(hr) ? 0 : hr
    const cal = parseInt(draft.calories, 10)
    record.calories = isNaN(cal) ? 0 : cal
    record.tags = draft.tags.trim()
    record.note = draft.note.trim()
    record.feeling = draft.feeling
    record.weather = draft.weather
    record.takeaway = draft.takeaway.trim()
    record.nextFocus = draft.nextFocus.trim()
    record.createdAt = new Date().toISOString()
    res.ok = true
    res.record = record
    return res
  }

  static sportTypes(): string[] {
    return ['跑步', '骑行', '健身', '球类', '游泳', '其他']
  }

  static feelings(): string[] {
    return ['轻松', '正常', '吃力', '比赛日']
  }

  static weathers(): string[] {
    return ['晴', '阴', '雨', '室内']
  }

  static templates(): SportDraft[] {
    const list: SportDraft[] = []
    const a = SportRecordService.emptyDraft()
    a.sportType = '跑步'
    a.durationMin = '30'
    a.distanceKm = '5'
    a.tags = '#晨跑'
    a.takeaway = '配速稳住不冲刺'
    list.push(a)
    const b = SportRecordService.emptyDraft()
    b.sportType = '健身'
    b.durationMin = '45'
    b.weather = '室内'
    b.tags = '#力量'
    b.takeaway = '核心组完成即可'
    list.push(b)
    const c = SportRecordService.emptyDraft()
    c.sportType = '骑行'
    c.durationMin = '60'
    c.distanceKm = '20'
    c.tags = '#骑行'
    list.push(c)
    const d = SportRecordService.emptyDraft()
    d.sportType = '球类'
    d.durationMin = '90'
    d.tags = '#比赛日'
    d.feeling = '比赛日'
    list.push(d)
    return list
  }

  static templateLabel(d: SportDraft): string {
    if (d.distanceKm.length > 0) {
      return `${d.sportType} ${d.durationMin}分 ${d.distanceKm}km`
    }
    return `${d.sportType} ${d.durationMin}分钟`
  }

  /** 问卷「建议开练方式」→ 训练模板 */
  static templateForCategory(category: string): SportDraft {
    const list = SportRecordService.templates()
    if (category === '耐力模板') {
      return SportRecordService.cloneDraft(list[0])
    }
    if (category === '力量模板') {
      return SportRecordService.cloneDraft(list[1])
    }
    if (category === '专项模板') {
      return SportRecordService.cloneDraft(list[3])
    }
    return SportRecordService.cloneDraft(list[0])
  }
}
