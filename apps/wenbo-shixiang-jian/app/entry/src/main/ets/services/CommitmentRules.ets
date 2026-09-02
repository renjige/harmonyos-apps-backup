import { TaskItem } from '../models/TaskModels'

/** 今日承诺制 + 三时段工位规则（客户端展示 / 创建预判） */
export class CommitmentRules {
  static readonly MAX_COMMIT = 3

  static slotKeys(): string[] {
    return ['morning', 'afternoon', 'evening']
  }

  static slotTitle(slot: string): string {
    if (slot === 'afternoon') {
      return '午后工位'
    }
    if (slot === 'evening') {
      return '晚间工位'
    }
    return '上午工位'
  }

  static slotHint(slot: string): string {
    if (slot === 'afternoon') {
      return '13:00–18:00'
    }
    if (slot === 'evening') {
      return '18:00 以后'
    }
    return '12:00 前'
  }

  static defaultSlot(): string {
    const hour = new Date().getHours()
    if (hour < 12) {
      return 'morning'
    }
    if (hour < 18) {
      return 'afternoon'
    }
    return 'evening'
  }

  static isToday(item: TaskItem, today: string): boolean {
    return item.dueDate === today
  }

  static commitmentsOf(items: TaskItem[], today: string): TaskItem[] {
    const out: TaskItem[] = []
    for (const item of items) {
      if (item.dueDate === today && item.lane === 'commitment') {
        out.push(item)
      }
    }
    return out
  }

  static waitlistOf(items: TaskItem[], today: string): TaskItem[] {
    const out: TaskItem[] = []
    for (const item of items) {
      if (item.dueDate === today && item.lane !== 'commitment' && !item.isDone()) {
        out.push(item)
      }
    }
    return out
  }

  static inSlot(items: TaskItem[], today: string, slot: string): TaskItem | undefined {
    for (const item of items) {
      if (item.dueDate === today && item.lane === 'commitment' && item.timeSlot === slot) {
        return item
      }
    }
    return undefined
  }

  static openCommitCount(items: TaskItem[], today: string): number {
    let n = 0
    for (const item of CommitmentRules.commitmentsOf(items, today)) {
      if (!item.isDone() && item.closeReason.length === 0) {
        n += 1
      }
    }
    return n
  }

  static doneCommitCount(items: TaskItem[], today: string): number {
    let n = 0
    for (const item of CommitmentRules.commitmentsOf(items, today)) {
      if (item.isDone()) {
        n += 1
      }
    }
    return n
  }

  static focusMinutes(items: TaskItem[], today: string): number {
    let sec = 0
    for (const item of items) {
      if (item.dueDate === today) {
        sec += item.focusSeconds
      }
    }
    return Math.floor(sec / 60)
  }

  static slotTaken(items: TaskItem[], today: string, slot: string, excludeId: string = ''): boolean {
    const found = CommitmentRules.inSlot(items, today, slot)
    if (found === undefined) {
      return false
    }
    return found.id !== excludeId
  }

  static canPromote(items: TaskItem[], today: string, slot: string): boolean {
    if (CommitmentRules.commitmentsOf(items, today).length >= CommitmentRules.MAX_COMMIT) {
      return false
    }
    return !CommitmentRules.slotTaken(items, today, slot)
  }

  static formatRemain(seconds: number): string {
    const m = Math.floor(seconds / 60)
    const s = seconds % 60
    const ms = m < 10 ? `0${m}` : `${m}`
    const ss = s < 10 ? `0${s}` : `${s}`
    return `${ms}:${ss}`
  }

  static daysAgo(n: number): string {
    const d = new Date()
    d.setDate(d.getDate() - n)
    const y = d.getFullYear()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${y}-${ms}-${ds}`
  }

  static inLastDays(dateStr: string, days: number): boolean {
    if (dateStr.length < 10) {
      return false
    }
    const from = CommitmentRules.daysAgo(days)
    return dateStr >= from
  }
}
