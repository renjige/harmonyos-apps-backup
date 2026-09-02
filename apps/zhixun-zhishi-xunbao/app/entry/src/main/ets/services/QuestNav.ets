export class QuestNav {
  static readonly NONE: string = ''
  static readonly MAP: string = 'map'
  static readonly TREASURE: string = 'treasure'
  static readonly BADGE: string = 'badge'
  static readonly QUIZ: string = 'quiz'
  static readonly MATCH: string = 'match'
  static readonly MESSAGES: string = 'messages'

  static setRoute(route: string): void {
    AppStorage.setOrCreate('questRoute', route)
    AppStorage.setOrCreate('tabBarHidden', route.length > 0)
    QuestNav.bump()
  }

  static close(): void {
    QuestNav.setRoute(QuestNav.NONE)
  }

  static bump(): void {
    const n = AppStorage.get<number>('questTick') ?? 0
    AppStorage.setOrCreate('questTick', n + 1)
  }

  static openMap(id: string): void {
    AppStorage.setOrCreate('detailId', id)
    AppStorage.setOrCreate('activeMapId', id)
    QuestNav.setRoute(QuestNav.MAP)
  }

  static openTreasure(id: string): void {
    AppStorage.setOrCreate('detailId', id)
    QuestNav.setRoute(QuestNav.TREASURE)
  }

  static openBadge(id: string): void {
    AppStorage.setOrCreate('detailId', id)
    QuestNav.setRoute(QuestNav.BADGE)
  }

  static openQuiz(mapId: string): void {
    AppStorage.setOrCreate('quizMapId', mapId)
    AppStorage.setOrCreate('activeMapId', mapId)
    QuestNav.setRoute(QuestNav.QUIZ)
  }

  static openMatch(): void {
    QuestNav.setRoute(QuestNav.MATCH)
  }

  static openMessages(): void {
    QuestNav.setRoute(QuestNav.MESSAGES)
  }

  static detailId(): string {
    return AppStorage.get<string>('detailId') ?? ''
  }

  static quizMapId(): string {
    return AppStorage.get<string>('quizMapId') ?? ''
  }
}
