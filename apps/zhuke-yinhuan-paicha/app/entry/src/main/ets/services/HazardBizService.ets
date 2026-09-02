import { HttpClient } from './HttpClient'
import { AuthService } from './AuthService'
import { HazardLocalStore } from './HazardLocalStore'
import {
  CheckItem,
  CreateHazardBody,
  HazardCatalog,
  HazardCategory,
  HazardItem,
  HazardNotice,
  HazardStats,
  InspectBody,
  InspectionRecord,
  InspectCreateResult,
  ListPayload,
  RectifyBody,
  ReviewBody
} from '../models/HazardModels'

const BASE = '/biz/site-hazard'

export class HazardBizService {
  private static values<T>(data: ListPayload<T> | undefined): T[] {
    if (data === undefined) {
      return []
    }
    if (data.list !== undefined) {
      return data.list
    }
    if (data.items !== undefined) {
      return data.items
    }
    return []
  }

  static actorId(): string {
    const name = AppStorage.get<string>('currentUsername') ?? ''
    if (name.length > 0 && AuthService.isLoggedIn()) {
      return name
    }
    return 'local'
  }

  static async categories(): Promise<HazardCategory[]> {
    const res = await HttpClient.get<ListPayload<HazardCategory>>(`${BASE}/categories`)
    if (res.code === 0 && HazardBizService.values(res.data).length > 0) {
      return HazardBizService.values(res.data)
    }
    const titles = HazardCatalog.titles()
    const list: HazardCategory[] = []
    for (let i = 0; i < titles.length; i++) {
      const c = new HazardCategory()
      c.id = `local_cat_${i}`
      c.title = titles[i]
      c.coverKey = HazardCatalog.coverFor(titles[i])
      list.push(c)
    }
    return list
  }

  static async checklist(): Promise<CheckItem[]> {
    const res = await HttpClient.get<ListPayload<CheckItem>>(`${BASE}/checklist`)
    const mapped: CheckItem[] = []
    if (res.code === 0) {
      for (const row of HazardBizService.values(res.data)) {
        mapped.push(CheckItem.from(row))
      }
    }
    if (mapped.length > 0) {
      return mapped
    }
    return HazardCatalog.fallbackChecks()
  }

  static async notices(): Promise<HazardNotice[]> {
    const res = await HttpClient.get<ListPayload<HazardNotice>>(`${BASE}/messages`)
    if (res.code === 0) {
      return HazardBizService.values(res.data)
    }
    const res2 = await HttpClient.get<ListPayload<HazardNotice>>('/messages')
    return res2.code === 0 ? HazardBizService.values(res2.data) : []
  }

  static async listInspections(): Promise<InspectionRecord[]> {
    if (HazardLocalStore.isRemoteSyncPaused()) {
      return []
    }
    const uid = HazardBizService.actorId()
    const mapped: InspectionRecord[] = []
    try {
      const res = await HttpClient.get<ListPayload<InspectionRecord>>(
        `${BASE}/inspections?userId=${encodeURIComponent(uid)}`)
      if (res.code === 0) {
        for (const row of HazardBizService.values(res.data)) {
          const item = InspectionRecord.from(row)
          if (item.id.length > 0 && HazardBizService.belongsToActor(item.userId, uid)) {
            mapped.push(item)
          }
        }
      }
    } catch {
      // empty
    }
    return mapped
  }

  static async listHazards(): Promise<HazardItem[]> {
    if (HazardLocalStore.isRemoteSyncPaused()) {
      return HazardLocalStore.all()
    }
    const uid = HazardBizService.actorId()
    const mapped: HazardItem[] = []
    try {
      const res = await HttpClient.get<ListPayload<HazardItem>>(
        `${BASE}/hazards?userId=${encodeURIComponent(uid)}`)
      if (res.code === 0) {
        for (const row of HazardBizService.values(res.data)) {
          const item = HazardItem.from(row)
          if (item.id.length > 0 && HazardBizService.belongsToActor(item.userId, uid)) {
            mapped.push(item)
          }
        }
      }
    } catch {
      return HazardLocalStore.all()
    }
    await HazardLocalStore.saveAll(mapped)
    return mapped
  }

