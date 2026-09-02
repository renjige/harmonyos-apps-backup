/** 知识探宝 — 平台 /biz/knowledge-treasure 数据模型 */

export class TreasureCard {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  category: string = ''
  categoryLabel: string = ''
  tags: string = ''
  publishDate: string = ''
  daily: boolean = false
}

export class TreasureQuestion {
  id: string = ''
  title: string = ''
  question: string = ''
  optionA: string = ''
  optionB: string = ''
  optionC: string = ''
  optionD: string = ''
  answerIndex: number = 0
  tip: string = ''
  explanation: string = ''
  difficulty: string = ''
  category: string = ''
  categoryLabel: string = ''
  daily: boolean = false
}

export class TreasureTheme {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  category: string = ''
  categoryLabel: string = ''
  coverKey: string = ''
}

export class TreasureMatch {
  id: string = ''
  title: string = ''
  summary: string = ''
  pairLeft: string = ''
  pairRight: string = ''
  category: string = ''
}

export class TreasureKpi {
  label: string = ''
  value: string = ''
  trend: string = ''
  positive: boolean = true
}

export class TreasureMessage {
  id: string = ''
  title: string = ''
  body: string = ''
  createdAt: string = ''
}

export class TreasureListData<T> {
  list: T[] = []
}

export class VaultRecord {
  id: string = ''
  refId: string = ''
  title: string = ''
  categoryLabel: string = ''
  correct: boolean = false
  pointsEarned: number = 0
  at: string = ''
}

export class VaultState {
  favorites: string[] = []
  completedQuestionIds: string[] = []
  completedMatchIds: string[] = []
  todayQuestionIds: string[] = []
  lastDate: string = ''
  streak: number = 0
  totalPoints: number = 0
  weekPoints: number = 0
  weekKey: string = ''
  records: VaultRecord[] = []
}

export class MsgListPayload {
  list: TreasureMessage[] = []
}

export class KpiListPayload {
  list: TreasureKpi[] = []
}
