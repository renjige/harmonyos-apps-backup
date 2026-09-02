import { reminderAgentManager } from '@kit.BackgroundTasksKit'
import { notificationManager } from '@kit.NotificationKit'
import { abilityAccessCtrl, common, Permissions, wantAgent } from '@kit.AbilityKit'
import { StudyReminder } from '../models/ZhixingModels'
import { ZhixingStore } from './ZhixingStore'

const ENTRY_ABILITY = 'EntryAbility'
const MIN_LEAD_MS = 3 * 60 * 1000
const TIMER_MAX_SEC = 7 * 24 * 3600

class ReminderCalendarDateTime {
  year: number = 2026
  month: number = 1
  day: number = 1
  hour: number = 21
  minute: number = 0
  second: number = 0
}

class ReminderRequestCalendarPlain {
  reminderType: reminderAgentManager.ReminderType =
    reminderAgentManager.ReminderType.REMINDER_TYPE_CALENDAR
  dateTime: ReminderCalendarDateTime = new ReminderCalendarDateTime()
  title: string = ''
  content: string = ''
  expiredContent: string = '知行页 · 学习提醒已过期'
  snoozeContent: string = '稍后提醒'
  notificationId: number = 26108
  slotType: notificationManager.SlotType = notificationManager.SlotType.SERVICE_INFORMATION
  daysOfWeek: number[] = [1, 2, 3, 4, 5, 6, 7]
}

class ReminderRequestCalendarAgent {
  reminderType: reminderAgentManager.ReminderType =
    reminderAgentManager.ReminderType.REMINDER_TYPE_CALENDAR
  dateTime: ReminderCalendarDateTime = new ReminderCalendarDateTime()
  title: string = ''
  content: string = ''
  expiredContent: string = '知行页 · 学习提醒已过期'
  snoozeContent: string = '稍后提醒'
  notificationId: number = 26108
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
  expiredContent: string = '知行页 · 学习提醒已过期'
  snoozeContent: string = '稍后提醒'
  notificationId: number = 26118
  slotType: notificationManager.SlotType = notificationManager.SlotType.SERVICE_INFORMATION
}

