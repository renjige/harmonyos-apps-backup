export class IdiomNav {
  static readonly NONE: string = ''
  static readonly QUIZ: string = 'quiz'
  static readonly CHAPTER: string = 'chapter'
  static readonly THEME: string = 'theme'
  static readonly SCORE: string = 'score'
  static readonly DIAGNOSE: string = 'diagnose'
  static readonly BADGE: string = 'badge'

  static setRoute(route: string): void {
    AppStorage.setOrCreate('quizRoute', route)
    AppStorage.setOrCreate('tabBarHidden', route.length > 0)
    IdiomNav.bump()
  }

  static close(): void {
    IdiomNav.setRoute(IdiomNav.NONE)
  }

  static bump(): void {
    const n = AppStorage.get<number>('quizTick') ?? 0
    AppStorage.setOrCreate('quizTick', n + 1)
  }

  static openQuiz(ids: string[], source: string): void {
    AppStorage.setOrCreate('quizQueue', ids.join(','))
    AppStorage.setOrCreate('quizIndex', 0)
    AppStorage.setOrCreate('quizSelected', -1)
    AppStorage.setOrCreate('quizPhase', 'answering')
    AppStorage.setOrCreate('quizSource', source)
    AppStorage.setOrCreate('quizCombo', 0)
    AppStorage.setOrCreate('quizScore', 0)
    AppStorage.setOrCreate('quizCorrect', 0)
    AppStorage.setOrCreate('quizMaxCombo', 0)
    AppStorage.setOrCreate('quizRemain', 15)
    IdiomNav.setRoute(IdiomNav.QUIZ)
  }

  static openChapter(id: string): void {
    AppStorage.setOrCreate('detailId', id)
    IdiomNav.setRoute(IdiomNav.CHAPTER)
  }

  static openTheme(id: string): void {
    AppStorage.setOrCreate('detailId', id)
    IdiomNav.setRoute(IdiomNav.THEME)
  }

  static openBadge(id: string): void {
    AppStorage.setOrCreate('detailId', id)
    IdiomNav.setRoute(IdiomNav.BADGE)
  }

  static openScore(): void {
    IdiomNav.setRoute(IdiomNav.SCORE)
  }

  static openDiagnose(): void {
    IdiomNav.setRoute(IdiomNav.DIAGNOSE)
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
    IdiomNav.bump()
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

  static detailId(): string {
    return AppStorage.get<string>('detailId') ?? ''
  }
}
