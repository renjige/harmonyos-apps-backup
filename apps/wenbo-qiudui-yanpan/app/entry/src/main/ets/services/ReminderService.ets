import { reminderAgentManager } from '@kit.BackgroundTasksKit'
import { notificationManager } from '@kit.NotificationKit'
import { common } from '@kit.AbilityKit'
import { MatchItem } from '../models/MatchModels'
import { ReminderLocalStore } from './ReminderLocalStore'

export class ReminderService {
  static lastError: string = ''

  static notifyEnabled(): boolean {
    return AppStorage.get<boolean>('notifyEnabled') !== false
  }

  static defaultMinutes(): number {
    return ReminderLocalStore.defaultMinutes()
  }

  static async ensurePermission(context: common.UIAbilityContext): Promise<boolean> {
    try {
      const enabled = await notificationManager.isNotificationEnabled()
      if (enabled) {
        return true
      }
      await notificationManager.requestEnableNotification(context)
      return await notificationManager.isNotificationEnabled()
    } catch {
      ReminderService.lastError = '通知权限未开启'
      return false
    }
  }

  static computeRemindAt(match: MatchItem, remindMinutes: number): string {
    if (match.startAt.length === 0) {
      return ''
    }
    const event = new Date(match.startAt)
    const fire = new Date(event.getTime() - remindMinutes * 60 * 1000)
    return fire.toISOString()
  }

  static notificationIdFromMatchId(id: string): number {
    let hash = 0
    for (let i = 0; i < id.length; i++) {
      hash = (hash * 31 + id.charCodeAt(i)) % 100000
    }
    return hash + 2000
  }

  static async cancelForMatch(matchId: string): Promise<void> {
    const agentId = ReminderLocalStore.reminderAgentId(matchId)
    if (agentId <= 0) {
      return
    }
    try {
      await reminderAgentManager.cancelReminder(agentId)
    } catch {
    }
    await ReminderLocalStore.removeReminderAgentId(matchId)
  }

  static async scheduleForMatch(match: MatchItem, remindMinutes: number, context: common.UIAbilityContext): Promise<boolean> {
    ReminderService.lastError = ''
    if (!ReminderService.notifyEnabled()) {
      ReminderService.lastError = '请先在设置中开启通知'
      return false
    }
    const okPerm = await ReminderService.ensurePermission(context)
    if (!okPerm) {
      return false
    }
    await ReminderService.cancelForMatch(match.id)
    const remindIso = ReminderService.computeRemindAt(match, remindMinutes)
    if (remindIso.length === 0) {
      ReminderService.lastError = '比赛时间无效'
      return false
    }
    const fire = new Date(remindIso)
    const now = new Date()
    if (fire.getTime() <= now.getTime()) {
      ReminderService.lastError = '提醒时间已过，请选择更短提前量或关注其他比赛'
      return false
    }
    const req = new ReminderRequestCalendarWrapper()
    req.reminderType = reminderAgentManager.ReminderType.REMINDER_TYPE_CALENDAR
    req.dateTime.year = fire.getFullYear()
    req.dateTime.month = fire.getMonth() + 1
    req.dateTime.day = fire.getDate()
    req.dateTime.hour = fire.getHours()
    req.dateTime.minute = fire.getMinutes()
    req.dateTime.second = 0
    req.title = match.title.length > 0 ? match.title : '比赛提醒'
    req.content = `${match.leagueName} · ${match.timeLabel()} 即将开始`
    req.notificationId = ReminderService.notificationIdFromMatchId(match.id)
    req.slotType = notificationManager.SlotType.SERVICE_INFORMATION
    try {
      const agentId: number = await reminderAgentManager.publishReminder(
        req as reminderAgentManager.ReminderRequestCalendar
      )
      await ReminderLocalStore.setReminderAgentId(match.id, agentId)
      return true
    } catch {
      ReminderService.lastError = '提醒设置失败，请检查通知权限'
      return false
    }
  }
}

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
  snoozeContent: string = ''
  notificationId: number = 0
  slotType: notificationManager.SlotType = notificationManager.SlotType.SERVICE_INFORMATION
  daysOfWeek?: number[] = []
}
