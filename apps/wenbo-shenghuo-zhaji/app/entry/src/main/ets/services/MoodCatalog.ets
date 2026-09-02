/** 札记心情标签（文字，非 Emoji） */
export class MoodOption {
  key: string = ''
  label: string = ''

  constructor(key: string, label: string) {
    this.key = key
    this.label = label
  }
}

export class MoodCatalog {
  static options(): MoodOption[] {
    return [
      new MoodOption('calm', '平静'),
      new MoodOption('joy', '喜悦'),
      new MoodOption('grateful', '感恩'),
      new MoodOption('miss', '思念'),
      new MoodOption('busy', '忙碌'),
      new MoodOption('heal', '治愈')
    ]
  }

  static labelOf(key: string): string {
    for (const opt of MoodCatalog.options()) {
      if (opt.key === key) {
        return opt.label
      }
    }
    return key.length > 0 ? key : ''
  }
}
