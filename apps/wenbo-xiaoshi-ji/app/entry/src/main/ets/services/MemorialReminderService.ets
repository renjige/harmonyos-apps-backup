import { reminderAgentManager } from '@kit.BackgroundTasksKit'
import { notificationManager } from '@kit.NotificationKit'
import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit'
import { LifeMemorial } from '../models/MomentModels'

const TIMER_MAX_SEC = 7 * 24 * 3600

class ReminderCalendarDateTime {
  year: number = 2026
  month: number = 1
  day: number = 1
  hour: number = 9
  minute: number = 0
  second: number = 0
}

class ReminderRequestCalendarWrapper {
  reminderType: reminderAgentManager.ReminderType = reminderAgentManager.ReminderType.REMINDER_TYPE_CALENDAR
  dateTime: ReminderCalendarDateTime = new ReminderCalendarDateTime()
  title: string = ''
  content: string = ''
  expiredContent: string = ''
  snoozeContent: string = '稍后提醒'
  notificationId: number = 0
  slotType: notificationManager.SlotType = notificationManager.SlotType.SERVICE_INFORMATION
  ringDuration: number = 1
}

class ReminderRequestTimerWrapper {
  reminderType: reminderAgentManager.ReminderType = reminderAgentManager.ReminderType.REMINDER_TYPE_TIMER
  triggerTimeInSeconds: number = 60
  title: string = ''
  content: string = ''
  expiredContent: string = ''
  snoozeContent: string = '稍后提醒'
  notificationId: number = 0
  slotType: notificationManager.SlotType = notificationManager.SlotType.SERVICE_INFORMATION
}

/** 纪念日 — ReminderAgent 预约系统通知 */
export class MemorialReminderService {
  static lastError: string = ''
  static lastAction: string = ''

  static async ensurePermission(context: common.UIAbilityContext, request: boolean = true): Promise<boolean> {
    MemorialReminderService.lastError = ''
    try {
      const enabled = await notificationManager.isNotificationEnabled()
      if (!enabled) {
        if (!request) {
          MemorialReminderService.lastError = '请在系统设置中允许通知'
          return false
        }
        await notificationManager.requestEnableNotification(context)
        if (!(await notificationManager.isNotificationEnabled())) {
          MemorialReminderService.lastError = '请在系统设置中允许通知'
          return false
        }
      }
      const perm: Permissions = 'ohos.permission.PUBLISH_AGENT_REMINDER'
      const atManager = abilityAccessCtrl.createAtManager()
      const status = await atManager.checkAccessToken(context.applicationInfo.accessTokenId, perm)
      if (status === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        return true
      }
      if (!request) {
        MemorialReminderService.lastError = '请允许发布系统提醒权限'
        return false
      }
      const req = await atManager.requestPermissionsFromUser(context, [perm])
      const ok = req.authResults.length > 0 &&
        req.authResults[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED
      if (!ok) {
        MemorialReminderService.lastError = '请允许发布系统提醒权限'
      }
      return ok
    } catch {
      MemorialReminderService.lastError = '请在系统设置中允许通知与发布提醒'
      return false
    }
  }

  static async cancelAgent(agentId: number): Promise<void> {
    if (agentId <= 0) {
      return
    }
    try {
      await reminderAgentManager.cancelReminder(agentId)
    } catch {
      return
    }
  }

  static fireAt(item: LifeMemorial): Date | undefined {
    if (item.dateKey.length < 10 || item.time.length < 5) {
      return undefined
    }
    const y = parseInt(item.dateKey.substring(0, 4), 10)
    const m = parseInt(item.dateKey.substring(5, 7), 10)
    const d = parseInt(item.dateKey.substring(8, 10), 10)
    const hh = parseInt(item.time.substring(0, 2), 10)
    const mm = parseInt(item.time.substring(3, 5), 10)
    if (isNaN(y) || isNaN(m) || isNaN(d) || isNaN(hh) || isNaN(mm)) {
      return undefined
    }
    return new Date(y, m - 1, d, hh, mm, 0)
  }

  static async schedule(item: LifeMemorial, context: common.UIAbilityContext): Promise<number> {
    MemorialReminderService.lastAction = ''
    await MemorialReminderService.cancelAgent(item.agentId)
    if (!item.enabled) {
      MemorialReminderService.lastAction = '已保存，提醒已关闭'
      return 0
    }
    const ok = await MemorialReminderService.ensurePermission(context, true)
    if (!ok) {
      MemorialReminderService.lastAction = '已保存纪念日；请允许通知后才会按时提醒'
      return 0
    }
    const fire = MemorialReminderService.fireAt(item)
    if (fire === undefined) {
      MemorialReminderService.lastAction = '已保存'
      return 0
    }
    const delta = Math.floor((fire.getTime() - Date.now()) / 1000)
    if (delta <= 0) {
      MemorialReminderService.lastAction = '提醒时间已过，请改到未来时刻'
      return 0
    }
    const noticeId = MemorialReminderService.noticeId(item.id)
    const title = '小事记 · 纪念日'
    const content = item.title
    if (delta <= TIMER_MAX_SEC) {
      const timer = new ReminderRequestTimerWrapper()
      timer.triggerTimeInSeconds = Math.max(15, delta)
      timer.title = title
      timer.content = content
      timer.expiredContent = `${item.title}（已到点）`
      timer.notificationId = noticeId
      try {
        const agentId = await reminderAgentManager.publishReminder(
          timer as reminderAgentManager.ReminderRequestTimer)
        if (agentId > 0) {
          MemorialReminderService.lastAction = `已预约 ${item.dateKey} ${item.time} 系统提醒`
          return agentId
        }
      } catch {
        return 0
      }
    }
    const cal = new ReminderRequestCalendarWrapper()
    cal.dateTime.year = fire.getFullYear()
    cal.dateTime.month = fire.getMonth() + 1
    cal.dateTime.day = fire.getDate()
    cal.dateTime.hour = fire.getHours()
    cal.dateTime.minute = fire.getMinutes()
    cal.title = title
    cal.content = content
    cal.expiredContent = `${item.title}（已到点）`
    cal.notificationId = noticeId
    try {
      const agentId = await reminderAgentManager.publishReminder(
        cal as reminderAgentManager.ReminderRequestCalendar)
      if (agentId > 0) {
        MemorialReminderService.lastAction = `已预约 ${item.dateKey} ${item.time} 系统提醒`
        return agentId
      }
    } catch {
      MemorialReminderService.lastAction = '已保存纪念日，系统提醒预约失败，请检查权限'
      return 0
    }
    MemorialReminderService.lastAction = '已保存纪念日，系统提醒预约失败，请检查权限'
    return 0
  }

  private static noticeId(id: string): number {
    let hash = 53
    let i = 0
    while (i < id.length) {
      hash = (hash * 31 + id.charCodeAt(i)) % 80000
      i += 1
    }
    return hash + 42000
  }
}
