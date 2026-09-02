import { GewuPathStatus, GewuPathStep } from '../models/FieldModels'
import { DateHelper } from './DateHelper'
import { FieldStore } from './FieldStore'
import { GewuStore } from './GewuStore'

export class GewuPathService {
  private static makeStep(key: string, label: string, shortLabel: string, done: boolean): GewuPathStep {
    const s = new GewuPathStep()
    s.key = key
    s.label = label
    s.shortLabel = shortLabel
    s.done = done
    return s
  }

  static async loadTodayPath(objectId: string): Promise<GewuPathStatus> {
    const readDone = await GewuStore.isReadToday()
    const inquiry = await GewuStore.loadInquiry(objectId)
    const inquiryDone = inquiry[0].trim().length > 0 ||
      inquiry[1].trim().length > 0 ||
      inquiry[2].trim().length > 0
    const quizDone = (await FieldStore.todayQuizScore()).length > 0
    const today = DateHelper.todayKey()
    const recs = await FieldStore.loadRecords()
    let observeDone = false
    for (const r of recs) {
      if (r.dateKey === today && r.subjectId === objectId) {
        observeDone = true
        break
      }
    }
    const checkinDone = (await FieldStore.todayCheckin()) !== undefined

    const steps: GewuPathStep[] = []
    steps.push(GewuPathService.makeStep('read', '读今日一物', '读', readDone))
    steps.push(GewuPathService.makeStep('inquiry', '格物三问', '问', inquiryDone))
    steps.push(GewuPathService.makeStep('quiz', '格物小测', '测', quizDone))
    steps.push(GewuPathService.makeStep('observe', '写观察札', '记', observeDone))
    steps.push(GewuPathService.makeStep('checkin', '物候打卡', '候', checkinDone))

    let doneCount = 0
    for (const s of steps) {
      if (s.done) {
        doneCount++
      }
    }

    const status = new GewuPathStatus()
    status.steps = steps
    status.doneCount = doneCount
    status.total = 5
    return status
  }
}
