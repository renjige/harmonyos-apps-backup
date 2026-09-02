export class HomeItem {
  id: string = ''
  name: string = ''
  category: string = '其他'
  purchaseDate: string = ''
  expiryDate: string = ''
  location: string = ''
  remark: string = ''
  room: string = ''
  customTag: string = ''
  remindLeadDays: number = 0
  reminderAgentId: number = 0
  userId: string = ''
  createdAt: string = ''
  updatedAt: string = ''

  coverKey(): string {
    if (this.category === '家电') {
      return 'item_appliance'
    }
    if (this.category === '药品') {
      return 'item_medicine'
    }
    if (this.category === '证件') {
      return 'item_document'
    }
    return 'item_other'
  }

  daysUntilExpiry(): number {
    if (this.expiryDate.length < 8) {
      return 9999
    }
    const today = new Date()
    today.setHours(0, 0, 0, 0)
    const parts = this.expiryDate.split('-')
    if (parts.length < 3) {
      return 9999
    }
    const exp = new Date(Number.parseInt(parts[0]), Number.parseInt(parts[1]) - 1, Number.parseInt(parts[2]))
    const diff = exp.getTime() - today.getTime()
    return Math.floor(diff / 86400000)
  }

  expiryLabel(): string {
    const d = this.daysUntilExpiry()
    if (d < 0) {
      return '已过期'
    }
    if (d === 0) {
      return '今日到期'
    }
    if (d <= 7) {
      return `${d} 天后到期`
    }
    if (d <= 30) {
      return `${d} 天后到期`
    }
    return this.expiryDate
  }

  isExpiringSoon(): boolean {
    const d = this.daysUntilExpiry()
    return d >= 0 && d <= 30
  }

  remindLeadLabel(): string {
    if (this.remindLeadDays <= 0) {
      return '到期当天上午 9 点系统通知'
    }
    return `到期前 ${this.remindLeadDays} 天上午 9 点系统通知`
  }
}

export class FamilyMember {
  id: string = ''
  name: string = ''
  role: string = '家人'
}

export class DutySlot {
  weekday: number = 1
  chore: string = ''
  memberId: string = ''
  memberName: string = ''
}

export class SceneTip {
  id: string = ''
  title: string = ''
  body: string = ''
  action: string = 'tasks'
}

export class FiredRecord {
  key: string = ''
  day: string = ''
}

export class FamilyMemo {
  id: string = ''
  title: string = ''
  body: string = ''
  tag: string = '采购'
  pinned: boolean = false
  userId: string = ''
  createdAt: string = ''
  updatedAt: string = ''

  coverKey(): string {
    if (this.tag === '采购') {
      return 'memo_shop'
    }
    if (this.tag === '出行') {
      return 'memo_travel'
    }
    if (this.tag === '维修') {
      return 'memo_repair'
    }
    return 'memo_other'
  }
}

export class JujiaBundleWire {
  tasks: object[] = []
  items: object[] = []
  memos: object[] = []
  members: object[] = []
  duties: object[] = []
  fired: object[] = []
  checklists: object[] = []
  diaries: object[] = []
  maintenance: object[] = []
}

export class ChecklistLine {
  id: string = ''
  text: string = ''
  done: boolean = false
}

export class ChecklistPack {
  id: string = ''
  title: string = ''
  kind: string = '日用品'
  lines: ChecklistLine[] = []
  userId: string = ''
  createdAt: string = ''
  updatedAt: string = ''

  doneCount(): number {
    let n = 0
    for (const row of this.lines) {
      if (row.done) {
        n += 1
      }
    }
    return n
  }

  progressLabel(): string {
    if (this.lines.length === 0) {
      return '0/0'
    }
    return `${this.doneCount()}/${this.lines.length}`
  }
}

export class DiaryEntry {
  id: string = ''
  title: string = ''
  body: string = ''
  mood: string = '平常'
  userId: string = ''
  createdAt: string = ''
  updatedAt: string = ''
}

export class MaintenanceJob {
  id: string = ''
  title: string = ''
  room: string = '客厅'
  cycleDays: number = 90
  lastDoneDate: string = ''
  nextDueDate: string = ''
  remark: string = ''
  reminderAgentId: number = 0
  userId: string = ''
  createdAt: string = ''
  updatedAt: string = ''
}

export class KnowledgeArticle {
  id: string = ''
  category: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
}

export class ChecklistKindOption {
  label: string = ''
  value: string = ''

  static all(): ChecklistKindOption[] {
    const kinds = ['搬家', '清洁', '装修', '日用品']
    const out: ChecklistKindOption[] = []
    for (const k of kinds) {
      const row = new ChecklistKindOption()
      row.label = k
      row.value = k
      out.push(row)
    }
    return out
  }
}

export class RoomOption {
  label: string = ''
  value: string = ''

  static all(): RoomOption[] {
    const rooms = ['客厅', '卧室', '厨房', '阳台', '其他']
    const out: RoomOption[] = []
    for (const r of rooms) {
      const row = new RoomOption()
      row.label = r
      row.value = r
      out.push(row)
    }
    return out
  }
}

