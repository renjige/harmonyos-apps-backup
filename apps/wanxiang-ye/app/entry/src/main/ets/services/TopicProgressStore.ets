import { LocalPrefs } from './LocalPrefs'
import { InfoRepository } from './InfoRepository'

const KEY_PREFIX = 'topic_progress_'

export class TopicProgress {
  topicId: string = ''
  doneCount: number = 0
  totalCount: number = 0

  percent(): number {
    if (this.totalCount <= 0) {
      return 0
    }
    return Math.min(100, Math.round((this.doneCount / this.totalCount) * 100))
  }
}

export class TopicProgressStore {
  static async load(topicId: string): Promise<TopicProgress> {
    const topic = InfoRepository.findTopic(topicId)
    const p = new TopicProgress()
    p.topicId = topicId
    p.totalCount = topic !== undefined ? topic.itemIds.length : 0
    const raw = await LocalPrefs.getString(`${KEY_PREFIX}${topicId}`, '')
    if (raw.length === 0) {
      return p
    }
    const ids = raw.split(',').filter((x: string) => x.length > 0)
    p.doneCount = ids.length
    return p
  }

  static async markRead(topicId: string, infoId: string): Promise<void> {
    const topic = InfoRepository.findTopic(topicId)
    if (topic === undefined || topic.itemIds.indexOf(infoId) < 0) {
      return
    }
    const raw = await LocalPrefs.getString(`${KEY_PREFIX}${topicId}`, '')
    const ids = raw.length > 0 ? raw.split(',').filter((x: string) => x.length > 0) : []
    if (ids.indexOf(infoId) >= 0) {
      return
    }
    ids.push(infoId)
    await LocalPrefs.putString(`${KEY_PREFIX}${topicId}`, ids.join(','))
  }

  static async isRead(topicId: string, infoId: string): Promise<boolean> {
    const raw = await LocalPrefs.getString(`${KEY_PREFIX}${topicId}`, '')
    if (raw.length === 0) {
      return false
    }
    const ids = raw.split(',')
    return ids.indexOf(infoId) >= 0
  }
}
