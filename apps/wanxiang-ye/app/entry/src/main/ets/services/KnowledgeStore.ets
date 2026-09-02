import { UserKnowledge } from '../models/UserKnowledgeModels'
import { WanXiangLocalStore } from './WanXiangLocalStore'
import { TimelineService } from './TimelineService'

const KEY_ITEMS = 'user_knowledge_items'

class KnowledgeWire {
  id: string = ''
  title: string = ''
  body: string = ''
  categoryKey: string = 'other'
  tags: string = ''
  source: string = 'user'
  linkedInfoId: string = ''
  favorited: boolean = false
  inReviewQueue: boolean = false
  createdAt: string = ''
  updatedAt: string = ''
}

export class KnowledgeStore {
  static async listAll(): Promise<UserKnowledge[]> {
    const raw = await WanXiangLocalStore.getString(KEY_ITEMS, '')
    return KnowledgeStore.parseList(raw)
  }

  static async findById(id: string): Promise<UserKnowledge | undefined> {
    const list = await KnowledgeStore.listAll()
    for (const item of list) {
      if (item.id === id) {
        return item
      }
    }
    return undefined
  }

  static async create(
    title: string,
    body: string,
    categoryKey: string,
    tags: string,
    linkedInfoId: string = ''
  ): Promise<UserKnowledge> {
    const id = WanXiangLocalStore.newId('kn')
    const source = linkedInfoId.length > 0 ? 'from_featured' : 'user'
    const item = UserKnowledge.create(id, title, body, categoryKey, tags, source, linkedInfoId)
    const list = await KnowledgeStore.listAll()
    list.unshift(item)
    await KnowledgeStore.persist(list)
    await TimelineService.log('knowledge_create', `新建知识「${title}」`, id)
    return item
  }

  static async update(item: UserKnowledge): Promise<void> {
    const list = await KnowledgeStore.listAll()
    const next: UserKnowledge[] = []
    for (const x of list) {
      if (x.id === item.id) {
        item.updatedAt = UserKnowledge.nowIso()
        next.push(item)
      } else {
        next.push(x)
      }
    }
    await KnowledgeStore.persist(next)
  }

  static async remove(id: string): Promise<boolean> {
    const list = await KnowledgeStore.listAll()
    const next: UserKnowledge[] = []
    let removed = false
    for (const x of list) {
      if (x.id === id) {
        removed = true
      } else {
        next.push(x)
      }
    }
    if (removed) {
      await KnowledgeStore.persist(next)
    }
    return removed
  }

  static async count(): Promise<number> {
    const list = await KnowledgeStore.listAll()
    return list.length
  }

  static async search(keyword: string, categoryKey: string = ''): Promise<UserKnowledge[]> {
    const q = keyword.trim().toLowerCase()
    const list = await KnowledgeStore.listAll()
    const out: UserKnowledge[] = []
    for (const item of list) {
      if (categoryKey.length > 0 && item.categoryKey !== categoryKey) {
        continue
      }
      if (q.length === 0) {
        out.push(item)
        continue
      }
      const hay = `${item.title} ${item.body} ${item.tags}`.toLowerCase()
      if (hay.indexOf(q) >= 0) {
        out.push(item)
      }
    }
    return out
  }

  static async fromFeatured(infoId: string, title: string, summary: string, body: string): Promise<UserKnowledge> {
    return KnowledgeStore.create(title, `${summary}\n\n${body}`, 'reading', '来自精选', infoId)
  }

  private static async persist(list: UserKnowledge[]): Promise<void> {
    const lines: string[] = []
    for (const item of list) {
      lines.push(KnowledgeStore.serializeJson(item))
    }
    await WanXiangLocalStore.putString(KEY_ITEMS, lines.join('\n'))
  }

