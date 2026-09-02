export class ListPayload<T> {
  list: T[] = []
  items: T[] = []
}

export class HazardCategory {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
}

export class CheckItem {
  id: string = ''
  title: string = ''
  groupName: string = ''
  summary: string = ''
  coverKey: string = ''
  result: string = ''

  static copy(src: CheckItem): CheckItem {
    return CheckItem.from(src)
  }

  static from(raw: CheckItem): CheckItem {
    const row = new CheckItem()
    row.id = raw.id !== undefined && raw.id.length > 0 ? raw.id : ''
    row.title = raw.title !== undefined && raw.title.length > 0 ? raw.title : ''
    row.groupName = raw.groupName !== undefined && raw.groupName.length > 0 ? raw.groupName : ''
    row.summary = raw.summary !== undefined && raw.summary.length > 0 ? raw.summary : ''
    row.coverKey = raw.coverKey !== undefined && raw.coverKey.length > 0 ? raw.coverKey : ''
    if (raw.result !== undefined && raw.result.length > 0) {
      row.result = raw.result
    } else {
      row.result = 'ok'
    }
    return row
  }
}

export class HazardNotice {
  id: string = ''
  title: string = ''
  body: string = ''
  type: string = 'system'
  read: boolean = false
}

export class InspectionRecord {
  id: string = ''
  title: string = ''
  summary: string = ''
  inspectedAt: string = ''
  abnormalCount: number = 0
  okCount: number = 0
  status: string = 'submitted'
  userId: string = ''

  static from(raw: InspectionRecord): InspectionRecord {
    const row = new InspectionRecord()
    row.id = raw.id ?? ''
    row.title = raw.title ?? ''
    row.summary = raw.summary ?? ''
    row.inspectedAt = raw.inspectedAt ?? ''
    row.abnormalCount = raw.abnormalCount ?? 0
    row.okCount = raw.okCount ?? 0
    row.status = raw.status ?? 'submitted'
    row.userId = raw.userId ?? ''
    return row
  }
}

export class HazardStats {
  todayInspect: number = 0
  pendingRectify: number = 0
  rectified: number = 0
  pendingReview: number = 0
  closed: number = 0
  low: number = 0
  mid: number = 0
  high: number = 0
  openTotal: number = 0
}

export class HazardItem {
  id: string = ''
  title: string = ''
  location: string = ''
  category: string = '其他'
  riskLevel: string = 'medium'
  status: string = 'pending_rectify'
  description: string = ''
  suggestion: string = ''
  ownerName: string = ''
  dueAt: string = ''
  foundAt: string = ''
  rectifyAt: string = ''
  reviewAt: string = ''
  closedAt: string = ''
  rectifyNote: string = ''
  rectifyBy: string = ''
  reviewResult: string = ''
  reviewNote: string = ''
  photosJson: string = '[]'
  coverKey: string = 'hero_site'
  userId: string = ''
  summary: string = ''
  body: string = ''
  createdAt: string = ''
  updatedAt: string = ''

  riskLabel(): string {
    if (this.riskLevel === 'high') {
      return '高风险'
    }
    if (this.riskLevel === 'low') {
      return '低风险'
    }
    return '中风险'
  }

  statusLabel(): string {
    if (this.status === 'closed') {
      return '已闭环'
    }
    if (this.status === 'pending_review') {
      return '待复查'
    }
    if (this.status === 'rectifying') {
      return '整改中'
    }
    return '待整改'
  }

  riskColor(): string {
    if (this.riskLevel === 'high') {
      return '#D94A4A'
    }
    if (this.riskLevel === 'low') {
      return '#36A269'
    }
    return '#E9932E'
  }

  statusColor(): string {
    if (this.status === 'closed') {
      return '#2D9B70'
    }
    if (this.status === 'pending_review') {
      return '#F28C28'
    }
    if (this.status === 'rectifying') {
      return '#16324F'
    }
    return '#D94A4A'
  }

  photoList(): string[] {
    if (this.photosJson.length < 2) {
      return []
    }
    try {
      const parsed = JSON.parse(this.photosJson) as string[]
      if (parsed !== undefined && parsed.length > 0) {
        return parsed
      }
    } catch {
    }
    return []
  }

  foundLabel(): string {
    return HazardItem.shortTime(this.foundAt)
  }

  dueLabel(): string {
    if (this.dueAt.length >= 10) {
      return this.dueAt.substring(0, 10)
    }
    return this.dueAt.length > 0 ? this.dueAt : '未设定'
  }

  static shortTime(raw: string): string {
    return HazardItem.formatLocalTime(raw)
  }

