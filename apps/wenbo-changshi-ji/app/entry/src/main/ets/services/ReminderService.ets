import { reminderAgentManager } from '@kit.BackgroundTasksKit'
import { notificationManager } from '@kit.NotificationKit'
import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit'
import { RemindPref } from '../models/CommonSenseToolModels'
import { CommonSenseLocalService } from './CommonSenseLocalService'

const BUNDLE_NAME = 'csj.llg.huawei'
const ENTRY_ABILITY = 'EntryAbility'

class ReminderWantAgent {
  pkgName: string = BUNDLE_NAME
  abilityName: string = ENTRY_ABILITY
}

class ReminderCalendarDateTime {
  year: number = 2026
  month: number = 1
  day: number = 1
  hour: number = 21
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
  snoozeContent: string = '稍后提醒'
  notificationId: number = 260828
  ringDuration: number = 1
  slotType: notificationManager.SlotType = notificationManager.SlotType.CONTENT_INFORMATION
  wantAgent: ReminderWantAgent = new ReminderWantAgent()
  daysOfWeek: number[] = [1, 2, 3, 4, 5, 6, 7]
}

export class ReminderService {
  static lastError: string = ''

  static async apply(pref: RemindPref, context: common.UIAbilityContext): Promise<boolean> {
    ReminderService.lastError = ''
    if (!pref.enabled) {
      await ReminderService.cancel(pref)
      pref.agentId = 0
      await CommonSenseLocalService.saveRemind(pref)
      return true
    }
    const okPerm = await ReminderService.ensurePermission(context)
    if (!okPerm) {
      await CommonSenseLocalService.saveRemind(pref)
      return false
    }
    await ReminderService.cancel(pref)
    const now = new Date()
    const fire = new Date()
    fire.setHours(pref.hour, pref.minute, 0, 0)
    if (fire.getTime() <= now.getTime()) {
      fire.setDate(fire.getDate() + 1)
    }
    const req = new ReminderRequestCalendarWrapper()
    req.dateTime.year = fire.getFullYear()
    req.dateTime.month = fire.getMonth() + 1
    req.dateTime.day = fire.getDate()
    req.dateTime.hour = pref.hour
    req.dateTime.minute = pref.minute
    req.title = '常识集 · 今日学习'
    req.content = '打开「今日常识」读一条，打卡并收藏真正有用的那条。'
    req.daysOfWeek = [1, 2, 3, 4, 5, 6, 7]
    try {
      const agentId: number = await reminderAgentManager.publishReminder(
        req as reminderAgentManager.ReminderRequestCalendar
      )
      pref.agentId = agentId
      await CommonSenseLocalService.saveRemind(pref)
      return true
    } catch {
      ReminderService.lastError = '提醒设置失败，请检查通知与「发布提醒」权限'
      await CommonSenseLocalService.saveRemind(pref)
      return false
    }
  }

  private static async ensurePermission(context: common.UIAbilityContext): Promise<boolean> {
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

  private static async cancel(pref: RemindPref): Promise<void> {
    if (pref.agentId > 0) {
      try {
        await reminderAgentManager.cancelReminder(pref.agentId)
      } catch {
      }
    }
  }
}
