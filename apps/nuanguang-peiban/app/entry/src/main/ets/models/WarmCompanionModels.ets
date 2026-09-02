/** 暖光陪伴 — 平台 Wire 与本地模型（ArkTS 严格模式） */

export class MoodKeyUtil {
  static all(): string[] {
    const list: string[] = []
    list.push('great')
    list.push('good')
    list.push('ok')
    list.push('low')
    list.push('bad')
    return list
  }

  static label(key: string): string {
    if (key === 'great') {
      return '很好'
    }
    if (key === 'good') {
      return '不错'
    }
    if (key === 'ok') {
      return '一般'
    }
    if (key === 'low') {
      return '低落'
    }
    if (key === 'bad') {
      return '难过'
    }
    return key
  }
}

export class QuoteWire {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  coverMedia: string = ''
}

export class QuoteItem {
  id: string = ''
  title: string = ''
  author: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''

  static fromWire(w: QuoteWire): QuoteItem {
    const item = new QuoteItem()
    item.id = w.id
    item.title = w.title
    item.author = w.subtitle ?? ''
    item.summary = w.summary ?? ''
    item.body = w.body ?? w.description ?? w.summary ?? ''
    if (w.coverKey.length > 0) {
      item.coverKey = w.coverKey
    } else if (w.coverMedia !== undefined && w.coverMedia.length > 0) {
      item.coverKey = w.coverMedia
    }
    return item
  }
}

export class QuoteListPayload {
  list: QuoteWire[] = []
}

export class DailyPayload {
  quote?: QuoteWire
}

export class BreathModeWire {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  inhaleSec: number = 4
  holdSec: number = 4
  exhaleSec: number = 4
  rounds: number = 4
  durationSec: number = 0
}

export class BreathModeItem {
  id: string = ''
  title: string = ''
  rhythmLabel: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
  inhaleSec: number = 4
  holdSec: number = 4
  exhaleSec: number = 4
  rounds: number = 4

  static fromWire(w: BreathModeWire): BreathModeItem {
    const item = new BreathModeItem()
    item.id = w.id
    item.title = w.title
    item.rhythmLabel = w.subtitle ?? `${w.inhaleSec}-${w.holdSec}-${w.exhaleSec}`
    item.summary = w.summary ?? ''
    item.body = w.body ?? w.description ?? ''
    item.inhaleSec = w.inhaleSec > 0 ? w.inhaleSec : 4
    item.holdSec = w.holdSec >= 0 ? w.holdSec : 4
    item.exhaleSec = w.exhaleSec > 0 ? w.exhaleSec : 4
    item.rounds = w.rounds > 0 ? w.rounds : 4
    if (w.coverKey.length > 0) {
      item.coverKey = w.coverKey
    } else if (w.coverMedia !== undefined && w.coverMedia.length > 0) {
      item.coverKey = w.coverMedia
    }
    return item
  }

  totalSeconds(): number {
    const oneRound = this.inhaleSec + this.holdSec + this.exhaleSec
    return oneRound * this.rounds
  }
}

export class BreathModeListPayload {
  list: BreathModeWire[] = []
}

export class NoiseTrackWire {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  tags: string = ''
}

export class NoiseTrackItem {
  id: string = ''
  title: string = ''
  summary: string = ''
  coverKey: string = ''
  tags: string = ''

  static fromWire(w: NoiseTrackWire): NoiseTrackItem {
    const item = new NoiseTrackItem()
    item.id = w.id
    item.title = w.title
    item.summary = w.summary ?? w.body ?? ''
    item.tags = w.tags ?? ''
    if (w.coverKey.length > 0) {
      item.coverKey = w.coverKey
    } else if (w.coverMedia !== undefined && w.coverMedia.length > 0) {
      item.coverKey = w.coverMedia
    }
    return item
  }
}

export class NoiseTrackListPayload {
  list: NoiseTrackWire[] = []
}

export class MoodFeedbackWire {
  id: string = ''
  title: string = ''
  mood: string = ''
  summary: string = ''
  body: string = ''
}

