import { HttpClient } from './HttpClient'
import {
  AlbumItem,
  AlbumListPayload,
  AlbumWriteRequest,
  ArtworkItem,
  ArtworkListPayload,
  ArtworkWriteRequest,
  CatalogItem,
  CatalogItemWire,
  CatalogListPayload,
  ChildItem,
  ChildListPayload,
  ChildWriteRequest,
  MsgItem,
  MsgListPayload
} from '../models/KagModels'

const BASE = '/biz/kids-art-gallery'

export class KagBizService {
  static currentUser(): string {
    return AppStorage.get<string>('currentUsername') ?? ''
  }

  static async loadThemes(): Promise<CatalogItem[]> {
    const res = await HttpClient.get<CatalogListPayload>(`${BASE}/themes`)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return KagBizService.mapCatalog(res.data.list)
    }
    return []
  }

  static async loadHalls(): Promise<CatalogItem[]> {
    const res = await HttpClient.get<CatalogListPayload>(`${BASE}/halls`)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return KagBizService.mapCatalog(res.data.list)
    }
    return []
  }

  static async loadMilestones(): Promise<CatalogItem[]> {
    const res = await HttpClient.get<CatalogListPayload>(`${BASE}/milestones`)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return KagBizService.mapCatalog(res.data.list)
    }
    return []
  }

  static async loadGuides(): Promise<CatalogItem[]> {
    const res = await HttpClient.get<CatalogListPayload>(`${BASE}/guides`)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return KagBizService.mapCatalog(res.data.list)
    }
    return []
  }

  private static mapCatalog(wires: CatalogItemWire[]): CatalogItem[] {
    const out: CatalogItem[] = []
    for (const w of wires) {
      out.push(CatalogItem.fromWire(w))
    }
    return out
  }

  static findCatalog(list: CatalogItem[], id: string): CatalogItem | undefined {
    for (const item of list) {
      if (item.id === id) {
        return item
      }
    }
    return undefined
  }

  static async loadWorks(childId: string, query: string, albumId: string): Promise<ArtworkItem[]> {
    const uid = KagBizService.currentUser()
    if (uid.length === 0) {
      return []
    }
    let path = `${BASE}/works?userId=${encodeURIComponent(uid)}`
    if (childId.length > 0) {
      path = `${path}&childId=${encodeURIComponent(childId)}`
    }
    if (query.length > 0) {
      path = `${path}&q=${encodeURIComponent(query)}`
    }
    if (albumId.length > 0) {
      path = `${path}&albumId=${encodeURIComponent(albumId)}`
    }
    const res = await HttpClient.get<ArtworkListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: ArtworkItem[] = []
      for (const w of res.data.list) {
        out.push(ArtworkItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static findWork(list: ArtworkItem[], id: string): ArtworkItem | undefined {
    for (const item of list) {
      if (item.id === id) {
        return item
      }
    }
    return undefined
  }

  static firstWork(list: ArtworkItem[]): ArtworkItem | undefined {
    for (const item of list) {
      return item
    }
    return undefined
  }

  static firstAlbum(list: AlbumItem[]): AlbumItem | undefined {
    for (const item of list) {
      return item
    }
    return undefined
  }

  static async createWork(body: ArtworkWriteRequest): Promise<boolean> {
    body.userId = KagBizService.currentUser()
    const res = await HttpClient.post<ArtworkItem>(`${BASE}/works`, body)
    return res.code === 0
  }

  static async deleteWork(id: string): Promise<boolean> {
    const res = await HttpClient.delete<ArtworkItem>(`${BASE}/works/${id}`)
    return res.code === 0
  }

  static async patchWorkAlbum(id: string, albumIds: string[]): Promise<boolean> {
    const body = new ArtworkWriteRequest()
    body.userId = KagBizService.currentUser()
    body.albumIds = albumIds
    const res = await HttpClient.put<ArtworkItem>(`${BASE}/works/${id}`, body)
    return res.code === 0
  }

  static async loadAlbums(childId: string): Promise<AlbumItem[]> {
    const uid = KagBizService.currentUser()
    if (uid.length === 0) {
      return []
    }
    let path = `${BASE}/albums?userId=${encodeURIComponent(uid)}`
    if (childId.length > 0) {
      path = `${path}&childId=${encodeURIComponent(childId)}`
    }
    const res = await HttpClient.get<AlbumListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: AlbumItem[] = []
      for (const w of res.data.list) {
        out.push(AlbumItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static findAlbum(list: AlbumItem[], id: string): AlbumItem | undefined {
    for (const item of list) {
      if (item.id === id) {
        return item
      }
    }
    return undefined
  }

  static async createAlbum(body: AlbumWriteRequest): Promise<boolean> {
    body.userId = KagBizService.currentUser()
    const res = await HttpClient.post<AlbumItem>(`${BASE}/albums`, body)
    return res.code === 0
  }

  static async deleteAlbum(id: string): Promise<boolean> {
    const res = await HttpClient.delete<AlbumItem>(`${BASE}/albums/${id}`)
    return res.code === 0
  }

  static async loadChildren(): Promise<ChildItem[]> {
    const uid = KagBizService.currentUser()
    if (uid.length === 0) {
      return []
    }
    const res = await HttpClient.get<ChildListPayload>(`${BASE}/children?userId=${encodeURIComponent(uid)}`)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: ChildItem[] = []
      for (const w of res.data.list) {
        out.push(ChildItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async createChild(body: ChildWriteRequest): Promise<boolean> {
    body.userId = KagBizService.currentUser()
    body.name = body.title
    const res = await HttpClient.post<ChildItem>(`${BASE}/children`, body)
    return res.code === 0
  }

  static async deleteChild(id: string): Promise<boolean> {
    const res = await HttpClient.delete<ChildItem>(`${BASE}/children/${id}`)
    return res.code === 0
  }

  static async loadMessages(): Promise<MsgItem[]> {
    const res = await HttpClient.get<MsgListPayload>('/messages')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: MsgItem[] = []
      for (const w of res.data.list) {
        out.push(MsgItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static thisMonthCount(works: ArtworkItem[]): number {
    const now = new Date()
    const prefix = `${now.getFullYear()}-${KagBizService.pad(now.getMonth() + 1)}`
    let n = 0
    for (const w of works) {
      if (w.createdOn.indexOf(prefix) === 0) {
        n++
      }
    }
    return n
  }

  static pad(n: number): string {
    if (n < 10) {
      return `0${n}`
    }
    return `${n}`
  }

  static today(): string {
    const d = new Date()
    return `${d.getFullYear()}-${KagBizService.pad(d.getMonth() + 1)}-${KagBizService.pad(d.getDate())}`
  }
}
