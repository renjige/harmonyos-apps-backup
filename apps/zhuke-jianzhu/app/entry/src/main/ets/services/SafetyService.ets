import { HttpClient } from './HttpClient'
import { ApiResponse, CreateSafetyRequest, EmptyPayload, PatchStatusNoteRequest } from '../models/ApiModels'

export class SafetyItem {
  id: string = ''
  projectId: string = ''
  projectName: string = ''
  title: string = ''
  type: string = 'routine'
  level: string = 'info'
  status: string = 'open'
  location: string = ''
  inspectorName: string = ''
  findings: string = ''
  rectificationNote: string = ''
  dueAt: string = ''
  closedAt: string = ''
  createdAt: string = ''
  updatedAt: string = ''
}

class SafetyListData {
  list: SafetyItem[] = []
}

export class SafetyService {
  static lastError: string = ''

  static levelLabel(level: string): string {
    if (level === 'critical') return '重大'
    if (level === 'warn') return '一般'
    return '提示'
  }

  static levelColor(level: string): string {
    if (level === 'critical') return '#BE123C'
    if (level === 'warn') return '#B45309'
    return '#0369A1'
  }

  static statusLabel(status: string): string {
    if (status === 'open') return '待处置'
    if (status === 'rectifying') return '整改中'
    return '已关闭'
  }

  static typeLabel(type: string): string {
    if (type === 'special') return '专项巡检'
    if (type === 'rectification') return '整改复查'
    return '日常巡检'
  }

  static async list(): Promise<SafetyItem[]> {
    SafetyService.lastError = ''
    try {
      const res: ApiResponse<SafetyListData> = await HttpClient.get<SafetyListData>('/biz/safety')
      if (res.code === 0 && res.data !== undefined) {
        return res.data.list
      }
      SafetyService.lastError = res.message.length > 0 ? res.message : '加载失败'
    } catch {
      SafetyService.lastError = '网络不可用'
    }
    return []
  }

  static async create(input: CreateSafetyRequest): Promise<boolean> {
    SafetyService.lastError = ''
    try {
      const res: ApiResponse<EmptyPayload> = await HttpClient.post<EmptyPayload>('/biz/safety', input)
      if (res.code !== 0) {
        SafetyService.lastError = res.message.length > 0 ? res.message : '创建未成功'
      }
      return res.code === 0
    } catch {
      SafetyService.lastError = '网络不可用'
    }
    return false
  }

  static async transitionStatus(id: string, status: string, note: string): Promise<boolean> {
    SafetyService.lastError = ''
    try {
      const body = new PatchStatusNoteRequest()
      body.status = status
      body.note = note
      const res: ApiResponse<EmptyPayload> = await HttpClient.patch<EmptyPayload>(`/biz/safety/${id}/status`, body)
      if (res.code !== 0) {
        SafetyService.lastError = res.message.length > 0 ? res.message : '状态更新未成功'
      }
      return res.code === 0
    } catch {
      SafetyService.lastError = '网络不可用'
    }
    return false
  }
}
