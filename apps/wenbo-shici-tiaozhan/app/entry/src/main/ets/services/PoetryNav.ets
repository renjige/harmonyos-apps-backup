export class PoetryNav {
  static readonly NONE: string = ''
  static readonly QUIZ: string = 'quiz'
  static readonly FEIHUA: string = 'feihua'
  static readonly POEM: string = 'poem'
  static readonly SCORE: string = 'score'
  static readonly MINE: string = 'mine'

  static route(): string {
    return AppStorage.get<string>('poetryRoute') ?? PoetryNav.NONE
  }

  static setRoute(route: string): void {
    AppStorage.setOrCreate('poetryRoute', route)
    AppStorage.setOrCreate('tabBarHidden', route.length > 0)
    PoetryNav.bump()
  }

  static close(): void {
    PoetryNav.setRoute(PoetryNav.NONE)
  }

  static bump(): void {
    const n = AppStorage.get<number>('poetryTick') ?? 0
    AppStorage.setOrCreate('poetryTick', n + 1)
  }

  static openQuiz(ids: string[]): void {
    AppStorage.setOrCreate('quizQueue', ids.join(','))
    AppStorage.setOrCreate('quizIndex', 0)
    AppStorage.setOrCreate('quizSelected', -1)
    AppStorage.setOrCreate('quizPhase', 'answering')
    AppStorage.setOrCreate('quizCombo', 0)
    AppStorage.setOrCreate('quizScore', 0)
    AppStorage.setOrCreate('quizCorrect', 0)
    AppStorage.setOrCreate('quizMaxCombo', 0)
    AppStorage.setOrCreate('quizRemain', 15)
    PoetryNav.setRoute(PoetryNav.QUIZ)
  }

  static openFeihua(id: string): void {
    AppStorage.setOrCreate('feihuaId', id)
    AppStorage.setOrCreate('feihuaRound', 0)
    PoetryNav.setRoute(PoetryNav.FEIHUA)
  }

  static openFeihuaPicker(): void {
    AppStorage.setOrCreate('feihuaId', '')
    AppStorage.setOrCreate('feihuaRound', 0)
    PoetryNav.setRoute(PoetryNav.FEIHUA)
  }

  static openPoem(id: string): void {
    AppStorage.setOrCreate('poetryFocusId', id)
    PoetryNav.setRoute(PoetryNav.POEM)
  }

  static openScore(): void {
    PoetryNav.setRoute(PoetryNav.SCORE)
  }

  static openMine(): void {
    PoetryNav.setRoute(PoetryNav.MINE)
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
    AppStorage.setOrCreate('quizRemain', 15)
    PoetryNav.bump()
  }

  static selected(): number {
    return AppStorage.get<number>('quizSelected') ?? -1
  }

  static setSelected(value: number): void {
    AppStorage.setOrCreate('quizSelected', value)
  }

  static phase(): string {
    return AppStorage.get<string>('quizPhase') ?? 'answering'
  }

  static setPhase(value: string): void {
    AppStorage.setOrCreate('quizPhase', value)
  }

  static focusId(): string {
    return AppStorage.get<string>('poetryFocusId') ?? ''
  }

  static feihuaId(): string {
    return AppStorage.get<string>('feihuaId') ?? ''
  }
}
