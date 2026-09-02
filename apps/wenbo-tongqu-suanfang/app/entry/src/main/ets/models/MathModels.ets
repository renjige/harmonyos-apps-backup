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
  sortOrder: number = 0
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
  qType: string = 'fill'
  story: string = ''
  hint: string = ''
  choiceA: string = ''
  choiceB: string = ''
  choiceC: string = ''
  answerLabel: string = ''
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
  qType: string = 'fill'
  story: string = ''
  answerLabel: string = ''
  choiceA: string = ''
  choiceB: string = ''
  choiceC: string = ''
  tag: string = ''
  note: string = ''
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
  difficulty: string = 'easy'
  sound: boolean = true
  motion: boolean = true
  grade: string = 'age68'
  planStart: string = ''
  planPreset: string = 'balance'
  weekGoal: number = 50
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

export class DayMark {
  label: string = ''
  date: string = ''
  done: boolean = false
}

export class WeakHint {
  mode: string = 'add'
  title: string = '加法'
  count: number = 0
}

export class DayMission {
  id: string = ''
  title: string = ''
  hint: string = ''
  done: boolean = false
}

export class TableRowItem {
  n: number = 1
  id: string = ''
  title: string = ''
  preview: string = ''
}

export class CustomExpr {
  id: string = ''
  expression: string = ''
  left: number = 0
  right: number = 0
  op: string = 'add'
  answer: number = 0
}

export class CustomSet {
  id: string = ''
  title: string = ''
  createdAt: string = ''
  items: CustomExpr[] = []
}

export class StudyPack {
  id: string = ''
  title: string = ''
  modes: string = ''
  createdAt: string = ''
}

export class DayCheckIn {
  id: string = ''
  date: string = ''
  note: string = ''
  source: string = 'auto'
}

export class TimeEvent {
  id: string = ''
  date: string = ''
  title: string = ''
  hint: string = ''
  kind: string = ''
}

export class FilterChip {
  id: string = ''
  label: string = ''
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
  limitSec: number = 0
  challengeId: string = ''
}

export class PadKey {
  label: string = ''
  action: string = 'digit'
}

export class LocalBundle {
  sessions: PracticeSession[] = []
  wrongs: WrongItem[] = []
  favorites: WrongItem[] = []
  stars: number = 0
  streak: number = 0
  lastDate: string = ''
  answered: number = 0
  correct: number = 0
  medals: string[] = []
  challengeClear: number = 0
  settings: MathSettings = new MathSettings()
  checkins: DayCheckIn[] = []
  customSets: CustomSet[] = []
  packs: StudyPack[] = []
  recentModes: string = ''
}