  private static parseList(raw: string): UserKnowledge[] {
    const out: UserKnowledge[] = []
    if (raw.length === 0) {
      return out
    }
    if (raw.indexOf('{') === 0 || raw.indexOf('[') === 0) {
      const lines = raw.split('\n')
      for (const line of lines) {
        const item = KnowledgeStore.deserializeJson(line)
        if (item !== undefined) {
          out.push(item)
        }
      }
      if (out.length > 0) {
        return out
      }
    }
    if (raw.indexOf('||') >= 0) {
      const chunks = raw.split('||')
      for (const chunk of chunks) {
        const item = KnowledgeStore.deserializeLegacy(chunk)
        if (item !== undefined) {
          out.push(item)
        }
      }
      if (out.length > 0) {
        void KnowledgeStore.persist(out)
      }
      return out
    }
    const legacy = KnowledgeStore.deserializeLegacy(raw)
    if (legacy !== undefined) {
      out.push(legacy)
      void KnowledgeStore.persist(out)
    }
    return out
  }

  private static serializeJson(item: UserKnowledge): string {
    return `{"id":${JSON.stringify(item.id)},"title":${JSON.stringify(item.title)},"body":${JSON.stringify(item.body)},"categoryKey":${JSON.stringify(item.categoryKey)},"tags":${JSON.stringify(item.tags)},"source":${JSON.stringify(item.source)},"linkedInfoId":${JSON.stringify(item.linkedInfoId)},"favorited":${item.favorited},"inReviewQueue":${item.inReviewQueue},"createdAt":${JSON.stringify(item.createdAt)},"updatedAt":${JSON.stringify(item.updatedAt)}}`
  }

  private static deserializeJson(line: string): UserKnowledge | undefined {
    if (line.length === 0 || line.indexOf('{') !== 0) {
      return undefined
    }
    try {
      const w = JSON.parse(line) as KnowledgeWire
      if (w.id.length === 0) {
        return undefined
      }
      const k = new UserKnowledge()
      k.id = w.id
      k.title = w.title
      k.body = w.body
      k.categoryKey = w.categoryKey.length > 0 ? w.categoryKey : 'other'
      k.tags = w.tags
      k.source = w.source.length > 0 ? w.source : 'user'
      k.linkedInfoId = w.linkedInfoId
      k.favorited = w.favorited === true
      k.inReviewQueue = w.inReviewQueue === true
      k.createdAt = w.createdAt
      k.updatedAt = w.updatedAt
      return k
    } catch {
      return undefined
    }
  }

  private static deserializeLegacy(chunk: string): UserKnowledge | undefined {
    const parts = chunk.split('|')
    if (parts.length < 11) {
      return undefined
    }
    const k = new UserKnowledge()
    k.id = parts[0]
    k.title = parts[1]
    if (parts.length === 11) {
      k.body = parts[2]
      k.categoryKey = parts[3].length > 0 ? parts[3] : 'other'
      k.tags = parts[4]
      k.source = parts[5].length > 0 ? parts[5] : 'user'
      k.linkedInfoId = parts[6]
      k.favorited = parts[7] === '1'
      k.inReviewQueue = parts[8] === '1'
      k.createdAt = parts[9]
      k.updatedAt = parts[10]
      return k
    }
    const bodyEnd = parts.length - 8
    const bodyParts: string[] = []
    for (let i = 2; i < bodyEnd; i++) {
      bodyParts.push(parts[i])
    }
    k.body = bodyParts.join('|')
    k.categoryKey = parts[parts.length - 8].length > 0 ? parts[parts.length - 8] : 'other'
    k.tags = parts[parts.length - 7]
    k.source = parts[parts.length - 6].length > 0 ? parts[parts.length - 6] : 'user'
    k.linkedInfoId = parts[parts.length - 5]
    k.favorited = parts[parts.length - 4] === '1'
    k.inReviewQueue = parts[parts.length - 3] === '1'
    k.createdAt = parts[parts.length - 2]
    k.updatedAt = parts[parts.length - 1]
    return k
  }
}
