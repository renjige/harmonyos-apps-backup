import { reminderAgentManager } from '@kit.BackgroundTasksKit'
import { notificationManager } from '@kit.NotificationKit'
import { common } from '@kit.AbilityKit'
import { CornerSettings } from '../models/YouyuModels'
import { YouyuStore } from './YouyuStore'

const AGENT_KEY = 'youyu_reminder_agent_id'

class ReminderCalendarDateTime {
  year: number = 2026
  month: number = 1
  day: number = 1
  hour: number = 21
  minute: number = 30
  second: number = 0
}

class ReminderRequestCalendarWrapper {
  reminderType: reminderAgentManager.ReminderType =
    reminderAgentManager.ReminderType.REMINDER_TYPE_CALENDAR
  dateTime: ReminderCalendarDateTime = new ReminderCalendarDateTime()
  title: string = ''
  content: string = ''
  expiredContent: string = ''
  snoozeContent: string = ''
  notificationId: number = 86016
  slotType: notificationManager.SlotType = notificationManager.SlotType.SERVICE_INFORMATION
  daysOfWeek: number[] = [1, 2, 3, 4, 5, 6, 7]
}

export class ReminderService {
  static lastError: string = ''

  static async ensurePermission(context: common.UIAbilityContext): Promise<boolean> {
    try {
      const enabled = await notificationManager.isNotificationEnabled()
      if (enabled) {
        return true
      }
      await notificationManager.requestEnableNotification(context)
      return await notificationManager.isNotificationEnabled()
    } catch {
      ReminderService.lastError = '请在系统设置中开启通知权限'
      return false
    }
  }

  static async cancelDaily(): Promise<void> {
    const settings = YouyuStore.settings()
    const stored = settings.reminderAgentId
    if (stored > 0) {
      try {
        await reminderAgentManager.cancelReminder(stored)
      } catch {
        // ignore
      }
    }
    AppStorage.setOrCreate(AGENT_KEY, 0)
  }

  static async scheduleDaily(settings: CornerSettings, context: common.UIAbilityContext): Promise<boolean> {
    ReminderService.lastError = ''
    if (!settings.reminderEnabled) {
      await ReminderService.cancelDaily()
      settings.reminderAgentId = 0
      await YouyuStore.saveSettings(settings)
      return true
    }
    const okPerm = await ReminderService.ensurePermission(context)
    if (!okPerm) {
      return false
    }
    await ReminderService.cancelDaily()
    const now = new Date()
    const fire = new Date()
    fire.setHours(settings.reminderHour, settings.reminderMinute, 0, 0)
    if (fire.getTime() <= now.getTime()) {
      fire.setDate(fire.getDate() + 1)
    }
    const req = new ReminderRequestCalendarWrapper()
    req.dateTime.year = fire.getFullYear()
    req.dateTime.month = fire.getMonth() + 1
    req.dateTime.day = fire.getDate()
    req.dateTime.hour = settings.reminderHour
    req.dateTime.minute = settings.reminderMinute
    req.title = '悠隅纪'
    req.content = '把此刻轻轻放下，写下一隅。'
    req.daysOfWeek = [1, 2, 3, 4, 5, 6, 7]
    try {
      const agentId: number = await reminderAgentManager.publishReminder(
        req as reminderAgentManager.ReminderRequestCalendar
      )
      settings.reminderAgentId = agentId
      AppStorage.setOrCreate(AGENT_KEY, agentId)
      await YouyuStore.saveSettings(settings)
      return true
    } catch {
      ReminderService.lastError = '提醒设置失败，请检查通知权限'
      return false
    }
  }
}
