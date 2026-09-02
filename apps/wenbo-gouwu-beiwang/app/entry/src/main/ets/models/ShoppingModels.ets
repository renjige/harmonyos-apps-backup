export class ShoppingList {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  status: string = 'active'
  dueDate: string = ''
  coverKey: string = ''
  budgetYuan: string = ''
  kind: string = '日常采购'
  starred: boolean = false
  members: string = ''
  userId: string = ''
  createdAt: string = ''
  updatedAt: string = ''
}

export class ShoppingItem {
  id: string = ''
  listId: string = ''
  title: string = ''
  category: string = '其他'
  qty: string = ''
  remark: string = ''
  estPrice: string = ''
  paidPrice: string = ''
  tag: string = ''
  assignee: string = ''
  lastBoughtAt: string = ''
  completed: boolean = false
  userId: string = ''
  updatedAt: string = ''
}

export class ShoppingMemoNote {
  id: string = ''
  title: string = ''
  body: string = ''
  important: boolean = false
  remindAt: string = ''
  userId: string = ''
  updatedAt: string = ''
}

export class ShoppingReminder {
  id: string = ''
  listId: string = ''
  title: string = ''
  remindAt: string = ''
  cycle: string = 'once'
  status: string = 'scheduled'
  userId: string = ''
  agentId: number = 0
}

export class FrequentItem {
  title: string = ''
  category: string = ''
  qty: string = ''
  remark: string = ''
  estPrice: string = ''
  count: number = 0
}

export class SpendSnapshot {
  estTotal: number = 0
  paidTotal: number = 0
  buyTimes: number = 0
  itemCount: number = 0
  topName: string = '暂无'
}

export class WeekStats {
  listCount: number = 0
  activeCount: number = 0
  doneCount: number = 0
  itemCount: number = 0
  checkedCount: number = 0
  remainCount: number = 0
  memoCount: number = 0
}

export class RemainingRow {
  listId: string = ''
  listTitle: string = ''
  itemId: string = ''
  title: string = ''
  qty: string = ''
}

export class RestockRow {
  title: string = ''
  category: string = ''
  qty: string = ''
  lastBoughtAt: string = ''
}

export class AisleGroup {
  cat: string = ''
  titles: string[] = []
}

export class WidgetPayload {
  title: string = '今日购物'
  progress: string = '打开应用查看进度'
  remain: string = ''
  preview: string = ''
}

export class ShoppingTemplate {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
  itemsJson: string = '[]'
}

export class TemplateItemSeed {
  title: string = ''
  category: string = '其他'
  qty: string = ''
}

export class ShoppingCategory {
  id: string = ''
  title: string = ''
}

export class ListData<T> {
  list: T[] = []
  items: T[] = []
}

export class CreateListBody {
  id: string = ''
  title: string = ''
  summary: string = ''
  dueDate: string = ''
  coverKey: string = ''
  templateId: string = ''
  userId: string = ''
  status: string = 'active'

