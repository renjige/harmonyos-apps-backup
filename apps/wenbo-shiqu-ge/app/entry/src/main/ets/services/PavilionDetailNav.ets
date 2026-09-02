/** 识趣阁全局 Overlay 路由 */

export class PavilionDetailNav {
  private static bump(): void {
    const token = AppStorage.get<number>('detailToken') ?? 0
    AppStorage.setOrCreate('detailToken', token + 1)
  }

  static openArticle(id: string): void {
    AppStorage.setOrCreate('detailRoute', `article:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    PavilionDetailNav.bump()
  }

  static openDaily(id: string): void {
    AppStorage.setOrCreate('detailRoute', `daily:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    PavilionDetailNav.bump()
  }

  static openSearch(): void {
    AppStorage.setOrCreate('detailRoute', 'search:all')
    AppStorage.setOrCreate('tabBarHidden', true)
    PavilionDetailNav.bump()
  }

  static openHistory(): void {
    AppStorage.setOrCreate('detailRoute', 'history:all')
    AppStorage.setOrCreate('tabBarHidden', true)
    PavilionDetailNav.bump()
  }

  static openMessages(): void {
    AppStorage.setOrCreate('detailRoute', 'messages:all')
    AppStorage.setOrCreate('tabBarHidden', true)
    PavilionDetailNav.bump()
  }

  static openDiagnose(): void {
    AppStorage.setOrCreate('detailRoute', 'diagnose:quiz')
    AppStorage.setOrCreate('tabBarHidden', true)
    PavilionDetailNav.bump()
  }

  static openQuiz(articleId: string): void {
    AppStorage.setOrCreate('detailRoute', `quiz:${articleId}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    PavilionDetailNav.bump()
  }

  static openNotes(): void {
    AppStorage.setOrCreate('detailRoute', 'notes:all')
    AppStorage.setOrCreate('tabBarHidden', true)
    PavilionDetailNav.bump()
  }

  static openNoteNew(articleId: string): void {
    AppStorage.setOrCreate('detailRoute', `notewrite:${articleId}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    PavilionDetailNav.bump()
  }

  static openCollections(): void {
    AppStorage.setOrCreate('detailRoute', 'collections:all')
    AppStorage.setOrCreate('tabBarHidden', true)
    PavilionDetailNav.bump()
  }

  static openCollection(id: string): void {
    AppStorage.setOrCreate('detailRoute', `collection:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    PavilionDetailNav.bump()
  }

  static openTasks(): void {
    AppStorage.setOrCreate('detailRoute', 'tasks:today')
    AppStorage.setOrCreate('tabBarHidden', true)
    PavilionDetailNav.bump()
  }

  static openProfile(): void {
    AppStorage.setOrCreate('detailRoute', 'profile:me')
    AppStorage.setOrCreate('tabBarHidden', true)
    PavilionDetailNav.bump()
  }

  static openCards(): void {
    AppStorage.setOrCreate('detailRoute', 'cards:all')
    AppStorage.setOrCreate('tabBarHidden', true)
    PavilionDetailNav.bump()
  }

  static openAlbums(articleId: string): void {
    AppStorage.setOrCreate('detailRoute', `albums:${articleId}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    PavilionDetailNav.bump()
  }

  static openLogs(): void {
    AppStorage.setOrCreate('detailRoute', 'logs:all')
    AppStorage.setOrCreate('tabBarHidden', true)
    PavilionDetailNav.bump()
  }

  static openFinds(): void {
    AppStorage.setOrCreate('detailRoute', 'finds:all')
    AppStorage.setOrCreate('tabBarHidden', true)
    PavilionDetailNav.bump()
  }

  static openWish(): void {
    AppStorage.setOrCreate('detailRoute', 'wish:all')
    AppStorage.setOrCreate('tabBarHidden', true)
    PavilionDetailNav.bump()
  }

  static close(): void {
    AppStorage.setOrCreate('detailRoute', '')
    if (!PavilionDetailNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
    PavilionDetailNav.bump()
  }

  static openSettings(): void {
    AppStorage.setOrCreate('showMineSettings', true)
    AppStorage.setOrCreate('tabBarHidden', true)
    PavilionDetailNav.bump()
  }

  static closeSettings(): void {
    AppStorage.setOrCreate('showMineSettings', false)
    if (!PavilionDetailNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
    PavilionDetailNav.bump()
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
    const n = AppStorage.get<number>('pavilionRefresh') ?? 0
    AppStorage.setOrCreate('pavilionRefresh', n + 1)
  }
}
