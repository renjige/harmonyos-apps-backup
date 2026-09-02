export class FamilyList {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  status: string = 'active'
  dueDate: string = ''
  coverKey: string = ''
  userId: string = ''
  createdAt: string = ''
  updatedAt: string = ''
}

export class FamilyTask {
  id: string = ''
  listId: string = ''
  title: string = ''
  category: string = '其他'
  qty: string = ''
  remark: string = ''
  completed: boolean = false
  userId: string = ''
  updatedAt: string = ''
}

export class FamilyNote {
  id: string = ''
  title: string = ''
  body: string = ''
  important: boolean = false
  remindAt: string = ''
  userId: string = ''
  updatedAt: string = ''
}

export class FamilyReminder {
  id: string = ''
  listId: string = ''
  title: string = ''
  remindAt: string = ''
  status: string = 'scheduled'
  userId: string = ''
  agentId: number = 0
  cycle: string = 'once'
}

export class FamilyTemplate {
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
  title: string = ''
  summary: string = ''
  dueDate: string = ''
  coverKey: string = ''
  templateId: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"summary":${JSON.stringify(this.summary)},"dueDate":${JSON.stringify(this.dueDate)},"coverKey":${JSON.stringify(this.coverKey)},"templateId":${JSON.stringify(this.templateId)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class CreateItemBody {
  title: string = ''
  listId: string = ''
  category: string = '其他'
  qty: string = ''
  remark: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"listId":${JSON.stringify(this.listId)},"category":${JSON.stringify(this.category)},"qty":${JSON.stringify(this.qty)},"remark":${JSON.stringify(this.remark)},"userId":${JSON.stringify(this.userId)}}`
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
  title: string = ''
  body: string = ''
  important: boolean = false
  remindAt: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"body":${JSON.stringify(this.body)},"important":${this.important ? 'true' : 'false'},"remindAt":${JSON.stringify(this.remindAt)},"userId":${JSON.stringify(this.userId)}}`
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
  title: string = ''
  listId: string = ''
  remindAt: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"listId":${JSON.stringify(this.listId)},"remindAt":${JSON.stringify(this.remindAt)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class LocalBundle {
  lists: FamilyList[] = []
  items: FamilyTask[] = []
  memos: FamilyNote[] = []
  reminders: FamilyReminder[] = []
}
