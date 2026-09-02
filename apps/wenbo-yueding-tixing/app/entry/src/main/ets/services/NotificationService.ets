import { reminderAgentManager } from '@kit.BackgroundTasksKit'
import { notificationManager } from '@kit.NotificationKit'
import { common } from '@kit.AbilityKit'
import { AppointmentItem } from '../models/AppointmentModels'
import { AppointmentLocalStore } from './AppointmentLocalStore'

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

class NotificationRequestWrapper {
  id: number = 0
  content: notificationManager.NotificationContent = {
    notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
    normal: {
      title: '',
      text: ''
    }
  }
  notificationSlotType: notificationManager.SlotType = notificationManager.SlotType.SERVICE_INFORMATION
}

export class NotificationService {
  static lastError: string = ''

  static notifyEnabled(): boolean {
    return AppStorage.get<boolean>('notifyEnabled') !== false
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
      NotificationService.lastError = '通知权限未开启'
      return false
    }
  }

  static computeRemindAt(item: AppointmentItem): string {
    if (item.dueDate.length === 0) {
      return ''
    }
    const parts = item.dueDate.split('-')
    if (parts.length !== 3) {
      return ''
    }
    const year = parseInt(parts[0], 10)
    const month = parseInt(parts[1], 10)
    const day = parseInt(parts[2], 10)
    let hour = 9
    let minute = 0
    if (item.dueTime.length >= 5) {
      const tp = item.dueTime.split(':')
      hour = parseInt(tp[0], 10)
      minute = parseInt(tp[1], 10)
    }
    const event = new Date(year, month - 1, day, hour, minute, 0)
    const fire = new Date(event.getTime() - item.remindBeforeMinutes * 60 * 1000)
    return fire.toISOString()
  }

  static notificationIdFromItemId(id: string): number {
    let hash = 0
    for (let i = 0; i < id.length; i++) {
      hash = (hash * 31 + id.charCodeAt(i)) % 100000
    }
    return hash + 1000
  }

  static async cancelForAppointment(appointmentId: string): Promise<void> {
    const agentId = AppointmentLocalStore.reminderAgentId(appointmentId)
    if (agentId <= 0) {
      return
    }
    try {
      await reminderAgentManager.cancelReminder(agentId)
    } catch {
    }
    await AppointmentLocalStore.removeReminderAgentId(appointmentId)
  }

  static async scheduleForAppointment(item: AppointmentItem, context: common.UIAbilityContext): Promise<boolean> {
    NotificationService.lastError = ''
    if (!NotificationService.notifyEnabled()) {
      return false
    }
    if (item.isDone()) {
      await NotificationService.cancelForAppointment(item.id)
      return false
    }
    const okPerm = await NotificationService.ensurePermission(context)
    if (!okPerm) {
      return false
    }
    await NotificationService.cancelForAppointment(item.id)
    const remindIso = NotificationService.computeRemindAt(item)
    if (remindIso.length === 0) {
      return false
    }
    const fire = new Date(remindIso)
    const now = new Date()
    if (fire.getHours() >= 22) {
      fire.setDate(fire.getDate() + 1)
      fire.setHours(7)
      fire.setMinutes(30)
    } else if (fire.getHours() < 7) {
      fire.setHours(7)
      fire.setMinutes(30)
    }
    if (fire.getTime() <= now.getTime()) {
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
    req.title = item.title.length > 0 ? item.title : '约定提醒'
    req.content = item.note.length > 0 ? item.note : '您有一个约定即将开始'
    req.notificationId = NotificationService.notificationIdFromItemId(item.id)
    req.slotType = notificationManager.SlotType.SERVICE_INFORMATION
    if (item.repeatType === 'daily') {
      req.daysOfWeek = [1, 2, 3, 4, 5, 6, 7]
    } else if (item.repeatType === 'weekly') {
      req.daysOfWeek = [fire.getDay() === 0 ? 7 : fire.getDay()]
    }
    try {
      const agentId: number = await reminderAgentManager.publishReminder(
        req as reminderAgentManager.ReminderRequestCalendar
      )
      await AppointmentLocalStore.setReminderAgentId(item.id, agentId)
      return true
    } catch {
      NotificationService.lastError = '提醒设置失败，请检查通知权限'
      return false
    }
  }

  static async publishNow(title: string, text: string): Promise<void> {
    const req = new NotificationRequestWrapper()
    req.id = Date.now() % 100000
    req.content = {
      notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
      normal: {
        title: title,
        text: text
      }
    }
    req.notificationSlotType = notificationManager.SlotType.SERVICE_INFORMATION
    try {
      await notificationManager.publish(req as notificationManager.NotificationRequest)
    } catch {
    }
  }
}
