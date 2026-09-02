import {
  CreateEngProjectRequest,
  CreateOutputRequest,
  EngProjectItem,
  EngProjectListData,
  OutputRecordItem,
  OutputRecordListData,
  PatchRiskStatusRequest,
  PatchStatusRequest,
  ProjectRiskItem,
  ProjectRiskListData,
  TodayTodosData
} from '../models/ApiModels'
import { HttpClient } from './HttpClient'

export class EngProjectView {
  id: string = ''
  name: string = ''
  code: string = ''
  address: string = ''
  clientName: string = ''
  managerName: string = ''
  contractAmount: number = 0
  outputTarget: number = 0
  outputDone: number = 0
  progressPct: number = 0
  riskOpenCount: number = 0
  status: string = ''
  statusCode: string = ''
  remark: string = ''

  static fromItem(row: EngProjectItem): EngProjectView {
    const item = new EngProjectView()
    item.id = row.id
    item.name = row.name
    item.code = row.code
    item.address = row.address
    item.clientName = row.clientName
    item.managerName = row.managerName
    item.contractAmount = row.contractAmount
    item.outputTarget = row.outputTarget
    item.outputDone = row.outputDone
    item.progressPct = row.progressPct
    item.riskOpenCount = row.riskOpenCount
    item.statusCode = row.status
    item.status = BizService.projectStatusLabel(row.status)
    item.remark = row.remark
    return item
  }
}

export class ProjectRiskView {
  id: string = ''
  projectId: string = ''
  title: string = ''
  category: string = ''
  categoryLabel: string = ''
  level: string = ''
  levelLabel: string = ''
  status: string = ''
  statusCode: string = ''
  ownerName: string = ''

  static fromItem(row: ProjectRiskItem): ProjectRiskView {
    const item = new ProjectRiskView()
    item.id = row.id
    item.projectId = row.projectId
    item.title = row.title
    item.category = row.category
    item.categoryLabel = BizService.riskCategoryLabel(row.category)
    item.level = row.level
    item.levelLabel = BizService.riskLevelLabel(row.level)
    item.statusCode = row.status
    item.status = BizService.riskStatusLabel(row.status)
    item.ownerName = row.ownerName
    return item
  }
}

export class OutputRecordView {
  id: string = ''
  projectId: string = ''
  periodLabel: string = ''
  amount: number = 0
  note: string = ''
  status: string = ''
  statusCode: string = ''

  static fromItem(row: OutputRecordItem): OutputRecordView {
    const item = new OutputRecordView()
    item.id = row.id
    item.projectId = row.projectId
    item.periodLabel = row.periodLabel
    item.amount = row.amount
    item.note = row.note
    item.statusCode = row.status
    item.status = BizService.outputStatusLabel(row.status)
    return item
  }
}

export class BizService {
  static lastError: string = ''

  static projectStatusLabel(code: string): string {
    if (code === 'planned') return '立项'
    if (code === 'in_progress') return '在建'
    if (code === 'accepting') return '验收'
    if (code === 'archived') return '归档'
    return code
  }

  static riskStatusLabel(code: string): string {
    if (code === 'open') return '开放'
    if (code === 'handling') return '处置中'
    if (code === 'closed') return '已关闭'
    return code
  }

  static riskLevelLabel(code: string): string {
    if (code === 'info') return '提示'
    if (code === 'warn') return '警告'
    if (code === 'critical') return '严重'
    return code
  }

  static riskCategoryLabel(code: string): string {
    if (code === 'safety') return '安全'
    if (code === 'quality') return '质量'
    if (code === 'cost') return '成本'
    if (code === 'schedule') return '工期'
    return '其他'
  }

  static outputStatusLabel(code: string): string {
    if (code === 'draft') return '草稿'
    if (code === 'submitted') return '已提交'
    if (code === 'confirmed') return '已确认'
    return code
  }

  static formatAmount(n: number): string {
    if (n >= 100000000) {
      return `${(n / 100000000).toFixed(2)}亿`
    }
    if (n >= 10000) {
      return `${(n / 10000).toFixed(1)}万`
    }
    return `${n}`
  }

