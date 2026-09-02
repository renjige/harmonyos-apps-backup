import { HttpClient } from './HttpClient'
import { EmptyPayload } from '../models/ApiModels'
import {
  CreateInspirationRequest,
  CreateMaterialRequest,
  CreateWorkRequest,
  HandcraftActionBody,
  HandcraftCategory,
  HandcraftCategoryListPayload,
  HandcraftChallenge,
  HandcraftChallengeWire,
  HandcraftFavoriteResult,
  HandcraftInspiration,
  HandcraftInspirationListPayload,
  HandcraftInteractionsWire,
  HandcraftLikeResult,
  HandcraftMaterial,
  HandcraftMaterialListPayload,
  HandcraftMaterialWire,
  HandcraftWork,
  HandcraftWorkListPayload,
  HandcraftWorkWire,
  MsgListPayload,
  MsgWire,
  MaterialActionBody,
  UpdateWorkRequest
} from '../models/HandcraftModels'

export class HandcraftBizService {
  private static username(): string {
    const u = AppStorage.get<string>('currentUsername')
    return u !== undefined && u !== null ? u : ''
  }

  private static mapWorks(wires: HandcraftWorkWire[]): HandcraftWork[] {
    const out: HandcraftWork[] = []
    for (const w of wires) {
      out.push(HandcraftWork.fromWire(w))
    }
    return out
  }

