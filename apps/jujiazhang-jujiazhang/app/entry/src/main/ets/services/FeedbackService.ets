import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'

const STORE = 'jujia_feedback'
const KEY_LIST = 'items'

class FeedbackItem {
  id: string = ''
  content: string = ''
  contact: string = ''
  createdAt: string = ''
}

class FeedbackWire {
  items: FeedbackItem[] = []
}

export class FeedbackService {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      FeedbackService.pref = await preferences.getPreferences(context, STORE)
    } catch {
      FeedbackService.pref = null
    }
  }

  static async save(content: string, contact: string): Promise<boolean> {
    if (FeedbackService.pref === null) {
      return false
    }
    try {
      const row = new FeedbackItem()
      row.id = `fb_${Date.now()}`
      row.content = content
      row.contact = contact
      row.createdAt = new Date().toISOString()
      const rawValue = await FeedbackService.pref.get(KEY_LIST, '')
      const raw: string = typeof rawValue === 'string' ? rawValue : ''
      const wire = FeedbackService.parseWire(raw)
      wire.items.unshift(row)
      await FeedbackService.pref.put(KEY_LIST, JSON.stringify(wire))
      await FeedbackService.pref.flush()
      return true
    } catch {
      return false
    }
  }

  private static parseWire(raw: string): FeedbackWire {
    const wire = new FeedbackWire()
    if (raw.length === 0) {
      return wire
    }
    try {
      const parsed = JSON.parse(raw) as FeedbackWire
      if (parsed.items !== undefined) {
        wire.items = parsed.items
      }
    } catch {
      wire.items = []
    }
    return wire
  }
}
