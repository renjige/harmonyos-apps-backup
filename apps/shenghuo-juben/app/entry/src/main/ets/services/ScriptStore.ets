import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { LifeScript } from '../models/ScriptModels'

const STORE = 'shenghuo_script_v1'
const KEY_ENTRIES = 'entries'

export class ScriptStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      ScriptStore.pref = await preferences.getPreferences(context, STORE)
    } catch {
      ScriptStore.pref = null
    }
  }

  static async loadAll(): Promise<LifeScript[]> {
    const raw = await ScriptStore.getString(KEY_ENTRIES, '')
    return ScriptStore.parseScripts(raw)
  }

  static async saveScript(script: LifeScript): Promise<void> {
    script.updatedAt = Date.now()
    const list = await ScriptStore.loadAll()
    const next: LifeScript[] = []
    let found = false
    for (const it of list) {
      if (it.id === script.id) {
        next.push(script)
        found = true
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.push(script)
    }
    next.sort((a, b) => b.updatedAt - a.updatedAt)
    await ScriptStore.persistScripts(next)
  }

  static async deleteScript(id: string): Promise<void> {
    const list = await ScriptStore.loadAll()
    const next: LifeScript[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await ScriptStore.persistScripts(next)
  }

  static async findById(id: string): Promise<LifeScript | undefined> {
    const list = await ScriptStore.loadAll()
    for (const it of list) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static async findByDateKey(dateKey: string): Promise<LifeScript[]> {
    const list = await ScriptStore.loadAll()
    const out: LifeScript[] = []
    for (const it of list) {
      if (it.dateKey === dateKey) {
        out.push(it)
      }
    }
    return out
  }

  static async countAll(): Promise<number> {
    const list = await ScriptStore.loadAll()
    return list.length
  }

  static async exportAllText(): Promise<string> {
    const list = await ScriptStore.loadAll()
    const lines: string[] = []
    lines.push('生活剧本 — 本地导出')
    lines.push(`共 ${list.length} 部`)
    lines.push('')
    for (const it of list) {
      lines.push('---')
      lines.push(it.dateKey)
      lines.push(it.title)
      lines.push(`心情：${it.moodTag}`)
      if (it.prologue.length > 0) {
        lines.push(it.prologue)
      }
      if (it.sceneDescription.length > 0) {
        lines.push(it.sceneDescription)
      }
      lines.push('')
    }
    return lines.join('\n')
  }

  static async dateKeysWithScripts(): Promise<string[]> {
    const list = await ScriptStore.loadAll()
    const keys: string[] = []
    for (const it of list) {
      if (keys.indexOf(it.dateKey) < 0) {
        keys.push(it.dateKey)
      }
    }
    return keys
  }

  private static async persistScripts(items: LifeScript[]): Promise<void> {
    const lines: string[] = []
    for (const it of items) {
      lines.push(ScriptStore.serialize(it))
    }
    await ScriptStore.putString(KEY_ENTRIES, lines.join('\n'))
  }

  private static serialize(it: LifeScript): string {
    const imgs = it.imagePaths.join('|')
    return [
      it.id,
      it.title.replace(/\n/g, ' '),
      it.sceneDescription.replace(/\n/g, '\\n'),
      it.prologue.replace(/\n/g, '\\n'),
      it.moodTag,
      imgs,
      `${it.createdAt}`,
      `${it.updatedAt}`,
      it.dateKey
    ].join('\t')
  }

  private static parseScripts(raw: string): LifeScript[] {
    if (raw.length === 0) {
      return []
    }
    const lines = raw.split('\n')
    const out: LifeScript[] = []
    for (const line of lines) {
      if (line.trim().length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 9) {
        continue
      }
      const s = new LifeScript()
      s.id = parts[0]
      s.title = parts[1]
      s.sceneDescription = parts[2].replace(/\\n/g, '\n')
      s.prologue = parts[3].replace(/\\n/g, '\n')
      s.moodTag = parts[4]
      s.imagePaths = parts[5].length > 0 ? parts[5].split('|') : []
      s.createdAt = parseInt(parts[6], 10)
      s.updatedAt = parseInt(parts[7], 10)
      s.dateKey = parts[8]
      out.push(s)
    }
    out.sort((a, b) => b.updatedAt - a.updatedAt)
    return out
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (ScriptStore.pref === null) {
      return fallback
    }
    try {
      const v = await ScriptStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (ScriptStore.pref === null) {
      return
    }
    try {
      await ScriptStore.pref.put(key, value)
      await ScriptStore.pref.flush()
    } catch {
      // ignore
    }
  }
}
