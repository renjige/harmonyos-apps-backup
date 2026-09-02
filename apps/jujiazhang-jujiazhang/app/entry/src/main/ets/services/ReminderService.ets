import { reminderAgentManager } from '@kit.BackgroundTasksKit'
import { notificationManager } from '@kit.NotificationKit'
import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit'
import { FamilyTaskItem, TaskDates } from '../models/FamilyTaskModels'
import { HomeItem, MaintenanceJob } from '../models/JujiaModels'
import { JujiaLocalStore } from './JujiaLocalStore'
import { TaskLocalStore } from './TaskLocalStore'
import { ItemService } from './ItemService'
import { TaskService } from './TaskService'
import { MaintenanceService } from './MaintenanceService'

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
  daysOfWeek?: number[]
  daysOfMonth?: number[]
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

export class ReminderService {
  static lastError: string = ''
  static lastAction: string = ''

  static notifyEnabled(): boolean {
    return AppStorage.get<boolean>('notifyEnabled') !== false
  }

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

  static async ensurePermission(context: common.UIAbilityContext, request: boolean = true): Promise<boolean> {
    try {
      const enabled = await notificationManager.isNotificationEnabled()
      if (!enabled) {
        if (!request) {
          return false
        }
        await notificationManager.requestEnableNotification(context)
        if (!(await notificationManager.isNotificationEnabled())) {
          ReminderService.lastError = '请在系统设置中允许通知'
          return false
        }
      }
      const reminderOk = await ReminderService.ensureReminderPermission(context, request)
      if (!reminderOk) {
        ReminderService.lastError = '请允许发布系统提醒权限'
        return false
      }
      return true
    } catch {
      ReminderService.lastError = '请在系统设置中允许通知与发布提醒'
      return false
    }
  }

  static notificationId(prefix: number, id: string): number {
    let hash = prefix
    for (let i = 0; i < id.length; i++) {
      hash = (hash * 31 + id.charCodeAt(i)) % 80000
    }
    return hash + 21000
  }

  static async cancelAgent(agentId: number): Promise<void> {
    if (agentId <= 0) {
      return
    }
    try {
      await reminderAgentManager.cancelReminder(agentId)
    } catch {
    }
  }

