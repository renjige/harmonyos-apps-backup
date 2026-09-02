import { ReviewQueueItem } from '../models/UserKnowledgeModels'
import { WanXiangLocalStore } from './WanXiangLocalStore'
import { LocalPrefs } from './LocalPrefs'
import { UserDataStore } from './UserDataStore'
import { TimelineService } from './TimelineService'

const KEY_QUEUE = 'review_queue'
const KEY_REVIEW_DONE = 'review_done_count'
const KEY_DONE_KEYS = 'review_done_keys'
const KEY_BOOTSTRAPPED = 'review_bootstrapped'

export class ReviewStore {
  /** 只读持久化队列，空队列时不再自动从稍后读/收藏回填（避免「记住了」后立刻复活）。 */
  static async getQueue(): Promise<ReviewQueueItem[]> {
    const raw = await WanXiangLocalStore.getString(KEY_QUEUE, '')
    return ReviewStore.parseQueue(raw)
  }

  /** 首次启动时从稍后读/收藏引导一次；之后仅通过「加入复习」等显式入口入队。 */
  static async ensureInitialQueue(): Promise<void> {
    const bootstrapped = await WanXiangLocalStore.getString(KEY_BOOTSTRAPPED, '')
    if (bootstrapped === '1') {
      return
    }
    const queue = await ReviewStore.getQueue()
    if (queue.length === 0) {
      await ReviewStore.bootstrapFromReadLater()
    }
    await WanXiangLocalStore.putString(KEY_BOOTSTRAPPED, '1')
  }

  static async bootstrapFromReadLater(): Promise<ReviewQueueItem[]> {
    const doneKeys = await ReviewStore.getDoneKeys()
    const laterIds = await UserDataStore.getReadLaterIds()
    const favIds = await UserDataStore.getFavoriteIds()
    const out: ReviewQueueItem[] = []
    const seen: string[] = []
    for (const id of laterIds) {
      const key = ReviewStore.itemKey(ReviewQueueItem.create(id, 'info'))
      if (seen.indexOf(key) < 0 && doneKeys.indexOf(key) < 0) {
        seen.push(key)
        out.push(ReviewQueueItem.create(id, 'info'))
      }
    }
    for (const id of favIds) {
      const key = ReviewStore.itemKey(ReviewQueueItem.create(id, 'info'))
      if (seen.indexOf(key) < 0 && doneKeys.indexOf(key) < 0) {
        seen.push(key)
        out.push(ReviewQueueItem.create(id, 'info'))
      }
    }
    await ReviewStore.persist(out)
    return out
  }

  static async addInfo(id: string): Promise<boolean> {
    const queue = await ReviewStore.getQueue()
    for (const item of queue) {
      if (item.refId === id && item.refType === 'info') {
        return false
      }
    }
    queue.unshift(ReviewQueueItem.create(id, 'info'))
    await ReviewStore.persist(queue)
    return true
  }

  static async addKnowledge(id: string): Promise<boolean> {
    const queue = await ReviewStore.getQueue()
    for (const item of queue) {
      if (item.refId === id && item.refType === 'knowledge') {
        return false
      }
    }
    queue.unshift(ReviewQueueItem.create(id, 'knowledge'))
    await ReviewStore.persist(queue)
    return true
  }

  static async rememberCurrent(item: ReviewQueueItem): Promise<void> {
    const queue = await ReviewStore.getQueue()
    const next: ReviewQueueItem[] = []
    for (const x of queue) {
      if (!(x.refId === item.refId && x.refType === item.refType)) {
        next.push(x)
      }
    }
    await ReviewStore.persist(next)
    await ReviewStore.addDoneKey(ReviewStore.itemKey(item))
    const done = await ReviewStore.getDoneCount()
    await LocalPrefs.putInt(KEY_REVIEW_DONE, done + 1)
    await TimelineService.log('review_done', '完成一次复习', item.refId)
  }

  static async deferCurrent(item: ReviewQueueItem): Promise<void> {
    const queue = await ReviewStore.getQueue()
    const next: ReviewQueueItem[] = []
    for (const x of queue) {
      if (!(x.refId === item.refId && x.refType === item.refType)) {
        next.push(x)
      }
    }
    next.push(item)
    await ReviewStore.persist(next)
  }

  static async pendingCount(): Promise<number> {
    const queue = await ReviewStore.getQueue()
    return queue.length
  }

  static async getDoneCount(): Promise<number> {
    return LocalPrefs.getInt(KEY_REVIEW_DONE, 0)
  }

  private static itemKey(item: ReviewQueueItem): string {
    return `${item.refType}:${item.refId}`
  }

  private static async getDoneKeys(): Promise<string[]> {
    const raw = await WanXiangLocalStore.getString(KEY_DONE_KEYS, '')
    if (raw.length === 0) {
      return []
    }
    return raw.split(',').filter((k: string) => k.length > 0)
  }

  private static async addDoneKey(key: string): Promise<void> {
    const keys = await ReviewStore.getDoneKeys()
    if (keys.indexOf(key) >= 0) {
      return
    }
    keys.push(key)
    await WanXiangLocalStore.putString(KEY_DONE_KEYS, keys.join(','))
  }

  private static async persist(queue: ReviewQueueItem[]): Promise<void> {
    const parts: string[] = []
    for (const item of queue) {
      parts.push(`${item.refId}|${item.refType}`)
    }
    await WanXiangLocalStore.putString(KEY_QUEUE, parts.join('||'))
  }

  private static parseQueue(raw: string): ReviewQueueItem[] {
    const out: ReviewQueueItem[] = []
    if (raw.length === 0) {
      return out
    }
    const chunks = raw.split('||')
    for (const chunk of chunks) {
      const parts = chunk.split('|')
      if (parts.length >= 2) {
        out.push(ReviewQueueItem.create(parts[0], parts[1]))
      }
    }
    return out
  }
}
