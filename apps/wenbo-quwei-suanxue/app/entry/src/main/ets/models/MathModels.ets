export class CatalogItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
  operator: string = ''
  questionCount: number = 10
  rule: string = ''
}

export class CatalogListData {
  list: CatalogItem[] = []
  items: CatalogItem[] = []
}

export class MathQuestion {
  id: string = ''
  left: number = 0
  right: number = 0
  op: string = 'add'
  opLabel: string = '+'
  expression: string = ''
  answer: number = 0
  options: number[] = []
  correctIndex: number = 0
}

export class WrongItem {
  id: string = ''
  expression: string = ''
  userAnswer: string = ''
  correctAnswer: string = ''
  lastAt: string = ''
  left: number = 0
  right: number = 0
  op: string = 'add'
}

export class PracticeSession {
  id: string = ''
  kind: string = 'daily'
  mode: string = 'mix'
  total: number = 0
  correct: number = 0
  stars: number = 0
  durationMs: number = 0
  date: string = ''
}

export class MathSettings {
  dailyCount: number = 10
  practiceCount: number = 10
  difficulty: string = 'easy'
  sound: boolean = true
  motion: boolean = true
  timedMode: boolean = false
  remindStudy: boolean = false
}

export class GrowthSnapshot {
  stars: number = 0
  sessions: number = 0
  answered: number = 0
  correct: number = 0
  streak: number = 0
  lastDate: string = ''
  accuracy: number = 0
  medals: string[] = []
}

export class WeekBar {
  label: string = ''
  value: number = 0
}

export class MedalView {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
  unlocked: boolean = false
}

export class QuizState {
  kind: string = 'daily'
  mode: string = 'mix'
  questions: MathQuestion[] = []
  index: number = 0
  correct: number = 0
  startedAt: number = 0
}

export class PadKey {
  label: string = ''
  action: string = 'digit'
}

export class LocalBundle {
  sessions: PracticeSession[] = []
  wrongs: WrongItem[] = []
  stars: number = 0
  streak: number = 0
  lastDate: string = ''
  answered: number = 0
  correct: number = 0
  medals: string[] = []
  settings: MathSettings = new MathSettings()
}
