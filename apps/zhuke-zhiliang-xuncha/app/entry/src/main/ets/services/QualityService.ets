import { AuthService } from './AuthService'
import { HttpClient } from './HttpClient'
import { QualityLocalStore } from './QualityLocalStore'
import { QualityNav } from './QualityNav'
import { QualityCatalog } from '../models/QualityModels'
import {
  CreateInspectBody,
  CreateIssueBody,
  InspectionItem,
  InspectionRecord,
  IssueRecord,
  ListPayload,
  NoticeItem,
  ProjectItem,
  QualityStats,
  RectifyBody,
  RectifyRecord
} from '../models/QualityModels'

const BASE = '/biz/site-quality'

export class QualityService {
  static actorId(): string {
    const name = AppStorage.get<string>('currentUsername') ?? ''
    if (name.length > 0) {
      return name
    }
    return 'local'
  }

  static stats(): QualityStats {
    return QualityLocalStore.stats()
  }

  static profileName(): string {
    return QualityLocalStore.snapshot().profile.displayName
  }

  static profileRole(): string {
    return QualityLocalStore.snapshot().profile.roleTitle
  }

  static projects(): ProjectItem[] {
    return QualityLocalStore.snapshot().projects
  }

  static inspections(): InspectionRecord[] {
    return QualityLocalStore.snapshot().inspections
  }

  static issues(): IssueRecord[] {
    return QualityLocalStore.snapshot().issues
  }

  static notices(): NoticeItem[] {
    return QualityLocalStore.snapshot().notices
  }

  static findProject(id: string): ProjectItem | undefined {
    for (const row of QualityLocalStore.snapshot().projects) {
      if (row.id === id) {
        return row
      }
    }
    return undefined
  }

  static findInspection(id: string): InspectionRecord | undefined {
    for (const row of QualityLocalStore.snapshot().inspections) {
      if (row.id === id) {
        return row
      }
    }
    return undefined
  }

  static findIssue(id: string): IssueRecord | undefined {
    for (const row of QualityLocalStore.snapshot().issues) {
      if (row.id === id) {
        return row
      }
    }
    return undefined
  }

  static issueTimeline(issueId: string): RectifyRecord[] {
    const out: RectifyRecord[] = []
    for (const row of QualityLocalStore.snapshot().rectifies) {
      if (row.issueId === issueId) {
        out.push(row)
      }
    }
    out.sort((a: RectifyRecord, b: RectifyRecord) => a.createdAt.localeCompare(b.createdAt))
    return out
  }

  static issuesOfInspection(inspectionId: string): IssueRecord[] {
    const out: IssueRecord[] = []
    for (const row of QualityLocalStore.snapshot().issues) {
      if (row.inspectionId === inspectionId) {
        out.push(row)
      }
    }
    return out
  }

  static filterIssues(status: string, keyword: string): IssueRecord[] {
    const q = keyword.trim()
    const out: IssueRecord[] = []
    for (const row of QualityLocalStore.snapshot().issues) {
      if (status !== '全部' && row.status !== status) {
        continue
      }
      if (q.length > 0) {
        const hit = row.title.indexOf(q) >= 0 || row.projectName.indexOf(q) >= 0 || row.location.indexOf(q) >= 0
        if (!hit) {
          continue
        }
      }
      out.push(row)
    }
    return out
  }

  static projectCounts(projectId: string): QualityStats {
    const s = new QualityStats()
    for (const row of QualityLocalStore.snapshot().issues) {
      if (row.projectId !== projectId) {
        continue
      }
      if (row.status === '待整改') {
        s.foundToday += 1
      }
      if (row.status === '整改中') {
        s.rectifying += 1
      }
      if (row.status === '已完成') {
        s.closed += 1
      }
    }
    return s
  }

