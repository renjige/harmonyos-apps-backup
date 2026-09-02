import { reminderAgentManager } from '@kit.BackgroundTasksKit'
import { notificationManager } from '@kit.NotificationKit'
import { common } from '@kit.AbilityKit'
import { UserProfile } from '../models/ObservationModels'
import { ObservationStore } from './ObservationStore'

const REMINDER_KEY = 'daily_observation_reminder'
const AGENT_ID_KEY = 'ximan_reminder_agent_id'

class ReminderCalendarDateTime {
  year: number = 2026
  month: number = 1
  day: number = 1
  hour: number = 20
  minute: number = 0
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
  notificationId: number = 88001
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
    let stored = AppStorage.get<number>(AGENT_ID_KEY) ?? 0
    if (stored <= 0) {
      stored = await ObservationStore.loadReminderAgentId()
    }
    if (stored > 0) {
      try {
        await reminderAgentManager.cancelReminder(stored)
      } catch {
        // ignore
      }
    }
    AppStorage.setOrCreate(AGENT_ID_KEY, 0)
    await ObservationStore.saveReminderAgentId(0)
  }

  static async scheduleDaily(profile: UserProfile, context: common.UIAbilityContext): Promise<boolean> {
    ReminderService.lastError = ''
    if (!profile.reminderEnabled) {
      await ReminderService.cancelDaily()
      return true
    }
    const okPerm = await ReminderService.ensurePermission(context)
    if (!okPerm) {
      return false
    }
    await ReminderService.cancelDaily()
    const now = new Date()
    const fire = new Date()
    fire.setHours(profile.reminderHour, profile.reminderMinute, 0, 0)
    if (fire.getTime() <= now.getTime()) {
      fire.setDate(fire.getDate() + 1)
    }
    const req = new ReminderRequestCalendarWrapper()
    req.dateTime.year = fire.getFullYear()
    req.dateTime.month = fire.getMonth() + 1
    req.dateTime.day = fire.getDate()
    req.dateTime.hour = profile.reminderHour
    req.dateTime.minute = profile.reminderMinute
    req.title = '溪漫观 · 记录时刻'
    req.content = '今天，你观察到了什么？写下一条漫观笔记吧。'
    req.daysOfWeek = [1, 2, 3, 4, 5, 6, 7]
    try {
      const agentId: number = await reminderAgentManager.publishReminder(
        req as reminderAgentManager.ReminderRequestCalendar
      )
      AppStorage.setOrCreate(AGENT_ID_KEY, agentId)
      await ObservationStore.saveReminderAgentId(agentId)
      return true
    } catch {
      ReminderService.lastError = '提醒设置失败，请检查通知与后台权限'
      return false
    }
  }

  static async syncFromProfile(context: common.UIAbilityContext): Promise<void> {
    const profile = await ObservationStore.loadProfile()
    if (profile.reminderEnabled) {
      await ReminderService.scheduleDaily(profile, context)
    } else {
      await ReminderService.cancelDaily()
    }
  }
}
