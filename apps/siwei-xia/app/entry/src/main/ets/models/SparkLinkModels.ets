export class SparkLink {
  cardId: string = ''
  breakId: string = ''
  noteId: string = ''
  opinionId: string = ''
}

export class TimelineEvent {
  id: string = ''
  kind: string = ''
  title: string = ''
  subtitle: string = ''
  at: number = 0
  cardId: string = ''
}

export class WeekInsight {
  sparkNew: number = 0
  thinkNew: number = 0
  linked: number = 0
  topTag: string = '未分类'
  streak: number = 0
  summary: string = ''
}
