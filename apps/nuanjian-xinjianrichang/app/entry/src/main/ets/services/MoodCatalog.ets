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

/** 产品固定 5 心情（非心理测评） */
export class MoodCatalog {
  static all(): MoodOption[] {
    return [
      new MoodOption('joyful', '愉快', 'sun', '#E98D83'),
      new MoodOption('calm', '平静', 'moon', '#C4B4A8'),
      new MoodOption('relaxed', '放松', 'leaf', '#7EAD89'),
      new MoodOption('ordinary', '普通', 'empty', '#8E8884'),
      new MoodOption('low', '低落', 'cloud', '#817A76')
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
    return '#8E8884'
  }

  static iconOf(id: string): AppIconName {
    const m = MoodCatalog.find(id)
    if (m !== undefined) {
      return m.icon
    }
    return 'empty'
  }

  static defaultTags(): string[] {
    return ['生活', '工作', '学习', '旅行', '美食', '家人', '朋友', '随手记']
  }
}
