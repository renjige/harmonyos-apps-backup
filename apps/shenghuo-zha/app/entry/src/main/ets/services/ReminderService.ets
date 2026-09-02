import { reminderAgentManager } from '@kit.BackgroundTasksKit'
import { notificationManager } from '@kit.NotificationKit'
import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit'
import { LifeTodoItem } from '../models/LifeModels'
import { LifeLocalStore } from './LifeLocalStore'

const TIMER_MAX_SEC = 7 * 24 * 3600
const BUNDLE_NAME = 'shz.llg.huawei'
const ENTRY_ABILITY = 'EntryAbility'

class ReminderWantAgent {
  pkgName: string = BUNDLE_NAME
  abilityName: string = ENTRY_ABILITY
}

class ReminderCalendarDateTime {
  year: number = 2026
  month: number = 1
  day: number = 1
  hour: number = 9
  minute: number = 0
  second: number = 0
}

class ReminderRequestTimerWrapper {
  reminderType: reminderAgentManager.ReminderType = reminderAgentManager.ReminderType.REMINDER_TYPE_TIMER
  triggerTimeInSeconds: number = 60
  title: string = ''
  content: string = ''
  expiredContent: string = ''
  snoozeContent: string = '稍后提醒'
  notificationId: number = 0
  ringDuration: number = 1
  slotType: notificationManager.SlotType = notificationManager.SlotType.CONTENT_INFORMATION
  wantAgent: ReminderWantAgent = new ReminderWantAgent()
}

class ReminderRequestOnceCalendar {
  reminderType: reminderAgentManager.ReminderType = reminderAgentManager.ReminderType.REMINDER_TYPE_CALENDAR
  dateTime: ReminderCalendarDateTime = new ReminderCalendarDateTime()
  title: string = ''
  content: string = ''
  expiredContent: string = ''
  snoozeContent: string = '稍后提醒'
  notificationId: number = 0
  ringDuration: number = 1
  slotType: notificationManager.SlotType = notificationManager.SlotType.CONTENT_INFORMATION
  wantAgent: ReminderWantAgent = new ReminderWantAgent()
}

class ReminderRequestWeeklyCalendar {
  reminderType: reminderAgentManager.ReminderType = reminderAgentManager.ReminderType.REMINDER_TYPE_CALENDAR
  dateTime: ReminderCalendarDateTime = new ReminderCalendarDateTime()
  title: string = ''
  content: string = ''
  expiredContent: string = ''
  snoozeContent: string = '稍后提醒'
  notificationId: number = 0
  ringDuration: number = 1
  slotType: notificationManager.SlotType = notificationManager.SlotType.CONTENT_INFORMATION
  wantAgent: ReminderWantAgent = new ReminderWantAgent()
  daysOfWeek: number[] = [1]
}

class ReminderRequestDailyCalendar {
  reminderType: reminderAgentManager.ReminderType = reminderAgentManager.ReminderType.REMINDER_TYPE_CALENDAR
  dateTime: ReminderCalendarDateTime = new ReminderCalendarDateTime()
  title: string = ''
  content: string = ''
  expiredContent: string = ''
  snoozeContent: string = '稍后提醒'
  notificationId: number = 0
  ringDuration: number = 1
  slotType: notificationManager.SlotType = notificationManager.SlotType.CONTENT_INFORMATION
  wantAgent: ReminderWantAgent = new ReminderWantAgent()
  daysOfWeek: number[] = [1, 2, 3, 4, 5, 6, 7]
}

class ReminderRequestMonthlyCalendar {
  reminderType: reminderAgentManager.ReminderType = reminderAgentManager.ReminderType.REMINDER_TYPE_CALENDAR
  dateTime: ReminderCalendarDateTime = new ReminderCalendarDateTime()
  title: string = ''
  content: string = ''
  expiredContent: string = ''
  snoozeContent: string = '稍后提醒'
  notificationId: number = 0
  ringDuration: number = 1
  slotType: notificationManager.SlotType = notificationManager.SlotType.CONTENT_INFORMATION
  wantAgent: ReminderWantAgent = new ReminderWantAgent()
  daysOfMonth: number[] = [1]
}

