import { XuAgendaItem, XuDateHelper, XuHabitItem, XuWisdomItem } from '../models/XuModels'

export class XuWisdom {
  static build(agenda: XuAgendaItem[], habits: XuHabitItem[], remindOn: boolean): XuWisdomItem[] {
    const out: XuWisdomItem[] = []
    if (!remindOn) {
      const off = new XuWisdomItem()
      off.title = '智慧提醒已关闭'
      off.body = '可在「我的 → 设置与隐私」重新打开首页提醒。'
      off.action = 'settings'
      out.push(off)
      return out
    }
    const today = XuDateHelper.todayKey()
    let openCount = 0
    let doneCount = 0
    for (const a of agenda) {
      if (a.dateKey === today) {
        if (a.done) {
          doneCount++
        } else {
          openCount++
        }
      }
    }
    let unchecked = 0
    for (const h of habits) {
      if (!h.checkedToday(today)) {
        unchecked++
      }
    }
    if (openCount > 0) {
      const it = new XuWisdomItem()
      it.title = `今日还有 ${openCount} 件待办`
      it.body = '点开日程，按优先级逐项完成，完成即勾选。'
      it.action = 'schedule'
      out.push(it)
    }
    if (unchecked > 0) {
      const it = new XuWisdomItem()
      it.title = `${unchecked} 个习惯尚未打卡`
      it.body = '连续记录比一次做完更重要。去习惯页点一下即可。'
      it.action = 'habit'
      out.push(it)
    }
    if (openCount === 0 && unchecked === 0 && (agenda.length > 0 || habits.length > 0)) {
      const it = new XuWisdomItem()
      it.title = '今日秩序已立'
      it.body = doneCount > 0 ? `已完成 ${doneCount} 项。可写一条知识碎片，把洞察留下来。` : '日程与习惯都空着。添加一件小事，让今天有锚点。'
      it.action = 'note'
      out.push(it)
    }
    if (out.length === 0) {
      const it = new XuWisdomItem()
      it.title = '明以洞察，序以行远'
      it.body = '先记一件待办，或开始一个习惯。阁中自有章法。'
      it.action = 'schedule'
      out.push(it)
    }
    return out
  }
}