  static async findHazard(id: string): Promise<HazardItem> {
    if (HazardLocalStore.isRemoteSyncPaused()) {
      for (const row of HazardLocalStore.all()) {
        if (row.id === id) {
          return row
        }
      }
      return new HazardItem()
    }
    const uid = HazardBizService.actorId()
    try {
      const res = await HttpClient.get<HazardItem>(
        `${BASE}/hazards/${id}?userId=${encodeURIComponent(uid)}`)
      if (res.code === 0 && res.data !== undefined) {
        const row = HazardItem.from(res.data)
        if (row.id.length > 0 && HazardBizService.belongsToActor(row.userId, uid)) {
          await HazardLocalStore.upsert(row)
          return row
        }
      }
    } catch {
      // local fallback
    }
    for (const row of HazardLocalStore.all()) {
      if (row.id === id) {
        return row
      }
    }
    return new HazardItem()
  }

  static async createHazard(draft: CreateHazardBody): Promise<HazardItem> {
    draft.userId = HazardBizService.actorId()
    draft.coverKey = HazardCatalog.coverFor(draft.category)
    try {
      const res = await HttpClient.post<HazardItem>(`${BASE}/hazards`, draft)
      if (res.code === 0 && res.data !== undefined) {
        const row = HazardItem.from(res.data)
        if (row.id.length > 0) {
          await HazardLocalStore.upsert(row)
          return row
        }
      }
    } catch {
      // local fallback
    }
    const local = new HazardItem()
    local.id = `local_${Date.now()}`
    local.title = draft.title
    local.location = draft.location
    local.category = draft.category
    local.riskLevel = draft.riskLevel
    local.description = draft.description
    local.suggestion = draft.suggestion
    local.ownerName = draft.ownerName
    local.dueAt = draft.dueAt
    local.photosJson = draft.photosJson
    local.coverKey = draft.coverKey
    local.userId = draft.userId
    local.status = 'pending_rectify'
    local.foundAt = new Date().toISOString()
    local.createdAt = local.foundAt
    local.updatedAt = local.foundAt
    await HazardLocalStore.upsert(local)
    return local
  }

  static async rectify(id: string, body: RectifyBody): Promise<HazardItem> {
    body.userId = HazardBizService.actorId()
    try {
      const res = await HttpClient.post<HazardItem>(`${BASE}/hazards/${id}/rectify`, body)
      if (res.code === 0 && res.data !== undefined) {
        const row = HazardItem.from(res.data)
        if (row.id.length > 0) {
          await HazardLocalStore.upsert(row)
          return row
        }
      }
    } catch {
      // local fallback
    }
    const current = await HazardBizService.findHazard(id)
    current.status = 'pending_review'
    current.rectifyNote = body.rectifyNote
    current.rectifyBy = body.rectifyBy
    current.rectifyAt = new Date().toISOString()
    if (body.photosJson.length > 2) {
      current.photosJson = body.photosJson
    }
    await HazardLocalStore.upsert(current)
    return current
  }

  static async review(id: string, body: ReviewBody): Promise<HazardItem> {
    body.userId = HazardBizService.actorId()
    try {
      const res = await HttpClient.post<HazardItem>(`${BASE}/hazards/${id}/review`, body)
      if (res.code === 0 && res.data !== undefined) {
        const row = HazardItem.from(res.data)
        if (row.id.length > 0) {
          await HazardLocalStore.upsert(row)
          return row
        }
      }
    } catch {
      // local fallback
    }
    const current = await HazardBizService.findHazard(id)
    current.reviewNote = body.reviewNote
    current.reviewAt = new Date().toISOString()
    if (body.passed) {
      current.status = 'closed'
      current.reviewResult = 'pass'
      current.closedAt = current.reviewAt
    } else {
      current.status = 'pending_rectify'
      current.reviewResult = 'fail'
    }
    await HazardLocalStore.upsert(current)
    return current
  }

