export class PoemItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  author: string = ''
  dynasty: string = ''
  theme: string = ''
  body: string = ''
  summary: string = ''
  annotation: string = ''
  translation: string = ''
  appreciation: string = ''
  description: string = ''
  coverKey: string = 'cover_scroll'
}

export class PoemListData {
  list: PoemItem[] = []
}

export class QuestionItem {
  id: string = ''
  title: string = ''
  poemId: string = ''
  questionType: string = 'choice'
  prompt: string = ''
  optionA: string = ''
  optionB: string = ''
  optionC: string = ''
  optionD: string = ''
  answerIndex: number = 0
  answerText: string = ''
  matchLeft: string = ''
  matchRight: string = ''
  orderItems: string = ''
  explanation: string = ''
  coverKey: string = 'cover_scroll'
  category: string = ''
  difficulty: string = ''
}

export class QuestionListData {
  list: QuestionItem[] = []
}

export class FeihuaItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  keyword: string = ''
  difficulty: string = 'intro'
  summary: string = ''
  body: string = ''
  answerText: string = ''
  systemLines: string = ''
  coverKey: string = 'cover_moon'
}

export class FeihuaListData {
  list: FeihuaItem[] = []
}

export class ThemeItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = 'cover_scroll'
  category: string = ''
  theme: string = ''
}

export class ThemeListData {
  list: ThemeItem[] = []
}

export class KpiItem {
  id: string = ''
  key: string = ''
  label: string = ''
  value: string = ''
  trend: string = ''
}

export class KpiListData {
  list: KpiItem[] = []
}

export class MsgItem {
  id: string = ''
  title: string = ''
  body: string = ''
  type: string = 'system'
  read: boolean = false
  createdAt: string = ''
}

export class MsgListData {
  list: MsgItem[] = []
}

export class DailyRecordItem {
  date: string = ''
  score: number = 0
  maxCombo: number = 0
  correct: number = 0
  total: number = 0
}

export class ProgressState {
  lastDate: string = ''
  streak: number = 0
  totalAnswered: number = 0
  correctCount: number = 0
  maxCombo: number = 0
  totalScore: number = 0
  dailyDate: string = ''
  dailyScore: number = 0
  feihuaRounds: number = 0
  feihuaWins: number = 0
  favorites: string = ''
  dailyRecords: string = ''
  colorMode: string = 'system'
  fontScale: number = 1
}

export class FeihuaChatLine {
  role: string = 'system'
  text: string = ''
  at: string = ''
}
