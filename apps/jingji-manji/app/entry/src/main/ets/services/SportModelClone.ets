import { PlanTask, SportChallenge, SportRecord, TrainingPlan } from '../models/SportModels'

/** 深拷贝业务模型，确保 @State / ForEach 在编辑后能即时刷新 */
export class SportModelClone {
  static record(src: SportRecord): SportRecord {
    const r = new SportRecord()
    r.id = src.id
    r.sportType = src.sportType
    r.recordDate = src.recordDate
    r.durationMin = src.durationMin
    r.distanceKm = src.distanceKm
    r.paceMinPerKm = src.paceMinPerKm
    r.heartRate = src.heartRate
    r.calories = src.calories
    r.tags = src.tags
    r.note = src.note
    r.feeling = src.feeling
    r.weather = src.weather
    r.takeaway = src.takeaway
    r.nextFocus = src.nextFocus
    r.createdAt = src.createdAt
    return r
  }

  static recordKey(r: SportRecord): string {
    return `${r.id}_${r.durationMin}_${r.distanceKm}_${r.takeaway}_${r.nextFocus}_${r.recordDate}_${r.feeling}_${r.weather}`
  }

  static challenge(src: SportChallenge): SportChallenge {
    const c = new SportChallenge()
    c.id = src.id
    c.title = src.title
    c.sportType = src.sportType
    c.targetSessions = src.targetSessions
    c.targetDistanceKm = src.targetDistanceKm
    c.startDate = src.startDate
    c.endDate = src.endDate
    c.note = src.note
    c.status = src.status
    c.createdAt = src.createdAt
    return c
  }

  static planTask(src: PlanTask): PlanTask {
    const t = new PlanTask()
    t.id = src.id
    t.sportType = src.sportType
    t.title = src.title
    t.targetCount = src.targetCount
    t.doneCount = src.doneCount
    t.status = src.status
    return t
  }

  static plan(src: TrainingPlan): TrainingPlan {
    const p = new TrainingPlan()
    p.id = src.id
    p.title = src.title
    p.weekStart = src.weekStart
    p.weekEnd = src.weekEnd
    p.status = src.status
    p.note = src.note
    p.createdAt = src.createdAt
    p.tasks = []
    for (const task of src.tasks) {
      p.tasks.push(SportModelClone.planTask(task))
    }
    return p
  }
}
