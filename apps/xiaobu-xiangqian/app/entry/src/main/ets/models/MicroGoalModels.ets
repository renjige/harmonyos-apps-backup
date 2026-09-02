export class MicroGoalItem {
  id: string = ''
  title: string = ''
  description: string = ''
  goalDate: string = ''
  category: string = '日常'
  status: string = 'pending'
  note: string = ''
  userId: string = ''
}

export class MicroGoalListData {
  list: MicroGoalItem[] = []
}

export class MicroGoalStats {
  streakDays: number = 0
  completionRate: number = 0
  totalDoneDays: number = 0
  monthDoneDays: number = 0
  monthTotalDays: number = 0
  todayTotal: number = 0
  todayDone: number = 0
}

export class InsightItem {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  category: string = ''
  readMinutes: number = 0
  coverKey: string = ''
}

export class InsightListData {
  list: InsightItem[] = []
}

export class AchievementItem {
  id: string = ''
  title: string = ''
  summary: string = ''
  description: string = ''
  thresholdDays: number = 0
  tier: string = ''
}

export class AchievementListData {
  list: AchievementItem[] = []
}

export class CreateMicroGoalBody {
  title: string = ''
  description: string = ''
  goalDate: string = ''
  category: string = '日常'
  userId: string = ''

  toJsonString(): string {
    return JSON.stringify({
      title: this.title,
      description: this.description,
      goalDate: this.goalDate,
      category: this.category,
      userId: this.userId,
    })
  }
}

export class CompleteMicroGoalBody {
  note: string = ''
  userId: string = ''

  toJsonString(): string {
    return JSON.stringify({ note: this.note, userId: this.userId })
  }
}

export class UserIdBody {
  userId: string = ''

  toJsonString(): string {
    return JSON.stringify({ userId: this.userId })
  }
}

export class CalendarMarksData {
  calendarMarks: Record<string, number> = {}
  categoryStats: Record<string, number> = {}
}

function mapMicroGoal(raw: object): MicroGoalItem {
  const r = raw as Record<string, string | number>
  const item = new MicroGoalItem()
  item.id = `${r['id'] ?? ''}`
  item.title = `${r['title'] ?? ''}`
  item.description = `${r['description'] ?? ''}`
  item.goalDate = `${r['goalDate'] ?? r['checkInDate'] ?? ''}`
  item.category = `${r['category'] ?? '日常'}`
  item.status = `${r['status'] ?? 'pending'}`
  item.note = `${r['note'] ?? ''}`
  item.userId = `${r['userId'] ?? ''}`
  return item
}

export function mapMicroGoals(list: object[]): MicroGoalItem[] {
  const out: MicroGoalItem[] = []
  for (const row of list) {
    out.push(mapMicroGoal(row))
  }
  return out
}

export function mapInsights(list: object[]): InsightItem[] {
  const out: InsightItem[] = []
  for (const row of list) {
    const r = row as Record<string, string | number>
    const item = new InsightItem()
    item.id = `${r['id'] ?? ''}`
    item.title = `${r['title'] ?? ''}`
    item.summary = `${r['summary'] ?? ''}`
    item.body = `${r['body'] ?? r['description'] ?? ''}`
    item.category = `${r['category'] ?? ''}`
    item.readMinutes = Number(r['readMinutes'] ?? 0)
    item.coverKey = `${r['coverKey'] ?? r['coverMedia'] ?? ''}`
    out.push(item)
  }
  return out
}

export function mapAchievements(list: object[]): AchievementItem[] {
  const out: AchievementItem[] = []
  for (const row of list) {
    const r = row as Record<string, string | number>
    const item = new AchievementItem()
    item.id = `${r['id'] ?? ''}`
    item.title = `${r['title'] ?? ''}`
    item.summary = `${r['summary'] ?? ''}`
    item.description = `${r['description'] ?? ''}`
    item.thresholdDays = Number(r['thresholdDays'] ?? 0)
    item.tier = `${r['tier'] ?? ''}`
    out.push(item)
  }
  return out
}
