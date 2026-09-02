import { Spark } from '../models/UserKnowledgeModels'
import { WanXiangLocalStore } from './WanXiangLocalStore'
import { TimelineService } from './TimelineService'

const KEY_SPARKS = 'user_sparks'

export class SparkStore {
  static async listAll(): Promise<Spark[]> {
    const raw = await WanXiangLocalStore.getString(KEY_SPARKS, '')
    return SparkStore.parseList(raw)
  }

  static async create(title: string, body: string, tags: string): Promise<Spark> {
    const id = WanXiangLocalStore.newId('sp')
    const item = Spark.create(id, title, body, tags)
    const list = await SparkStore.listAll()
    list.unshift(item)
    await SparkStore.persist(list)
    await TimelineService.log('spark_create', `记录灵感「${title}」`, id)
    return item
  }

  static async remove(id: string): Promise<boolean> {
    const list = await SparkStore.listAll()
    const next: Spark[] = []
    let removed = false
    for (const x of list) {
      if (x.id === id) {
        removed = true
      } else {
        next.push(x)
      }
    }
    if (removed) {
      await SparkStore.persist(next)
    }
    return removed
  }

  static async count(): Promise<number> {
    const list = await SparkStore.listAll()
    return list.length
  }

  static async search(keyword: string): Promise<Spark[]> {
    const q = keyword.trim().toLowerCase()
    const list = await SparkStore.listAll()
    const out: Spark[] = []
    for (const item of list) {
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

  private static async persist(list: Spark[]): Promise<void> {
    const parts: string[] = []
    for (const item of list) {
      parts.push(`${item.id}|${item.title}|${item.body}|${item.tags}|${item.createdAt}`)
    }
    await WanXiangLocalStore.putString(KEY_SPARKS, parts.join('||'))
  }

  private static parseList(raw: string): Spark[] {
    const out: Spark[] = []
    if (raw.length === 0) {
      return out
    }
    const chunks = raw.split('||')
    for (const chunk of chunks) {
      const parts = chunk.split('|')
      if (parts.length >= 5) {
        const s = new Spark()
        s.id = parts[0]
        s.title = parts[1]
        s.body = parts[2]
        s.tags = parts[3]
        s.createdAt = parts[4]
        out.push(s)
      }
    }
    return out
  }
}
