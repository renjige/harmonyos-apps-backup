import { HttpClient } from './HttpClient'
import { ApiResponse, CreateQualityRequest, EmptyPayload, PatchStatusNoteRequest } from '../models/ApiModels'

export class QualityItem {
  id: string = ''
  projectId: string = ''
  projectName: string = ''
  title: string = ''
  type: string = 'structure'
  level: string = 'minor'
  status: string = 'open'
  location: string = ''
  discovererName: string = ''
  description: string = ''
  rectificationNote: string = ''
  dueAt: string = ''
  createdAt: string = ''
  updatedAt: string = ''
}

class QualityListData {
  list: QualityItem[] = []
}

export class QualityService {
  static lastError: string = ''

  static levelLabel(level: string): string {
    if (level === 'critical') return '严重'
    if (level === 'major') return '较重'
    return '轻微'
  }

  static levelColor(level: string): string {
    if (level === 'critical') return '#BE123C'
    if (level === 'major') return '#B45309'
    return '#0369A1'
  }

  static statusLabel(status: string): string {
    if (status === 'open') return '已发现'
    if (status === 'rectifying') return '整改中'
    if (status === 'verified') return '验收中'
    return '已关闭'
  }

  static typeLabel(type: string): string {
    if (type === 'structure') return '结构质量'
    if (type === 'process') return '工艺质量'
    if (type === 'material') return '材料质量'
    if (type === 'safety_prod') return '安全生产'
    return '其他'
  }

  static async list(): Promise<QualityItem[]> {
    QualityService.lastError = ''
    try {
      const res: ApiResponse<QualityListData> = await HttpClient.get<QualityListData>('/biz/quality')
      if (res.code === 0 && res.data !== undefined) {
        return res.data.list
      }
      QualityService.lastError = res.message.length > 0 ? res.message : '加载失败'
    } catch {
      QualityService.lastError = '网络不可用'
    }
    return []
  }

  static async create(input: CreateQualityRequest): Promise<boolean> {
    QualityService.lastError = ''
    try {
      const res: ApiResponse<EmptyPayload> = await HttpClient.post<EmptyPayload>('/biz/quality', input)
      if (res.code !== 0) {
        QualityService.lastError = res.message.length > 0 ? res.message : '创建未成功'
      }
      return res.code === 0
    } catch {
      QualityService.lastError = '网络不可用'
    }
    return false
  }

  static async transitionStatus(id: string, status: string, note: string): Promise<boolean> {
    QualityService.lastError = ''
    try {
      const body = new PatchStatusNoteRequest()
      body.status = status
      body.note = note
      const res: ApiResponse<EmptyPayload> = await HttpClient.patch<EmptyPayload>(`/biz/quality/${id}/status`, body)
      if (res.code !== 0) {
        QualityService.lastError = res.message.length > 0 ? res.message : '状态更新未成功'
      }
      return res.code === 0
    } catch {
      QualityService.lastError = '网络不可用'
    }
    return false
  }
}
