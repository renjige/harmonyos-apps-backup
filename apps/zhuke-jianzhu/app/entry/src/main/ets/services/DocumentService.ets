import { HttpClient } from './HttpClient'
import { ApiResponse, EmptyPayload } from '../models/ApiModels'

export class DocItem {
  id: string = ''
  projectId: string = ''
  projectName: string = ''
  title: string = ''
  type: string = 'drawing'
  authorName: string = ''
  version: string = 'v1.0'
  status: string = 'draft'
  fileNote: string = ''
  createdAt: string = ''
  updatedAt: string = ''
}

class DocListData {
  list: DocItem[] = []
}

export class DocumentService {
  static typeLabel(type: string): string {
    if (type === 'drawing') return '施工图纸'
    if (type === 'contract') return '合同文件'
    if (type === 'report') return '检验报告'
    if (type === 'approval') return '审批文件'
    if (type === 'log') return '施工日志'
    return '其他'
  }

  static statusLabel(status: string): string {
    if (status === 'draft') return '草稿'
    if (status === 'reviewing') return '审核中'
    if (status === 'approved') return '已批准'
    if (status === 'archived') return '已归档'
    return status
  }

  static statusColor(status: string): string {
    if (status === 'approved') return '#0F766E'
    if (status === 'reviewing') return '#B45309'
    if (status === 'archived') return '#64748B'
    return '#94A3B8'
  }

  static async list(): Promise<DocItem[]> {
    try {
      const res: ApiResponse<DocListData> = await HttpClient.get<DocListData>('/biz/documents')
      if (res.code === 0 && res.data !== undefined) {
        return res.data.list
      }
    } catch { }
    return []
  }

  static async create(input: DocItem): Promise<boolean> {
    try {
      const res: ApiResponse<EmptyPayload> = await HttpClient.post<EmptyPayload>('/biz/documents', input)
      return res.code === 0
    } catch { }
    return false
  }
}
