export class RenoAction {
  id: string = ''
  label: string = ''

  static of(id: string, label: string): RenoAction {
    const row = new RenoAction()
    row.id = id
    row.label = label
    return row
  }

  static quick(): RenoAction[] {
    const rows: RenoAction[] = []
    rows.push(RenoAction.of('note', '记一笔'))
    rows.push(RenoAction.of('task', '加事项'))
    rows.push(RenoAction.of('material', '记材料'))
    rows.push(RenoAction.of('inspect', '做验收'))
    rows.push(RenoAction.of('expense', '记一笔费用'))
    return rows
  }
}

export class RenoProject {
  id: string = ''
  title: string = ''
  houseType: string = '三室两厅'
  startDate: string = ''
  stage: string = '拆改'
  progress: number = 0
  budget: string = ''
  remark: string = ''
  status: string = 'active'
  userId: string = 'local'
  updatedAt: string = ''
  isSample: boolean = false
}

export class RenoTask {
  id: string = ''
  title: string = ''
  stage: string = '水电'
  status: string = 'todo'
  remindAt: string = ''
  remark: string = ''
  projectId: string = ''
  date: string = ''
  userId: string = 'local'
  updatedAt: string = ''
}

export class RenoMaterial {
  id: string = ''
  title: string = ''
  brand: string = ''
  model: string = ''
  spec: string = ''
  qty: string = ''
  room: string = ''
  status: string = 'pending'
  remark: string = ''
  projectId: string = ''
  userId: string = 'local'
  updatedAt: string = ''
}

export class RenoNote {
  id: string = ''
  title: string = ''
  body: string = ''
  kind: string = '普通记录'
  date: string = ''
  stage: string = ''
  photoUri: string = ''
  remark: string = ''
  projectId: string = ''
  userId: string = 'local'
  updatedAt: string = ''
}

export class RenoExpense {
  id: string = ''
  title: string = ''
  amount: string = ''
  category: string = '材料'
  date: string = ''
  remark: string = ''
  projectId: string = ''
  userId: string = 'local'
  updatedAt: string = ''
}

export class RenoEvent {
  id: string = ''
  title: string = ''
  summary: string = ''
  date: string = ''
  kind: string = 'note'
  targetId: string = ''
}

export class RenoInspect {
  id: string = ''
  title: string = ''
  category: string = '水电验收'
  result: string = 'pending'
  remark: string = ''
  itemKey: string = ''
  projectId: string = ''
  userId: string = 'local'
  coverKey: string = ''
  body: string = ''
  updatedAt: string = ''
}

export class RenoStage {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
  sortOrder: number = 0
}

export class RenoSuggestion {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  category: string = ''
  coverKey: string = ''
}

export class RenoGuide {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
}

export class RenoNotice {
  id: string = ''
  title: string = ''
  body: string = ''
  type: string = 'system'
  read: boolean = false
}

export class ListPayload<T> {
  list: T[] = []
  items: T[] = []
}

export class LocalBundle {
  projects: RenoProject[] = []
  tasks: RenoTask[] = []
  materials: RenoMaterial[] = []
  notes: RenoNote[] = []
  inspections: RenoInspect[] = []
  expenses: RenoExpense[] = []
  currentId: string = ''
}

export class BundleWire {
  projects: RenoProject[] = []
  tasks: RenoTask[] = []
  materials: RenoMaterial[] = []
  notes: RenoNote[] = []
  inspections: RenoInspect[] = []
  expenses: RenoExpense[] = []
  currentId: string = ''
}

export class RenoDates {
  static names(): string[] {
    const rows: string[] = []
    rows.push('拆改')
    rows.push('水电')
    rows.push('泥木')
    rows.push('油漆')
    rows.push('安装')
    rows.push('验收')
    return rows
  }

