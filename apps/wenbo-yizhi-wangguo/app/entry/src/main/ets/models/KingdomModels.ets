export class CatalogItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
  kind: string = ''
  skill: string = ''
  difficulty: number = 1
  questionCount: number = 4
  sortOrder: number = 0
  prompt: string = ''
  optionA: string = ''
  optionB: string = ''
  optionC: string = ''
  optionD: string = ''
  answerIndex: number = 0
  sequence: string = ''
  visualA: string = ''
  visualB: string = ''
  visualC: string = ''
  visualD: string = ''
  hint: string = ''
  explanation: string = ''
  rule: string = ''
  levelId: string = ''
  description: string = ''
}

export class MsgItem {
  id: string = ''
  title: string = ''
  body: string = ''
}

export class MsgListData {
  list: MsgItem[] = []
}

export class CatalogListData {
  list: CatalogItem[] = []
}

export class QuizQuestion {
  id: string = ''
  levelId: string = ''
  kind: string = ''
  skill: string = ''
  prompt: string = ''
  optionA: string = ''
  optionB: string = ''
  optionC: string = ''
  optionD: string = ''
  answerIndex: number = 0
  sequence: string = ''
  visualA: string = ''
  visualB: string = ''
  visualC: string = ''
  visualD: string = ''
  hint: string = ''
  explanation: string = ''
  coverKey: string = ''
}

export class QuizState {
  kind: string = 'level'
  levelId: string = ''
  questions: QuizQuestion[] = []
  index: number = 0
  correct: number = 0
  startedAt: number = 0
  seqProgress: number = 0
}

export class LevelProgress {
  levelId: string = ''
  kind: string = ''
  stars: number = 0
  correct: number = 0
  total: number = 0
  completed: boolean = false
  completedAt: string = ''
}

export class PracticeSession {
  id: string = ''
  kind: string = 'level'
  levelId: string = ''
  total: number = 0
  correct: number = 0
  stars: number = 0
  date: string = ''
}

export class KingdomSettings {
  sound: boolean = true
  fontScale: number = 1
}

export class GrowthSnapshot {
  stars: number = 0
  levelsDone: number = 0
  dailies: number = 0
  streak: number = 0
  lastDate: string = ''
  observe: number = 0
  logic: number = 0
  memory: number = 0
  create: number = 0
  answered: number = 0
}

export class WeekMark {
  label: string = ''
  done: boolean = false
}

export class RelicView {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
  rule: string = ''
  unlocked: boolean = false
}

export class LocalBundle {
  sessions: PracticeSession[] = []
  levels: LevelProgress[] = []
  stars: number = 0
  streak: number = 0
  lastDate: string = ''
  dailiesDone: number = 0
  lastDailyDate: string = ''
  relics: string[] = []
  observe: number = 0
  logic: number = 0
  memory: number = 0
  create: number = 0
  answered: number = 0
  correct: number = 0
  settings: KingdomSettings = new KingdomSettings()
}
