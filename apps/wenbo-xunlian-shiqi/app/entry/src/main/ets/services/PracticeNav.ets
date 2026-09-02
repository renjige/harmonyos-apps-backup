import { TrainingDetailNav } from './TrainingDetailNav'

export class PracticeNav {
  static openHub(kind: string): void {
    AppStorage.setOrCreate('practiceHubKind', kind)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeHub(): void {
    AppStorage.setOrCreate('practiceHubKind', '')
    TrainingDetailNav.restoreTabBar()
  }

  static openFollowAlong(): void {
    AppStorage.setOrCreate('showFollowAlong', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeFollowAlong(): void {
    AppStorage.setOrCreate('showFollowAlong', false)
    TrainingDetailNav.restoreTabBar()
  }

  static openRoulette(): void {
    AppStorage.setOrCreate('showSportRoulette', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeRoulette(): void {
    AppStorage.setOrCreate('showSportRoulette', false)
    TrainingDetailNav.restoreTabBar()
  }

  static openBreath(): void {
    AppStorage.setOrCreate('showBreathGuide', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeBreath(): void {
    AppStorage.setOrCreate('showBreathGuide', false)
    TrainingDetailNav.restoreTabBar()
  }

  static openWeekPlaybook(): void {
    AppStorage.setOrCreate('showWeekPlaybook', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeWeekPlaybook(): void {
    AppStorage.setOrCreate('showWeekPlaybook', false)
    TrainingDetailNav.restoreTabBar()
  }
}
