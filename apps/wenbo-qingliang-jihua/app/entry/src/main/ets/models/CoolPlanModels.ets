/** 清凉计划 — 平台 Wire 与本地模型（ArkTS 严格模式） */

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

export class MoodWire {
  id: string = ''
  title: string = ''
  mood: string = ''
  noteDate: string = ''
  coolIndex: number = 0
  userId: string = ''
}

export class MoodItem {
  id: string = ''
  mood: string = ''
  noteDate: string = ''
  coolIndex: number = 0

  static fromWire(w: MoodWire): MoodItem {
    const item = new MoodItem()
    item.id = w.id
    item.mood = w.mood ?? w.title
    item.noteDate = w.noteDate ?? ''
    item.coolIndex = w.coolIndex ?? 0
    return item
  }

  static fromLocal(id: string, mood: string, noteDate: string, coolIndex: number): MoodItem {
    const item = new MoodItem()
    item.id = id
    item.mood = mood
    item.noteDate = noteDate
    item.coolIndex = coolIndex
    return item
  }
}

export class MoodListPayload {
  list: MoodWire[] = []
}

export class MoodBody {
  mood: string = ''
  noteDate: string = ''
  coolIndex: number = 0
  userId: string = ''

  toJsonString(): string {
    return `{"mood":${JSON.stringify(this.mood)},"noteDate":${JSON.stringify(this.noteDate)},"coolIndex":${this.coolIndex},"userId":${JSON.stringify(this.userId)}}`
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
    return `{"modeId":${JSON.stringify(this.modeId)},"title":${JSON.stringify(this.title)},"durationSec":${this.durationSec},"noteDate":${JSON.stringify(this.noteDate)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class JournalWire {
  id: string = ''
  title: string = ''
  body: string = ''
  mood: string = ''
  noteDate: string = ''
  userId: string = ''
}

export class JournalItem {
  id: string = ''
  title: string = ''
  body: string = ''
  mood: string = ''
  noteDate: string = ''

  static fromWire(w: JournalWire): JournalItem {
    const item = new JournalItem()
    item.id = w.id
    item.title = w.title
    item.body = w.body ?? w.title
    item.mood = w.mood ?? ''
    item.noteDate = w.noteDate ?? ''
    return item
  }

  static fromLocal(id: string, title: string, body: string, mood: string, noteDate: string): JournalItem {
    const item = new JournalItem()
    item.id = id
    item.title = title
    item.body = body
    item.mood = mood
    item.noteDate = noteDate
    return item
  }
}

export class JournalListPayload {
  list: JournalWire[] = []
}

export class JournalBody {
  title: string = ''
  body: string = ''
  mood: string = ''
  noteDate: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"body":${JSON.stringify(this.body)},"mood":${JSON.stringify(this.mood)},"noteDate":${JSON.stringify(this.noteDate)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class EmptyOk {
  success: boolean = false
}

export class CoolPlanStats {
  moodCount: number = 0
  breathMinutes: number = 0
  journalCount: number = 0
  streakDays: number = 0
  todayCoolIndex: number = 0
}

export class MsgWire {
  id: string = ''
  title: string = ''
  body: string = ''
  summary: string = ''
  createdAt: string = ''
}

export class MsgListPayload {
  list: MsgWire[] = []
}

export class JournalUpdateBody {
  title: string = ''
  body: string = ''
  mood: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"body":${JSON.stringify(this.body)},"mood":${JSON.stringify(this.mood)},"userId":${JSON.stringify(this.userId)}}`
  }
}
