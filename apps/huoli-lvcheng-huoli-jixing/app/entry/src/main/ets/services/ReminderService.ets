import { reminderAgentManager } from '@kit.BackgroundTasksKit'
import { notificationManager } from '@kit.NotificationKit'
import { abilityAccessCtrl, common, Permissions, wantAgent } from '@kit.AbilityKit'
import { UserProfile } from '../models/VitalityModels'
import { VitalityStore } from './VitalityStore'

const AGENT_ID_KEY = 'huoli_reminder_agent_id'
const ENTRY_ABILITY = 'EntryAbility'
const MIN_LEAD_MS = 3 * 60 * 1000
const TIMER_MAX_SEC = 7 * 24 * 3600

class ReminderCalendarDateTime {
  year: number = 2026
  month: number = 1
  day: number = 1
  hour: number = 20
  minute: number = 0
  second: number = 0
}

class ReminderRequestCalendarPlain {
  reminderType: reminderAgentManager.ReminderType =
    reminderAgentManager.ReminderType.REMINDER_TYPE_CALENDAR
  dateTime: ReminderCalendarDateTime = new ReminderCalendarDateTime()
  title: string = ''
  content: string = ''
  expiredContent: string = '活力纪行 · 记录提醒已过期'
  snoozeContent: string = '稍后提醒'
  notificationId: number = 88002
  slotType: notificationManager.SlotType = notificationManager.SlotType.SERVICE_INFORMATION
  daysOfWeek: number[] = [1, 2, 3, 4, 5, 6, 7]
}

class ReminderRequestCalendarAgent {
  reminderType: reminderAgentManager.ReminderType =
    reminderAgentManager.ReminderType.REMINDER_TYPE_CALENDAR
  dateTime: ReminderCalendarDateTime = new ReminderCalendarDateTime()
  title: string = ''
  content: string = ''
  expiredContent: string = '活力纪行 · 记录提醒已过期'
  snoozeContent: string = '稍后提醒'
  notificationId: number = 88002
  slotType: notificationManager.SlotType = notificationManager.SlotType.SERVICE_INFORMATION
  wantAgent: object = new Object()
  daysOfWeek: number[] = [1, 2, 3, 4, 5, 6, 7]
}

class ReminderRequestTimerPlain {
  reminderType: reminderAgentManager.ReminderType =
    reminderAgentManager.ReminderType.REMINDER_TYPE_TIMER
  triggerTimeInSeconds: number = 3600
  title: string = ''
  content: string = ''
  expiredContent: string = '活力纪行 · 记录提醒已过期'
  snoozeContent: string = '稍后提醒'
  notificationId: number = 88003
  slotType: notificationManager.SlotType = notificationManager.SlotType.SERVICE_INFORMATION
}

class ReminderRequestTimerAgent {
  reminderType: reminderAgentManager.ReminderType =
    reminderAgentManager.ReminderType.REMINDER_TYPE_TIMER
  triggerTimeInSeconds: number = 3600
  title: string = ''
  content: string = ''
  expiredContent: string = '活力纪行 · 记录提醒已过期'
  snoozeContent: string = '稍后提醒'
  notificationId: number = 88003
  slotType: notificationManager.SlotType = notificationManager.SlotType.SERVICE_INFORMATION
  wantAgent: object = new Object()
}

export class ReminderService {
  static lastError: string = ''

