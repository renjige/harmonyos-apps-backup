import { ApiResponse, EmptyPayload } from '../models/ApiModels'
import { InspectRecord, InspectSaveBody, InspectStats, ProjectBrief } from '../models/InspectModels'
import { InspectLocalStore } from './InspectLocalStore'
import { AuthService } from './AuthService'
import { HttpClient } from './HttpClient'

export class InspectService {
  static list(): InspectRecord[] {
    return InspectLocalStore.records()
  }

  static stats(): InspectStats {
    return InspectLocalStore.stats()
  }

  static recent(limit: number): InspectRecord[] {
    const all = InspectLocalStore.records()
    const out: InspectRecord[] = []
    let n = 0
    for (const row of all) {
      if (n >= limit) {
        break
      }
      out.push(row)
      n += 1
    }
    return out
  }

  static find(id: string): InspectRecord | null {
    return InspectLocalStore.findById(id)
  }

  static async save(row: InspectRecord): Promise<InspectRecord> {
    const saved = await InspectLocalStore.save(row)
    InspectService.queueSync(saved)
    return saved
  }

  static async remove(id: string): Promise<boolean> {
    const ok = await InspectLocalStore.remove(id)
    if (ok && AuthService.isLoggedIn()) {
      void InspectService.syncDelete(id)
    }
    return ok
  }

  private static queueSync(saved: InspectRecord): void {
    if (!AuthService.isLoggedIn()) {
      return
    }
    void InspectService.syncCloud(saved)
  }

  private static async syncCloud(saved: InspectRecord): Promise<void> {
    const body = new InspectSaveBody()
    body.id = saved.id
    body.title = saved.materialName
    body.subtitle = saved.spec
    body.category = saved.category
    body.spec = saved.spec
    body.quantity = saved.quantity
    body.unit = saved.unit
    body.supplier = saved.supplier
    body.arrivalDate = saved.arrivalDate
    body.checkAppearance = saved.checkAppearance
    body.checkPacking = saved.checkPacking
    body.checkQty = saved.checkQty
    body.checkDocs = saved.checkDocs
    body.result = saved.result
    body.status = saved.result
    body.remark = saved.remark
    body.photosJson = saved.photosCsv
    body.userId = AuthService.currentUsername()
    try {
      const putRes: ApiResponse<EmptyPayload> = await HttpClient.put<EmptyPayload>(
        '/biz/material-acceptance/records/' + saved.id,
        body
      )
      if (putRes.code !== 0) {
        await HttpClient.post<EmptyPayload>('/biz/material-acceptance/records', body)
      }
    } catch {
    }
  }

  private static async syncDelete(id: string): Promise<void> {
    try {
      await HttpClient.delete<EmptyPayload>('/biz/material-acceptance/records/' + id)
    } catch {
    }
  }

  static search(keyword: string, filter: string, inspectMode: boolean): InspectRecord[] {
    const q = keyword.trim()
    const all = InspectLocalStore.records()
    const out: InspectRecord[] = []
    for (const row of all) {
      let matchFilter = true
      if (inspectMode) {
        matchFilter = InspectService.matchInspect(row.result, filter)
      } else {
        matchFilter = InspectService.matchRecord(row.result, filter)
      }
      if (!matchFilter) {
        continue
      }
      if (q.length > 0) {
        const hit = row.materialName.indexOf(q) >= 0 || row.supplier.indexOf(q) >= 0 ||
          row.spec.indexOf(q) >= 0 || row.projectName.indexOf(q) >= 0 || row.batchNo.indexOf(q) >= 0
        if (!hit) {
          continue
        }
      }
      out.push(row)
    }
    return out
  }

