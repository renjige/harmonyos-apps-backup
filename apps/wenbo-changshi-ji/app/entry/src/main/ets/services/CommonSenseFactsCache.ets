import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { util } from '@kit.ArkTS'
import { FactItem, FactWire } from '../models/CommonSenseModels'

const PREFS_NAME = 'changshiji_facts_cache'
const KEY_FACTS = 'facts_json'

/** API 成功结果缓存 + 与平台种子一致的 rawfile 兜底（仅在网络/服务异常时使用）。 */
export class CommonSenseFactsCache {
  private static pref: preferences.Preferences | null = null
  private static hostContext: common.UIAbilityContext | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    CommonSenseFactsCache.hostContext = context
    try {
      CommonSenseFactsCache.pref = await preferences.getPreferences(context, PREFS_NAME)
    } catch {
      CommonSenseFactsCache.pref = null
    }
  }

  static async saveWires(list: FactWire[]): Promise<void> {
    if (CommonSenseFactsCache.pref === null || list.length === 0) {
      return
    }
    try {
      await CommonSenseFactsCache.pref.put(KEY_FACTS, JSON.stringify(list))
      await CommonSenseFactsCache.pref.flush()
    } catch {
    }
  }

  static async loadCachedWires(): Promise<FactWire[]> {
    if (CommonSenseFactsCache.pref === null) {
      return []
    }
    try {
      const raw = await CommonSenseFactsCache.pref.get(KEY_FACTS, '[]')
      const text: string = typeof raw === 'string' ? raw : '[]'
      return CommonSenseFactsCache.parseWireList(text)
    } catch {
      return []
    }
  }

  static async loadBootstrapWires(): Promise<FactWire[]> {
    if (CommonSenseFactsCache.hostContext === null) {
      return []
    }
    try {
      const rm = CommonSenseFactsCache.hostContext.resourceManager
      const raw = await rm.getRawFileContent('common_sense_facts.json')
      const decoder = util.TextDecoder.create('utf-8')
      const text = decoder.decodeToString(raw)
      return CommonSenseFactsCache.parseBootstrap(text)
    } catch {
      return []
    }
  }

  static mapWires(list: FactWire[]): FactItem[] {
    const out: FactItem[] = []
    for (const w of list) {
      try {
        const item = FactItem.fromWire(w)
        if (item.id.length > 0) {
          out.push(item)
        }
      } catch {
      }
    }
    return out
  }

  static delay(ms: number): Promise<void> {
    return new Promise((resolve: () => void) => {
      setTimeout(resolve, ms)
    })
  }

  private static parseBootstrap(text: string): FactWire[] {
    const root = JSON.parse(text) as BootstrapFile
    if (root.items !== undefined && root.items.length > 0) {
      return root.items
    }
    if (root.list !== undefined && root.list.length > 0) {
      return root.list
    }
    return []
  }

  private static parseWireList(text: string): FactWire[] {
    if (text.length < 2) {
      return []
    }
    try {
      const parsed = JSON.parse(text) as FactWire[]
      const out: FactWire[] = []
      for (const row of parsed) {
        out.push(row)
      }
      return out
    } catch {
      return []
    }
  }
}

class BootstrapFile {
  items: FactWire[] = []
  list: FactWire[] = []
}
