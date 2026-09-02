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
  wisdomPoints: number = 10
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

export class LeaderboardEntry {
  rank: number = 0
  userId: string = ''
  displayName: string = ''
  wisdomPoints: number = 0
  isSelf: boolean = false
}

export class LeaderboardListData {
  list: LeaderboardEntry[] = []
  scope: string = 'weekly'
}

export class PlayRecord {
  id: string = ''
  puzzleId: string = ''
  title: string = ''
  categoryLabel: string = ''
  correct: boolean = false
  wisdomEarned: number = 0
  at: string = ''
}

export class ProgressState {
  completedIds: string[] = []
  todayIds: string[] = []
  lastDate: string = ''
  streak: number = 0
  favorites: string[] = []
  records: PlayRecord[] = []
  wisdomPointsTotal: number = 0
  wisdomPointsWeek: number = 0
  wisdomWeekKey: string = ''
  visualCount: number = 0
  mathCount: number = 0
  medalIds: string[] = []
}

export class CategoryChip {
  id: string = ''
  label: string = ''
}