export class MoodFeedbackItem {
  id: string = ''
  mood: string = ''
  text: string = ''

  static fromWire(w: MoodFeedbackWire): MoodFeedbackItem {
    const item = new MoodFeedbackItem()
    item.id = w.id
    item.mood = w.mood ?? w.title
    item.text = w.body ?? w.summary ?? ''
    return item
  }
}

export class MoodFeedbackPayload {
  feedback?: MoodFeedbackWire
  list: MoodFeedbackWire[] = []
}

export class BadgeWire {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  unlockDays: number = 0
}

export class BadgeItem {
  id: string = ''
  title: string = ''
  summary: string = ''
  coverKey: string = ''
  unlockDays: number = 0

  static fromWire(w: BadgeWire): BadgeItem {
    const item = new BadgeItem()
    item.id = w.id
    item.title = w.title
    item.summary = w.summary ?? w.body ?? ''
    item.unlockDays = w.unlockDays ?? 0
    if (w.coverKey.length > 0) {
      item.coverKey = w.coverKey
    } else if (w.coverMedia !== undefined && w.coverMedia.length > 0) {
      item.coverKey = w.coverMedia
    }
    return item
  }
}

export class BadgeListPayload {
  list: BadgeWire[] = []
}

export class MoodWire {
  id: string = ''
  title: string = ''
  mood: string = ''
  body: string = ''
  noteDate: string = ''
  userId: string = ''
}

export class MoodItem {
  id: string = ''
  mood: string = ''
  body: string = ''
  noteDate: string = ''

  static fromWire(w: MoodWire): MoodItem {
    const item = new MoodItem()
    item.id = w.id
    item.mood = w.mood ?? w.title
    item.body = w.body ?? ''
    item.noteDate = w.noteDate ?? ''
    return item
  }

  static fromLocal(id: string, mood: string, body: string, noteDate: string): MoodItem {
    const item = new MoodItem()
    item.id = id
    item.mood = mood
    item.body = body
    item.noteDate = noteDate
    return item
  }
}

export class MoodListPayload {
  list: MoodWire[] = []
}

export class MoodBody {
  mood: string = ''
  body: string = ''
  noteDate: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"mood":${JSON.stringify(this.mood)},"body":${JSON.stringify(this.body)},` +
      `"noteDate":${JSON.stringify(this.noteDate)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class BreathSessionWire {
  id: string = ''
  title: string = ''
  modeId: string = ''
  durationSec: number = 0
  noteDate: string = ''
  userId: string = ''
}

export class BreathSessionItem {
  id: string = ''
  title: string = ''
  modeId: string = ''
  durationSec: number = 0
  noteDate: string = ''

  static fromWire(w: BreathSessionWire): BreathSessionItem {
    const item = new BreathSessionItem()
    item.id = w.id
    item.title = w.title
    item.modeId = w.modeId ?? ''
    item.durationSec = w.durationSec ?? 0
    item.noteDate = w.noteDate ?? ''
    return item
  }

  static fromLocal(id: string, modeId: string, title: string, durationSec: number, noteDate: string): BreathSessionItem {
    const item = new BreathSessionItem()
    item.id = id
    item.modeId = modeId
    item.title = title
    item.durationSec = durationSec
    item.noteDate = noteDate
    return item
  }
}

export class BreathSessionListPayload {
  list: BreathSessionWire[] = []
}

export class BreathSessionBody {
  modeId: string = ''
  title: string = ''
  durationSec: number = 0
  noteDate: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"modeId":${JSON.stringify(this.modeId)},"title":${JSON.stringify(this.title)},` +
      `"durationSec":${this.durationSec},"noteDate":${JSON.stringify(this.noteDate)},` +
      `"userId":${JSON.stringify(this.userId)}}`
  }
}

export class EmptyOk {
  success: boolean = false
}

export class WarmCompanionStats {
  moodCount: number = 0
  breathMinutes: number = 0
  streakDays: number = 0
  companionDays: number = 0
}
