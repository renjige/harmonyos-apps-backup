export class PuzzleItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  category: string = ''
  categoryLabel: string = ''
  difficulty: string = '轻松'
  question: string = ''
  optionA: string = ''
  optionB: string = ''
  optionC: string = ''
  optionD: string = ''
  answerIndex: number = 0
  hint: string = ''
  explanation: string = ''
  summary: string = ''
  coverKey: string = 'cat_riddle'
  ageBand: string = ''
  ageLabel: string = ''
  knowledge: string = ''
}

export class PuzzleListData {
  list: PuzzleItem[] = []
}

export class MedalItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  rule: string = ''
  coverKey: string = ''
}

export class MedalListData {
  list: MedalItem[] = []
}

export class GuideItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
}

export class GuideListData {
  list: GuideItem[] = []
}

export class MessageItem {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
}

export class MessageListData {
  list: MessageItem[] = []
}

export class PlayRecord {
  id: string = ''
  puzzleId: string = ''
  title: string = ''
  categoryLabel: string = ''
  correct: boolean = false
  at: string = ''
}

export class PlanGoalState {
  weekKey: string = ''
  targetCorrect: number = 15
  targetFamily: number = 1
  note: string = ''
}

export class ProgressState {
  completedIds: string[] = []
  todayIds: string[] = []
  lastDate: string = ''
  streak: number = 0
  favorites: string[] = []
  records: PlayRecord[] = []
  familyMatch: number = 0
  familyDate: string = ''
  familyRounds: number = 0
  visualCount: number = 0
  mathCount: number = 0
  medalIds: string[] = []
  wrongIds: string[] = []
  customJson: string = '[]'
  agePref: string = 'all'
  dailyGoalSet: number = 3
  weekKey: string = ''
  weekFamilyDone: boolean = false
  planGoal: PlanGoalState = new PlanGoalState()
  collectionsJson: string = '[]'
  timelineJson: string = '[]'
}

export class CategoryChip {
  id: string = ''
  label: string = ''
}
