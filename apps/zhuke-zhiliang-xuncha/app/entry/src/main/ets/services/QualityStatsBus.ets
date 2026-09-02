import { QualityLocalStore } from './QualityLocalStore'

export class QualityStatsBus {
  static publish(): void {
    const s = QualityLocalStore.stats()
    AppStorage.setOrCreate('sqStatTodayInspect', s.todayInspect)
    AppStorage.setOrCreate('sqStatFoundToday', s.foundToday)
    AppStorage.setOrCreate('sqStatRectifying', s.rectifying)
    AppStorage.setOrCreate('sqStatClosed', s.closed)
    AppStorage.setOrCreate('sqStatMonthInspect', s.monthInspect)
    AppStorage.setOrCreate('sqStatMonthFound', s.monthFound)
    AppStorage.setOrCreate('sqStatMonthClosed', s.monthClosed)
    AppStorage.setOrCreate('sqProjectCount', QualityLocalStore.snapshot().projects.length)
    AppStorage.setOrCreate('sqInspectionCount', QualityLocalStore.snapshot().inspections.length)
    AppStorage.setOrCreate('sqIssueCount', QualityLocalStore.snapshot().issues.length)
  }
}
