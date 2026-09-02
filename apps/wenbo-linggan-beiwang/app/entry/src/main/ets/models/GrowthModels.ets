/** 灵感备忘 — 本机成长数据（打卡 / 专题 / 动态 / 最近 / 成就），按账号分桶 */

export class CheckInRecord {
  date: string = ''
  note: string = ''

  static of(date: string, note: string): CheckInRecord {
    const row = new CheckInRecord()
    row.date = date
    row.note = note
    return row
  }
}

export class TopicItem {
  id: string = ''
  title: string = ''
  summary: string = ''
  inspirationIds: string[] = []
  createdAt: string = ''
}

export class ActivityEvent {
  type: string = ''
  title: string = ''
  refKind: string = ''
  refId: string = ''
  at: string = ''
}

export class RecentBrowseItem {
  kind: string = ''
  id: string = ''
  title: string = ''
  at: string = ''
}

export class AchievementDef {
  id: string = ''
  title: string = ''
  hint: string = ''
}

export class GrowthPayload {
  checkIns: CheckInRecord[] = []
  topics: TopicItem[] = []
  activity: ActivityEvent[] = []
  recent: RecentBrowseItem[] = []
  unlocked: string[] = []
}