  static async submitInspect(items: CheckItem[], location: string): Promise<InspectCreateResult> {
    const abnormal: string[] = []
    for (const it of items) {
      if (it.result === 'abnormal') {
        abnormal.push(it.title)
      }
    }
    let titlesJson = '['
    for (let i = 0; i < abnormal.length; i++) {
      if (i > 0) {
        titlesJson += ','
      }
      titlesJson += JSON.stringify(abnormal[i])
    }
    titlesJson += ']'
    const body = new InspectBody()
    body.userId = HazardBizService.actorId()
    body.location = location
    body.titlesJson = titlesJson
    body.itemsJson = titlesJson
    try {
      const res = await HttpClient.post<InspectCreateResult>(`${BASE}/inspections`, body)
      await HazardLocalStore.bumpInspect()
      if (res.code === 0 && res.data !== undefined && res.data.hazards !== undefined) {
        const boxed = new InspectCreateResult()
        if (res.data.inspection !== undefined) {
          boxed.inspection = InspectionRecord.from(res.data.inspection)
        }
        for (const h of res.data.hazards) {
          const row = HazardItem.from(h)
          if (row.id.length > 0) {
            await HazardLocalStore.upsert(row)
            boxed.hazards.push(row)
          }
        }
        return boxed
      }
    } catch {
      await HazardLocalStore.bumpInspect()
    }
    const fallback = new InspectCreateResult()
    fallback.inspection.abnormalCount = abnormal.length
    fallback.inspection.okCount = items.length - abnormal.length
    fallback.inspection.inspectedAt = new Date().toISOString()
    for (const title of abnormal) {
      const draft = new CreateHazardBody()
      draft.title = `${title}异常`
      draft.location = location.length > 0 ? location : '现场检查'
      draft.category = HazardBizService.categoryFromCheck(title)
      draft.riskLevel = 'medium'
      draft.description = `安全检查发现「${title}」异常，请现场复核并整改。`
      draft.suggestion = '按规范完成整改并设置警示标识后提交复查。'
      const created = await HazardBizService.createHazard(draft)
      fallback.hazards.push(created)
    }
    return fallback
  }

  static stats(items: HazardItem[], inspectToday: number): HazardStats {
    const s = new HazardStats()
    const localToday = HazardLocalStore.todayInspect()
    s.todayInspect = inspectToday > localToday ? inspectToday : localToday
    const today = HazardLocalStore.todayKey()
    for (const row of items) {
      if (row.status === 'pending_rectify' || row.status === 'rectifying') {
        s.pendingRectify += 1
      }
      if (row.status === 'pending_review' || row.status === 'closed') {
        if (row.rectifyAt.length > 0) {
          s.rectified += 1
        }
      }
      if (row.status === 'pending_review') {
        s.pendingReview += 1
      }
      if (row.status === 'closed') {
        s.closed += 1
      }
      if (row.status !== 'closed') {
        s.openTotal += 1
        if (row.riskLevel === 'high') {
          s.high += 1
        } else if (row.riskLevel === 'low') {
          s.low += 1
        } else {
          s.mid += 1
        }
      }
      if (row.foundAt.length > 0 && HazardLocalStore.isSameLocalDay(row.foundAt, today) && s.todayInspect === 0) {
        s.todayInspect = 1
      }
    }
    return s
  }

  static countTodayInspections(rows: InspectionRecord[]): number {
    const today = HazardLocalStore.todayKey()
    let n = 0
    for (const row of rows) {
      if (HazardLocalStore.isSameLocalDay(row.inspectedAt, today)) {
        n += 1
      }
    }
    return n
  }

  static async syncFromRemote(): Promise<HazardItem[]> {
    await HazardLocalStore.resumeRemoteSync()
    return HazardBizService.listHazards()
  }

  static belongsToActor(recordUserId: string, actor: string): boolean {
    if (recordUserId.length === 0) {
      return actor === 'local'
    }
    return recordUserId === actor
  }

  static recent(items: HazardItem[], limit: number): HazardItem[] {
    const out: HazardItem[] = []
    for (const row of items) {
      if (out.length < limit) {
        out.push(row)
      }
    }
    return out
  }

  static filter(items: HazardItem[], status: string, q: string): HazardItem[] {
    const key = q.trim()
    const out: HazardItem[] = []
    for (const row of items) {
      let ok = true
      if (status.length > 0 && status !== 'all' && row.status !== status) {
        ok = false
      }
      if (ok && key.length > 0) {
        const blob = `${row.title}${row.location}${row.category}`
        if (blob.indexOf(key) < 0) {
          ok = false
        }
      }
      if (ok) {
        out.push(row)
      }
    }
    return out
  }

  private static categoryFromCheck(title: string): string {
    if (title.indexOf('栏杆') >= 0 || title.indexOf('洞口') >= 0 || title.indexOf('警示') >= 0) {
      return '临边防护'
    }
    if (title.indexOf('配电') >= 0 || title.indexOf('电缆') >= 0 || title.indexOf('接地') >= 0) {
      return '用电安全'
    }
    if (title.indexOf('灭火') >= 0 || title.indexOf('消防') >= 0 || title.indexOf('易燃') >= 0) {
      return '消防安全'
    }
    if (title.indexOf('防护用品') >= 0 || title.indexOf('作业') >= 0) {
      return '高处作业'
    }
    return '文明施工'
  }
}
