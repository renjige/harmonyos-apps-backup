import { EmotionDef } from './MoodModels'

export class EmotionCatalog {
  static all(): EmotionDef[] {
    const list: EmotionDef[] = []
    const defs: string[][] = [
      ['calm', '宁静', '#8BB8C9', '🌙'],
      ['joy', '愉悦', '#F5C6A0', '☀'],
      ['tired', '疲惫', '#B7A99A', '🍂'],
      ['anxious', '焦虑', '#C9A9A6', '🌧'],
      ['touched', '感动', '#E8C9C0', '💫'],
      ['expect', '期待', '#B8C9B8', '🌱'],
      ['fulfilled', '充实', '#C4B5A0', '✦'],
      ['lost', '迷茫', '#A8A8C8', '🌫']
    ]
    for (const row of defs) {
      const e = new EmotionDef()
      e.id = row[0]
      e.label = row[1]
      e.color = row[2]
      e.emoji = row[3]
      list.push(e)
    }
    return list
  }

  static find(id: string): EmotionDef | undefined {
    for (const e of EmotionCatalog.all()) {
      if (e.id === id) {
        return e
      }
    }
    return undefined
  }

  static labelOf(id: string): string {
    const e = EmotionCatalog.find(id)
    if (e !== undefined) {
      return e.label
    }
    return id
  }

  static colorOf(id: string): string {
    const e = EmotionCatalog.find(id)
    if (e !== undefined) {
      return e.color
    }
    return '#D4A574'
  }
}
