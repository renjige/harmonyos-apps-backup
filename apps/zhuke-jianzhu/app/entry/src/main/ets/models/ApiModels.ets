export class ApiResponse<T> {
  code: number = 0
  message: string = ''
  data: T | undefined = undefined
}

export class LoginRequest {
  username: string = ''
  password: string = ''
  tenantId: string = ''

  toJsonString(): string {
    return `{"username":${JSON.stringify(this.username)},"password":${JSON.stringify(this.password)},"tenantId":${JSON.stringify(this.tenantId)}}`
  }
}

export class RegisterRequest {
  username: string = ''
  password: string = ''
  realName: string = ''
  phone: string = ''
  inviteCode: string = ''
  tenantId: string = ''

  toJsonString(): string {
    return `{"username":${JSON.stringify(this.username)},"password":${JSON.stringify(this.password)},"realName":${JSON.stringify(this.realName)},"phone":${JSON.stringify(this.phone)},"inviteCode":${JSON.stringify(this.inviteCode)},"tenantId":${JSON.stringify(this.tenantId)}}`
  }
}

export class LoginResponse {
  accessToken: string = ''
}

export class AiChatRequest {
  prompt: string = ''
  context: string = ''
}

export class AiChatResponse {
  reply: string = ''
}

export class AiAnalyzeRequest {
  payload: string = ''
  type: string = ''
}

export class AiAnalyzeResponse {
  summary: string = ''
  highlight1: string = ''
  highlight2: string = ''
}

export class AiGenerateRequest {
  template: string = ''
  variables: string = ''
}

export class AiGenerateResponse {
  content: string = ''
}

export class EmptyPayload {
}

export class EngProjectItem {
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
  planStart: string = ''
  planEnd: string = ''
  remark: string = ''
  createdAt: string = ''
  updatedAt: string = ''
}

export class EngProjectListData {
  list: EngProjectItem[] = []
  page: number = 1
  pageSize: number = 50
  total: number = 0
}

export class CreateEngProjectRequest {
  name: string = ''
  code: string = ''
  address: string = ''
  clientName: string = ''
  managerName: string = ''
  contractAmount: number = 0
  outputTarget: number = 0
  planStart: string = ''
  planEnd: string = ''
  remark: string = ''

  toJsonString(): string {
    return `{"name":${JSON.stringify(this.name)},"code":${JSON.stringify(this.code)},"address":${JSON.stringify(this.address)},"clientName":${JSON.stringify(this.clientName)},"managerName":${JSON.stringify(this.managerName)},"contractAmount":${this.contractAmount},"outputTarget":${this.outputTarget},"planStart":${JSON.stringify(this.planStart)},"planEnd":${JSON.stringify(this.planEnd)},"remark":${JSON.stringify(this.remark)}}`
  }
}

export class PatchStatusRequest {
  status: string = ''

  toJsonString(): string {
    return `{"status":${JSON.stringify(this.status)}}`
  }
}

export class ProjectRiskItem {
  id: string = ''
  projectId: string = ''
  title: string = ''
  category: string = ''
  level: string = ''
  status: string = ''
  ownerName: string = ''
  dueAt: string = ''
  createdAt: string = ''
  updatedAt: string = ''
}

export class ProjectRiskListData {
  list: ProjectRiskItem[] = []
  total: number = 0
}

export class PatchRiskStatusRequest {
  status: string = ''
  ownerName: string = ''

  toJsonString(): string {
    return `{"status":${JSON.stringify(this.status)},"ownerName":${JSON.stringify(this.ownerName)}}`
  }
}

/** safety / quality 状态流转 */
export class PatchStatusNoteRequest {
  status: string = ''
  note: string = ''

  toJsonString(): string {
    return `{"status":${JSON.stringify(this.status)},"note":${JSON.stringify(this.note)}}`
  }
}

export class CreateSafetyRequest {
  title: string = ''
  type: string = 'routine'
  level: string = 'info'
  location: string = ''
  inspectorName: string = ''
  findings: string = ''
  dueAt: string = ''
  projectName: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"type":${JSON.stringify(this.type)},"level":${JSON.stringify(this.level)},"location":${JSON.stringify(this.location)},"inspectorName":${JSON.stringify(this.inspectorName)},"findings":${JSON.stringify(this.findings)},"dueAt":${JSON.stringify(this.dueAt)},"projectName":${JSON.stringify(this.projectName)}}`
  }
}

export class CreateQualityRequest {
  title: string = ''
  type: string = 'structure'
  level: string = 'minor'
  location: string = ''
  discovererName: string = ''
  description: string = ''
  dueAt: string = ''
  projectName: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"type":${JSON.stringify(this.type)},"level":${JSON.stringify(this.level)},"location":${JSON.stringify(this.location)},"discovererName":${JSON.stringify(this.discovererName)},"description":${JSON.stringify(this.description)},"dueAt":${JSON.stringify(this.dueAt)},"projectName":${JSON.stringify(this.projectName)}}`
  }
}

export class OutputRecordItem {
  id: string = ''
  projectId: string = ''
  periodLabel: string = ''
  amount: number = 0
  note: string = ''
  status: string = ''
  createdAt: string = ''
  updatedAt: string = ''
}

export class OutputRecordListData {
  list: OutputRecordItem[] = []
  total: number = 0
}

export class CreateOutputRequest {
  projectId: string = ''
  periodLabel: string = ''
  amount: number = 0
  note: string = ''
  status: string = 'draft'
}

export class TodayTodosData {
  acceptingProjects: EngProjectItem[] = []
  openRisks: ProjectRiskItem[] = []
  criticalSafety: EngProjectItem[] = []
  openQuality: EngProjectItem[] = []
}

export class MessageItem {
  id: string = ''
  title: string = ''
  body: string = ''
  type: string = ''
  read: boolean = false
}

export class MessageListData {
  list: MessageItem[] = []
}

export class DashboardKpiItem {
  key: string = ''
  label: string = ''
  value: number = 0
}

export class DashboardKpiData {
  items: DashboardKpiItem[] = []
  activeProjects: number = 0
  outputRate: number = 0
  openRisks: number = 0
  openSafetyIssues: number = 0
  openQualityIssues: number = 0
  maintenanceEquipment: number = 0
  trend: number[] = []
}

export class FavoriteRowWire {
  type: string = ''
  id: string = ''
  title: string = ''
  createdAt: string = ''
}

export class HistoryRowWire {
  type: string = ''
  id: string = ''
  title: string = ''
  viewedAt: number = 0
}

export class FavoriteToggleRequest {
  type: string = ''
  id: string = ''
  title: string = ''

  toJsonString(): string {
    return `{"type":${JSON.stringify(this.type)},"id":${JSON.stringify(this.id)},"title":${JSON.stringify(this.title)}}`
  }
}

export class HistoryPushRequest {
  type: string = ''
  id: string = ''
  title: string = ''

  toJsonString(): string {
    return `{"type":${JSON.stringify(this.type)},"id":${JSON.stringify(this.id)},"title":${JSON.stringify(this.title)}}`
  }
}

export class FavoriteSyncRow {
  type: string = ''
  id: string = ''
  title: string = ''
  createdAt: string = ''
}

export class FavoritesSyncRequest {
  favorites: FavoriteSyncRow[] = []

  toJsonString(): string {
    const parts: string[] = []
    for (const row of this.favorites) {
      parts.push(
        `{"type":${JSON.stringify(row.type)},"id":${JSON.stringify(row.id)},"title":${JSON.stringify(row.title)},"createdAt":${JSON.stringify(row.createdAt)}}`
      )
    }
    return `{"favorites":[${parts.join(',')}]}`
  }
}