class ReminderRequestTimerAgent {
  reminderType: reminderAgentManager.ReminderType =
    reminderAgentManager.ReminderType.REMINDER_TYPE_TIMER
  triggerTimeInSeconds: number = 3600
  title: string = ''
  content: string = ''
  expiredContent: string = '知行页 · 学习提醒已过期'
  snoozeContent: string = '稍后提醒'
  notificationId: number = 26118
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
        ReminderService.lastError = '请在系统设置中开启通知权限'
        return false
      }
    } catch {
      ReminderService.lastError = '请在系统设置中开启通知权限'
      return false
    }
    try {
      await notificationManager.addSlot(notificationManager.SlotType.SERVICE_INFORMATION)
    } catch {
      // slot may exist
    }
    try {
      await notificationManager.addSlot(notificationManager.SlotType.CONTENT_INFORMATION)
    } catch {
      // slot may exist
    }
    const reminderOk = await ReminderService.ensureReminderPermission(context, true)
    if (!reminderOk) {
      ReminderService.lastError = '请允许「发布提醒」权限后再开启学习提醒'
      return false
    }
    return true
  }

  static async cancel(): Promise<void> {
    const stored = await ZhixingStore.loadReminder()
    if (stored.agentId > 0) {
      try {
        await reminderAgentManager.cancelReminder(stored.agentId)
      } catch {
        // ignore
      }
    }
    stored.agentId = 0
    await ZhixingStore.saveReminder(stored)
  }

  private static buildFireDate(profile: StudyReminder): Date {
    const fire = new Date()
    fire.setHours(profile.hour, profile.minute, 0, 0)
    if (fire.getTime() - Date.now() < MIN_LEAD_MS) {
      fire.setDate(fire.getDate() + 1)
    }
    return fire
  }

  static nextLabel(profile: StudyReminder): string {
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
      requestCode: 26108,
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

  static async apply(profile: StudyReminder, context: common.UIAbilityContext): Promise<boolean> {
    ReminderService.lastError = ''
    if (!profile.enabled) {
      await ReminderService.cancel()
      profile.agentId = 0
      await ZhixingStore.saveReminder(profile)
      return true
    }
    const okPerm = await ReminderService.ensurePermission(context)
    if (!okPerm) {
      return false
    }
    await ReminderService.cancel()
    const fire = ReminderService.buildFireDate(profile)
    const title = '知行页 · 学习提醒'
    const content = '到点了：把今天学到的写成卡片，或给计划打卡一次。'
    const noticeBase = 26108 + (profile.hour * 10 + profile.minute)
    const deltaSec = Math.max(180, Math.min(Math.floor((fire.getTime() - Date.now()) / 1000), TIMER_MAX_SEC))
    const launchAgent = await ReminderService.buildLaunchWantAgent(context)

    if (await ReminderService.publishTimer(profile, deltaSec, title, content, noticeBase, null)) {
      ReminderService.lastError = `已预约 ${ReminderService.nextLabel(profile)} 提醒，不会立即弹出`
      return true
    }
    if (launchAgent !== null &&
      await ReminderService.publishTimer(profile, deltaSec, title, content, noticeBase + 1, launchAgent)) {
      ReminderService.lastError = `已预约 ${ReminderService.nextLabel(profile)} 提醒，不会立即弹出`
      return true
    }
    if (await ReminderService.publishCalendar(profile, fire, title, content, noticeBase + 2, null)) {
      ReminderService.lastError = `已预约每日 ${ReminderService.nextLabel(profile)} 提醒，不会立即弹出`
      return true
    }
    if (launchAgent !== null &&
      await ReminderService.publishCalendar(profile, fire, title, content, noticeBase + 3, launchAgent)) {
      ReminderService.lastError = `已预约每日 ${ReminderService.nextLabel(profile)} 提醒，不会立即弹出`
      return true
    }
    if (ReminderService.lastError.length === 0) {
      ReminderService.lastError = '提醒设置失败，请确认通知与发布提醒权限均已开启'
    }
    return false
  }

  private static async publishTimer(profile: StudyReminder, deltaSec: number, title: string,
    content: string, noticeId: number, agent: object | null): Promise<boolean> {
    try {
      let agentId = 0
      if (agent !== null) {
        const req = new ReminderRequestTimerAgent()
        req.triggerTimeInSeconds = deltaSec
        req.title = title
        req.content = content
        req.notificationId = noticeId
        req.wantAgent = agent
        agentId = await reminderAgentManager.publishReminder(
          req as reminderAgentManager.ReminderRequestTimer
        )
      } else {
        const req = new ReminderRequestTimerPlain()
        req.triggerTimeInSeconds = deltaSec
        req.title = title
        req.content = content
        req.notificationId = noticeId
        agentId = await reminderAgentManager.publishReminder(
          req as reminderAgentManager.ReminderRequestTimer
        )
      }
      if (agentId <= 0) {
        return false
      }
      profile.agentId = agentId
      await ZhixingStore.saveReminder(profile)
      return true
    } catch {
      return false
    }
  }

  private static async publishCalendar(profile: StudyReminder, fire: Date, title: string,
    content: string, noticeId: number, agent: object | null): Promise<boolean> {
    try {
      let agentId = 0
      if (agent !== null) {
        const req = new ReminderRequestCalendarAgent()
        req.dateTime.year = fire.getFullYear()
        req.dateTime.month = fire.getMonth() + 1
        req.dateTime.day = fire.getDate()
        req.dateTime.hour = profile.hour
        req.dateTime.minute = profile.minute
        req.dateTime.second = 0
        req.title = title
        req.content = content
        req.notificationId = noticeId
        req.wantAgent = agent
        agentId = await reminderAgentManager.publishReminder(
          req as reminderAgentManager.ReminderRequestCalendar
        )
      } else {
        const req = new ReminderRequestCalendarPlain()
        req.dateTime.year = fire.getFullYear()
        req.dateTime.month = fire.getMonth() + 1
        req.dateTime.day = fire.getDate()
        req.dateTime.hour = profile.hour
        req.dateTime.minute = profile.minute
        req.dateTime.second = 0
        req.title = title
        req.content = content
        req.notificationId = noticeId
        agentId = await reminderAgentManager.publishReminder(
          req as reminderAgentManager.ReminderRequestCalendar
        )
      }
      if (agentId <= 0) {
        return false
      }
      profile.agentId = agentId
      await ZhixingStore.saveReminder(profile)
      return true
    } catch {
      return false
    }
  }
}
