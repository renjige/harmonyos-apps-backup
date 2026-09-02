import { HttpClient } from './HttpClient'
import { StepWire, TplItem, TplListPayload, TplStep, TplWire, TripDateHelp } from '../models/TripModels'

export class TripBizService {
  static async loadTemplates(): Promise<TplItem[]> {
    const res = await HttpClient.get<TplListPayload>('/biz/trip-memo/templates')
    const out: TplItem[] = []
    if (res.code === 0 && res.data !== undefined) {
      for (const w of res.data.list) {
        out.push(TripBizService.mapTpl(w))
      }
    }
    if (out.length === 0) {
      return TripBizService.localTemplates()
    }
    return out
  }

  static mapTpl(w: TplWire): TplItem {
    const item = new TplItem()
    item.id = w.id
    item.title = w.title
    item.subtitle = w.subtitle
    item.summary = w.summary
    item.description = w.description.length > 0 ? w.description : w.summary
    item.coverKey = w.coverKey.length > 0 ? w.coverKey : w.coverMedia
    item.durationDays = w.durationDays > 0 ? w.durationDays : 1
    item.steps = TripBizService.parseSteps(w.body)
    return item
  }

  static parseSteps(body: string): TplStep[] {
    const out: TplStep[] = []
    if (body.length < 2) {
      return out
    }
    try {
      const parsed = JSON.parse(body) as StepWire[]
      for (const w of parsed) {
        const s = new TplStep()
        s.title = w.title
        s.offsetDays = w.offsetDays
        s.time = w.time
        s.location = w.location
        s.remark = w.remark
        out.push(s)
      }
    } catch {
      return out
    }
    return out
  }

  static localTemplates(): TplItem[] {
    const a = new TplItem()
    a.id = 'tpl_business'
    a.title = '商务出行'
    a.subtitle = '出发 · 会议 · 返程'
    a.summary = '适合客户拜访与短期差旅'
    a.description = '生成三天基础结构：出发、客户会议、返程。'
    a.coverKey = 'tpl_business'
    a.durationDays = 3
    a.steps = TripBizService.stepsBusiness()
    const b = new TplItem()
    b.id = 'tpl_weekend'
    b.title = '周末短途'
    b.subtitle = '出发 · 抵达 · 返程'
    b.summary = '适合两日短途安排'
    b.description = '生成两天基础结构：出发、抵达、返程。'
    b.coverKey = 'tpl_weekend'
    b.durationDays = 2
    b.steps = TripBizService.stepsWeekend()
    const c = new TplItem()
    c.id = 'tpl_appointment'
    c.title = '重要约定'
    c.subtitle = '准备 · 赴约 · 结束'
    c.summary = '适合会议、约会、考试或预约'
    c.description = '生成当天基础结构：准备、赴约、结束整理。'
    c.coverKey = 'tpl_appointment'
    c.durationDays = 1
    c.steps = TripBizService.stepsAppoint()
    return [a, b, c]
  }

  private static stepsBusiness(): TplStep[] {
    return [
      TripBizService.step('出发', 0, '08:30', '核对行程与资料'),
      TripBizService.step('客户会议', 0, '14:00', '准备产品资料'),
      TripBizService.step('返程', 2, '16:00', '')
    ]
  }

  private static stepsWeekend(): TplStep[] {
    return [
      TripBizService.step('出发', 0, '09:00', ''),
      TripBizService.step('抵达', 0, '12:00', ''),
      TripBizService.step('返程', 1, '16:00', '')
    ]
  }

  private static stepsAppoint(): TplStep[] {
    return [
      TripBizService.step('出发准备', 0, '09:00', ''),
      TripBizService.step('赴约', 0, '14:00', ''),
      TripBizService.step('结束整理', 0, '16:30', '')
    ]
  }

  private static step(title: string, offset: number, time: string, remark: string): TplStep {
    const s = new TplStep()
    s.title = title
    s.offsetDays = offset
    s.time = time
    s.remark = remark
    return s
  }

  static todayPlus(days: number): string {
    return TripDateHelp.addDaysIso(TripDateHelp.todayIso(), days)
  }
}
