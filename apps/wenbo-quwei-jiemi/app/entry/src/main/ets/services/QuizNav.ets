export class QuizNav {
  static readonly NONE: string = ''
  static readonly QUIZ: string = 'quiz'
  static readonly FAVORITES: string = 'favorites'
  static readonly RECORDS: string = 'records'
  static readonly MEDALS: string = 'medals'
  static readonly GUIDE: string = 'guide'
  static readonly ABOUT: string = 'about'

  static route(): string {
    return AppStorage.get<string>('quizRoute') ?? QuizNav.NONE
  }

  static setRoute(route: string): void {
    AppStorage.setOrCreate('quizRoute', route)
    AppStorage.setOrCreate('tabBarHidden', route.length > 0)
    QuizNav.bump()
  }

  static close(): void {
    QuizNav.setRoute(QuizNav.NONE)
  }

  static bump(): void {
    const n = AppStorage.get<number>('quizTick') ?? 0
    AppStorage.setOrCreate('quizTick', n + 1)
  }

  static openQuiz(ids: string[], startIndex: number): void {
    AppStorage.setOrCreate('quizQueue', ids.join(','))
    AppStorage.setOrCreate('quizIndex', startIndex)
    AppStorage.setOrCreate('quizSelected', -1)
    AppStorage.setOrCreate('quizPhase', 'answering')
    AppStorage.setOrCreate('quizHintLevel', 0)
    AppStorage.setOrCreate('quizMaxHintUsed', 0)
    AppStorage.setOrCreate('quizSource', 'solo')
    QuizNav.setRoute(QuizNav.QUIZ)
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
    AppStorage.setOrCreate('quizHintLevel', 0)
    AppStorage.setOrCreate('quizMaxHintUsed', 0)
    QuizNav.bump()
  }

  static selected(): number {
    return AppStorage.get<number>('quizSelected') ?? -1
  }

  static setSelected(value: number): void {
    AppStorage.setOrCreate('quizSelected', value)
    QuizNav.bump()
  }

  static phase(): string {
    return AppStorage.get<string>('quizPhase') ?? 'answering'
  }

  static setPhase(value: string): void {
    AppStorage.setOrCreate('quizPhase', value)
    QuizNav.bump()
  }

  static hintLevel(): number {
    return AppStorage.get<number>('quizHintLevel') ?? 0
  }

  static setHintLevel(value: number): void {
    AppStorage.setOrCreate('quizHintLevel', value)
    const maxUsed = AppStorage.get<number>('quizMaxHintUsed') ?? 0
    if (value > maxUsed) {
      AppStorage.setOrCreate('quizMaxHintUsed', value)
    }
    QuizNav.bump()
  }

  static maxHintUsed(): number {
    return AppStorage.get<number>('quizMaxHintUsed') ?? 0
  }
}