  static formatLocalTime(raw: string): string {
    if (raw.length === 0) {
      return '—'
    }
    const d = new Date(raw)
    const ts = d.getTime()
    if (Number.isNaN(ts)) {
      if (raw.length >= 16) {
        return `${raw.substring(0, 10)} ${raw.substring(11, 16)}`
      }
      if (raw.length >= 10) {
        return raw.substring(0, 10)
      }
      return raw
    }
    const y = d.getFullYear()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const h = d.getHours()
    const min = d.getMinutes()
    const mm = m < 10 ? `0${m}` : `${m}`
    const dd = day < 10 ? `0${day}` : `${day}`
    const hh = h < 10 ? `0${h}` : `${h}`
    const mi = min < 10 ? `0${min}` : `${min}`
    return `${y}-${mm}-${dd} ${hh}:${mi}`
  }

  toJsonString(): string {
    return `{"id":${JSON.stringify(this.id)},"title":${JSON.stringify(this.title)},"location":${JSON.stringify(this.location)},"category":${JSON.stringify(this.category)},"riskLevel":${JSON.stringify(this.riskLevel)},"status":${JSON.stringify(this.status)},"description":${JSON.stringify(this.description)},"suggestion":${JSON.stringify(this.suggestion)},"ownerName":${JSON.stringify(this.ownerName)},"dueAt":${JSON.stringify(this.dueAt)},"foundAt":${JSON.stringify(this.foundAt)},"rectifyAt":${JSON.stringify(this.rectifyAt)},"reviewAt":${JSON.stringify(this.reviewAt)},"closedAt":${JSON.stringify(this.closedAt)},"rectifyNote":${JSON.stringify(this.rectifyNote)},"rectifyBy":${JSON.stringify(this.rectifyBy)},"reviewResult":${JSON.stringify(this.reviewResult)},"reviewNote":${JSON.stringify(this.reviewNote)},"photosJson":${JSON.stringify(this.photosJson)},"coverKey":${JSON.stringify(this.coverKey)},"userId":${JSON.stringify(this.userId)},"createdAt":${JSON.stringify(this.createdAt)},"updatedAt":${JSON.stringify(this.updatedAt)}}`
  }

  static from(raw: HazardItem): HazardItem {
    const row = new HazardItem()
    row.id = raw.id !== undefined && raw.id.length > 0 ? raw.id : ''
    row.title = raw.title !== undefined && raw.title.length > 0 ? raw.title : ''
    row.location = raw.location !== undefined ? raw.location : ''
    row.category = raw.category !== undefined && raw.category.length > 0 ? raw.category : '其他'
    row.riskLevel = HazardItem.normRisk(raw.riskLevel)
    row.status = HazardItem.normStatus(raw.status)
    row.description = HazardItem.firstText(raw.description, raw.body, raw.summary)
    row.suggestion = raw.suggestion ?? ''
    row.ownerName = raw.ownerName ?? ''
    row.dueAt = raw.dueAt ?? ''
    row.foundAt = raw.foundAt ?? raw.createdAt ?? ''
    row.rectifyAt = raw.rectifyAt ?? ''
    row.reviewAt = raw.reviewAt ?? ''
    row.closedAt = raw.closedAt ?? ''
    row.rectifyNote = raw.rectifyNote ?? ''
    row.rectifyBy = raw.rectifyBy ?? ''
    row.reviewResult = raw.reviewResult ?? ''
    row.reviewNote = raw.reviewNote ?? ''
    row.photosJson = raw.photosJson && raw.photosJson.length > 0 ? raw.photosJson : '[]'
    row.coverKey = raw.coverKey && raw.coverKey.length > 0 ? raw.coverKey : HazardCatalog.coverFor(row.category)
    row.userId = raw.userId ?? ''
    row.createdAt = raw.createdAt ?? ''
    row.updatedAt = raw.updatedAt ?? ''
    return row
  }

  static normStatus(raw: string | undefined): string {
    if (raw === undefined || raw.length === 0) {
      return 'pending_rectify'
    }
    if (raw === 'closed' || raw === 'pending_review' || raw === 'rectifying' || raw === 'pending_rectify') {
      return raw
    }
    return 'pending_rectify'
  }

  static normRisk(raw: string | undefined): string {
    if (raw === undefined || raw.length === 0) {
      return 'medium'
    }
    if (raw === 'high' || raw === 'low' || raw === 'medium') {
      return raw
    }
    return 'medium'
  }

  static firstText(a: string, b: string, c: string): string {
    if (a.length > 0) {
      return a
    }
    if (b.length > 0) {
      return b
    }
    return c
  }
}

export class HazardCatalog {
  static titles(): string[] {
    return ['临边防护', '高处作业', '用电安全', '消防安全', '机械设备', '脚手架', '文明施工', '其他']
  }

  static groupNames(): string[] {
    return ['临边与洞口', '用电安全', '消防安全', '高处作业', '文明施工']
  }

