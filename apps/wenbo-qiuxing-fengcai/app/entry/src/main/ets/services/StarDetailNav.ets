/** 全局详情导航 — MainTabPage 顶层 Overlay */
export class StarDetailNav {
  private static bumpToken(): void {
    const token = AppStorage.get<number>('detailToken') ?? 0
    AppStorage.setOrCreate('detailToken', token + 1)
  }

  static openAthlete(id: string): void {
    AppStorage.setOrCreate('detailRoute', `athlete:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    StarDetailNav.bumpToken()
  }

  /** 从子 Overlay 跳转详情时强制刷新路由栈 */
  static pushAthlete(id: string): void {
    StarDetailNav.openAthlete(id)
  }

  static pushEvent(id: string): void {
    StarDetailNav.openEvent(id)
  }

  static openEvent(id: string): void {
    AppStorage.setOrCreate('detailRoute', `event:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    StarDetailNav.bumpToken()
  }

  static openSportHub(sport: string): void {
    AppStorage.setOrCreate('detailRoute', `sport:${sport}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    StarDetailNav.bumpToken()
  }

  static openCompare(): void {
    AppStorage.setOrCreate('detailRoute', 'compare')
    AppStorage.setOrCreate('tabBarHidden', true)
    StarDetailNav.bumpToken()
  }

  static openWatchPlan(): void {
    AppStorage.setOrCreate('detailRoute', 'watchplan')
    AppStorage.setOrCreate('tabBarHidden', true)
    StarDetailNav.bumpToken()
  }

  static openScoutNotes(athleteId: string): void {
    if (athleteId.length > 0) {
      AppStorage.setOrCreate('detailRoute', `scout:${athleteId}`)
    } else {
      AppStorage.setOrCreate('detailRoute', 'scout')
    }
    AppStorage.setOrCreate('tabBarHidden', true)
    StarDetailNav.bumpToken()
  }

  static openQuiz(): void {
    AppStorage.setOrCreate('detailRoute', 'quiz')
    AppStorage.setOrCreate('tabBarHidden', true)
    StarDetailNav.bumpToken()
  }

  static close(): void {
    AppStorage.setOrCreate('detailRoute', '')
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static currentRoute(): string {
    const v = AppStorage.get<string>('detailRoute')
    return v !== undefined && v !== null ? v : ''
  }

  static isOpen(): boolean {
    return StarDetailNav.currentRoute().length > 0
  }

  static parseKind(): string {
    const route = StarDetailNav.currentRoute()
    if (route === 'compare' || route === 'watchplan' || route === 'quiz' || route === 'scout') {
      return route
    }
    const idx = route.indexOf(':')
    if (idx < 0) {
      return ''
    }
    return route.substring(0, idx)
  }

  static parseId(): string {
    const route = StarDetailNav.currentRoute()
    if (route === 'compare' || route === 'watchplan' || route === 'quiz' || route === 'scout') {
      return ''
    }
    const idx = route.indexOf(':')
    if (idx < 0) {
      return ''
    }
    return route.substring(idx + 1)
  }
}
