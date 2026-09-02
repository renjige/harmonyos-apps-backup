import { reminderAgentManager } from '@kit.BackgroundTasksKit'
import { notificationManager } from '@kit.NotificationKit'
import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit'
import { ShoppingReminder } from '../models/ShoppingModels'
import { ShoppingLocalStore } from './ShoppingLocalStore'
import { BrandIdentity } from '../config/BrandIdentity'

const TIMER_MAX_SEC = 7 * 24 * 3600
const BUNDLE_NAME = 'gwbw.wxy.huawei'
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

export class ShoppingNotifyService {
  static lastError: string = ''
  private static context: common.UIAbilityContext | null = null

  static init(context: common.UIAbilityContext): void {
    ShoppingNotifyService.context = context
  }

  static hostContext(): common.UIAbilityContext | undefined {
    return ShoppingNotifyService.context !== null ? ShoppingNotifyService.context : undefined
  }

  static notifyEnabled(): boolean {
    return AppStorage.get<boolean>('notifyEnabled') !== false
  }

  static async ensurePermission(): Promise<boolean> {
    const ctx = ShoppingNotifyService.context
    if (ctx === null) {
      ShoppingNotifyService.lastError = '通知服务未就绪'
      return false
    }
    try {
      const enabled = await notificationManager.isNotificationEnabled()
      if (!enabled) {
        await notificationManager.requestEnableNotification(ctx)
        if (!(await notificationManager.isNotificationEnabled())) {
          ShoppingNotifyService.lastError = '请在系统设置中开启通知'
          return false
        }
      }
    } catch {
      ShoppingNotifyService.lastError = '请在系统设置中开启通知'
      return false
    }
    try {
      await notificationManager.addSlot(notificationManager.SlotType.CONTENT_INFORMATION)
    } catch {
    }
    // 发布提醒权限尽最大努力申请；已开通知时即使弹窗结果异常也继续调度，避免误报「请检查权限」
    await ShoppingNotifyService.ensureReminderPermission(ctx)
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

  static async schedule(row: ShoppingReminder): Promise<number> {
    ShoppingNotifyService.lastError = ''
    if (!ShoppingNotifyService.notifyEnabled()) {
      ShoppingNotifyService.lastError = '已关闭提醒，可在「我的 → 通知设置」开启'
      return 0
    }
    const okPerm = await ShoppingNotifyService.ensurePermission()
    if (!okPerm) {
      return 0
    }
    const fire = ShoppingNotifyService.parseRemindAt(row.remindAt)
    if (fire === undefined) {
      ShoppingNotifyService.lastError = '提醒时间无效'
      return 0
    }
    let delaySec = Math.floor((fire.getTime() - Date.now()) / 1000)
    if (delaySec < 10) {
      delaySec = 60
      fire.setTime(Date.now() + 60 * 1000)
    }
    await ShoppingNotifyService.cancel(row.agentId)
    const title = BrandIdentity.appName()
    const content = row.title.length > 0 ? row.title : '别忘了完成今天的购物清单'
    const notificationId = ShoppingNotifyService.notificationId(row.id)
    let agentId = 0
    const weekly = row.cycle === 'weekly'
    if (!weekly && delaySec <= TIMER_MAX_SEC) {
      agentId = await ShoppingNotifyService.publishTimer(title, content, notificationId, delaySec)
    }
    if (agentId <= 0) {
      agentId = await ShoppingNotifyService.publishCalendar(title, content, notificationId, fire, weekly)
    }
    if (agentId > 0) {
      return agentId
    }
    const posted = await ShoppingNotifyService.publishNow(title, `已记下 ${row.remindAt} 的购物提醒`)
    if (posted) {
      ShoppingNotifyService.lastError = ''
      return 1
    }
    ShoppingNotifyService.lastError = '系统提醒设置失败，请在系统设置中允许通知、发布提醒与后台活动'
    return 0
  }

  static async testRing(): Promise<boolean> {
    ShoppingNotifyService.lastError = ''
    const ok = await ShoppingNotifyService.ensurePermission()
    if (!ok) {
      return false
    }
    const title = BrandIdentity.appName()
    await ShoppingNotifyService.publishNow(title, '提醒通道已接通，1 分钟后会再通知一次')
    const agentId = await ShoppingNotifyService.publishTimer(title, '到点了，记得核对购物清单', 20991, 60)
    if (agentId <= 0) {
      ShoppingNotifyService.lastError = ''
    }
    return true
  }

  static async deliverDue(): Promise<void> {
    if (!ShoppingNotifyService.notifyEnabled()) {
      return
    }
    for (const row of ShoppingLocalStore.reminders()) {
      const fire = ShoppingNotifyService.parseRemindAt(row.remindAt)
      if (fire === undefined || fire.getTime() > Date.now()) {
        continue
      }
      if (row.status === 'fired') {
        continue
      }
      const title = BrandIdentity.appName()
      const content = row.title.length > 0 ? row.title : '别忘了完成今天的购物清单'
      await ShoppingNotifyService.publishNow(title, content)
    }
  }

  static async publishNow(title: string, text: string): Promise<boolean> {
    const req = new NotificationRequestWrapper()
    req.id = (Date.now() % 80000) + 21000
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

  private static async publishTimer(title: string, content: string, notificationId: number, delaySec: number): Promise<number> {
    const req = new ReminderRequestTimerWrapper()
    req.triggerTimeInSeconds = Math.max(10, Math.min(delaySec, TIMER_MAX_SEC))
    req.title = title
    req.content = content
    req.expiredContent = '购物提醒已到期'
    req.notificationId = notificationId
    try {
      return await reminderAgentManager.publishReminder(req as reminderAgentManager.ReminderRequestTimer)
    } catch {
      return 0
    }
  }

  private static async publishCalendar(title: string, content: string, notificationId: number, fire: Date,
    weekly: boolean): Promise<number> {
    if (weekly) {
      const req = new ReminderRequestWeeklyCalendar()
      req.dateTime.year = fire.getFullYear()
      req.dateTime.month = fire.getMonth() + 1
      req.dateTime.day = fire.getDate()
      req.dateTime.hour = fire.getHours()
      req.dateTime.minute = fire.getMinutes()
      req.dateTime.second = 0
      req.title = title
      req.content = content
      req.expiredContent = '购物提醒已到期'
      req.notificationId = notificationId
      const day = fire.getDay()
      const days: number[] = []
      days.push(day === 0 ? 7 : day)
      req.daysOfWeek = days
      try {
        return await reminderAgentManager.publishReminder(req as reminderAgentManager.ReminderRequestCalendar)
      } catch {
        return 0
      }
    }
    const req = new ReminderRequestOnceCalendar()
    req.dateTime.year = fire.getFullYear()
    req.dateTime.month = fire.getMonth() + 1
    req.dateTime.day = fire.getDate()
    req.dateTime.hour = fire.getHours()
    req.dateTime.minute = fire.getMinutes()
    req.dateTime.second = 0
    req.title = title
    req.content = content
    req.expiredContent = '购物提醒已到期'
    req.notificationId = notificationId
    const days: number[] = []
    days.push(fire.getDate())
    req.daysOfMonth = days
    try {
      return await reminderAgentManager.publishReminder(req as reminderAgentManager.ReminderRequestCalendar)
    } catch {
      return 0
    }
  }

  private static notificationId(id: string): number {
    let hash = 0
    for (let i = 0; i < id.length; i++) {
      hash = (hash * 31 + id.charCodeAt(i)) % 80000
    }
    return hash + 21000
  }
}