  static coverFor(category: string): string {
    if (category === '临边防护' || category === '脚手架') {
      return 'banner_edge'
    }
    if (category === '高处作业') {
      return 'cover_height'
    }
    if (category === '用电安全') {
      return 'cover_electric'
    }
    if (category === '消防安全') {
      return 'cover_fire'
    }
    if (category === '文明施工') {
      return 'cover_civil'
    }
    return 'hero_site'
  }

  static fallbackChecks(): CheckItem[] {
    const rows: CheckItem[] = []
    const add = (id: string, groupName: string, title: string, summary: string, coverKey: string): void => {
      const c = new CheckItem()
      c.id = id
      c.groupName = groupName
      c.title = title
      c.summary = summary
      c.coverKey = coverKey
      c.result = 'ok'
      rows.push(c)
    }
    add('sh_chk_1', '临边与洞口', '防护栏杆完整', '临边栏杆高度与固定满足现场要求', 'banner_edge')
    add('sh_chk_2', '临边与洞口', '洞口防护有效', '预留洞口盖板或围挡到位', 'banner_edge')
    add('sh_chk_3', '临边与洞口', '警示标识清晰', '危险区域警示牌可见', 'banner_edge')
    add('sh_chk_4', '用电安全', '配电设施正常', '配电箱门锁、漏电保护完好', 'cover_electric')
    add('sh_chk_5', '用电安全', '电缆无破损', '电缆绝缘层无裸露破损', 'cover_electric')
    add('sh_chk_6', '用电安全', '接地措施正常', '设备接地线连接可靠', 'cover_electric')
    add('sh_chk_7', '消防安全', '灭火器有效', '灭火器在检定有效期内且压力正常', 'cover_fire')
    add('sh_chk_8', '消防安全', '消防通道畅通', '疏散通道无材料堵塞', 'cover_fire')
    add('sh_chk_9', '消防安全', '易燃物分类存放', '油漆、气瓶等分类隔离', 'cover_fire')
    add('sh_chk_10', '高处作业', '安全防护用品齐全', '安全带、安全帽按要求佩戴', 'cover_height')
    add('sh_chk_11', '高处作业', '作业区域设置防护', '高处作业面有围挡或水平网', 'cover_height')
    add('sh_chk_12', '高处作业', '作业人员规范操作', '未发现违章攀爬或抛物', 'cover_height')
    add('sh_chk_13', '文明施工', '材料堆放整齐', '钢筋、模板分区码放', 'cover_civil')
    add('sh_chk_14', '文明施工', '通道保持畅通', '施工通道可通行、无积水杂物', 'cover_civil')
    add('sh_chk_15', '文明施工', '作业区域整洁', '作业面及时清扫，建筑垃圾集中', 'cover_civil')
    return rows
  }
}

export class CreateHazardBody {
  title: string = ''
  location: string = ''
  category: string = ''
  riskLevel: string = ''
  description: string = ''
  suggestion: string = ''
  ownerName: string = ''
  dueAt: string = ''
  photosJson: string = '[]'
  userId: string = ''
  coverKey: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"location":${JSON.stringify(this.location)},"category":${JSON.stringify(this.category)},"riskLevel":${JSON.stringify(this.riskLevel)},"description":${JSON.stringify(this.description)},"suggestion":${JSON.stringify(this.suggestion)},"ownerName":${JSON.stringify(this.ownerName)},"dueAt":${JSON.stringify(this.dueAt)},"photosJson":${JSON.stringify(this.photosJson)},"userId":${JSON.stringify(this.userId)},"coverKey":${JSON.stringify(this.coverKey)}}`
  }
}

export class RectifyBody {
  rectifyNote: string = ''
  rectifyBy: string = ''
  photosJson: string = '[]'
  userId: string = ''

  toJsonString(): string {
    return `{"rectifyNote":${JSON.stringify(this.rectifyNote)},"rectifyBy":${JSON.stringify(this.rectifyBy)},"photosJson":${JSON.stringify(this.photosJson)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class ReviewBody {
  passed: boolean = false
  reviewNote: string = ''
  userId: string = ''

  toJsonString(): string {
    const flag = this.passed ? 'true' : 'false'
    return `{"passed":${flag},"reviewNote":${JSON.stringify(this.reviewNote)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class InspectBody {
  itemsJson: string = '[]'
  location: string = ''
  userId: string = ''
  titlesJson: string = '[]'

  toJsonString(): string {
    return `{"itemsJson":${JSON.stringify(this.itemsJson)},"abnormalTitles":${this.titlesJson},"location":${JSON.stringify(this.location)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class InspectCreateResult {
  inspection: InspectionRecord = new InspectionRecord()
  hazards: HazardItem[] = []
}
