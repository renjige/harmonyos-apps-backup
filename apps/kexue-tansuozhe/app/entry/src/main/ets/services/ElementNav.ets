export class ElementNav {
  static bump(): void {
    const tick = AppStorage.get<number>('elementNavTick') ?? 0
    AppStorage.setOrCreate('elementNavTick', tick + 1)
    const rev = AppStorage.get<number>('progressRev') ?? 0
    AppStorage.setOrCreate('progressRev', rev + 1)
  }

  static anyOverlayOpen(): boolean {
    if (AppStorage.get<boolean>('elementShowDetail') === true) {
      return true
    }
    if (AppStorage.get<boolean>('elementShowSearch') === true) {
      return true
    }
    if (AppStorage.get<boolean>('elementShowQuiz') === true) {
      return true
    }
    if (AppStorage.get<boolean>('elementShowRelation') === true) {
      return true
    }
    if (AppStorage.get<boolean>('elementShowScenario') === true) {
      return true
    }
    if (AppStorage.get<boolean>('elementShowRecords') === true) {
      return true
    }
    if (AppStorage.get<boolean>('elementShowBadges') === true) {
      return true
    }
    return false
  }

  static maybeShowTabBar(): void {
    if (!ElementNav.anyOverlayOpen()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static openDetail(symbol: string): void {
    AppStorage.setOrCreate('elementDetailSymbol', symbol)
    AppStorage.setOrCreate('elementShowDetail', true)
    AppStorage.setOrCreate('tabBarHidden', true)
    ElementNav.bump()
  }

  static closeDetail(): void {
    AppStorage.setOrCreate('elementShowDetail', false)
    AppStorage.setOrCreate('elementDetailSymbol', '')
    ElementNav.maybeShowTabBar()
    ElementNav.bump()
  }

  static detailSymbol(): string {
    return AppStorage.get<string>('elementDetailSymbol') ?? ''
  }

  static openSearch(): void {
    AppStorage.setOrCreate('elementShowSearch', true)
    AppStorage.setOrCreate('tabBarHidden', true)
    ElementNav.bump()
  }

  static closeSearch(): void {
    AppStorage.setOrCreate('elementShowSearch', false)
    ElementNav.maybeShowTabBar()
    ElementNav.bump()
  }

  static openQuiz(challengeType: string): void {
    AppStorage.setOrCreate('elementQuizType', challengeType)
    AppStorage.setOrCreate('elementQuizIndex', 0)
    AppStorage.setOrCreate('elementQuizSelected', -1)
    AppStorage.setOrCreate('elementQuizPhase', 'answering')
    AppStorage.setOrCreate('elementQuizScore', 0)
    AppStorage.setOrCreate('elementShowQuiz', true)
    AppStorage.setOrCreate('tabBarHidden', true)
    ElementNav.bump()
  }

  static closeQuiz(): void {
    AppStorage.setOrCreate('elementShowQuiz', false)
    AppStorage.setOrCreate('elementQuizType', '')
    ElementNav.maybeShowTabBar()
    ElementNav.bump()
  }

  static quizType(): string {
    return AppStorage.get<string>('elementQuizType') ?? ''
  }

  static openRelation(symbol: string): void {
    AppStorage.setOrCreate('elementRelationSymbol', symbol)
    AppStorage.setOrCreate('elementShowRelation', true)
    AppStorage.setOrCreate('tabBarHidden', true)
    ElementNav.bump()
  }

  static closeRelation(): void {
    AppStorage.setOrCreate('elementShowRelation', false)
    AppStorage.setOrCreate('elementRelationSymbol', '')
    ElementNav.maybeShowTabBar()
    ElementNav.bump()
  }

  static relationSymbol(): string {
    return AppStorage.get<string>('elementRelationSymbol') ?? ''
  }

  static openScenario(scenarioId: string): void {
    AppStorage.setOrCreate('elementScenarioId', scenarioId)
    AppStorage.setOrCreate('elementScenarioStep', 0)
    AppStorage.setOrCreate('elementShowScenario', true)
    AppStorage.setOrCreate('tabBarHidden', true)
    ElementNav.bump()
  }

  static openScenarioForSymbol(symbol: string): void {
    AppStorage.setOrCreate('elementScenarioSymbol', symbol)
    AppStorage.setOrCreate('elementScenarioId', '')
    AppStorage.setOrCreate('elementScenarioStep', 0)
    AppStorage.setOrCreate('elementShowScenario', true)
    AppStorage.setOrCreate('tabBarHidden', true)
    ElementNav.bump()
  }

  static closeScenario(): void {
    AppStorage.setOrCreate('elementShowScenario', false)
    AppStorage.setOrCreate('elementScenarioId', '')
    AppStorage.setOrCreate('elementScenarioSymbol', '')
    AppStorage.setOrCreate('elementScenarioStep', 0)
    ElementNav.maybeShowTabBar()
    ElementNav.bump()
  }

  static scenarioId(): string {
    return AppStorage.get<string>('elementScenarioId') ?? ''
  }

  static scenarioSymbol(): string {
    return AppStorage.get<string>('elementScenarioSymbol') ?? ''
  }

  static openRecords(): void {
    AppStorage.setOrCreate('elementShowRecords', true)
    AppStorage.setOrCreate('tabBarHidden', true)
    ElementNav.bump()
  }

  static closeRecords(): void {
    AppStorage.setOrCreate('elementShowRecords', false)
    ElementNav.maybeShowTabBar()
    ElementNav.bump()
  }

  static openBadges(): void {
    AppStorage.setOrCreate('elementShowBadges', true)
    AppStorage.setOrCreate('tabBarHidden', true)
    ElementNav.bump()
  }

  static closeBadges(): void {
    AppStorage.setOrCreate('elementShowBadges', false)
    ElementNav.maybeShowTabBar()
    ElementNav.bump()
  }

  static switchTab(index: number): void {
    AppStorage.setOrCreate('elementSwitchTab', index)
    ElementNav.bump()
  }
}