export class ItemTagOption {
  label: string = ''
  value: string = ''

  static all(): ItemTagOption[] {
    const tags = ['厨房用品', '季节用品', '贵重物品', '常用物品', '其他']
    const out: ItemTagOption[] = []
    for (const t of tags) {
      const row = new ItemTagOption()
      row.label = t
      row.value = t
      out.push(row)
    }
    return out
  }
}

export class MaintenanceCycleOption {
  label: string = ''
  days: number = 90

  static all(): MaintenanceCycleOption[] {
    const out: MaintenanceCycleOption[] = []
    const labels = ['每 30 天', '每 90 天', '每 180 天', '每 365 天']
    const days = [30, 90, 180, 365]
    for (let i = 0; i < labels.length; i++) {
      const row = new MaintenanceCycleOption()
      row.label = labels[i]
      row.days = days[i]
      out.push(row)
    }
    return out
  }
}

export class FamilyStatsSnapshot {
  taskTotal: number = 0
  taskDone: number = 0
  itemTotal: number = 0
  memoTotal: number = 0
  checklistTotal: number = 0
  diaryTotal: number = 0
  maintenanceTotal: number = 0
  memberTotal: number = 0
  favoriteTotal: number = 0
  streakDays: number = 0
  weekDone: number = 0
}

export class FavoriteRecord {
  id: string = ''
  targetType: string = 'task'
  targetId: string = ''
  title: string = ''
  createdAt: string = ''
}

export class ActivityEvent {
  id: string = ''
  kind: string = 'create'
  entityType: string = 'task'
  entityId: string = ''
  title: string = ''
  summary: string = ''
  occurredAt: string = ''
}

export class CheckInRecord {
  date: string = ''
  taskDoneCount: number = 0
}

export class AchievementDef {
  code: string = ''
  title: string = ''
  description: string = ''
  iconName: string = 'check'
}

export class AchievementState {
  code: string = ''
  unlockedAt: string = ''
}

export class FamilyGoal {
  id: string = ''
  title: string = ''
  targetCount: number = 10
  currentCount: number = 0
  unit: string = '项'
  status: string = 'active'
  startDate: string = ''
  endDate: string = ''
  createdAt: string = ''
  updatedAt: string = ''

  progressPercent(): number {
    if (this.targetCount <= 0) {
      return 0
    }
    const n = Math.round((this.currentCount * 100) / this.targetCount)
    return n > 100 ? 100 : n
  }

  progressLabel(): string {
    return `${this.currentCount}/${this.targetCount} ${this.unit}`
  }
}

export class SearchHit {
  entityType: string = 'task'
  entityId: string = ''
  title: string = ''
  subtitle: string = ''
  tag: string = ''
}

export class GrowthWire {
  favorites: object[] = []
  activities: object[] = []
  checkins: object[] = []
  achievements: object[] = []
  goals: object[] = []
}

export class CreateItemBody {
  name: string = ''
  category: string = '其他'
  purchaseDate: string = ''
  expiryDate: string = ''
  location: string = ''
  remark: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"name":${JSON.stringify(this.name)},"category":${JSON.stringify(this.category)},"purchaseDate":${JSON.stringify(this.purchaseDate)},"expiryDate":${JSON.stringify(this.expiryDate)},"location":${JSON.stringify(this.location)},"remark":${JSON.stringify(this.remark)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class CreateMemoBody {
  title: string = ''
  body: string = ''
  tag: string = '采购'
  pinned: boolean = false
  userId: string = ''

  toJsonString(): string {
    const pin = this.pinned ? 'true' : 'false'
    return `{"title":${JSON.stringify(this.title)},"body":${JSON.stringify(this.body)},"tag":${JSON.stringify(this.tag)},"pinned":${pin},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class ItemCategoryOption {
  label: string = ''
  value: string = ''

  static all(): ItemCategoryOption[] {
    const out: ItemCategoryOption[] = []
    const labels = ['家电', '药品', '证件', '其他']
    for (const label of labels) {
      const row = new ItemCategoryOption()
      row.label = label
      row.value = label
      out.push(row)
    }
    return out
  }
}

export class RemindLeadOption {
  label: string = ''
  days: number = 0

  static all(): RemindLeadOption[] {
    const out: RemindLeadOption[] = []
    const labels: string[] = ['当天上午 9 点', '提前 1 天', '提前 3 天', '提前 7 天']
    const days: number[] = [0, 1, 3, 7]
    for (let i = 0; i < labels.length; i++) {
      const row = new RemindLeadOption()
      row.label = labels[i]
      row.days = days[i]
      out.push(row)
    }
    return out
  }
}

export class MemberRoleOption {
  static all(): string[] {
    return ['家长', '伴侣', '孩子', '家人']
  }
}

export class MemoTagOption {
  label: string = ''
  value: string = ''

  static all(): MemoTagOption[] {
    const out: MemoTagOption[] = []
    const labels = ['采购', '出行', '维修', '其他']
    for (const label of labels) {
      const row = new MemoTagOption()
      row.label = label
      row.value = label
      out.push(row)
    }
    return out
  }
}