  toJsonString(): string {
    return `{"id":${JSON.stringify(this.id)},"title":${JSON.stringify(this.title)},"summary":${JSON.stringify(this.summary)},"dueDate":${JSON.stringify(this.dueDate)},"coverKey":${JSON.stringify(this.coverKey)},"templateId":${JSON.stringify(this.templateId)},"status":${JSON.stringify(this.status)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class CreateItemBody {
  id: string = ''
  title: string = ''
  listId: string = ''
  category: string = '其他'
  qty: string = ''
  remark: string = ''
  userId: string = ''
  completed: boolean = false

  toJsonString(): string {
    return `{"id":${JSON.stringify(this.id)},"title":${JSON.stringify(this.title)},"listId":${JSON.stringify(this.listId)},"category":${JSON.stringify(this.category)},"qty":${JSON.stringify(this.qty)},"remark":${JSON.stringify(this.remark)},"completed":${this.completed ? 'true' : 'false'},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class PatchListBody {
  status: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"status":${JSON.stringify(this.status)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class PatchItemBody {
  completed: boolean = false
  category: string = ''
  qty: string = ''
  remark: string = ''
  title: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"completed":${this.completed ? 'true' : 'false'},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class CreateMemoBody {
  id: string = ''
  title: string = ''
  body: string = ''
  important: boolean = false
  remindAt: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"id":${JSON.stringify(this.id)},"title":${JSON.stringify(this.title)},"body":${JSON.stringify(this.body)},"important":${this.important ? 'true' : 'false'},"remindAt":${JSON.stringify(this.remindAt)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class UpdateMemoBody {
  title: string = ''
  body: string = ''
  important: boolean = false
  remindAt: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"body":${JSON.stringify(this.body)},"important":${this.important ? 'true' : 'false'},"remindAt":${JSON.stringify(this.remindAt)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class CreateReminderBody {
  id: string = ''
  title: string = ''
  listId: string = ''
  remindAt: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"id":${JSON.stringify(this.id)},"title":${JSON.stringify(this.title)},"listId":${JSON.stringify(this.listId)},"remindAt":${JSON.stringify(this.remindAt)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class LocalBundle {
  lists: ShoppingList[] = []
  items: ShoppingItem[] = []
  memos: ShoppingMemoNote[] = []
  reminders: ShoppingReminder[] = []
}

export class ProcurementPlan {
  id: string = ''
  title: string = ''
  period: string = 'week'
  startDate: string = ''
  endDate: string = ''
  targetItemCount: number = 0
  targetBudgetYuan: string = ''
  linkedListIds: string[] = []
  status: string = 'active'
  createdAt: string = ''
}

export class CheckInRecord {
  dateKey: string = ''
  source: string = 'manual'
  note: string = ''
  createdAt: string = ''
}

export class ActivityEvent {
  id: string = ''
  type: string = ''
  title: string = ''
  summary: string = ''
  refId: string = ''
  createdAt: string = ''
}

export class AchievementBadge {
  id: string = ''
  title: string = ''
  desc: string = ''
  iconKey: string = 'check'
  target: number = 1
  progress: number = 0
  unlockedAt: string = ''
}

export class ProcurementTopic {
  id: string = ''
  title: string = ''
  coverKey: string = 'tpl_daily'
  listIds: string[] = []
  memoIds: string[] = []
  updatedAt: string = ''
}

export class FavoriteEntry {
  refType: string = ''
  refId: string = ''
  title: string = ''
  subtitle: string = ''
  createdAt: string = ''
}

export class SearchHit {
  kind: string = ''
  id: string = ''
  title: string = ''
  subtitle: string = ''
  listId: string = ''
}

export class GrowthSnapshot {
  listCount: number = 0
  checkedTotal: number = 0
  favoriteCount: number = 0
  checkInStreak: number = 0
  planDone: number = 0
  planTarget: number = 0
  planBudgetUsed: number = 0
  planBudgetTarget: number = 0
  achievementUnlocked: number = 0
  achievementTotal: number = 0
  topicCount: number = 0
}

export class WeeklyReview {
  checkedCount: number = 0
  paidTotal: number = 0
  topCategory: string = '暂无'
  listDone: number = 0
  checkInDays: number = 0
  summary: string = ''
}

export class EventNavTarget {
  kind: string = ''
  id: string = ''
  listId: string = ''
}

export class MonthlyReview {
  monthKey: string = ''
  paidTotal: number = 0
  estTotal: number = 0
  checkedCount: number = 0
  listDone: number = 0
  checkInDays: number = 0
  topCategory: string = '暂无'
  vsLastMonthPercent: number = 0
  summary: string = ''
}

export class CalendarDayMark {
  dateKey: string = ''
  checkIn: boolean = false
  listDoneCount: number = 0
  checkedCount: number = 0
  overBudget: boolean = false
}

export class SearchFilter {
  keyword: string = ''
  status: string = 'all'
  tag: string = ''
  category: string = ''
  dateFrom: string = ''
  dateTo: string = ''
}

export class AssigneeRow {
  name: string = ''
  pendingCount: number = 0
  doneCount: number = 0
  items: ShoppingItem[] = []
}