  static async loadCategories(): Promise<HandcraftCategory[]> {
    const res = await HttpClient.get<HandcraftCategoryListPayload>('/biz/handcraft/categories')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: HandcraftCategory[] = []
      for (const w of res.data.list) {
        out.push(HandcraftCategory.fromWire(w))
      }
      return out
    }
    return []
  }

  static async loadWorks(filter?: WorkListFilter): Promise<HandcraftWork[]> {
    let path = '/biz/handcraft/works?'
    if (filter !== undefined) {
      if (filter.category.length > 0) {
        path += `category=${encodeURIComponent(filter.category)}&`
      }
      if (filter.userId.length > 0) {
        path += `userId=${encodeURIComponent(filter.userId)}&`
      }
      if (filter.tag.length > 0) {
        path += `tag=${encodeURIComponent(filter.tag)}&`
      }
      if (filter.q.length > 0) {
        path += `q=${encodeURIComponent(filter.q)}&`
      }
      if (filter.sort.length > 0) {
        path += `sort=${encodeURIComponent(filter.sort)}&`
      }
    }
    const res = await HttpClient.get<HandcraftWorkListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return HandcraftBizService.mapWorks(res.data.list)
    }
    return []
  }

  static async findWork(id: string): Promise<HandcraftWork | undefined> {
    const user = HandcraftBizService.username()
    let path = `/biz/handcraft/works/${id}`
    if (user.length > 0) {
      path += `?username=${encodeURIComponent(user)}`
    }
    const res = await HttpClient.get<HandcraftWorkWire>(path)
    if (res.code === 0 && res.data !== undefined) {
      return HandcraftWork.fromWire(res.data)
    }
    return undefined
  }

  static async loadFavorites(): Promise<HandcraftWork[]> {
    const user = HandcraftBizService.username()
    if (user.length === 0) {
      return []
    }
    const res = await HttpClient.get<HandcraftWorkListPayload>(
      `/biz/handcraft/favorites?username=${encodeURIComponent(user)}`
    )
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return HandcraftBizService.mapWorks(res.data.list)
    }
    return []
  }

  static async loadInspirations(userOnly: boolean): Promise<HandcraftInspiration[]> {
    let path = '/biz/handcraft/inspirations?'
    if (userOnly) {
      const user = HandcraftBizService.username()
      if (user.length === 0) {
        return []
      }
      path += `username=${encodeURIComponent(user)}&`
    }
    const res = await HttpClient.get<HandcraftInspirationListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: HandcraftInspiration[] = []
      for (const w of res.data.list) {
        out.push(HandcraftInspiration.fromWire(w))
      }
      return out
    }
    return []
  }

  static async createWork(req: CreateWorkRequest): Promise<HandcraftWork | undefined> {
    req.username = HandcraftBizService.username()
    req.userName = req.username
    const res = await HttpClient.post<HandcraftWorkWire>('/biz/handcraft/works', req)
    if (res.code === 0 && res.data !== undefined) {
      return HandcraftWork.fromWire(res.data)
    }
    return undefined
  }

  static async updateWork(id: string, req: UpdateWorkRequest): Promise<HandcraftWork | undefined> {
    req.username = HandcraftBizService.username()
    const res = await HttpClient.put<HandcraftWorkWire>(`/biz/handcraft/works/${id}`, req)
    if (res.code === 0 && res.data !== undefined) {
      return HandcraftWork.fromWire(res.data)
    }
    return undefined
  }

  static async createInspiration(req: CreateInspirationRequest): Promise<boolean> {
    req.username = HandcraftBizService.username()
    const res = await HttpClient.post<HandcraftInspiration>('/biz/handcraft/inspirations', req)
    return res.code === 0
  }

  static async loadInteractions(workId: string): Promise<HandcraftInteractionsWire> {
    const user = HandcraftBizService.username()
    let path = `/biz/handcraft/works/${workId}/interactions`
    if (user.length > 0) {
      path += `?username=${encodeURIComponent(user)}`
    }
    const res = await HttpClient.get<HandcraftInteractionsWire>(path)
    if (res.code === 0 && res.data !== undefined) {
      return res.data
    }
    const empty = new HandcraftInteractionsWire()
    return empty
  }

  static async toggleFavorite(workId: string): Promise<HandcraftFavoriteResult | undefined> {
    const body = new HandcraftActionBody()
    body.username = HandcraftBizService.username()
    const res = await HttpClient.post<HandcraftFavoriteResult>(
      `/biz/handcraft/works/${workId}/favorite`,
      body
    )
    if (res.code === 0 && res.data !== undefined) {
      return res.data
    }
    return undefined
  }

  static async loadGuides(): Promise<HandcraftWork[]> {
    const res = await HttpClient.get<HandcraftWorkListPayload>('/biz/handcraft/guides')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return HandcraftBizService.mapWorks(res.data.list)
    }
    return []
  }

  static async findGuide(id: string): Promise<HandcraftWork | undefined> {
    const res = await HttpClient.get<HandcraftWorkWire>(`/biz/handcraft/guides/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return HandcraftWork.fromWire(res.data)
    }
    return undefined
  }

  static async loadCurrentChallenge(): Promise<HandcraftChallenge | undefined> {
    const user = HandcraftBizService.username()
    let path = '/biz/handcraft/challenges/current'
    if (user.length > 0) {
      path += `?username=${encodeURIComponent(user)}`
    }
    const res = await HttpClient.get<HandcraftChallengeWire>(path)
    if (res.code === 0 && res.data !== undefined) {
      return HandcraftChallenge.fromWire(res.data)
    }
    return undefined
  }

  static async joinChallenge(challengeId: string): Promise<boolean> {
    const body = new HandcraftActionBody()
    body.username = HandcraftBizService.username()
    const res = await HttpClient.post<HandcraftLikeResult>(
      `/biz/handcraft/challenges/${challengeId}/join`,
      body
    )
    return res.code === 0
  }

  static async loadMaterials(): Promise<HandcraftMaterial[]> {
    const user = HandcraftBizService.username()
    if (user.length === 0) {
      return []
    }
    const res = await HttpClient.get<HandcraftMaterialListPayload>(
      `/biz/handcraft/materials?username=${encodeURIComponent(user)}`
    )
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: HandcraftMaterial[] = []
      for (const w of res.data.list) {
        out.push(HandcraftMaterial.fromWire(w))
      }
      return out
    }
    return []
  }

  static async createMaterial(req: CreateMaterialRequest): Promise<boolean> {
    req.username = HandcraftBizService.username()
    const res = await HttpClient.post<HandcraftMaterialWire>('/biz/handcraft/materials', req)
    return res.code === 0
  }

  static async deleteMaterial(id: string): Promise<boolean> {
    const body = new MaterialActionBody()
    body.username = HandcraftBizService.username()
    const res = await HttpClient.post<EmptyPayload>(`/biz/handcraft/materials/${id}/delete`, body)
    return res.code === 0
  }

  static async loadMessages(): Promise<MsgWire[]> {
    const res = await HttpClient.get<MsgListPayload>('/messages')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return res.data.list
    }
    return []
  }
}

export class WorkListFilter {
  category: string = ''
  userId: string = ''
  tag: string = ''
  q: string = ''
  sort: string = ''
}