export class ReminderService {
  static lastError: string = ''

  static async ensurePermission(context: common.UIAbilityContext): Promise<boolean> {
    ReminderService.lastError = ''
    try {
      const enabled = await notificationManager.isNotificationEnabled()
      if (!enabled) {
        await notificationManager.requestEnableNotification(context)
        if (!(await notificationManager.isNotificationEnabled())) {
          ReminderService.lastError = '请在系统设置中开启通知'
          return false
        }
      }
    } catch {
      ReminderService.lastError = '请在系统设置中开启通知'
      return false
    }
    try {
      await notificationManager.addSlot(notificationManager.SlotType.CONTENT_INFORMATION)
    } catch {
    }
    try {
      const perm: Permissions = 'ohos.permission.PUBLISH_AGENT_REMINDER'
      const atManager = abilityAccessCtrl.createAtManager()
      const status = await atManager.checkAccessToken(context.applicationInfo.accessTokenId, perm)
      if (status !== abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        const req = await atManager.requestPermissionsFromUser(context, [perm])
        if (!(req.authResults.length > 0 &&
          req.authResults[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)) {
          ReminderService.lastError = '请允许「发布提醒」权限，否则无法在约定时间通知'
          return false
        }
      }
    } catch {
      ReminderService.lastError = '请允许「发布提醒」权限'
      return false
    }
    return true
  }

  static async cancelTodo(agentId: number): Promise<void> {
    if (agentId <= 0) {
      return
    }
    try {
      await reminderAgentManager.cancelReminder(agentId)
    } catch {
    }
  }

  static buildFireDate(dueDate: string, dueTime: string): Date {
    const now = new Date()
    const fire = new Date()
    if (dueDate.length >= 10) {
      const parts = dueDate.split('-')
      fire.setFullYear(parseInt(parts[0], 10))
      fire.setMonth(parseInt(parts[1], 10) - 1)
      fire.setDate(parseInt(parts[2], 10))
    }
    const tm = dueTime.length >= 4 ? dueTime : '09:00'
    const hp = tm.split(':')
    const hour = hp.length >= 2 ? parseInt(hp[0], 10) : 9
    const minute = hp.length >= 2 ? parseInt(hp[1], 10) : 0
    fire.setHours(hour, minute, 0, 0)
    if (fire.getTime() <= now.getTime() + 15000) {
      if (dueDate.length === 0) {
        fire.setDate(fire.getDate() + 1)
      }
    }
    return fire
  }

  static async scheduleTodo(todo: LifeTodoItem, context: common.UIAbilityContext): Promise<boolean> {
    ReminderService.lastError = ''
    if (todo.done) {
      await ReminderService.cancelTodo(todo.reminderAgentId)
      todo.reminderAgentId = 0
      await LifeLocalStore.saveTodo(todo)
      return true
    }
    if (todo.dueTime.length === 0 && todo.dueDate.length === 0) {
      return true
    }
    const okPerm = await ReminderService.ensurePermission(context)
    if (!okPerm) {
      return false
    }
    await ReminderService.cancelTodo(todo.reminderAgentId)
    const fire = ReminderService.buildFireDate(todo.dueDate, todo.dueTime)
    const delaySec = Math.floor((fire.getTime() - Date.now()) / 1000)
    if (delaySec < 10 && todo.repeatType === 'none') {
      ReminderService.lastError = '请选择至少 1 分钟后的提醒时间'
      return false
    }
    const title = '生活札 · 提醒'
    const content = todo.content.length > 0 ? todo.content : '你有一条生活待办'
    const notificationId = ReminderService.hashId(todo.id)
    let agentId = 0
    if (todo.repeatType === 'none' && delaySec <= TIMER_MAX_SEC && delaySec >= 10) {
      agentId = await ReminderService.publishTimer(title, content, notificationId, delaySec)
    }
    if (agentId <= 0) {
      agentId = await ReminderService.publishCalendar(title, content, notificationId, fire, todo.repeatType)
    }
    if (agentId <= 0) {
      ReminderService.lastError = '系统提醒设置失败，请允许通知、发布提醒与后台活动'
      return false
    }
    todo.reminderAgentId = agentId
    await LifeLocalStore.saveTodo(todo)
    return true
  }

  static async syncAllTodos(context: common.UIAbilityContext): Promise<void> {
    const todos = await LifeLocalStore.loadTodos()
    for (const t of todos) {
      if (!t.done && (t.dueDate.length > 0 || t.dueTime.length > 0)) {
        await ReminderService.scheduleTodo(t, context)
      } else if (t.done && t.reminderAgentId > 0) {
        await ReminderService.cancelTodo(t.reminderAgentId)
        t.reminderAgentId = 0
        await LifeLocalStore.saveTodo(t)
      }
    }
  }

  private static fillDate(target: ReminderCalendarDateTime, fire: Date): void {
    target.year = fire.getFullYear()
    target.month = fire.getMonth() + 1
    target.day = fire.getDate()
    target.hour = fire.getHours()
    target.minute = fire.getMinutes()
    target.second = 0
  }

  private static async publishTimer(title: string, content: string, notificationId: number,
    delaySec: number): Promise<number> {
    const req = new ReminderRequestTimerWrapper()
    req.triggerTimeInSeconds = Math.max(10, Math.min(delaySec, TIMER_MAX_SEC))
    req.title = title
    req.content = content
    req.expiredContent = '提醒已到期'
    req.notificationId = notificationId
    try {
      return await reminderAgentManager.publishReminder(req as reminderAgentManager.ReminderRequestTimer)
    } catch {
      return 0
    }
  }

  private static async publishCalendar(title: string, content: string, notificationId: number,
    fire: Date, repeatType: string): Promise<number> {
    try {
      if (repeatType === 'daily') {
        const req = new ReminderRequestDailyCalendar()
        ReminderService.fillDate(req.dateTime, fire)
        req.title = title
        req.content = content
        req.expiredContent = '提醒已到期'
        req.notificationId = notificationId
        return await reminderAgentManager.publishReminder(req as reminderAgentManager.ReminderRequestCalendar)
      }
      if (repeatType === 'weekly') {
        const req = new ReminderRequestWeeklyCalendar()
        ReminderService.fillDate(req.dateTime, fire)
        req.title = title
        req.content = content
        req.expiredContent = '提醒已到期'
        req.notificationId = notificationId
        const dow = fire.getDay()
        const days: number[] = []
        days.push(dow === 0 ? 7 : dow)
        req.daysOfWeek = days
        return await reminderAgentManager.publishReminder(req as reminderAgentManager.ReminderRequestCalendar)
      }
      if (repeatType === 'monthly') {
        const req = new ReminderRequestMonthlyCalendar()
        ReminderService.fillDate(req.dateTime, fire)
        req.title = title
        req.content = content
        req.expiredContent = '提醒已到期'
        req.notificationId = notificationId
        const days: number[] = []
        days.push(fire.getDate())
        req.daysOfMonth = days
        return await reminderAgentManager.publishReminder(req as reminderAgentManager.ReminderRequestCalendar)
      }
      const req = new ReminderRequestOnceCalendar()
      ReminderService.fillDate(req.dateTime, fire)
      req.title = title
      req.content = content
      req.expiredContent = '提醒已到期'
      req.notificationId = notificationId
      return await reminderAgentManager.publishReminder(req as reminderAgentManager.ReminderRequestCalendar)
    } catch {
      return 0
    }
  }

  private static hashId(id: string): number {
    let hash = 0
    for (let i = 0; i < id.length; i++) {
      hash = (hash * 31 + id.charCodeAt(i)) % 80000
    }
    return hash + 41000
  }
}
