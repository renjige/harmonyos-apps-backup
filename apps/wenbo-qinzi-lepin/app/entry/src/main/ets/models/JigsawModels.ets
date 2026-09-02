export class ThemeItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  description: string = ''
  body: string = ''
  coverKey: string = 'theme_animal'
  theme: string = ''
  themeLabel: string = ''
}

export class ThemeListData {
  list: ThemeItem[] = []
}

export class JigsawItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  description: string = ''
  body: string = ''
  coverKey: string = 'jz_a_puppy'
  theme: string = ''
  themeLabel: string = ''
}

export class JigsawListData {
  list: JigsawItem[] = []
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

export class PlayRecord {
  id: string = ''
  jigsawId: string = ''
  title: string = ''
  themeLabel: string = ''
  pieces: number = 4
  stars: number = 1
  durationMs: number = 0
  hintsUsed: number = 0
  collab: boolean = false
  coverKey: string = 'hero_desk'
  at: string = ''
}

export class ProgressState {
  completedIds: string[] = []
  lastDate: string = ''
  streak: number = 0
  totalStars: number = 0
  noHintCount: number = 0
  pieces16Count: number = 0
  collabCount: number = 0
  hintUsedCount: number = 0
  records: PlayRecord[] = []
  medalIds: string[] = []
  soundOn: boolean = true
  defaultPieces: number = 4
}

export class BoardSlot {
  index: number = 0
  occupant: number = -1
}

export class TrayPiece {
  correctIndex: number = 0
}
