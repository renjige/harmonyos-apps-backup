import {
  AppointmentFormDraft,
  AppointmentItem,
  FreeSlot,
  ImportPreview
} from '../models/AppointmentModels'
import { AppointmentLocalStore } from './AppointmentLocalStore'
import { ScheduleEngine } from './ScheduleEngine'

export class AppointmentTools {
  static missed(all: AppointmentItem[]): AppointmentItem[] {
    const today = AppointmentLocalStore.today()
    const out: AppointmentItem[] = []
    for (const row of all) {
      if (!row.isDone() && row.dueDate.length > 0 && row.dueDate < today) {
        out.push(row)
      }
    }
    return out
  }

  static tomorrow(all: AppointmentItem[]): AppointmentItem[] {
    const iso = ScheduleEngine.addDays(AppointmentLocalStore.today(), 1)
    const out: AppointmentItem[] = []
    for (const row of all) {
      if (!row.isDone() && row.dueDate === iso) {
        out.push(row)
      }
    }
    return out
  }

  static weekFreeSlots(all: AppointmentItem[], durationMin: number): FreeSlot[] {
    const today = AppointmentLocalStore.today()
    const out: FreeSlot[] = []
    const dur = durationMin > 0 ? durationMin : 60
    for (let d = 0; d < 7; d++) {
      const probe = new AppointmentItem()
      probe.id = `probe_${d}`
      probe.dueDate = ScheduleEngine.addDays(today, d)
      probe.dueTime = '09:00'
      probe.durationMin = dur
      const slots = ScheduleEngine.suggestFreeSlots(probe, all, 2)
      for (const slot of slots) {
        out.push(slot)
      }
      if (out.length >= 8) {
        break
      }
    }
    return out
  }

  static briefingText(todayItems: AppointmentItem[]): string {
    const iso = AppointmentLocalStore.today()
    let text = `【约定提醒 · 今日简报】${iso}\n`
    if (todayItems.length === 0) {
      return `${text}今天还没有待办约定。\n可用「找空档」安排一件重要的事。`
    }
    text = `${text}待办 ${todayItems.length} 件\n`
    for (const row of todayItems) {
      const leave = ScheduleEngine.leaveByLabel(row)
      const when = row.allDay ? '全天' : row.timeRangeLabel()
      text = `${text}- ${when} ${row.title}`
      if (row.contactName.length > 0) {
        text = `${text}（与 ${row.contactName}）`
      }
      if (leave.length > 0) {
        text = `${text} · ${leave}`
      }
      text = `${text}\n`
    }
    return text
  }

  static sampleImport(): string {
    return '明天 09:00 团队周会 @3楼会议室 与张经理\n明天 15:00 运动健身\n后天 10:30 客户拜访 @线上'
  }

  static parseImport(raw: string): ImportPreview[] {
    const out: ImportPreview[] = []
    const parts = raw.split('\n')
    for (const part of parts) {
      const line = part.trim()
      if (line.length === 0) {
        continue
      }
      const preview = AppointmentTools.parseLine(line)
      if (preview !== undefined) {
        out.push(preview)
      }
    }
    return out
  }

  private static parseLine(line: string): ImportPreview | undefined {
    const draft = new AppointmentFormDraft()
    draft.dueDate = AppointmentTools.parseDateToken(line)
    draft.dueTime = AppointmentTools.extractTime(line)
    draft.place = AppointmentTools.afterToken(line, '@')
    draft.contactName = AppointmentTools.afterToken(line, '与')
    let title = line
    title = AppointmentTools.stripToken(title, '今天')
    title = AppointmentTools.stripToken(title, '明天')
    title = AppointmentTools.stripToken(title, '后天')
    if (title.length >= 10 && title.slice(4, 5) === '-') {
      title = title.slice(10).trim()
    }
    title = AppointmentTools.stripTime(title, draft.dueTime)
    if (draft.place.length > 0) {
      title = AppointmentTools.stripToken(title, `@${draft.place}`)
    }
    if (draft.contactName.length > 0) {
      title = AppointmentTools.stripToken(title, `与${draft.contactName}`)
    }
    draft.title = title.trim()
    if (draft.title.length === 0) {
      return undefined
    }
    draft.scene = ScheduleEngine.classifyScene(draft.title, '')
    draft.prepLine = ScheduleEngine.defaultPrep(draft.scene)
    draft.durationMin = 60
    const row = new ImportPreview()
    row.title = draft.title
    row.whenLabel = `${draft.dueDate} ${draft.dueTime}`
    row.draft = draft
    return row
  }

  private static parseDateToken(line: string): string {
    const today = AppointmentLocalStore.today()
    if (line.indexOf('后天') >= 0) {
      return ScheduleEngine.addDays(today, 2)
    }
    if (line.indexOf('明天') >= 0) {
      return ScheduleEngine.addDays(today, 1)
    }
    if (line.length >= 10 && line.slice(4, 5) === '-' && line.slice(7, 8) === '-') {
      return line.slice(0, 10)
    }
    return today
  }

  private static extractTime(line: string): string {
    for (let i = 0; i + 5 <= line.length; i++) {
      const chunk = line.slice(i, i + 5)
      if (chunk.slice(2, 3) !== ':') {
        continue
      }
      const h = parseInt(chunk.slice(0, 2), 10)
      const m = parseInt(chunk.slice(3, 5), 10)
      if (!Number.isNaN(h) && h >= 0 && h < 24 && !Number.isNaN(m) && m >= 0 && m < 60) {
        return chunk
      }
    }
    return '09:00'
  }

  private static afterToken(line: string, token: string): string {
    const idx = line.indexOf(token)
    if (idx < 0) {
      return ''
    }
    let rest = line.slice(idx + token.length).trim()
    const space = rest.indexOf(' ')
    if (space >= 0) {
      rest = rest.slice(0, space)
    }
    return rest.trim()
  }

  private static stripToken(text: string, token: string): string {
    const idx = text.indexOf(token)
    if (idx < 0) {
      return text
    }
    return `${text.slice(0, idx)} ${text.slice(idx + token.length)}`.trim()
  }

  private static stripTime(text: string, time: string): string {
    const idx = text.indexOf(time)
    if (idx < 0) {
      return text
    }
    return `${text.slice(0, idx)} ${text.slice(idx + time.length)}`.trim()
  }
}
