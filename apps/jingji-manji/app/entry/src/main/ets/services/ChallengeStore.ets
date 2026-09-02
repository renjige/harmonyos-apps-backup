import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { SportChallenge } from '../models/SportModels'
import { SportModelClone } from './SportModelClone'

const STORE_NAME = 'sport_challenge_v1'
const KEY_ITEMS = 'challenges_json'

export class ChallengeStore {
  private static pref: preferences.Preferences | null = null
  private static cache: SportChallenge[] = []

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      ChallengeStore.pref = await preferences.getPreferences(context, STORE_NAME)
      const raw = await ChallengeStore.pref.get(KEY_ITEMS, '[]')
      const text: string = typeof raw === 'string' ? raw : '[]'
      ChallengeStore.cache = ChallengeStore.parseList(text)
    } catch {
      ChallengeStore.cache = []
    }
  }

  static list(): SportChallenge[] {
    const copy: SportChallenge[] = []
    for (const item of ChallengeStore.cache) {
      copy.push(SportModelClone.challenge(item))
    }
    copy.sort((a: SportChallenge, b: SportChallenge) => b.createdAt.localeCompare(a.createdAt))
    return copy
  }

  static active(): SportChallenge[] {
    const out: SportChallenge[] = []
    for (const item of ChallengeStore.list()) {
      if (item.status === 'active') {
        out.push(item)
      }
    }
    return out
  }

  static findById(id: string): SportChallenge | null {
    for (const item of ChallengeStore.cache) {
      if (item.id === id) {
        return SportModelClone.challenge(item)
      }
    }
    return null
  }

  static async save(item: SportChallenge): Promise<void> {
    let found = false
    const next: SportChallenge[] = []
    for (const cur of ChallengeStore.cache) {
      if (cur.id === item.id) {
        next.push(item)
        found = true
      } else {
        next.push(cur)
      }
    }
    if (!found) {
      next.push(item)
    }
    ChallengeStore.cache = next
    await ChallengeStore.flush()
  }

  static async remove(id: string): Promise<void> {
    const next: SportChallenge[] = []
    for (const cur of ChallengeStore.cache) {
      if (cur.id !== id) {
        next.push(cur)
      }
    }
    ChallengeStore.cache = next
    await ChallengeStore.flush()
  }

  private static async flush(): Promise<void> {
    if (ChallengeStore.pref === null) {
      return
    }
    await ChallengeStore.pref.put(KEY_ITEMS, JSON.stringify(ChallengeStore.cache))
    await ChallengeStore.pref.flush()
  }

  private static parseList(text: string): SportChallenge[] {
    try {
      const arr = JSON.parse(text) as object[]
      const out: SportChallenge[] = []
      for (const raw of arr) {
        const c = ChallengeStore.mapItem(raw)
        if (c.id.length > 0) {
          out.push(c)
        }
      }
      return out
    } catch {
      return []
    }
  }

  private static mapItem(raw: object): SportChallenge {
    const c = new SportChallenge()
    const o = raw as Record<string, string | number>
    c.id = typeof o['id'] === 'string' ? o['id'] : ''
    c.title = typeof o['title'] === 'string' ? o['title'] : ''
    c.sportType = typeof o['sportType'] === 'string' ? o['sportType'] : '全部'
    c.targetSessions = typeof o['targetSessions'] === 'number' ? o['targetSessions'] : 8
    c.targetDistanceKm = typeof o['targetDistanceKm'] === 'number' ? o['targetDistanceKm'] : 0
    c.startDate = typeof o['startDate'] === 'string' ? o['startDate'] : ''
    c.endDate = typeof o['endDate'] === 'string' ? o['endDate'] : ''
    c.note = typeof o['note'] === 'string' ? o['note'] : ''
    c.status = typeof o['status'] === 'string' ? o['status'] : 'active'
    c.createdAt = typeof o['createdAt'] === 'string' ? o['createdAt'] : ''
    return c
  }
}
