/** 元素探索者 v2 — 探索档案 / 图鉴 / 任务 / 专题 */

export class AtlasNote {
  atlasId: string = ''
  status: string = 'unknown'
  myNote: string = ''
  updatedAt: number = 0
}

export class UserDiscovery {
  id: string = ''
  title: string = ''
  category: string = 'nature'
  tags: string[] = []
  status: string = 'exploring'
  description: string = ''
  whyInteresting: string = ''
  feeling: string = ''
  learned: string = ''
  placeText: string = ''
  dateKey: string = ''
  atlasRefId: string = ''
  isSample: boolean = false
  createdAt: number = 0
  updatedAt: number = 0

  static makeEmpty(): UserDiscovery {
    return new UserDiscovery()
  }
}

export class FavoriteFolder {
  id: string = ''
  name: string = ''
  itemKeys: string[] = []
  createdAt: number = 0
}

export class UserTopic {
  id: string = ''
  title: string = ''
  summary: string = ''
  discoveryIds: string[] = []
  atlasIds: string[] = []
  createdAt: number = 0
}

export class TaskCompletion {
  taskId: string = ''
  dateKey: string = ''
  done: boolean = false
}

export class ChallengeProgress {
  trackId: string = 'week7'
  currentDay: number = 0
  completedDays: number[] = []
  startedAt: string = ''
}

export class TimelineEvent {
  id: string = ''
  kind: string = ''
  title: string = ''
  detail: string = ''
  dateKey: string = ''
  at: number = 0
}

export class DisplayPrefs {
  themeMode: string = 'system'
  privacyAccepted: boolean = false
}

export class ExplorationState {
  discoveries: UserDiscovery[] = []
  atlasNotes: AtlasNote[] = []
  favoriteAtlasIds: string[] = []
  favoriteDiscoveryIds: string[] = []
  favoriteFolders: FavoriteFolder[] = []
  userTopics: UserTopic[] = []
  customTags: string[] = []
  taskCompletions: TaskCompletion[] = []
  challenge: ChallengeProgress = new ChallengeProgress()
  badgeIds: string[] = []
  timeline: TimelineEvent[] = []
  searchHistory: string[] = []
  lastOpenDate: string = ''
  streakDays: number = 0
  samplesDismissed: boolean = false
  displayPrefs: DisplayPrefs = new DisplayPrefs()
  legacyChemExplored: string[] = []
}

export class DomainStat {
  category: string = ''
  label: string = ''
  count: number = 0
  total: number = 0
}
