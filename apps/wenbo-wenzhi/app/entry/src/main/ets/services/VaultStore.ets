import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { CollectionItem, InsightItem } from '../models/AskModels'
import { AskBizService } from './AskBizService'
import { AskMedia } from './AskMedia'
import { ThemeAppearance } from './ThemeAppearance'

const STORE_NAME = 'wenzhi_local'
const KEY_ITEMS = 'collections_json'
const KEY_ASK = 'ask_count'
const KEY_STREAK = 'streak_days'
const KEY_STREAK_DAY = 'streak_day'
const KEY_NICK = 'nickname'
const KEY_DARK = 'dark_mode'

export class VaultStore {
  private static pref: preferences.Preferences | null = null
  private static items: CollectionItem[] = []
  private static askCount: number = 0
  private static streak: number = 0
  private static streakDay: string = ''
  private static nickname: string = '问知用户'

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      VaultStore.pref = await preferences.getPreferences(context, STORE_NAME)
      const raw = await VaultStore.pref.get(KEY_ITEMS, '[]')
      const str: string = typeof raw === 'string' ? raw : '[]'
      VaultStore.items = VaultStore.parseItems(str)
      const askVal = await VaultStore.pref.get(KEY_ASK, 0)
      VaultStore.askCount = typeof askVal === 'number' ? askVal : 0
      const streakVal = await VaultStore.pref.get(KEY_STREAK, 0)
      VaultStore.streak = typeof streakVal === 'number' ? streakVal : 0
      const dayVal = await VaultStore.pref.get(KEY_STREAK_DAY, '')
      VaultStore.streakDay = typeof dayVal === 'string' ? dayVal : ''
      const nickVal = await VaultStore.pref.get(KEY_NICK, '问知用户')
      VaultStore.nickname = typeof nickVal === 'string' && nickVal.length > 0 ? nickVal : '问知用户'
      const dark = await VaultStore.pref.get(KEY_DARK, false)
      const isDark = dark === true
      AppStorage.setOrCreate('darkModeOn', isDark)
      ThemeAppearance.apply(isDark ? 'dark' : 'light', context)
    } catch {
      VaultStore.items = []
    }
  }

  static all(): CollectionItem[] {
    const copy: CollectionItem[] = []
    for (const n of VaultStore.items) {
      copy.push(n)
    }
    return copy
  }

  static count(): number {
    return VaultStore.items.length
  }

  static asks(): number {
    return VaultStore.askCount
  }

  static streakDays(): number {
    return VaultStore.streak
  }

  static nick(): string {
    return VaultStore.nickname
  }

  static hasReadToday(): boolean {
    return VaultStore.streakDay === VaultStore.todayKey()
  }

  static find(id: string): CollectionItem | undefined {
    for (const n of VaultStore.items) {
      if (n.id === id) {
        return n
      }
    }
    return undefined
  }

  static isCollected(insightId: string): boolean {
    for (const n of VaultStore.items) {
      if (n.insightId === insightId) {
        return true
      }
    }
    return false
  }

  static async bumpAsk(): Promise<void> {
    VaultStore.askCount += 1
    await VaultStore.flush()
  }

  static async setNick(name: string): Promise<void> {
    const t = name.trim()
    VaultStore.nickname = t.length > 0 ? t : '问知用户'
    await VaultStore.flush()
  }

  static async setDark(dark: boolean): Promise<void> {
    AppStorage.setOrCreate('darkModeOn', dark)
    if (VaultStore.pref) {
      try {
        await VaultStore.pref.put(KEY_DARK, dark)
        await VaultStore.pref.flush()
      } catch {
      }
    }
  }

  static async markDailyRead(): Promise<void> {
    const today = VaultStore.todayKey()
    if (VaultStore.streakDay === today) {
      return
    }
    const yest = VaultStore.yesterdayKey()
    if (VaultStore.streakDay === yest) {
      VaultStore.streak += 1
    } else {
      VaultStore.streak = 1
    }
    VaultStore.streakDay = today
    await VaultStore.flush()
  }

  static async collect(question: string, insight: InsightItem, folder: string, note: string): Promise<CollectionItem> {
    const row = new CollectionItem()
    row.id = `col_${Date.now()}`
    row.insightId = insight.id
    row.question = question.length > 0 ? question : insight.title
    row.summary = insight.summary
    row.body = insight.body
    row.description = insight.description
    row.further = insight.further
    row.folder = folder.length > 0 ? folder : insight.category
    row.tags = insight.tags
    row.note = note
    row.userTag = '待了解'
    row.coverKey = insight.coverKey.length > 0 ? insight.coverKey : AskMedia.coverForFolder(row.folder)
    row.createdAt = Date.now()
    VaultStore.items.unshift(row)
    await VaultStore.flush()
    void AskBizService.syncCollection(row.question, insight, row.folder, note)
    return row
  }

  static async updateNote(id: string, note: string, folder: string, userTag: string): Promise<void> {
    for (const n of VaultStore.items) {
      if (n.id === id) {
        n.note = note
        n.folder = folder
        n.userTag = userTag
        break
      }
    }
    await VaultStore.flush()
  }

  static async remove(id: string): Promise<void> {
    const next: CollectionItem[] = []
    for (const n of VaultStore.items) {
      if (n.id !== id) {
        next.push(n)
      }
    }
    VaultStore.items = next
    await VaultStore.flush()
  }

  static async clearLocalCache(): Promise<void> {
    AppStorage.setOrCreate('localCacheEpoch', Date.now())
  }

  private static async flush(): Promise<void> {
    if (!VaultStore.pref) {
      return
    }
    try {
      await VaultStore.pref.put(KEY_ITEMS, VaultStore.encodeItems())
      await VaultStore.pref.put(KEY_ASK, VaultStore.askCount)
      await VaultStore.pref.put(KEY_STREAK, VaultStore.streak)
      await VaultStore.pref.put(KEY_STREAK_DAY, VaultStore.streakDay)
      await VaultStore.pref.put(KEY_NICK, VaultStore.nickname)
      await VaultStore.pref.flush()
    } catch {
    }
  }

  private static encodeItems(): string {
    let json = '['
    for (let i = 0; i < VaultStore.items.length; i++) {
      const n = VaultStore.items[i]
      if (i > 0) {
        json += ','
      }
      json += `{"id":${JSON.stringify(n.id)},"insightId":${JSON.stringify(n.insightId)},` +
        `"question":${JSON.stringify(n.question)},"summary":${JSON.stringify(n.summary)},` +
        `"body":${JSON.stringify(n.body)},"description":${JSON.stringify(n.description)},` +
        `"further":${JSON.stringify(n.further)},"folder":${JSON.stringify(n.folder)},` +
        `"tags":${JSON.stringify(n.tags)},"note":${JSON.stringify(n.note)},` +
        `"userTag":${JSON.stringify(n.userTag)},` +
        `"coverKey":${JSON.stringify(n.coverKey)},"createdAt":${n.createdAt}}`
    }
    json += ']'
    return json
  }

  private static parseItems(raw: string): CollectionItem[] {
    const out: CollectionItem[] = []
    if (raw.length < 4) {
      return out
    }
    try {
      const arr = JSON.parse(raw) as CollectionItem[]
      if (arr) {
        for (const n of arr) {
          const row = new CollectionItem()
          row.id = n.id
          row.insightId = n.insightId
          row.question = n.question
          row.summary = n.summary
          row.body = n.body
          row.description = n.description
          row.further = n.further
          row.folder = n.folder
          row.tags = n.tags
          row.note = n.note
          row.userTag = n.userTag && n.userTag.length > 0 ? n.userTag : '待了解'
          row.coverKey = n.coverKey
          row.createdAt = n.createdAt
          out.push(row)
        }
      }
    } catch {
      return out
    }
    return out
  }

  static todayKey(): string {
    const d = new Date()
    return `${d.getFullYear()}-${d.getMonth() + 1}-${d.getDate()}`
  }

  static yesterdayKey(): string {
    const d = new Date()
    d.setDate(d.getDate() - 1)
    return `${d.getFullYear()}-${d.getMonth() + 1}-${d.getDate()}`
  }

  static formatDate(ms: number): string {
    const d = new Date(ms)
    return `${d.getFullYear()}-${d.getMonth() + 1}-${d.getDate()}`
  }

  static todayLabel(): string {
    const d = new Date()
    return `${d.getFullYear()}年${d.getMonth() + 1}月${d.getDate()}日`
  }
}
