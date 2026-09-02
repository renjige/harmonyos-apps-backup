export class MoodOption {
  id: string = ''
  label: string = ''
  color: string = ''
  emoji: string = ''

  constructor(id: string, label: string, color: string, emoji: string) {
    this.id = id
    this.label = label
    this.color = color
    this.emoji = emoji
  }
}

export class MoodCatalog {
  static all(): MoodOption[] {
    return [
      new MoodOption('calm', '安宁', '#A8C5B5', '🌿'),
      new MoodOption('warm', '暖杏', '#E8C4A0', '🌤'),
      new MoodOption('soft', '柔粉', '#E8B4BC', '🌸'),
      new MoodOption('mist', '雾蓝', '#A8B8CC', '🌊'),
      new MoodOption('deep', '沉思', '#8B7A6B', '🌙'),
      new MoodOption('bright', '清朗', '#D4A55A', '✨')
    ]
  }

  static find(id: string): MoodOption | undefined {
    for (const m of MoodCatalog.all()) {
      if (m.id === id) {
        return m
      }
    }
    return undefined
  }

  static labelOf(id: string): string {
    const m = MoodCatalog.find(id)
    if (m !== undefined) {
      return m.label
    }
    return ''
  }

  static colorOf(id: string): string {
    const m = MoodCatalog.find(id)
    if (m !== undefined) {
      return m.color
    }
    return '#8B6B4D'
  }

  static emojiOf(id: string): string {
    const m = MoodCatalog.find(id)
    if (m !== undefined) {
      return m.emoji
    }
    return '📝'
  }
}