  static async refreshRemote(): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      return
    }
    const uid = encodeURIComponent(QualityService.actorId())
    const ins = await HttpClient.get<ListPayload<InspectionRecord>>(`${BASE}/inspections?userId=${uid}`)
    if (ins.code === 0 && ins.data !== undefined && ins.data.list.length > 0) {
      QualityLocalStore.snapshot().inspections = ins.data.list
      await QualityLocalStore.persist()
    }
    const iss = await HttpClient.get<ListPayload<IssueRecord>>(`${BASE}/issues?userId=${uid}`)
    if (iss.code === 0 && iss.data !== undefined && iss.data.list.length > 0) {
      QualityLocalStore.snapshot().issues = iss.data.list
      await QualityLocalStore.persist()
    }
  }

  static async createInspection(draft: InspectionRecord): Promise<InspectionRecord> {
    const titles = QualityCatalog.checklist(draft.inspectType)
    const items: InspectionItem[] = []
    for (let i = 0; i < titles.length; i++) {
      const it = new InspectionItem()
      it.id = `it_${i}`
      it.title = titles[i]
      it.status = 'ok'
      items.push(it)
    }
    const row = new InspectionRecord()
    row.id = QualityLocalStore.newId('ins')
    row.title = `${draft.projectName} · ${draft.area}`
    row.projectId = draft.projectId
    row.projectName = draft.projectName
    row.area = draft.area
    row.inspectType = draft.inspectType
    row.inspectDate = draft.inspectDate
    row.remark = draft.remark
    row.status = '进行中'
    row.itemsJson = QualityLocalStore.stringifyItems(items)
    row.itemCount = items.length
    row.okCount = items.length
    row.issueCount = 0
    row.userId = QualityService.actorId()
    row.createdAt = QualityLocalStore.nowIso()
    row.updatedAt = row.createdAt
    QualityLocalStore.snapshot().inspections.unshift(row)
    await QualityLocalStore.persist()
    if (AuthService.isLoggedIn()) {
      const body = new CreateInspectBody()
      body.title = row.title
      body.projectId = row.projectId
      body.projectName = row.projectName
      body.area = row.area
      body.inspectType = row.inspectType
      body.inspectDate = row.inspectDate
      body.remark = row.remark
      body.itemsJson = row.itemsJson
      body.status = 'in_progress'
      body.userId = row.userId
      const res = await HttpClient.post<InspectionRecord>(`${BASE}/inspections`, body)
      if (res.code === 0 && res.data !== undefined && res.data.id.length > 0) {
        row.id = res.data.id
        await QualityLocalStore.persist()
      }
    }
    QualityNav.bump()
    return row
  }

  static async saveInspection(row: InspectionRecord): Promise<void> {
    const items = QualityLocalStore.parseItems(row.itemsJson)
    let ok = 0
    let bad = 0
    for (const it of items) {
      if (it.status === 'issue') {
        bad += 1
      } else {
        ok += 1
      }
    }
    row.okCount = ok
    row.issueCount = bad
    row.itemCount = items.length
    row.updatedAt = QualityLocalStore.nowIso()
    await QualityLocalStore.persist()
    if (AuthService.isLoggedIn()) {
      await HttpClient.put<InspectionRecord>(`${BASE}/inspections/${row.id}`, row)
    }
    QualityNav.bump()
  }

  static async deleteInspection(id: string): Promise<void> {
    const next: InspectionRecord[] = []
    for (const row of QualityLocalStore.snapshot().inspections) {
      if (row.id !== id) {
        next.push(row)
      }
    }
    QualityLocalStore.snapshot().inspections = next
    await QualityLocalStore.persist()
    if (AuthService.isLoggedIn()) {
      await HttpClient.delete<InspectionRecord>(`${BASE}/inspections/${id}`)
    }
    QualityNav.bump()
  }

  static async createIssue(draft: IssueRecord): Promise<IssueRecord> {
    const row = new IssueRecord()
    row.id = QualityLocalStore.newId('iss')
    row.title = draft.title.trim()
    row.projectId = draft.projectId
    row.projectName = draft.projectName
    row.location = draft.location
    row.category = draft.category
    row.severity = draft.severity
    row.description = draft.description
    row.requirement = draft.requirement
    row.photosJson = draft.photosJson
    row.coverKey = draft.coverKey.length > 0 ? draft.coverKey : QualityCatalog.coverForCategory(draft.category)
    row.status = '待整改'
    row.inspectionId = draft.inspectionId
    row.foundAt = QualityLocalStore.nowIso()
    row.userId = QualityService.actorId()
    row.createdAt = row.foundAt
    row.updatedAt = row.foundAt
    QualityLocalStore.snapshot().issues.unshift(row)
    const rec = new RectifyRecord()
    rec.id = QualityLocalStore.newId('rec')
    rec.issueId = row.id
    rec.title = row.title
    rec.note = '发现问题'
    rec.status = '发现问题'
    rec.createdAt = row.foundAt
    rec.userId = row.userId
    QualityLocalStore.snapshot().rectifies.push(rec)
    await QualityLocalStore.persist()
    if (AuthService.isLoggedIn()) {
      const body = new CreateIssueBody()
      body.title = row.title
      body.projectId = row.projectId
      body.projectName = row.projectName
      body.location = row.location
      body.category = row.category
      body.severity = row.severity
      body.description = row.description
      body.requirement = row.requirement
      body.photosJson = row.photosJson
      body.inspectionId = row.inspectionId
      body.coverKey = row.coverKey
      body.userId = row.userId
      const res = await HttpClient.post<IssueRecord>(`${BASE}/issues`, body)
      if (res.code === 0 && res.data !== undefined && res.data.id.length > 0) {
        row.id = res.data.id
        rec.issueId = row.id
        await QualityLocalStore.persist()
      }
    }
    QualityNav.bump()
    return row
  }

  static async updateIssue(draft: IssueRecord): Promise<IssueRecord> {
    const found = QualityService.findIssue(draft.id)
    if (found === undefined) {
      return QualityService.createIssue(draft)
    }
    found.title = draft.title.trim()
    found.projectId = draft.projectId
    found.projectName = draft.projectName
    found.location = draft.location
    found.category = draft.category
    found.severity = draft.severity
    found.description = draft.description
    found.requirement = draft.requirement
    found.photosJson = draft.photosJson
    found.coverKey = draft.coverKey.length > 0 ? draft.coverKey : found.coverKey
    found.updatedAt = QualityLocalStore.nowIso()
    await QualityLocalStore.persist()
    if (AuthService.isLoggedIn()) {
      await HttpClient.put<IssueRecord>(`${BASE}/issues/${found.id}`, found)
    }
    QualityNav.bump()
    return found
  }

  static async createProject(title: string, location: string, summary: string): Promise<ProjectItem> {
    const row = new ProjectItem()
    row.id = QualityLocalStore.newId('proj')
    row.title = title
    row.location = location
    row.summary = summary
    row.body = summary
    row.coverKey = 'hero_home'
    row.status = 'active'
    row.isSample = false
    QualityLocalStore.snapshot().projects.unshift(row)
    await QualityLocalStore.persist()
    QualityNav.bump()
    return row
  }

  static async deleteProject(id: string): Promise<void> {
    const next: ProjectItem[] = []
    for (const row of QualityLocalStore.snapshot().projects) {
      if (row.id !== id) {
        next.push(row)
      }
    }
    QualityLocalStore.snapshot().projects = next
    await QualityLocalStore.persist()
    QualityNav.bump()
  }

  static async deleteIssue(id: string): Promise<void> {
    const next: IssueRecord[] = []
    for (const row of QualityLocalStore.snapshot().issues) {
      if (row.id !== id) {
        next.push(row)
      }
    }
    QualityLocalStore.snapshot().issues = next
    const recs: RectifyRecord[] = []
    for (const row of QualityLocalStore.snapshot().rectifies) {
      if (row.issueId !== id) {
        recs.push(row)
      }
    }
    QualityLocalStore.snapshot().rectifies = recs
    await QualityLocalStore.persist()
    if (AuthService.isLoggedIn()) {
      await HttpClient.delete<IssueRecord>(`${BASE}/issues/${id}`)
    }
    QualityNav.bump()
  }

  static async submitRectify(issue: IssueRecord, note: string, photosJson: string, done: boolean): Promise<void> {
    const rec = new RectifyRecord()
    rec.id = QualityLocalStore.newId('rec')
    rec.issueId = issue.id
    rec.title = issue.title
    rec.note = note
    rec.status = done ? '整改完成' : '开始整改'
    rec.photosJson = photosJson
    rec.createdAt = QualityLocalStore.nowIso()
    rec.userId = QualityService.actorId()
    QualityLocalStore.snapshot().rectifies.push(rec)
    issue.status = done ? '已完成' : '整改中'
    issue.updatedAt = rec.createdAt
    await QualityLocalStore.persist()
    if (AuthService.isLoggedIn()) {
      const body = new RectifyBody()
      body.note = note
      body.photosJson = photosJson
      body.status = done ? 'done' : 'rectifying'
      body.userId = issue.userId
      await HttpClient.post<IssueRecord>(`${BASE}/issues/${issue.id}/rectify`, body)
    }
    QualityNav.bump()
  }
}
