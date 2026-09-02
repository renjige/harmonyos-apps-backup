import { AppIconName } from '../components/design-system/AppIcon'

export class MoodOption {
  id: string = ''
  label: string = ''
  icon: AppIconName = 'empty'
  color: string = ''

  constructor(id: string, label: string, icon: AppIconName, color: string) {
    this.id = id
    this.label = label
    this.icon = icon
    this.color = color
  }
}

export class MoodCatalog {
  static all(): MoodOption[] {
    return [
      new MoodOption('joy', '欣喜', 'sparkle', '#D4A574'),
      new MoodOption('fear', '恐惧', 'alert', '#7B6B8A'),
      new MoodOption('puzzled', '困惑', 'empty', '#8A9BB5'),
      new MoodOption('calm', '安宁', 'moon', '#6B9BB5'),
      new MoodOption('expect', '期待', 'star', '#C9A87C'),
      new MoodOption('anxious', '焦虑', 'refresh', '#A67B8A')
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
    return '#858B99'
  }

  static iconOf(id: string): AppIconName {
    const m = MoodCatalog.find(id)
    if (m !== undefined) {
      return m.icon
    }
    return 'empty'
  }

  static defaultTags(): string[] {
    return ['飞翔', '坠落', '追逐', '重逢', '迷失', '考试', '工作', '旅行']
  }

  static parseEmotions(csv: string): string[] {
    const out: string[] = []
    if (csv.length === 0) {
      return out
    }
    const parts = csv.split('|')
    for (const p of parts) {
      const t = p.trim()
      if (t.length > 0) {
        out.push(t)
      }
    }
    return out
  }

  static emotionLabels(csv: string): string {
    const ids = MoodCatalog.parseEmotions(csv)
    const labels: string[] = []
    for (const id of ids) {
      const l = MoodCatalog.labelOf(id)
      if (l.length > 0) {
        labels.push(l)
      }
    }
    return labels.join(' · ')
  }

  static primaryColor(csv: string): string {
    const ids = MoodCatalog.parseEmotions(csv)
    if (ids.length > 0) {
      return MoodCatalog.colorOf(ids[0])
    }
    return '#6B9BB5'
  }

  static templateNames(): string[] {
    return ['plain', 'ink', 'dawn', 'night']
  }

  static templateLabel(key: string): string {
    if (key === 'ink') {
      return '墨夜'
    }
    if (key === 'dawn') {
      return '晨梦'
    }
    if (key === 'night') {
      return '深眠'
    }
    return '素札'
  }
}
