import { SceneTip } from '../models/JujiaModels'
import { TaskDates } from '../models/FamilyTaskModels'
import { ItemService } from './ItemService'
import { TaskService } from './TaskService'
import { MemberService } from './MemberService'
import { MemoService } from './MemoService'

export class SceneTipService {
  static async build(): Promise<SceneTip[]> {
    const tips: SceneTip[] = []
    const expiring = await ItemService.expiringSoon()
    if (expiring.length > 0) {
      const first = expiring[0]
      const t = new SceneTip()
      t.id = 'exp'
      t.title = '物品到期'
      t.body = `${first.name} ${first.expiryLabel()}，可点「试响」验证系统通知。`
      t.action = 'items'
      tips.push(t)
    }
    const today = await TaskService.today()
    const pending = TaskService.pendingCount(today)
    if (pending > 0) {
      const t = new SceneTip()
      t.id = 'plan'
      t.title = '今日计划'
      t.body = `还有 ${pending} 件未完成。打卡后本周盖章会自动点亮。`
      t.action = 'tasks'
      tips.push(t)
    }
    const day = new Date().getDay()
    if (day === 0 || day === 6) {
      const t = new SceneTip()
      t.id = 'weekend'
      t.title = '周末节奏'
      t.body = '周末适合换床单、清冰箱。可设每周重复计划，完成后自动生成下一周。'
      t.action = 'tasks'
      tips.push(t)
    }
    const monthDay = new Date().getDate()
    if (monthDay <= 3) {
      const t = new SceneTip()
      t.id = 'month'
      t.title = '月初盘点'
      t.body = '月初适合核对证件、保修与药品有效期，避免过期才发现。'
      t.action = 'items'
      tips.push(t)
    }
    if (MemberService.list().length === 0) {
      const t = new SceneTip()
      t.id = 'member'
      t.title = '家庭轮值'
      t.body = '添加家人后，倒垃圾/洗碗/浇花会按星期自动轮值，避免总是同一个人做。'
      t.action = 'members'
      tips.push(t)
    } else {
      const slots = MemberService.todaySlots()
      if (slots.length > 0) {
        const t = new SceneTip()
        t.id = 'duty'
        t.title = `${MemberService.weekdayLabel(MemberService.weekdayIndex())}轮值`
        t.body = `${slots[0].memberName} 负责${slots[0].chore}，可在「我的」调整家人。`
        t.action = 'members'
        tips.push(t)
      }
    }
    const memos = await MemoService.list()
    if (memos.length === 0) {
      const t = new SceneTip()
      t.id = 'memo'
      t.title = '共享备忘'
      t.body = '采购清单、出行计划可写成备忘并置顶，家人打开就能看到。'
      t.action = 'memos'
      tips.push(t)
    }
    const hour = new Date().getHours()
    if (hour >= 18 && pending > 0) {
      const t = new SceneTip()
      t.id = 'evening'
      t.title = '傍晚收尾'
      t.body = '晚上适合把未完成家务勾掉或改到明天，看板数字会立刻更新。'
      t.action = 'tasks'
      tips.push(t)
    }
    if (tips.length === 0) {
      const t = new SceneTip()
      t.id = 'ok'
      t.title = `${TaskDates.displayDate(TaskDates.today())}`
      t.body = '家里暂无到期物品，也没有未完成计划。可以登记一件保修，或写一条备忘。'
      t.action = 'items'
      tips.push(t)
    }
    const capped: SceneTip[] = []
    const limit = tips.length > 3 ? 3 : tips.length
    for (let i = 0; i < limit; i++) {
      capped.push(tips[i])
    }
    return capped
  }
}