  static async publishNow(title: string, text: string): Promise<boolean> {
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
      ReminderService.lastAction = '已发送通知'
      return true
    } catch {
      ReminderService.lastError = '发送通知失败，请允许通知权限'
      return false
    }
  }

  static itemFireAt(item: HomeItem): Date | null {
    if (item.expiryDate.length < 8) {
      return null
    }
    const parts = item.expiryDate.split('-')
    if (parts.length < 3) {
      return null
    }
    const fire = new Date(Number.parseInt(parts[0]), Number.parseInt(parts[1]) - 1, Number.parseInt(parts[2]), 9, 0, 0)
    fire.setDate(fire.getDate() - item.remindLeadDays)
    return fire
  }

  static taskFireAt(item: FamilyTaskItem): Date | null {
    if (item.reminder === 'none' || item.date.length < 8) {
      return null
    }
    const d = TaskDates.parse(item.date)
    let hour = 9
    let minute = 0
    if (item.time.length >= 5) {
      const tp = item.time.split(':')
      hour = Number.parseInt(tp[0])
      minute = Number.parseInt(tp[1])
    }
    d.setHours(hour, minute, 0, 0)
    const ahead = Number.parseInt(item.reminder)
    if (!Number.isNaN(ahead) && ahead > 0) {
      d.setMinutes(d.getMinutes() - ahead)
    }
    return d
  }

  static async scheduleTimer(seconds: number, title: string, content: string, noticeId: number): Promise<number> {
    const req = new ReminderRequestTimerWrapper()
    req.triggerTimeInSeconds = Math.max(15, Math.min(seconds, TIMER_MAX_SEC))
    req.title = title
    req.content = content
    req.expiredContent = `${title}（已过期）`
    req.snoozeContent = '稍后提醒'
    req.notificationId = noticeId
    try {
      return await reminderAgentManager.publishReminder(req as reminderAgentManager.ReminderRequestTimer)
    } catch {
      return 0
    }
  }

  static async scheduleCalendar(fire: Date, title: string, content: string, noticeId: number,
    daysOfWeek: number[]): Promise<number> {
    const req = new ReminderRequestCalendarWrapper()
    req.dateTime.year = fire.getFullYear()
    req.dateTime.month = fire.getMonth() + 1
    req.dateTime.day = fire.getDate()
    req.dateTime.hour = fire.getHours()
    req.dateTime.minute = fire.getMinutes()
    req.dateTime.second = 0
    req.title = title
    req.content = content
    req.expiredContent = `${title}（已过期）`
    req.snoozeContent = '稍后提醒'
    req.notificationId = noticeId
    if (daysOfWeek.length > 0) {
      req.daysOfWeek = daysOfWeek
    } else {
      req.daysOfMonth = [fire.getDate()]
    }
    try {
      return await reminderAgentManager.publishReminder(req as reminderAgentManager.ReminderRequestCalendar)
    } catch {
      return 0
    }
  }

  static async scheduleAt(fire: Date, title: string, content: string, noticeId: number,
    daysOfWeek: number[]): Promise<number> {
    const deltaSec = Math.floor((fire.getTime() - Date.now()) / 1000)
    if (deltaSec <= 0) {
      return 0
    }
    if (daysOfWeek.length === 0 && deltaSec <= TIMER_MAX_SEC) {
      const timerId = await ReminderService.scheduleTimer(deltaSec, title, content, noticeId)
      if (timerId > 0) {
        return timerId
      }
    }
    const calendarId = await ReminderService.scheduleCalendar(fire, title, content, noticeId, daysOfWeek)
    if (calendarId > 0) {
      return calendarId
    }
    if (daysOfWeek.length === 0 && deltaSec <= TIMER_MAX_SEC) {
      return await ReminderService.scheduleTimer(deltaSec, title, content, noticeId)
    }
    return 0
  }

  static formatFireTime(fire: Date): string {
    return `${fire.getMonth() + 1}月${fire.getDate()}日 ${TaskDates.pad(fire.getHours())}:${TaskDates.pad(fire.getMinutes())}`
  }

  static async deliverDueReminders(context: common.UIAbilityContext): Promise<void> {
    if (!ReminderService.notifyEnabled()) {
      return
    }
    const today = TaskDates.today()
    const items = await ItemService.list()
    for (const row of items) {
      const fire = ReminderService.itemFireAt(row)
      if (fire === null) {
        continue
      }
      const dueSoon = row.daysUntilExpiry() <= row.remindLeadDays || row.isExpiringSoon()
      if (fire.getTime() <= Date.now()) {
        if (dueSoon && !JujiaLocalStore.wasFiredToday(`item_${row.id}`, today)) {
          const title = '居家章 · 到期提醒'
          const content = `${row.name} ${row.expiryLabel()}，请及时处理`
          const sent = await ReminderService.publishNow(title, content)
          if (sent) {
            await JujiaLocalStore.markFired(`item_${row.id}`, today)
          }
        }
        continue
      }
      if (row.reminderAgentId <= 0) {
        await ReminderService.scheduleItem(row, context, false)
      }
    }
    const tasks = TaskLocalStore.tasks()
    for (const row of tasks) {
      if (row.completed || row.reminder === 'none') {
        continue
      }
      const fire = ReminderService.taskFireAt(row)
      if (fire === null) {
        continue
      }
      if (fire.getTime() <= Date.now()) {
        if (!JujiaLocalStore.wasFiredToday(`task_${row.id}`, today)) {
          const title = '居家章 · 计划提醒'
          const who = row.assignee.length > 0 ? `${row.assignee}：` : ''
          const content = `${who}${row.title}`
          const sent = await ReminderService.publishNow(title, content)
          if (sent) {
            await JujiaLocalStore.markFired(`task_${row.id}`, today)
          }
        }
        continue
      }
      if (row.reminderAgentId <= 0) {
        await ReminderService.scheduleTask(row, context, false)
      }
    }
  }

  static async scheduleItem(item: HomeItem, context: common.UIAbilityContext,
    requestPerm: boolean = true): Promise<boolean> {
    ReminderService.lastError = ''
    ReminderService.lastAction = ''
    if (!ReminderService.notifyEnabled() || item.expiryDate.length < 8) {
      await ReminderService.cancelAgent(item.reminderAgentId)
      item.reminderAgentId = 0
      ReminderService.lastAction = '已登记'
      return true
    }
    const ok = await ReminderService.ensurePermission(context, requestPerm)
    if (!ok) {
      ReminderService.lastAction = '已登记；请允许通知与发布提醒后，在看板点「试响通道」验证'
      return true
    }
    await ReminderService.cancelAgent(item.reminderAgentId)
    item.reminderAgentId = 0
    const fire = ReminderService.itemFireAt(item)
    if (fire === null) {
      ReminderService.lastAction = '已登记'
      return true
    }
    const title = '居家章 · 到期提醒'
    const content = `${item.name} ${item.expiryLabel()}，请及时处理`
    const today = TaskDates.today()
    const dueSoon = item.daysUntilExpiry() <= item.remindLeadDays || item.isExpiringSoon()
    if (fire.getTime() <= Date.now()) {
      if (dueSoon && !JujiaLocalStore.wasFiredToday(`item_${item.id}`, today)) {
        const sent = await ReminderService.publishNow(title, content)
        if (sent) {
          await JujiaLocalStore.markFired(`item_${item.id}`, today)
          ReminderService.lastAction = '已登记 · 到期提醒已送达通知栏'
        } else {
          ReminderService.lastAction = '已登记 · 到期提醒待发送，请允许通知权限'
        }
      } else {
        ReminderService.lastAction = '已登记'
      }
      await ItemService.update(item)
      return true
    }
    const agentId = await ReminderService.scheduleAt(fire, title, content,
      ReminderService.notificationId(11, item.id), [])
    item.reminderAgentId = agentId
    await ItemService.update(item)
    if (agentId > 0) {
      ReminderService.lastAction =
        `已登记 · 已预约 ${ReminderService.formatFireTime(fire)} 系统提醒`
      return true
    }
    ReminderService.lastAction =
      `已登记 · 将在 ${ReminderService.formatFireTime(fire)} 推送通知（请保持通知与提醒权限开启；可点看板「试响通道」验证）`
    return true
  }

  static async scheduleTask(item: FamilyTaskItem, context: common.UIAbilityContext,
    requestPerm: boolean = true): Promise<boolean> {
    ReminderService.lastError = ''
    ReminderService.lastAction = ''
    if (!ReminderService.notifyEnabled() || item.completed || item.reminder === 'none') {
      await ReminderService.cancelAgent(item.reminderAgentId)
      item.reminderAgentId = 0
      return false
    }
    const ok = await ReminderService.ensurePermission(context, requestPerm)
    if (!ok) {
      return false
    }
    await ReminderService.cancelAgent(item.reminderAgentId)
    item.reminderAgentId = 0
    const fire = ReminderService.taskFireAt(item)
    if (fire === null) {
      return false
    }
    const title = '居家章 · 计划提醒'
    const who = item.assignee.length > 0 ? `${item.assignee}：` : ''
    const content = `${who}${item.title}`
    const today = TaskDates.today()
    if (fire.getTime() <= Date.now()) {
      if (!JujiaLocalStore.wasFiredToday(`task_${item.id}`, today)) {
        const sent = await ReminderService.publishNow(title, content)
        if (sent) {
          await JujiaLocalStore.markFired(`task_${item.id}`, today)
          ReminderService.lastAction = '计划提醒已送达通知栏'
        }
      }
      await TaskService.update(item)
      return true
    }
    const week: number[] = []
    if (item.repeatType === 'daily') {
      week.push(1, 2, 3, 4, 5, 6, 7)
    } else if (item.repeatType === 'weekly') {
      const d = fire.getDay()
      week.push(d === 0 ? 7 : d)
    }
    const agentId = await ReminderService.scheduleAt(fire, title, content,
      ReminderService.notificationId(22, item.id), week)
    item.reminderAgentId = agentId
    await TaskService.update(item)
    if (agentId > 0) {
      ReminderService.lastAction =
        `已预约 ${ReminderService.formatFireTime(fire)} 系统提醒`
      return true
    }
    ReminderService.lastAction =
      `将在 ${ReminderService.formatFireTime(fire)} 推送通知（请保持通知与提醒权限开启）`
    return true
  }

  static async testRing(context: common.UIAbilityContext, name: string): Promise<boolean> {
    ReminderService.lastError = ''
    const ok = await ReminderService.ensurePermission(context)
    if (!ok) {
      return false
    }
    const title = '居家章 · 到期提醒试响'
    const content = name.length > 0 ? `${name} 到期提醒已接通，1 分钟后将再次提醒` : '到期提醒通道正常'
    await ReminderService.publishNow(title, content)
    const agentId = await ReminderService.scheduleTimer(60, '居家章 · 到期提醒',
      name.length > 0 ? `${name} 到达提醒时间，请及时处理` : '到达提醒时间，请及时处理', 20999)
    if (agentId > 0) {
      ReminderService.lastAction = '已立即通知，并预约 1 分钟后再次提醒'
      return true
    }
    ReminderService.lastAction = '已立即发送通知；若 1 分钟后未收到，请在系统设置允许后台与提醒'
    return true
  }

  static maintenanceFireAt(job: MaintenanceJob): Date | null {
    if (job.nextDueDate.length < 8) {
      return null
    }
    const parts = job.nextDueDate.split('-')
    if (parts.length < 3) {
      return null
    }
    return new Date(Number.parseInt(parts[0]), Number.parseInt(parts[1]) - 1, Number.parseInt(parts[2]), 9, 0, 0)
  }

  static async scheduleMaintenance(job: MaintenanceJob, context: common.UIAbilityContext,
    requestPerm: boolean = true): Promise<boolean> {
    ReminderService.lastError = ''
    ReminderService.lastAction = ''
    if (!ReminderService.notifyEnabled() || job.nextDueDate.length < 8) {
      await ReminderService.cancelAgent(job.reminderAgentId)
      job.reminderAgentId = 0
      ReminderService.lastAction = '维护提醒已保存'
      return true
    }
    const ok = await ReminderService.ensurePermission(context, requestPerm)
    if (!ok) {
      ReminderService.lastAction = '已保存；请允许通知与发布提醒'
      return true
    }
    await ReminderService.cancelAgent(job.reminderAgentId)
    job.reminderAgentId = 0
    const fire = ReminderService.maintenanceFireAt(job)
    if (fire === null) {
      ReminderService.lastAction = '维护提醒已保存'
      return true
    }
    const title = '居家章 · 维护提醒'
    const content = `${job.title}（${job.room}）到期维护，请及时处理`
    if (fire.getTime() <= Date.now()) {
      await ReminderService.publishNow(title, content)
      ReminderService.lastAction = '维护提醒已送达通知栏'
      await MaintenanceService.update(job)
      return true
    }
    const agentId = await ReminderService.scheduleAt(fire, title, content,
      ReminderService.notificationId(33, job.id), [])
    job.reminderAgentId = agentId
    await MaintenanceService.update(job)
    if (agentId > 0) {
      ReminderService.lastAction = `已预约 ${ReminderService.formatFireTime(fire)} 维护提醒`
      return true
    }
    ReminderService.lastAction = `将在 ${ReminderService.formatFireTime(fire)} 推送维护通知`
    return true
  }

  static async cancelMaintenance(job: MaintenanceJob): Promise<void> {
    await ReminderService.cancelAgent(job.reminderAgentId)
    job.reminderAgentId = 0
  }

  static async cancelItem(item: HomeItem): Promise<void> {
    await ReminderService.cancelAgent(item.reminderAgentId)
    item.reminderAgentId = 0
  }

  static async cancelTask(item: FamilyTaskItem): Promise<void> {
    await ReminderService.cancelAgent(item.reminderAgentId)
    item.reminderAgentId = 0
  }

  static async syncAll(context: common.UIAbilityContext): Promise<void> {
    if (!ReminderService.notifyEnabled()) {
      return
    }
    await ReminderService.deliverDueReminders(context)
    const items = await ItemService.list()
    for (const row of items) {
      await ReminderService.scheduleItem(row, context, false)
    }
    const tasks = TaskLocalStore.tasks()
    for (const row of tasks) {
      await ReminderService.scheduleTask(row, context, false)
    }
    const jobs = await MaintenanceService.list()
    for (const row of jobs) {
      await ReminderService.scheduleMaintenance(row, context, false)
    }
  }

  static async cancelAll(): Promise<void> {
    const items = await ItemService.list()
    for (const row of items) {
      await ReminderService.cancelItem(row)
      await ItemService.update(row)
    }
    const tasks = TaskLocalStore.tasks()
    for (const row of tasks) {
      await ReminderService.cancelTask(row)
      await TaskService.update(row)
    }
  }
}
