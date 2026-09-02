/** 漫观笔记与洞察数据模型 */

export class EmotionOption {
  key: string = ''
  label: string = ''
  color: string = ''
  tag: string = ''

  static all(): EmotionOption[] {
    const list: EmotionOption[] = []
    const rows: string[][] = [
      ['calm', '平静', '#5B8C8C', '🌿'],
      ['happy', '愉悦', '#D4A574', '☀'],
      ['anxious', '焦虑', '#C98A8A', '🌫'],
      ['tired', '疲惫', '#9A9A9A', '🌙'],
      ['focused', '专注', '#6B8FA3', '🎯'],
      ['expect', '期待', '#B89A7A', '✨']
    ]
    for (const row of rows) {
      const o = new EmotionOption()
      o.key = row[0]
      o.label = row[1]
      o.color = row[2]
      o.tag = row[3]
      list.push(o)
    }
    return list
  }

  static find(key: string): EmotionOption | undefined {
    for (const o of EmotionOption.all()) {
      if (o.key === key) {
        return o
      }
    }
    return undefined
  }
}

export class ObservationNote {
  id: string = ''
  dateKey: string = ''
  text: string = ''
  emotionKey: string = 'calm'
  emotionLabel: string = '平静'
  createdAt: number = 0

  static createNew(dateKey: string): ObservationNote {
    const n = new ObservationNote()
    n.id = `n_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    n.dateKey = dateKey
    n.createdAt = Date.now()
    return n
  }

  preview(): string {
    const t = this.text.trim()
    if (t.length === 0) {
      return '（空笔记）'
    }
    return t.length > 24 ? `${t.substring(0, 24)}…` : t
  }
}

export class KeywordItem {
  word: string = ''
  count: number = 0
}

export class EmotionStat {
  key: string = ''
  label: string = ''
  color: string = ''
  count: number = 0
  ratio: number = 0
}

export class TrendPoint {
  dateKey: string = ''
  label: string = ''
  score: number = 0
}

export class InsightReport {
  periodLabel: string = ''
  mainEmotion: string = ''
  mainEmotionRatio: number = 0
  peakHourLabel: string = ''
  keywords: string[] = []
  wisdomMessage: string = ''
  noteCount: number = 0
}

export class UserProfile {
  nickname: string = '漫观者'
  avatarKey: string = 'default'
  reminderHour: number = 20
  reminderMinute: number = 0
  reminderEnabled: boolean = false
  themeMode: string = 'system'
}
