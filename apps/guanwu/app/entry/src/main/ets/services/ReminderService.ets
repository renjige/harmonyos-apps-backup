import { reminderAgentManager } from '@kit.BackgroundTasksKit'
import { notificationManager } from '@kit.NotificationKit'
import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit'
import { UserProfile } from '../models/ObserveModels'
import { ObserveStore } from './ObserveStore'
import { ObserveAtlasStore } from './ObserveAtlasStore'

const AGENT_ID_KEY = 'guanwu_reminder_agent_id'
const BUNDLE_NAME = 'gw.llg.huawei'
const ENTRY_ABILITY = 'EntryAbility'
const MIN_LEAD_MS = 3 * 60 * 1000

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
  expiredContent: string = '观物 · 观察提醒已过期'
  snoozeContent: string = '稍后提醒'
  notificationId: number = 88021
  ringDuration: number = 1
  slotType: notificationManager.SlotType = notificationManager.SlotType.CONTENT_INFORMATION
  wantAgent: ReminderWantAgent = new ReminderWantAgent()
  daysOfWeek: number[] = [1, 2, 3, 4, 5, 6, 7]
}

class ReminderRequestTimerWrapper {
  reminderType: reminderAgentManager.ReminderType =
    reminderAgentManager.ReminderType.REMINDER_TYPE_TIMER
  triggerTimeInSeconds: number = 3600
  title: string = ''
  content: string = ''
  expiredContent: string = '观物 · 观察提醒已过期'
  snoozeContent: string = '稍后提醒'
  notificationId: number = 88021
  ringDuration: number = 1
  slotType: notificationManager.SlotType = notificationManager.SlotType.CONTENT_INFORMATION
  wantAgent: ReminderWantAgent = new ReminderWantAgent()
}

export class ReminderService {
  static lastError: string = ''

  static async ensureReminderPermission(context: common.UIAbilityContext, request: boolean): Promise<boolean> {
    try {
      const perm: Permissions = 'ohos.permission.PUBLISH_AGENT_REMINDER'
      const atManager = abilityAccessCtrl.createAtManager()
      const status = await atManager.checkAccessToken(context.applicationInfo.accessTokenId, perm)
      if (status === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        return true
      }
      if (!request) {
        return false
      }
      const req = await atManager.requestPermissionsFromUser(context, [perm])
      return req.authResults.length > 0 &&
        req.authResults[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED
    } catch {
      return false
    }
  }

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
    const reminderOk = await ReminderService.ensureReminderPermission(context, true)
    if (!reminderOk) {
      ReminderService.lastError = '请允许「发布提醒」权限，否则无法在约定时间通知'
      return false
    }
    return true
  }

  static async cancelDaily(): Promise<void> {
    let stored = AppStorage.get<number>(AGENT_ID_KEY) ?? 0
    if (stored <= 0) {
      stored = await ObserveStore.loadReminderAgentId()
    }
    if (stored > 0) {
      try {
        await reminderAgentManager.cancelReminder(stored)
      } catch {
      }
    }
    AppStorage.setOrCreate(AGENT_ID_KEY, 0)
    await ObserveStore.saveReminderAgentId(0)
  }

  /** 距现在不足 3 分钟则改到次日，避免设置后立刻弹出 */
  static buildFireDate(profile: UserProfile): Date {
    const fire = new Date()
    fire.setHours(profile.reminderHour, profile.reminderMinute, 0, 0)
    if (fire.getTime() - Date.now() < MIN_LEAD_MS) {
      fire.setDate(fire.getDate() + 1)
    }
    return fire
  }

  static nextLabel(profile: UserProfile): string {
    const fire = ReminderService.buildFireDate(profile)
    const h = fire.getHours()
    const m = fire.getMinutes()
    const hh = h < 10 ? `0${h}` : `${h}`
    const mm = m < 10 ? `0${m}` : `${m}`
    const today = new Date()
    const sameDay = fire.getDate() === today.getDate() && fire.getMonth() === today.getMonth()
    return `${sameDay ? '今天' : '明天'} ${hh}:${mm}`
  }

  private static async buildContent(): Promise<string> {
    let content = '到点了：花一分钟记下眼前一物，或为图鉴补一条成长记录。'
    try {
      const subjects = await ObserveAtlasStore.loadAll()
      let weekly = 0
      for (const s of subjects) {
        if (s.remindWeekly) {
          weekly++
        }
      }
      if (weekly > 0) {
        content = `到点了：有 ${weekly} 件图鉴设了每周复访，补一条成长记录吧。`
      }
    } catch {
    }
    return content
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
    const fire = ReminderService.buildFireDate(profile)
    const title = '观物 · 观察提醒'
    const content = await ReminderService.buildContent()
    const noticeId = 88021 + (profile.reminderHour * 10 + profile.reminderMinute)

    const calendarOk = await ReminderService.scheduleCalendar(profile, fire, title, content, noticeId)
    if (calendarOk) {
      return true
    }
    return await ReminderService.scheduleTimer(profile, fire, title, content, noticeId)
  }

  private static async scheduleCalendar(profile: UserProfile, fire: Date, title: string,
    content: string, noticeId: number): Promise<boolean> {
    try {
      const req = new ReminderRequestCalendarWrapper()
      req.dateTime.year = fire.getFullYear()
      req.dateTime.month = fire.getMonth() + 1
      req.dateTime.day = fire.getDate()
      req.dateTime.hour = profile.reminderHour
      req.dateTime.minute = profile.reminderMinute
      req.dateTime.second = 0
      req.title = title
      req.content = content
      req.notificationId = noticeId
      req.daysOfWeek = [1, 2, 3, 4, 5, 6, 7]
      const agentId: number = await reminderAgentManager.publishReminder(
        req as reminderAgentManager.ReminderRequestCalendar
      )
      AppStorage.setOrCreate(AGENT_ID_KEY, agentId)
      await ObserveStore.saveReminderAgentId(agentId)
      ReminderService.lastError = `已预约每日 ${ReminderService.nextLabel(profile)}，不会立即弹出`
      return true
    } catch {
      return false
    }
  }

  private static async scheduleTimer(profile: UserProfile, fire: Date, title: string,
    content: string, noticeId: number): Promise<boolean> {
    try {
      const deltaSec = Math.max(180, Math.floor((fire.getTime() - Date.now()) / 1000))
      const timerReq = new ReminderRequestTimerWrapper()
      timerReq.triggerTimeInSeconds = deltaSec
      timerReq.title = title
      timerReq.content = content
      timerReq.notificationId = noticeId + 1
      const agentId: number = await reminderAgentManager.publishReminder(
        timerReq as reminderAgentManager.ReminderRequestTimer
      )
      AppStorage.setOrCreate(AGENT_ID_KEY, agentId)
      await ObserveStore.saveReminderAgentId(agentId)
      ReminderService.lastError = `已预约 ${ReminderService.nextLabel(profile)}（单次），不会立即弹出`
      return true
    } catch {
      ReminderService.lastError = '提醒设置失败，请检查通知与「发布提醒」权限'
      return false
    }
  }

  static async syncFromProfile(context: common.UIAbilityContext): Promise<void> {
    const profile = await ObserveStore.loadProfile()
    if (profile.reminderEnabled) {
      await ReminderService.scheduleDaily(profile, context)
    } else {
      await ReminderService.cancelDaily()
    }
  }
}
