import { ProgressStore } from './ProgressStore'

export class QuizNav {
  static readonly NONE: string = ''
  static readonly QUIZ: string = 'quiz'
  static readonly FAMILY: string = 'family'
  static readonly DETAIL: string = 'detail'
  static readonly SUMMARY: string = 'summary'
  static readonly FAVORITES: string = 'favorites'
  static readonly RECORDS: string = 'records'
  static readonly MEDALS: string = 'medals'
  static readonly GUIDE: string = 'guide'
  static readonly CUSTOM: string = 'custom'
  static readonly REVIEW: string = 'review'

  static route(): string {
    return AppStorage.get<string>('quizRoute') ?? QuizNav.NONE
  }

  static setRoute(route: string): void {
    AppStorage.setOrCreate('quizRoute', route)
    AppStorage.setOrCreate('tabBarHidden', route.length > 0)
    QuizNav.bump()
  }

  static close(): void {
    ProgressStore.sync()
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
    AppStorage.setOrCreate('quizShowHint', false)
    AppStorage.setOrCreate('quizSource', 'solo')
    AppStorage.setOrCreate('quizSessionCorrect', 0)
    QuizNav.setRoute(QuizNav.QUIZ)
  }

  static openDetail(id: string): void {
    AppStorage.setOrCreate('detailPuzzleId', id)
    QuizNav.setRoute(QuizNav.DETAIL)
  }

  static detailId(): string {
    return AppStorage.get<string>('detailPuzzleId') ?? ''
  }

  static openSummary(correctCount: number, total: number): void {
    AppStorage.setOrCreate('summaryCorrect', correctCount)
    AppStorage.setOrCreate('summaryTotal', total)
    QuizNav.setRoute(QuizNav.SUMMARY)
  }

  static summaryCorrect(): number {
    return AppStorage.get<number>('summaryCorrect') ?? 0
  }

  static summaryTotal(): number {
    return AppStorage.get<number>('summaryTotal') ?? 0
  }

  static sessionCorrect(): number {
    return AppStorage.get<number>('quizSessionCorrect') ?? 0
  }

  static addSessionCorrect(): void {
    const n = AppStorage.get<number>('quizSessionCorrect') ?? 0
    AppStorage.setOrCreate('quizSessionCorrect', n + 1)
  }

  static openCustom(): void {
    QuizNav.setRoute(QuizNav.CUSTOM)
  }

  static openReview(): void {
    QuizNav.setRoute(QuizNav.REVIEW)
  }

  static openFamily(ids: string[]): void {
    AppStorage.setOrCreate('quizQueue', ids.join(','))
    AppStorage.setOrCreate('quizIndex', 0)
    AppStorage.setOrCreate('quizSelected', -1)
    AppStorage.setOrCreate('familyStep', 'parent')
    AppStorage.setOrCreate('familyParent', '')
    AppStorage.setOrCreate('familyChild', '')
    QuizNav.setRoute(QuizNav.FAMILY)
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
    AppStorage.setOrCreate('quizShowHint', false)
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
}
