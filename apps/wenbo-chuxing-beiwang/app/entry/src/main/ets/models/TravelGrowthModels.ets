export class TravelFavorite {
  id: string = ''
  entityType: string = ''
  entityId: string = ''
  title: string = ''
  subtitle: string = ''
  createdAt: string = ''
}

export class PrepCheckInRecord {
  logDate: string = ''
  tripId: string = ''
  habitId: string = ''
}

export class TravelStatsSnapshot {
  tripCount: number = 0
  completedTrips: number = 0
  checklistDone: number = 0
  checklistTotal: number = 0
  favoriteCount: number = 0
  prepStreakDays: number = 0
  destinationCount: number = 0
  noteCount: number = 0
  reminderPending: number = 0
}

export class ActivityEvent {
  id: string = ''
  eventType: string = ''
  title: string = ''
  subtitle: string = ''
  occurredAt: string = ''
  tripId: string = ''
  entityId: string = ''
}

export class AchievementItem {
  key: string = ''
  title: string = ''
  description: string = ''
  unlocked: boolean = false
  unlockedAt: string = ''
  iconKey: string = 'check'
}

export class SearchResultItem {
  id: string = ''
  group: string = ''
  title: string = ''
  subtitle: string = ''
  entityType: string = ''
}

export class TripRecapItem {
  tripId: string = ''
  title: string = ''
  destination: string = ''
  startDate: string = ''
  endDate: string = ''
  progress: number = 0
  checklistDone: number = 0
  checklistTotal: number = 0
  itineraryCount: number = 0
  noteCount: number = 0
}

export class HabitRow {
  id: string = ''
  title: string = ''
  streakDays: number = 0
}

export class HabitLogRow {
  id: string = ''
  habitId: string = ''
  logDate: string = ''
}

export class CreateHabitRequest {
  title: string = ''
  description: string = ''
  targetDays: number = 21
  iconKey: string = 'check'
  userId: string = ''
}

export class CreateHabitLogRequest {
  habitId: string = ''
  userId: string = ''
  logDate: string = ''
}
