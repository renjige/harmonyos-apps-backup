export class ExploreRecord {
  id: string = ''
  symbol: string = ''
  title: string = ''
  action: string = ''
  detail: string = ''
  at: string = ''

  static make(id: string, symbol: string, title: string, action: string, detail: string, at: string): ExploreRecord {
    const x = new ExploreRecord()
    x.id = id
    x.symbol = symbol
    x.title = title
    x.action = action
    x.detail = detail
    x.at = at
    return x
  }
}

export class DisplayPrefs {
  showMass: boolean = true
  compactTable: boolean = false
  themeMode: string = 'system'
  privacyAccepted: boolean = false
}

export class ProgressState {
  exploredSymbols: string[] = []
  challengeDone: number = 0
  challengeCorrect: number = 0
  badgeIds: string[] = []
  favoriteElements: string[] = []
  favoriteTopics: string[] = []
  wishlist: string[] = []
  recentSymbols: string[] = []
  displayPrefs: DisplayPrefs = new DisplayPrefs()
  records: ExploreRecord[] = []
  scenarioDoneIds: string[] = []
  topicViewedIds: string[] = []
  searchHistory: string[] = []
  lastOpenDate: string = ''
  streakDays: number = 0
  scenarioDone: number = 0
}