  static async listProjects(status: string = '', keyword: string = ''): Promise<EngProjectView[]> {
    let path = '/biz/projects?pageSize=100'
    if (status.length > 0 && status !== 'all') {
      path = `${path}&status=${status}`
    }
    if (keyword.length > 0) {
      path = `${path}&keyword=${encodeURIComponent(keyword)}`
    }
    const res = await HttpClient.get<EngProjectListData>(path)
    if (res.code !== 0 || res.data === undefined) {
      return []
    }
    const list: EngProjectView[] = []
    for (const row of res.data.list) {
      list.push(EngProjectView.fromItem(row))
    }
    return list
  }

  static async getProject(id: string): Promise<EngProjectView | null> {
    const res = await HttpClient.get<EngProjectItem>(`/biz/projects/${id}`)
    if (res.code !== 0 || res.data === undefined) {
      return null
    }
    return EngProjectView.fromItem(res.data)
  }

  static async createProject(req: CreateEngProjectRequest): Promise<EngProjectView | null> {
    BizService.lastError = ''
    const res = await HttpClient.post<EngProjectItem>('/biz/projects', req)
    if (res.code !== 0 || res.data === undefined) {
      BizService.lastError = res.message.length > 0 ? res.message : '创建未成功'
      return null
    }
    return EngProjectView.fromItem(res.data)
  }

  static async patchProjectStatus(id: string, status: string): Promise<EngProjectView | null> {
    BizService.lastError = ''
    const body = new PatchStatusRequest()
    body.status = status
    const res = await HttpClient.patch<EngProjectItem>(`/biz/projects/${id}/status`, body)
    if (res.code !== 0 || res.data === undefined || res.data === null) {
      BizService.lastError = res.message.length > 0 ? res.message : '状态更新未成功'
      return null
    }
    return EngProjectView.fromItem(res.data)
  }

  static async listRisks(status: string = ''): Promise<ProjectRiskView[]> {
    let path = '/biz/risks'
    if (status.length > 0 && status !== 'all') {
      path = `${path}?status=${status}`
    }
    const res = await HttpClient.get<ProjectRiskListData>(path)
    if (res.code !== 0 || res.data === undefined) {
      return []
    }
    const list: ProjectRiskView[] = []
    for (const row of res.data.list) {
      list.push(ProjectRiskView.fromItem(row))
    }
    return list
  }

  static async getRisk(id: string): Promise<ProjectRiskView | null> {
    const res = await HttpClient.get<ProjectRiskItem>(`/biz/risks/${id}`)
    if (res.code !== 0 || res.data === undefined) {
      return null
    }
    return ProjectRiskView.fromItem(res.data)
  }

  static async patchRiskStatus(id: string, status: string, ownerName: string = ''): Promise<ProjectRiskView | null> {
    const body = new PatchRiskStatusRequest()
    body.status = status
    body.ownerName = ownerName
    const res = await HttpClient.patch<ProjectRiskItem>(`/biz/risks/${id}/status`, body)
    if (res.code !== 0 || res.data === undefined) {
      return null
    }
    return ProjectRiskView.fromItem(res.data)
  }

  static async listOutputs(status: string = ''): Promise<OutputRecordView[]> {
    let path = '/biz/outputs'
    if (status.length > 0 && status !== 'all') {
      path = `${path}?status=${status}`
    }
    const res = await HttpClient.get<OutputRecordListData>(path)
    if (res.code !== 0 || res.data === undefined) {
      return []
    }
    const list: OutputRecordView[] = []
    for (const row of res.data.list) {
      list.push(OutputRecordView.fromItem(row))
    }
    return list
  }

  static async createOutput(req: CreateOutputRequest): Promise<OutputRecordView | null> {
    const res = await HttpClient.post<OutputRecordItem>('/biz/outputs', req)
    if (res.code !== 0 || res.data === undefined) {
      return null
    }
    return OutputRecordView.fromItem(res.data)
  }

  static async patchOutputStatus(id: string, status: string): Promise<OutputRecordView | null> {
    const body = new PatchStatusRequest()
    body.status = status
    const res = await HttpClient.patch<OutputRecordItem>(`/biz/outputs/${id}/status`, body)
    if (res.code !== 0 || res.data === undefined) {
      return null
    }
    return OutputRecordView.fromItem(res.data)
  }

  static async todayTodos(): Promise<TodayTodosData> {
    const res = await HttpClient.get<TodayTodosData>('/biz/todos/today')
    if (res.code !== 0 || res.data === undefined) {
      return new TodayTodosData()
    }
    return res.data
  }
}