  private static matchInspect(result: string, filter: string): boolean {
    if (filter === 'all') {
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
    return true
  }

  private static matchRecord(result: string, filter: string): boolean {
    if (filter === 'all') {
      return true
    }
    return result === filter
  }

  static pendingFollow(): InspectRecord[] {
    const out: InspectRecord[] = []
    for (const row of InspectLocalStore.records()) {
      if ((row.result === 'fail' || row.result === 'pending') && row.followUpDone !== '1') {
        out.push(row)
      }
    }
    return out
  }

  static isToday(row: InspectRecord): boolean {
    const today = InspectLocalStore.today()
    const created = row.createdAt.length >= 10 ? row.createdAt.slice(0, 10) : ''
    return created === today || row.arrivalDate === today
  }

  static todayRecords(): InspectRecord[] {
    const out: InspectRecord[] = []
    for (const row of InspectLocalStore.records()) {
      if (InspectService.isToday(row)) {
        out.push(row)
      }
    }
    return out
  }

  static todayPendingList(): InspectRecord[] {
    const out: InspectRecord[] = []
    for (const row of InspectService.todayRecords()) {
      if (row.result === 'pending' || row.result.length === 0) {
        out.push(row)
      }
    }
    return out
  }

  static todayPassList(): InspectRecord[] {
    const out: InspectRecord[] = []
    for (const row of InspectService.todayRecords()) {
      if (row.result === 'pass') {
        out.push(row)
      }
    }
    return out
  }

  static byProject(projectName: string): InspectRecord[] {
    const out: InspectRecord[] = []
    for (const row of InspectLocalStore.records()) {
      if (row.projectName === projectName) {
        out.push(row)
      }
    }
    return out
  }

  static projectBriefs(limit: number): ProjectBrief[] {
    return InspectService.groupBriefs(limit, false)
  }

  static supplierBriefs(limit: number): ProjectBrief[] {
    return InspectService.groupBriefs(limit, true)
  }

  static bySupplier(supplier: string): InspectRecord[] {
    const out: InspectRecord[] = []
    for (const row of InspectLocalStore.records()) {
      const name = row.supplier.length > 0 ? row.supplier : '未填写供应商'
      if (name === supplier) {
        out.push(row)
      }
    }
    return out
  }

  static overduePending(): InspectRecord[] {
    const today = InspectLocalStore.today()
    const out: InspectRecord[] = []
    for (const row of InspectLocalStore.records()) {
      if (row.arrivalDate.length >= 10 && row.arrivalDate < today) {
        if (row.result === 'pending' || row.result.length === 0) {
          out.push(row)
        }
      }
    }
    return out
  }

  static batchExists(batchNo: string, exceptId: string): boolean {
    const q = batchNo.trim()
    if (q.length === 0) {
      return false
    }
    for (const row of InspectLocalStore.records()) {
      if (row.id !== exceptId && row.batchNo === q) {
        return true
      }
    }
    return false
  }

  private static groupBriefs(limit: number, bySupplier: boolean): ProjectBrief[] {
    const names: string[] = []
    const briefs: ProjectBrief[] = []
    for (const row of InspectLocalStore.records()) {
      let key = bySupplier ? row.supplier : row.projectName
      if (key.length === 0) {
        key = bySupplier ? '未填写供应商' : '未填写工点'
      }
      let idx = -1
      let i = 0
      for (const name of names) {
        if (name === key) {
          idx = i
          break
        }
        i += 1
      }
      if (idx < 0) {
        const brief = new ProjectBrief()
        brief.name = key
        names.push(key)
        briefs.push(brief)
        idx = briefs.length - 1
      }
      briefs[idx].total += 1
      if (row.result === 'pass') {
        briefs[idx].passCount += 1
      } else {
        briefs[idx].pending += 1
      }
    }
    for (let a = 0; a < briefs.length; a++) {
      for (let b = a + 1; b < briefs.length; b++) {
        if (briefs[b].total > briefs[a].total) {
          const tmp = briefs[a]
          briefs[a] = briefs[b]
          briefs[b] = tmp
        }
      }
    }
    const out: ProjectBrief[] = []
    let n = 0
    for (const row of briefs) {
      if (n >= limit) {
        break
      }
      out.push(row)
      n += 1
    }
    return out
  }

  static boardList(mode: string, key: string): InspectRecord[] {
    if (mode === 'todayPending') {
      return InspectService.todayPendingList()
    }
    if (mode === 'todayPass') {
      return InspectService.todayPassList()
    }
    if (mode === 'follow') {
      return InspectService.pendingFollow()
    }
    if (mode === 'project') {
      return InspectService.byProject(key)
    }
    if (mode === 'supplier') {
      return InspectService.bySupplier(key)
    }
    if (mode === 'overdue') {
      return InspectService.overduePending()
    }
    return []
  }

  static boardTitle(mode: string, key: string): string {
    if (mode === 'todayPending') {
      return '今日待验收'
    }
    if (mode === 'todayPass') {
      return '今日已通过'
    }
    if (mode === 'follow') {
      return '待跟进记录'
    }
    if (mode === 'project') {
      return key.length > 0 ? key : '工点记录'
    }
    if (mode === 'supplier') {
      return key.length > 0 ? key : '供应商记录'
    }
    if (mode === 'overdue') {
      return '超期未验'
    }
    return '记录清单'
  }

  static byDay(day: string): InspectRecord[] {
    const out: InspectRecord[] = []
    if (day.length === 0) {
      return InspectLocalStore.records()
    }
    for (const row of InspectLocalStore.records()) {
      const created = row.createdAt.slice(0, 10)
      if (created === day || row.arrivalDate === day) {
        out.push(row)
      }
    }
    return out
  }

  static async reinspect(id: string): Promise<InspectRecord | null> {
    const old = InspectLocalStore.findById(id)
    if (old === null) {
      return null
    }
    const copy = InspectLocalStore.clone(old)
    copy.id = ''
    copy.parentId = old.id
    copy.result = 'pending'
    copy.followUpNote = ''
    copy.followUpDone = ''
    copy.remark = `复验来源：${old.materialName}`
    return InspectService.save(copy)
  }
}
