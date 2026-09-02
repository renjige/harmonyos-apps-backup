import { reminderAgentManager } from '@kit.BackgroundTasksKit'
import { notificationManager } from '@kit.NotificationKit'
import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit'
import { FamilyReminder, LocalBundle } from '../models/FamilyModels'
import { FamilyLocalStore } from './FamilyLocalStore'

const TIMER_MAX_SEC = 7 * 24 * 3600
const BUNDLE_NAME = 'jtbw.wxy.huawei'
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
  daysOfMonth: number[] = [1]
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

class NotificationRequestWrapper {
  id: number = 0
  content: notificationManager.NotificationContent = {
    notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
    normal: {
      title: '',
      text: ''
    }
  }
  notificationSlotType: notificationManager.SlotType = notificationManager.SlotType.CONTENT_INFORMATION
}

export class FamilyNotifyService {
  static lastError: string = ''
  static lastAgentId: number = 0
  private static context: common.UIAbilityContext | null = null

  static init(context: common.UIAbilityContext): void {
    FamilyNotifyService.context = context
  }

  static notifyEnabled(): boolean {
    return AppStorage.get<boolean>('notifyEnabled') !== false
  }

  static async ensurePermission(): Promise<boolean> {
    const ctx = FamilyNotifyService.context
    if (ctx === null) {
      FamilyNotifyService.lastError = '通知服务未就绪'
      return false
    }
    try {
      const enabled = await notificationManager.isNotificationEnabled()
      if (!enabled) {
        await notificationManager.requestEnableNotification(ctx)
        if (!(await notificationManager.isNotificationEnabled())) {
          FamilyNotifyService.lastError = '请在系统设置中开启通知'
          return false
        }
      }
    } catch {
      FamilyNotifyService.lastError = '请在系统设置中开启通知'
      return false
    }
    try {
      await notificationManager.addSlot(notificationManager.SlotType.CONTENT_INFORMATION)
    } catch {
    }
    const reminderOk = await FamilyNotifyService.ensureReminderPermission(ctx)
    if (!reminderOk) {
      FamilyNotifyService.lastError = '请允许「发布提醒」权限，否则无法在约定时间通知你'
      return false
    }
    return true
  }

