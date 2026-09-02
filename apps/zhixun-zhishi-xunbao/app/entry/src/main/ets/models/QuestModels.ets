export class QuestMap {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = 'hero_discover'
  coverMedia: string = ''
  category: string = ''
  categoryLabel: string = ''
  difficulty: number = 1
  totalQuestions: number = 6
  estimatedMinutes: number = 8
  heat: number = 0
  recommend: boolean = false
  wisdomReward: number = 40
  retryLimit: number = 3
}

export class MapListData {
  list: QuestMap[] = []
}

export class QuestQuestion {
  id: string = ''
  mapId: string = ''
  title: string = ''
  qType: string = 'choice'
  optionA: string = ''
  optionB: string = ''
  optionC: string = ''
  optionD: string = ''
  answerIndex: number = 0
  explanation: string = ''
  coverKey: string = ''
  sortOrder: number = 0
}

export class QuestionListData {
  list: QuestQuestion[] = []
}

export class QuestTreasure {
  id: string = ''
  mapId: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = 'hero_discover'
  coverMedia: string = ''
  categoryLabel: string = ''
  wisdomReward: number = 40
}

export class TreasureListData {
  list: QuestTreasure[] = []
}

export class QuestBadge {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = 'badge_first'
  coverMedia: string = ''
}

export class BadgeListData {
  list: QuestBadge[] = []
}

export class KpiItem {
  id: string = ''
  key: string = ''
  label: string = ''
  value: string = ''
}

export class KpiListData {
  list: KpiItem[] = []
}

export class MsgItem {
  id: string = ''
  title: string = ''
  body: string = ''
  type: string = ''
}

export class MsgListData {
  list: MsgItem[] = []
}

export class OptionItem {
  index: number = 0
  text: string = ''
}

export class CatChip {
  id: string = ''
  label: string = ''
}
