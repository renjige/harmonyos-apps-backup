export type KnowledgeCategory = '历史' | '科学' | '文化' | '哲学' | '艺术'

export class KnowledgeFact {
  label: string = ''
  content: string = ''

  constructor(label: string = '', content: string = '') {
    this.label = label
    this.content = content
  }
}

export class TimelinePoint {
  year: string = ''
  event: string = ''

  constructor(year: string = '', event: string = '') {
    this.year = year
    this.event = event
  }
}

export class KnowledgeObject {
  id: string = ''
  title: string = ''
  category: KnowledgeCategory = '历史'
  coverKey: string = ''
  atlasKind: string = ''
  summary: string = ''
  body: string = ''
  facts: KnowledgeFact[] = []
  timeline: TimelinePoint[] = []

  addFact(label: string, content: string): void {
    this.facts.push(new KnowledgeFact(label, content))
  }

  addTimeline(year: string, event: string): void {
    this.timeline.push(new TimelinePoint(year, event))
  }
}

export class UserProfile {
  nickname: string = '格物者'
  themeMode: string = 'system'
}

export class TraceStats {
  readDays: number = 0
  favoriteCount: number = 0
  deepenCount: number = 0
  totalPool: number = 0
  noteCount: number = 0
  recordCount: number = 0
  albumCount: number = 0
  questDone: number = 0
  exploreStreak: number = 0
  streakHint: string = ''
}
