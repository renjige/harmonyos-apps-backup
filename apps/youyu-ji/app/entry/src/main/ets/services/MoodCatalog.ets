import { AppIconName } from '../components/design-system/AppIcon'
import { MoodItem } from '../models/YouyuModels'

export class MoodCatalog {
  static all(): MoodItem[] {
    const list: MoodItem[] = []
    list.push(MoodCatalog.make('joy', '愉悦', 'sun'))
    list.push(MoodCatalog.make('calm', '平静', 'leaf'))
    list.push(MoodCatalog.make('think', '思考', 'moon'))
    list.push(MoodCatalog.make('miss', '怀念', 'heart'))
    list.push(MoodCatalog.make('hope', '期待', 'star'))
    return list
  }

  static labelOf(id: string): string {
    const list = MoodCatalog.all()
    for (const m of list) {
      if (m.id === id) {
        return m.label
      }
    }
    return '平静'
  }

  static iconOf(id: string): AppIconName {
    if (id === 'joy') {
      return 'sun'
    }
    if (id === 'think') {
      return 'moon'
    }
    if (id === 'miss') {
      return 'heart'
    }
    if (id === 'hope') {
      return 'star'
    }
    return 'leaf'
  }

  static emojiMark(id: string): string {
    if (id === 'joy') {
      return '☀️'
    }
    if (id === 'think') {
      return '🌙'
    }
    if (id === 'miss') {
      return '🌿'
    }
    if (id === 'hope') {
      return '✨'
    }
    return '🍃'
  }

  static defaultTagNames(): string[] {
    return ['窗边', '食事', '日常', '夜色', '出行']
  }

  private static make(id: string, label: string, icon: string): MoodItem {
    const m = new MoodItem()
    m.id = id
    m.label = label
    m.icon = icon
    return m
  }
}
