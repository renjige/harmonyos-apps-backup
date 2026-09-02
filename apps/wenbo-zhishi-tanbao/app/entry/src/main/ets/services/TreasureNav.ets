export class TreasureNav {
  static readonly NONE: string = ''
  static readonly QUIZ: string = 'quiz'
  static readonly CARD: string = 'card'

  static route(): string {
    return AppStorage.get<string>('treasureRoute') ?? TreasureNav.NONE
  }

  static setRoute(route: string): void {
    AppStorage.setOrCreate('treasureRoute', route)
    AppStorage.setOrCreate('tabBarHidden', route.length > 0)
    TreasureNav.bump()
  }

  static close(): void {
    TreasureNav.setRoute(TreasureNav.NONE)
  }

  static bump(): void {
    const n = AppStorage.get<number>('treasureTick') ?? 0
    AppStorage.setOrCreate('treasureTick', n + 1)
  }

  static openQuiz(ids: string[], startIndex: number): void {
    AppStorage.setOrCreate('quizQueue', ids.join(','))
    AppStorage.setOrCreate('quizIndex', startIndex)
    AppStorage.setOrCreate('quizSelected', -1)
    AppStorage.setOrCreate('quizPhase', 'answering')
    TreasureNav.setRoute(TreasureNav.QUIZ)
  }

  static openCard(id: string): void {
    AppStorage.setOrCreate('detailCardId', id)
    AppStorage.setOrCreate('detailRoute', `${TreasureNav.CARD}:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    TreasureNav.bump()
  }

  static closeDetail(): void {
    AppStorage.setOrCreate('detailRoute', '')
    AppStorage.setOrCreate('detailCardId', '')
    if (!TreasureNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
    TreasureNav.bump()
  }

  static openMessages(): void {
    AppStorage.setOrCreate('showMessages', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeMessages(): void {
    AppStorage.setOrCreate('showMessages', false)
    if (!TreasureNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static switchTab(index: number): void {
    AppStorage.setOrCreate('mainTabIndex', index)
  }

  static isDetailOpen(): boolean {
    const route = AppStorage.get<string>('detailRoute') ?? ''
    return route.length > 0
  }

  static keepTabHidden(): boolean {
    return TreasureNav.isDetailOpen() ||
      AppStorage.get<string>('treasureRoute') === TreasureNav.QUIZ ||
      AppStorage.get<boolean>('showMessages') === true ||
      AppStorage.get<boolean>('vaultSettingsOpen') === true
  }

  static parseCardId(): string {
    const route = AppStorage.get<string>('detailRoute') ?? ''
    const idx = route.indexOf(':')
    if (idx < 0) {
      return AppStorage.get<string>('detailCardId') ?? ''
    }
    return route.substring(idx + 1)
  }

  static queue(): string[] {
    const raw = AppStorage.get<string>('quizQueue') ?? ''
    if (raw.length === 0) {
      return []
    }
    return raw.split(',')
  }

  static index(): number {
    return AppStorage.get<number>('quizIndex') ?? 0
  }

  static setIndex(value: number): void {
    AppStorage.setOrCreate('quizIndex', value)
    AppStorage.setOrCreate('quizSelected', -1)
    AppStorage.setOrCreate('quizPhase', 'answering')
    TreasureNav.bump()
  }

  static selected(): number {
    return AppStorage.get<number>('quizSelected') ?? -1
  }

  static setSelected(value: number): void {
    AppStorage.setOrCreate('quizSelected', value)
    TreasureNav.bump()
  }

  static phase(): string {
    return AppStorage.get<string>('quizPhase') ?? 'answering'
  }

  static setPhase(value: string): void {
    AppStorage.setOrCreate('quizPhase', value)
    TreasureNav.bump()
  }
}
