/** 森野小记 — 五种心情标签 */

export class MoodOption {
  id: string = ''
  emoji: string = ''
  label: string = ''
  color: string = ''
}

export class MoodCatalog {
  static all(): MoodOption[] {
    const list: MoodOption[] = []
    const m1 = new MoodOption()
    m1.id = 'calm'
    m1.emoji = '🌿'
    m1.label = '宁静'
    m1.color = '#3A7D5A'
    list.push(m1)
    const m2 = new MoodOption()
    m2.id = 'hope'
    m2.emoji = '🌱'
    m2.label = '期待'
    m2.color = '#8FBC8F'
    list.push(m2)
    const m3 = new MoodOption()
    m3.id = 'ease'
    m3.emoji = '🍃'
    m3.label = '轻松'
    m3.color = '#6B9E78'
    list.push(m3)
    const m4 = new MoodOption()
    m4.id = 'focus'
    m4.emoji = '🌲'
    m4.label = '专注'
    m4.color = '#2F6B4F'
    list.push(m4)
    const m5 = new MoodOption()
    m5.id = 'think'
    m5.emoji = '🍂'
    m5.label = '沉思'
    m5.color = '#D4A574'
    list.push(m5)
    return list
  }

  static find(id: string): MoodOption {
    for (const m of MoodCatalog.all()) {
      if (m.id === id) {
        return m
      }
    }
    return MoodCatalog.all()[0]
  }

  static emojiOf(id: string): string {
    return MoodCatalog.find(id).emoji
  }

  static labelOf(id: string): string {
    return MoodCatalog.find(id).label
  }

  static colorOf(id: string): string {
    return MoodCatalog.find(id).color
  }
}
