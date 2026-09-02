import { WorkbenchSnapshot, TodoItem } from '../models/SaituGrowthModels'
import { SaituLocalStore } from './SaituLocalStore'
import { SaituTrackStore } from './SaituTrackStore'
import { SaituSportStore } from './SaituSportStore'
import { SaituCheckInStore } from './SaituCheckInStore'
import { SaituPlanStore } from './SaituPlanStore'
import { SaituAchievementStore } from './SaituAchievementStore'
import { SaituSearchService } from './SaituSearchService'
import { SaituTimelineService } from './SaituTimelineService'
import { DateHelper } from './DateHelper'

export class SaituWorkbenchService {
  static async loadSnapshot(): Promise<WorkbenchSnapshot> {
    const snap = new WorkbenchSnapshot()
    const profile = await SaituLocalStore.loadProfile()
    snap.nickname = profile.nickname
    const stats = await SaituLocalStore.dashboardStats()
    snap.totalRecords = stats.totalRecords
    snap.recordStreak = stats.streakDays
    snap.milestoneDone = stats.milestoneDone
    snap.milestoneTotal = stats.milestoneTotal
    snap.favoriteCount = await SaituSearchService.favoriteCount()
    snap.checkInStreak = await SaituCheckInStore.checkInStreak()
    snap.todayCheckedIn = await SaituCheckInStore.hasTodayCheckIn()
    snap.sportTotal = (await SaituSportStore.loadEvents()).length
    snap.trainingTotal = (await SaituSportStore.loadTrainings()).length
    snap.achievementUnlocked = await SaituAchievementStore.unlockedCount()
    snap.achievementTotal = SaituAchievementStore.defs().length

    const weekKeys = DateHelper.lastNDays(7)
    const weekStart = weekKeys[weekKeys.length - 1]
    const weekEnd = weekKeys[0]
    const weekRecords = await SaituLocalStore.recordsInRange(weekStart, weekEnd)
    snap.weekRecordCount = weekRecords.length
    const events = await SaituSportStore.loadEvents()
    let weekSport = 0
    for (const e of events) {
      if (e.eventDate >= weekStart && e.eventDate <= weekEnd) {
        weekSport++
      }
    }
    snap.weekSportCount = weekSport
    const trainings = await SaituSportStore.loadTrainings()
    let weekTrain = 0
    for (const t of trainings) {
      if (t.logDate >= weekStart && t.logDate <= weekEnd) {
        weekTrain++
      }
    }
    snap.weekTrainingCount = weekTrain

    const progress = await SaituLocalStore.journeyProgress()
    if (progress.length > 0) {
      snap.focusJourneyId = progress[0].journeyId
      snap.focusJourneyName = progress[0].name
      snap.focusJourneyColor = progress[0].color
      snap.focusProgress = progress[0].ratio
      snap.focusProgressLabel = progress[0].progressLabel
    }

    snap.todos = await SaituWorkbenchService.buildTodos()
    snap.recentTimeline = await SaituTimelineService.build(5)
    return snap
  }

  private static async buildTodos(): Promise<TodoItem[]> {
    const out: TodoItem[] = []
    const milestones = await SaituTrackStore.loadMilestones()
    for (const m of milestones) {
      if (!m.done) {
        const t = new TodoItem()
        t.id = m.id
        t.kind = 'milestone'
        t.title = m.title
        t.subtitle = '赛途节点未达成'
        t.refId = m.id
        t.journeyId = m.journeyId
        out.push(t)
        if (out.length >= 3) {
          break
        }
      }
    }

    const events = await SaituSportStore.loadEvents()
    for (const e of events) {
      if (e.kind === 'plan' && e.status === 'pending') {
        const t = new TodoItem()
        t.id = e.id
        t.kind = 'sport_plan'
        t.title = e.title.length > 0 ? e.title : '观赛计划'
        t.subtitle = '待关注'
        t.refId = e.id
        out.push(t)
        if (out.length >= 5) {
          break
        }
      }
    }

    const plans = await SaituPlanStore.activePlans()
    for (const p of plans) {
      const t = new TodoItem()
      t.id = p.id
      t.kind = 'journey_plan'
      t.title = p.title.length > 0 ? p.title : '赛途计划'
      t.subtitle = p.progressLabel()
      t.refId = p.id
      t.journeyId = p.journeyId
      out.push(t)
      if (out.length >= 6) {
        break
      }
    }
    return out
  }
}