  static async ensureReminderPermission(context: common.UIAbilityContext, request: boolean): Promise<boolean> {
    try {
      const perm: Permissions = 'ohos.permission.PUBLISH_AGENT_REMINDER'
      const atManager = abilityAccessCtrl.createAtManager()
      let status = await atManager.checkAccessToken(context.applicationInfo.accessTokenId, perm)
      if (status === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        return true
      }
      if (!request) {
        return false
      }
      const req = await atManager.requestPermissionsFromUser(context, [perm])
      if (req.authResults.length > 0 &&
        req.authResults[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        return true
      }
      status = await atManager.checkAccessToken(context.applicationInfo.accessTokenId, perm)
      return status === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED
    } catch {
      return false
    }
  }

  static async ensurePermission(context: common.UIAbilityContext): Promise<boolean> {
    ReminderService.lastError = ''
    try {
      let enabled = await notificationManager.isNotificationEnabled()
      if (!enabled) {
        await notificationManager.requestEnableNotification(context)
        enabled = await notificationManager.isNotificationEnabled()
      }
      if (!enabled) {
        ReminderService.lastError = '请在系统设置中允许「活力纪行」通知'
        return false
      }
    } catch {
      ReminderService.lastError = '请在系统设置中允许「活力纪行」通知'
      return false
    }
    try {
      await notificationManager.addSlot(notificationManager.SlotType.SERVICE_INFORMATION)
    } catch {
      // slot may already exist
    }
    try {
      await notificationManager.addSlot(notificationManager.SlotType.CONTENT_INFORMATION)
    } catch {
      // slot may already exist
    }
    const reminderOk = await ReminderService.ensureReminderPermission(context, true)
    if (!reminderOk) {
      ReminderService.lastError = '请允许「发布提醒」权限后再开启每日提醒'
      return false
    }
    return true
  }

  static async cancelDaily(): Promise<void> {
    let stored = AppStorage.get<number>(AGENT_ID_KEY) ?? 0
    if (stored <= 0) {
      stored = await VitalityStore.loadReminderAgentId()
    }
    if (stored > 0) {
      try {
        await reminderAgentManager.cancelReminder(stored)
      } catch {
        // ignore
      }
    }
    AppStorage.setOrCreate(AGENT_ID_KEY, 0)
    await VitalityStore.saveReminderAgentId(0)
  }

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

  private static async buildLaunchWantAgent(context: common.UIAbilityContext): Promise<object | null> {
    const info: wantAgent.WantAgentInfo = {
      wants: [{
        bundleName: context.applicationInfo.name,
        abilityName: ENTRY_ABILITY
      }],
      operationType: wantAgent.OperationType.START_ABILITY,
      requestCode: 88002,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    }
    return await new Promise<object | null>((resolve) => {
      try {
        wantAgent.getWantAgent(info, (err: Error, data: object) => {
          if (err) {
            resolve(null)
            return
          }
          resolve(data)
        })
      } catch {
        resolve(null)
      }
    })
  }

  private static async persistAgentId(agentId: number): Promise<boolean> {
    if (agentId <= 0) {
      return false
    }
    AppStorage.setOrCreate(AGENT_ID_KEY, agentId)
    await VitalityStore.saveReminderAgentId(agentId)
    return true
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
    const title = '活力纪行 · 记录提醒'
    const content = '今天过得怎样？用 3 秒记录你的活力状态吧。'
    const noticeId = 88002 + (profile.reminderHour * 10 + profile.reminderMinute)
    const deltaSec = Math.max(180, Math.min(Math.floor((fire.getTime() - Date.now()) / 1000), TIMER_MAX_SEC))
    const launchAgent = await ReminderService.buildLaunchWantAgent(context)

    const timerPlain = await ReminderService.publishTimer(deltaSec, title, content, noticeId, null)
    if (timerPlain) {
      ReminderService.lastError = `已预约 ${ReminderService.nextLabel(profile)} 提醒`
      return true
    }
    if (launchAgent !== null) {
      const timerAgent = await ReminderService.publishTimer(deltaSec, title, content, noticeId + 1, launchAgent)
      if (timerAgent) {
        ReminderService.lastError = `已预约 ${ReminderService.nextLabel(profile)} 提醒`
        return true
      }
    }
    const calendarPlain = await ReminderService.publishCalendar(profile, fire, title, content, noticeId + 2, null)
    if (calendarPlain) {
      ReminderService.lastError = `已预约每日 ${ReminderService.nextLabel(profile)} 提醒`
      return true
    }
    if (launchAgent !== null) {
      const calendarAgent = await ReminderService.publishCalendar(profile, fire, title, content, noticeId + 3, launchAgent)
      if (calendarAgent) {
        ReminderService.lastError = `已预约每日 ${ReminderService.nextLabel(profile)} 提醒`
        return true
      }
    }
    if (ReminderService.lastError.length === 0) {
      ReminderService.lastError = '提醒设置失败，请确认通知与发布提醒权限均已开启'
    }
    return false
  }

  private static async publishTimer(deltaSec: number, title: string, content: string,
    noticeId: number, agent: object | null): Promise<boolean> {
    try {
      if (agent !== null) {
        const req = new ReminderRequestTimerAgent()
        req.triggerTimeInSeconds = deltaSec
        req.title = title
        req.content = content
        req.notificationId = noticeId
        req.wantAgent = agent
        const agentId: number = await reminderAgentManager.publishReminder(
          req as reminderAgentManager.ReminderRequestTimer
        )
        return await ReminderService.persistAgentId(agentId)
      }
      const req = new ReminderRequestTimerPlain()
      req.triggerTimeInSeconds = deltaSec
      req.title = title
      req.content = content
      req.notificationId = noticeId
      const agentId: number = await reminderAgentManager.publishReminder(
        req as reminderAgentManager.ReminderRequestTimer
      )
      return await ReminderService.persistAgentId(agentId)
    } catch {
      if (ReminderService.lastError.length === 0) {
        ReminderService.lastError = '单次提醒创建失败'
      }
      return false
    }
  }

  private static async publishCalendar(profile: UserProfile, fire: Date, title: string,
    content: string, noticeId: number, agent: object | null): Promise<boolean> {
    try {
      if (agent !== null) {
        const req = new ReminderRequestCalendarAgent()
        req.dateTime.year = fire.getFullYear()
        req.dateTime.month = fire.getMonth() + 1
        req.dateTime.day = fire.getDate()
        req.dateTime.hour = profile.reminderHour
        req.dateTime.minute = profile.reminderMinute
        req.dateTime.second = 0
        req.title = title
        req.content = content
        req.notificationId = noticeId
        req.wantAgent = agent
        const agentId: number = await reminderAgentManager.publishReminder(
          req as reminderAgentManager.ReminderRequestCalendar
        )
        return await ReminderService.persistAgentId(agentId)
      }
      const req = new ReminderRequestCalendarPlain()
      req.dateTime.year = fire.getFullYear()
      req.dateTime.month = fire.getMonth() + 1
      req.dateTime.day = fire.getDate()
      req.dateTime.hour = profile.reminderHour
      req.dateTime.minute = profile.reminderMinute
      req.dateTime.second = 0
      req.title = title
      req.content = content
      req.notificationId = noticeId
      const agentId: number = await reminderAgentManager.publishReminder(
        req as reminderAgentManager.ReminderRequestCalendar
      )
      return await ReminderService.persistAgentId(agentId)
    } catch {
      return false
    }
  }

  static async syncFromProfile(context: common.UIAbilityContext): Promise<void> {
    const profile = await VitalityStore.loadProfile()
    if (profile.reminderEnabled) {
      await ReminderService.scheduleDaily(profile, context)
    } else {
      await ReminderService.cancelDaily()
    }
  }
}
