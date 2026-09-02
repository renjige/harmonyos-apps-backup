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
      new MoodOption('bright', '明亮', 'sun', '#D9AE62'),
      new MoodOption('calm', '平静', 'moon', '#858B99'),
      new MoodOption('stirred', '涌动', 'leaf', '#5B7A68'),
      new MoodOption('soft', '柔软', 'cloud', '#8A7A62'),
      new MoodOption('still', '沉思', 'empty', '#293044')
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
    return ['生活', '工作', '创意', '阅读', '随笔', '其他']
  }

  static templateNames(): string[] {
    return ['plain', 'ink', 'dawn', 'night']
  }

  static templateLabel(key: string): string {
    if (key === 'ink') {
      return '墨韵'
    }
    if (key === 'dawn') {
      return '晨光'
    }
    if (key === 'night') {
      return '夜笺'
    }
    return '素笺'
  }
}
