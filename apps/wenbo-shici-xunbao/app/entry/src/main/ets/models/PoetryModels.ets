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
  placeId: string = ''
  placeName: string = ''
  difficulty: string = ''
}

export class PoemListData {
  list: PoemItem[] = []
}

export class PlaceItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  region: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = 'cover_city'
  mapX: number = 50
  mapY: number = 50
}

export class PlaceListData {
  list: PlaceItem[] = []
}

export class LevelItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  difficulty: string = ''
  rankKey: string = ''
  summary: string = ''
  body: string = ''
  coins: number = 8
  hidden: boolean = false
  coverKey: string = 'cover_scroll'
}

export class LevelListData {
  list: LevelItem[] = []
}

export class QuestionItem {
  id: string = ''
  title: string = ''
  levelId: string = ''
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
}

export class QuestionListData {
  list: QuestionItem[] = []
}

export class MedalItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  rule: string = ''
  coverKey: string = 'cover_scroll'
}

export class MedalListData {
  list: MedalItem[] = []
}

export class HuntNote {
  poemId: string = ''
  title: string = ''
  body: string = ''
  at: string = ''
}

export class HuntRecord {
  levelId: string = ''
  title: string = ''
  coins: number = 0
  at: string = ''
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

export class HuntProgressState {
  coins: number = 0
  clearedLevelIds: string[] = []
  unlockedPlaceIds: string[] = []
  favorites: string[] = []
  medalIds: string[] = []
  notes: HuntNote[] = []
  records: HuntRecord[] = []
  hiddenUnlocked: boolean = false
  fontScale: number = 100
  colorMode: string = 'system'
}
