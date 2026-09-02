import { ObserveRecord } from '../models/ObserveModels'
import { ObserveSubject } from '../models/ObserveCatalog'
import { CheckInService } from './CheckInService'
import { ObservePlanService } from './ObservePlanService'
import { ActivityTimelineService } from './ActivityTimelineService'
import { AchievementService } from './AchievementService'
import { ObserveStore } from './ObserveStore'

export class ObserveLifecycleService {
  static async afterRecordCreated(record: ObserveRecord): Promise<string[]> {
    const newCheckIn = await CheckInService.autoFromRecord()
    if (newCheckIn) {
      await ActivityTimelineService.onCheckIn()
    }
    await ObservePlanService.syncFromTodayRecords()
    await ActivityTimelineService.onRecordAdded(record)
    return await AchievementService.evaluateAll()
  }

  static async afterRecordUpdated(record: ObserveRecord): Promise<string[]> {
    await ObservePlanService.syncFromTodayRecords()
    await ActivityTimelineService.onRecordUpdated(record)
    return await AchievementService.evaluateAll()
  }

  static async afterFavoriteToggle(recordId: string): Promise<string[]> {
    const found = await ObserveStore.findById(recordId)
    if (found === undefined) {
      return []
    }
    if (found.favorited) {
      await ActivityTimelineService.onFavorite(found, true)
    }
    return await AchievementService.evaluateAll()
  }

  static async afterManualCheckIn(): Promise<string[]> {
    await CheckInService.checkInToday()
    await ActivityTimelineService.onCheckIn()
    await ObservePlanService.syncFromTodayRecords()
    return await AchievementService.evaluateAll()
  }

  static async afterSubjectCreated(subject: ObserveSubject): Promise<string[]> {
    await ActivityTimelineService.onSubjectCreated(subject)
    return await AchievementService.evaluateAll()
  }
}