  static coverOf(stage: string): string {
    if (stage === '拆改') {
      return 'stage_demo'
    }
    if (stage === '水电') {
      return 'stage_hydro'
    }
    if (stage === '泥木') {
      return 'stage_wood'
    }
    if (stage === '油漆') {
      return 'stage_paint'
    }
    if (stage === '安装') {
      return 'stage_install'
    }
    return 'stage_accept'
  }

  static indexOf(stage: string): number {
    const names = RenoDates.names()
    for (let i = 0; i < names.length; i++) {
      if (names[i] === stage) {
        return i
      }
    }
    return 0
  }

  static pad(n: number): string {
    return n < 10 ? `0${n}` : `${n}`
  }

  static today(): string {
    const d = new Date()
    return `${d.getFullYear()}-${RenoDates.pad(d.getMonth() + 1)}-${RenoDates.pad(d.getDate())}`
  }

  static displayDate(ymd: string): string {
    const p = ymd.split('-')
    if (p.length < 3) {
      return ymd
    }
    return `${Number.parseInt(p[1])}月${Number.parseInt(p[2])}日`
  }

  static taskLabel(status: string): string {
    if (status === 'done') {
      return '已完成'
    }
    if (status === 'doing') {
      return '进行中'
    }
    return '待办'
  }

  static materialLabel(status: string): string {
    if (status === 'confirmed') {
      return '已确认'
    }
    if (status === 'bought') {
      return '已购买'
    }
    if (status === 'onsite') {
      return '已进场'
    }
    return '待确认'
  }

  static inspectLabel(result: string): string {
    if (result === 'pass') {
      return '通过'
    }
    if (result === 'na') {
      return '不适用'
    }
    return '待处理'
  }

  static houseTypes(): string[] {
    const rows: string[] = []
    rows.push('一室一厅')
    rows.push('两室一厅')
    rows.push('三室两厅')
    rows.push('四室两厅')
    rows.push('其他')
    return rows
  }

  static recordKinds(): string[] {
    const rows: string[] = []
    rows.push('进度记录')
    rows.push('材料记录')
    rows.push('问题记录')
    rows.push('普通记录')
    return rows
  }

  static expenseCats(): string[] {
    const rows: string[] = []
    rows.push('材料')
    rows.push('人工')
    rows.push('设计')
    rows.push('家具')
    rows.push('其他')
    return rows
  }

  static money(raw: string): number {
    const n = Number(raw)
    if (n > 0) {
      return n
    }
    return 0
  }
}

export class RenoWriteBody {
  title: string = ''
  houseType: string = ''
  startDate: string = ''
  stage: string = ''
  progress: number = 0
  remark: string = ''
  status: string = ''
  brand: string = ''
  model: string = ''
  spec: string = ''
  qty: string = ''
  room: string = ''
  kind: string = ''
  date: string = ''
  body: string = ''
  photoUri: string = ''
  result: string = ''
  itemKey: string = ''
  category: string = ''
  remindAt: string = ''
  projectId: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"houseType":${JSON.stringify(this.houseType)},` +
      `"startDate":${JSON.stringify(this.startDate)},"stage":${JSON.stringify(this.stage)},` +
      `"progress":${this.progress},"remark":${JSON.stringify(this.remark)},"status":${JSON.stringify(this.status)},` +
      `"brand":${JSON.stringify(this.brand)},"model":${JSON.stringify(this.model)},"spec":${JSON.stringify(this.spec)},` +
      `"qty":${JSON.stringify(this.qty)},"room":${JSON.stringify(this.room)},"kind":${JSON.stringify(this.kind)},` +
      `"date":${JSON.stringify(this.date)},"body":${JSON.stringify(this.body)},"photoUri":${JSON.stringify(this.photoUri)},` +
      `"result":${JSON.stringify(this.result)},"itemKey":${JSON.stringify(this.itemKey)},` +
      `"category":${JSON.stringify(this.category)},"remindAt":${JSON.stringify(this.remindAt)},` +
      `"projectId":${JSON.stringify(this.projectId)},"userId":${JSON.stringify(this.userId)}}`
  }
}