  private static async ensureReminderPermission(ctx: common.UIAbilityContext): Promise<boolean> {
    try {
      const perm: Permissions = 'ohos.permission.PUBLISH_AGENT_REMINDER'
      const atManager = abilityAccessCtrl.createAtManager()
      const status = await atManager.checkAccessToken(ctx.applicationInfo.accessTokenId, perm)
      if (status === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        return true
      }
      const req = await atManager.requestPermissionsFromUser(ctx, [perm])
      return req.authResults.length > 0 &&
        req.authResults[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED
    } catch {
      return false
    }
  }

  static parseRemindAt(whenText: string): Date | undefined {
    const parts = whenText.trim().split(' ')
    if (parts.length < 2) {
      return undefined
    }
    const dateParts = parts[0].split('-')
    const timeParts = parts[1].split(':')
    if (dateParts.length !== 3 || timeParts.length < 2) {
      return undefined
    }
    const year = parseInt(dateParts[0], 10)
    const month = parseInt(dateParts[1], 10)
    const day = parseInt(dateParts[2], 10)
    const hour = parseInt(timeParts[0], 10)
    const minute = parseInt(timeParts[1], 10)
    if (!(year > 0) || !(month > 0) || !(day > 0) || hour < 0 || minute < 0) {
      return undefined
    }
    return new Date(year, month - 1, day, hour, minute, 0)
  }

  static defaultTimeText(): string {
    const d = new Date()
    d.setMinutes(d.getMinutes() + 15)
    const h = d.getHours()
    const m = d.getMinutes()
    const hs: string = h < 10 ? `0${h}` : `${h}`
    const ms: string = m < 10 ? `0${m}` : `${m}`
    return `${hs}:${ms}`
  }

  static async cancel(agentId: number): Promise<void> {
    if (agentId <= 0) {
      return
    }
    try {
      await reminderAgentManager.cancelReminder(agentId)
    } catch {
    }
  }

  static async schedule(row: FamilyReminder): Promise<boolean> {
    FamilyNotifyService.lastError = ''
    FamilyNotifyService.lastAgentId = 0
    if (!FamilyNotifyService.notifyEnabled()) {
      FamilyNotifyService.lastError = '已关闭提醒，可在「我的 → 通知设置」开启'
      return false
    }
    const okPerm = await FamilyNotifyService.ensurePermission()
    if (!okPerm) {
      return false
    }
    const fire = FamilyNotifyService.parseRemindAt(row.remindAt)
    if (fire === undefined) {
      FamilyNotifyService.lastError = '提醒时间无效'
      return false
    }
    const delaySec = Math.floor((fire.getTime() - Date.now()) / 1000)
    if (delaySec < 10) {
      FamilyNotifyService.lastError = '请选择至少 1 分钟后的提醒时间'
      return false
    }
    await FamilyNotifyService.cancel(row.agentId)
    const title = '家庭备忘'
    const content = row.title.length > 0 ? row.title : '看看今天的家庭事项'
    const notificationId = FamilyNotifyService.notificationId(row.id)
    let agentId = 0
    if (row.cycle !== 'weekly' && delaySec <= TIMER_MAX_SEC) {
      agentId = await FamilyNotifyService.publishTimer(title, content, notificationId, delaySec)
    }
    if (agentId <= 0) {
      agentId = await FamilyNotifyService.publishCalendar(title, content, notificationId, fire, row.cycle === 'weekly')
    }
    if (agentId <= 0 && row.cycle !== 'weekly' && delaySec <= TIMER_MAX_SEC) {
      agentId = await FamilyNotifyService.publishTimer(title, content, notificationId, delaySec)
    }
    FamilyNotifyService.lastAgentId = agentId
    if (agentId > 0) {
      return true
    }
    const posted = await FamilyNotifyService.publishNow(title, `已记下：${row.remindAt} 将再次提醒你`)
    if (posted) {
      FamilyNotifyService.lastError = ''
      return true
    }
    FamilyNotifyService.lastError = '系统提醒设置失败，请在系统设置中允许通知、发布提醒与后台活动'
    return false
  }

  static async publishNow(title: string, text: string): Promise<boolean> {
    const req = new NotificationRequestWrapper()
    req.id = (Date.now() % 80000) + 32000
    req.content = {
      notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
      normal: {
        title: title,
        text: text
      }
    }
    req.notificationSlotType = notificationManager.SlotType.CONTENT_INFORMATION
    try {
      await notificationManager.publish(req as notificationManager.NotificationRequest)
      return true
    } catch {
      return false
    }
  }

  static async deliverDue(): Promise<void> {
    if (!FamilyNotifyService.notifyEnabled()) {
      return
    }
    const bundle = FamilyLocalStore.snapshot()
    const nextRows: FamilyReminder[] = []
    let changed = false
    for (const row of bundle.reminders) {
      const copy = FamilyLocalStore.cloneReminder(row)
      if (copy.status === 'fired' || copy.status === 'done') {
        nextRows.push(copy)
        continue
      }
      const fire = FamilyNotifyService.parseRemindAt(copy.remindAt)
      if (fire === undefined || fire.getTime() > Date.now()) {
        nextRows.push(copy)
        continue
      }
      const title = '家庭备忘'
      const content = copy.title.length > 0 ? copy.title : '看看今天的家庭事项'
      const sent = await FamilyNotifyService.publishNow(title, content)
      if (sent) {
        copy.status = 'fired'
        changed = true
      }
      nextRows.push(copy)
    }
    if (!changed) {
      return
    }
    const next = new LocalBundle()
    next.lists = FamilyLocalStore.copyLists(bundle.lists)
    next.items = FamilyLocalStore.copyItems(bundle.items)
    next.memos = FamilyLocalStore.copyMemos(bundle.memos)
    next.reminders = nextRows
    await FamilyLocalStore.saveBundle(next)
  }

  private static async publishTimer(title: string, content: string, notificationId: number, delaySec: number): Promise<number> {
    const req = new ReminderRequestTimerWrapper()
    req.triggerTimeInSeconds = Math.max(10, Math.min(delaySec, TIMER_MAX_SEC))
    req.title = title
    req.content = content
    req.expiredContent = '家庭事项提醒已到期'
    req.notificationId = notificationId
    try {
      return await reminderAgentManager.publishReminder(req as reminderAgentManager.ReminderRequestTimer)
    } catch {
      return 0
    }
  }

  private static async publishCalendar(title: string, content: string, notificationId: number, fire: Date,
    weekly: boolean): Promise<number> {
    try {
      if (weekly) {
        const req = new ReminderRequestWeeklyCalendar()
        FamilyNotifyService.fillDate(req.dateTime, fire)
        req.title = title
        req.content = content
        req.expiredContent = '家庭事项提醒已到期'
        req.notificationId = notificationId
        const day = fire.getDay()
        const days: number[] = []
        days.push(day === 0 ? 7 : day)
        req.daysOfWeek = days
        return await reminderAgentManager.publishReminder(req as reminderAgentManager.ReminderRequestCalendar)
      }
      const req = new ReminderRequestOnceCalendar()
      FamilyNotifyService.fillDate(req.dateTime, fire)
      req.title = title
      req.content = content
      req.expiredContent = '家庭事项提醒已到期'
      req.notificationId = notificationId
      const months: number[] = []
      months.push(fire.getDate())
      req.daysOfMonth = months
      return await reminderAgentManager.publishReminder(req as reminderAgentManager.ReminderRequestCalendar)
    } catch {
      return 0
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

  private static notificationId(id: string): number {
    let hash = 0
    for (let i = 0; i < id.length; i++) {
      hash = (hash * 31 + id.charCodeAt(i)) % 80000
    }
    return hash + 31000
  }
}
