import { MoodOption, PickupKindOption } from '../models/ShiyiModels'

export class MoodCatalog {
  static all(): MoodOption[] {
    const list: MoodOption[] = []
    list.push(MoodCatalog.make('happy', '开心', '😊', '#F3E8D4', 'cover_life'))
    list.push(MoodCatalog.make('calm', '平静', '🌿', '#E4EAE3', 'cover_read'))
    list.push(MoodCatalog.make('expect', '期待', '✨', '#EDE4E8', 'cover_travel'))
    list.push(MoodCatalog.make('tired', '疲惫', '☁️', '#EBE6DF', 'cover_work'))
    list.push(MoodCatalog.make('low', '低落', '🌧', '#E4E8ED', 'cover_rain'))
    return list
  }

  static labelOf(id: string): string {
    const all = MoodCatalog.all()
    for (const item of all) {
      if (item.id === id) {
        return item.label
      }
    }
    return '未选'
  }

  static markOf(id: string): string {
    const all = MoodCatalog.all()
    for (const item of all) {
      if (item.id === id) {
        return item.mark
      }
    }
    return ''
  }

  static tintOf(id: string): string {
    const all = MoodCatalog.all()
    for (const item of all) {
      if (item.id === id) {
        return item.tint
      }
    }
    return '#EEE6DA'
  }

  static coverOf(id: string): string {
    const all = MoodCatalog.all()
    for (const item of all) {
      if (item.id === id) {
        return item.coverKey
      }
    }
    return 'hero_paper'
  }

  private static make(id: string, label: string, mark: string, tint: string, coverKey: string): MoodOption {
    const item = new MoodOption()
    item.id = id
    item.label = label
    item.mark = mark
    item.tint = tint
    item.coverKey = coverKey
    return item
  }
}

export class PickupKinds {
  static all(): PickupKindOption[] {
    const list: PickupKindOption[] = []
    list.push(PickupKinds.make('inspiration', '灵感'))
    list.push(PickupKinds.make('sentence', '一句话'))
    list.push(PickupKinds.make('happiness', '小确幸'))
    list.push(PickupKinds.make('quote', '阅读摘录'))
    list.push(PickupKinds.make('todo', '想做的事'))
    return list
  }

  static labelOf(id: string): string {
    const all = PickupKinds.all()
    for (const item of all) {
      if (item.id === id) {
        return item.label
      }
    }
    return '拾意'
  }

  private static make(id: string, label: string): PickupKindOption {
    const item = new PickupKindOption()
    item.id = id
    item.label = label
    return item
  }
}

export class DefaultTags {
  static names(): string[] {
    return ['生活', '阅读', '旅行', '美食', '工作', '朋友', '灵感']
  }
}
