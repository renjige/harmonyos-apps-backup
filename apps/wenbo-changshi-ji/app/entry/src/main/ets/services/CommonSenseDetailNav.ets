/** 常识集全局 Overlay 路由 */

export class CommonSenseDetailNav {
  private static bump(): void {
    const token = AppStorage.get<number>('detailToken') ?? 0
    AppStorage.setOrCreate('detailToken', token + 1)
  }

  static openFact(id: string): void {
    AppStorage.setOrCreate('detailRoute', `fact:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    CommonSenseDetailNav.bump()
  }

  static openNote(id: string): void {
    AppStorage.setOrCreate('detailRoute', `note:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    CommonSenseDetailNav.bump()
  }

  static openStats(): void {
    AppStorage.setOrCreate('detailRoute', 'stats:all')
    AppStorage.setOrCreate('tabBarHidden', true)
    CommonSenseDetailNav.bump()
  }

  static openCheckIn(): void {
    AppStorage.setOrCreate('detailRoute', 'checkin:all')
    AppStorage.setOrCreate('tabBarHidden', true)
    CommonSenseDetailNav.bump()
  }

  static openDiagnose(): void {
    AppStorage.setOrCreate('detailRoute', 'diagnose:quiz')
    AppStorage.setOrCreate('tabBarHidden', true)
    CommonSenseDetailNav.bump()
  }

  static openQuiz(): void {
    AppStorage.setOrCreate('detailRoute', 'quiz:all')
    AppStorage.setOrCreate('tabBarHidden', true)
    CommonSenseDetailNav.bump()
  }

  static openScenes(): void {
    AppStorage.setOrCreate('detailRoute', 'scenes:all')
    AppStorage.setOrCreate('tabBarHidden', true)
    CommonSenseDetailNav.bump()
  }

  static openLists(): void {
    AppStorage.setOrCreate('detailRoute', 'lists:all')
    AppStorage.setOrCreate('tabBarHidden', true)
    CommonSenseDetailNav.bump()
  }

  static openList(id: string): void {
    AppStorage.setOrCreate('detailRoute', `list:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    CommonSenseDetailNav.bump()
  }

  static openTools(): void {
    AppStorage.setOrCreate('detailRoute', 'tools:all')
    AppStorage.setOrCreate('tabBarHidden', true)
    CommonSenseDetailNav.bump()
  }

  static openRemind(): void {
    AppStorage.setOrCreate('detailRoute', 'remind:all')
    AppStorage.setOrCreate('tabBarHidden', true)
    CommonSenseDetailNav.bump()
  }

  static openHistory(): void {
    AppStorage.setOrCreate('detailRoute', 'history:all')
    AppStorage.setOrCreate('tabBarHidden', true)
    CommonSenseDetailNav.bump()
  }

  static openSearch(): void {
    AppStorage.setOrCreate('detailRoute', 'search:all')
    AppStorage.setOrCreate('tabBarHidden', true)
    CommonSenseDetailNav.bump()
  }

  static openSceneGuide(scene: string): void {
    AppStorage.setOrCreate('detailRoute', `sceneGuide:${scene}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    CommonSenseDetailNav.bump()
  }

  static openGrowth(): void {
    AppStorage.setOrCreate('detailRoute', 'growth:all')
    AppStorage.setOrCreate('tabBarHidden', true)
    CommonSenseDetailNav.bump()
  }

  static openPlan(): void {
    AppStorage.setOrCreate('detailRoute', 'plan:all')
    AppStorage.setOrCreate('tabBarHidden', true)
    CommonSenseDetailNav.bump()
  }

  static openTimeline(): void {
    AppStorage.setOrCreate('detailRoute', 'timeline:all')
    AppStorage.setOrCreate('tabBarHidden', true)
    CommonSenseDetailNav.bump()
  }

  static openAchievements(): void {
    AppStorage.setOrCreate('detailRoute', 'achievements:all')
    AppStorage.setOrCreate('tabBarHidden', true)
    CommonSenseDetailNav.bump()
  }

  static openReview(): void {
    AppStorage.setOrCreate('detailRoute', 'review:all')
    AppStorage.setOrCreate('tabBarHidden', true)
    CommonSenseDetailNav.bump()
  }

  static openTopics(): void {
    AppStorage.setOrCreate('detailRoute', 'topics:all')
    AppStorage.setOrCreate('tabBarHidden', true)
    CommonSenseDetailNav.bump()
  }

  static openUserNotes(): void {
    AppStorage.setOrCreate('detailRoute', 'usernotes:all')
    AppStorage.setOrCreate('tabBarHidden', true)
    CommonSenseDetailNav.bump()
  }

  static openMessages(): void {
    AppStorage.setOrCreate('detailRoute', 'messages:all')
    AppStorage.setOrCreate('tabBarHidden', true)
    CommonSenseDetailNav.bump()
  }

  static openShare(id: string): void {
    AppStorage.setOrCreate('detailRoute', `share:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    CommonSenseDetailNav.bump()
  }

  static close(): void {
    AppStorage.setOrCreate('detailRoute', '')
    if (!CommonSenseDetailNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
    CommonSenseDetailNav.bump()
  }

  static openSettings(): void {
    AppStorage.setOrCreate('showMineSettings', true)
    AppStorage.setOrCreate('tabBarHidden', true)
    CommonSenseDetailNav.bump()
  }

  static closeSettings(): void {
    AppStorage.setOrCreate('showMineSettings', false)
    if (!CommonSenseDetailNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
    CommonSenseDetailNav.bump()
  }

  static routeKind(route: string): string {
    const idx = route.indexOf(':')
    if (idx < 0) {
      return ''
    }
    return route.substring(0, idx)
  }

  static parseRouteId(route: string): string {
    const first = route.indexOf(':')
    if (first < 0) {
      return ''
    }
    return route.substring(first + 1)
  }

  static keepTabHidden(): boolean {
    const route = AppStorage.get<string>('detailRoute') ?? ''
    const settings = AppStorage.get<boolean>('showMineSettings') === true
    return route.length > 0 || settings
  }

  static switchTab(index: number): void {
    AppStorage.setOrCreate('mainTabIndex', index)
  }

  static bumpRefresh(): void {
    const n = AppStorage.get<number>('csRefresh') ?? 0
    AppStorage.setOrCreate('csRefresh', n + 1)
  }
}
