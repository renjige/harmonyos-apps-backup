export class MaterialCategory {
  id: string = ''
  title: string = ''
  coverKey: string = ''
}

export class InspectRecord {
  id: string = ''
  materialName: string = ''
  category: string = '其他'
  spec: string = ''
  quantity: string = ''
  unit: string = '箱'
  supplier: string = ''
  arrivalDate: string = ''
  checkAppearance: string = 'ok'
  checkPacking: string = 'ok'
  checkQty: string = 'match'
  checkDocs: string = 'complete'
  result: string = ''
  photosCsv: string = ''
  remark: string = ''
  projectName: string = ''
  batchNo: string = ''
  extraA: string = 'ok'
  extraB: string = 'ok'
  followUpNote: string = ''
  followUpDone: string = ''
  parentId: string = ''
  createdAt: string = ''
  updatedAt: string = ''
}

export class InspectWire {
  records: InspectRecord[] = []
}

export class InspectStats {
  todayTotal: number = 0
  todayDone: number = 0
  todayPending: number = 0
  todayFail: number = 0
  monthTotal: number = 0
  monthPass: number = 0
  monthPending: number = 0
  monthFail: number = 0
  allTotal: number = 0
  allPass: number = 0
  allPending: number = 0
  allFail: number = 0
  passRate: number = 0
}

export class ProjectBrief {
  name: string = ''
  total: number = 0
  pending: number = 0
  passCount: number = 0
}

export class InspectSaveBody {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  category: string = ''
  spec: string = ''
  quantity: string = ''
  unit: string = ''
  supplier: string = ''
  arrivalDate: string = ''
  checkAppearance: string = ''
  checkPacking: string = ''
  checkQty: string = ''
  checkDocs: string = ''
  result: string = ''
  status: string = ''
  remark: string = ''
  photosJson: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"id":${JSON.stringify(this.id)},"title":${JSON.stringify(this.title)},"subtitle":${JSON.stringify(this.subtitle)},"category":${JSON.stringify(this.category)},"spec":${JSON.stringify(this.spec)},"quantity":${JSON.stringify(this.quantity)},"unit":${JSON.stringify(this.unit)},"supplier":${JSON.stringify(this.supplier)},"arrivalDate":${JSON.stringify(this.arrivalDate)},"checkAppearance":${JSON.stringify(this.checkAppearance)},"checkPacking":${JSON.stringify(this.checkPacking)},"checkQty":${JSON.stringify(this.checkQty)},"checkDocs":${JSON.stringify(this.checkDocs)},"result":${JSON.stringify(this.result)},"status":${JSON.stringify(this.status)},"remark":${JSON.stringify(this.remark)},"photosJson":${JSON.stringify(this.photosJson)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class InspectCatalog {
  static all(): MaterialCategory[] {
    const rows: MaterialCategory[] = []
    const names: string[] = ['水泥', '钢材', '木材', '板材', '瓷砖', '石材', '管材', '电线电缆', '防水材料', '涂料', '门窗', '五金', '其他']
    const keys: string[] = ['cat_cement', 'cat_steel', 'cat_wood', 'cat_board', 'cat_tile', 'cat_stone', 'cat_pipe', 'cat_cable', 'cat_waterproof', 'cat_paint', 'cat_window', 'cat_hardware', 'cat_other']
    for (let i = 0; i < names.length; i++) {
      const row = new MaterialCategory()
      row.id = keys[i]
      row.title = names[i]
      row.coverKey = keys[i]
      rows.push(row)
    }
    return rows
  }

  static units(): string[] {
    return ['件', '个', '吨', 'm', '㎡', 'm³', '箱']
  }
}

export class InspectStatus {
  static label(result: string): string {
    if (result === 'pass') {
      return '验收通过'
    }
    if (result === 'pending') {
      return '待处理'
    }
    if (result === 'fail') {
      return '验收不通过'
    }
    return '待验收'
  }

  static shortLabel(result: string): string {
    if (result === 'pass') {
      return '通过'
    }
    if (result === 'pending') {
      return '待处理'
    }
    if (result === 'fail') {
      return '不通过'
    }
    return '待验收'
  }

  static inspectFilter(result: string, filter: string): boolean {
    if (filter === 'all' || filter.length === 0) {
      return true
    }
    if (filter === 'todo') {
      return result === 'pending' || result.length === 0
    }
    if (filter === 'done') {
      return result === 'pass'
    }
    if (filter === 'abnormal') {
      return result === 'fail'
    }
    return result === filter
  }

  static recordFilter(result: string, filter: string): boolean {
    if (filter === 'all' || filter.length === 0) {
      return true
    }
    return result === filter
  }

  static checkLabel(kind: string, value: string): string {
    if (kind === 'qty') {
      return value === 'mismatch' ? '不一致' : '一致'
    }
    if (kind === 'docs') {
      return value === 'missing' ? '缺失' : '齐全'
    }
    return value === 'abnormal' ? '异常' : '正常'
  }
}

export class InspectMedia {
  static cover(category: string): Resource {
    if (category === '水泥' || category === 'cat_cement') {
      return $r('app.media.cat_cement')
    }
    if (category === '钢材' || category === 'cat_steel') {
      return $r('app.media.cat_steel')
    }
    if (category === '木材' || category === 'cat_wood') {
      return $r('app.media.cat_wood')
    }
    if (category === '板材' || category === 'cat_board') {
      return $r('app.media.cat_board')
    }
    if (category === '瓷砖' || category === 'cat_tile') {
      return $r('app.media.cat_tile')
    }
    if (category === '石材' || category === 'cat_stone') {
      return $r('app.media.cat_stone')
    }
    if (category === '管材' || category === 'cat_pipe') {
      return $r('app.media.cat_pipe')
    }
    if (category === '电线电缆' || category === 'cat_cable') {
      return $r('app.media.cat_cable')
    }
    if (category === '防水材料' || category === 'cat_waterproof') {
      return $r('app.media.cat_waterproof')
    }
    if (category === '涂料' || category === 'cat_paint') {
      return $r('app.media.cat_paint')
    }
    if (category === '门窗' || category === 'cat_window') {
      return $r('app.media.cat_window')
    }
    if (category === '五金' || category === 'cat_hardware') {
      return $r('app.media.cat_hardware')
    }
    return $r('app.media.cat_other')
  }
}

export class PhotoList {
  static split(csv: string): string[] {
    if (csv.length === 0) {
      return []
    }
    const out: string[] = []
    const parts = csv.split('\n')
    for (const p of parts) {
      if (p.length > 0) {
        out.push(p)
      }
    }
    return out
  }

  static join(items: string[]): string {
    let s = ''
    for (let i = 0; i < items.length; i++) {
      if (i > 0) {
        s += '\n'
      }
      s += items[i]
    }
    return s
  }
}
