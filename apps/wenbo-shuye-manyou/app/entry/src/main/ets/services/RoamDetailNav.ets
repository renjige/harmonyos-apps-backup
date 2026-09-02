/** 书页漫游全局 Overlay 路由 */

export class RoamDetailNav {
  private static bumpDetailToken(): void {
    const token = AppStorage.get<number>('detailToken') ?? 0
    AppStorage.setOrCreate('detailToken', token + 1)
  }

  static openExcerpt(id: string): void {
    AppStorage.setOrCreate('detailRoute', `excerpt:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    RoamDetailNav.bumpDetailToken()
  }

  static openBookList(id: string): void {
    AppStorage.setOrCreate('detailRoute', `booklist:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    RoamDetailNav.bumpDetailToken()
  }

  static openListBook(listId: string, bookIndex: number): void {
    AppStorage.setOrCreate('detailRoute', `listbook:${listId}:${bookIndex}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    RoamDetailNav.bumpDetailToken()
  }

  static backToBookList(listId: string): void {
    if (listId.length === 0) {
      RoamDetailNav.close()
      return
    }
    RoamDetailNav.openBookList(listId)
  }

  static openNote(id: string): void {
    AppStorage.setOrCreate('detailRoute', `note:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    RoamDetailNav.bumpDetailToken()
  }

  static close(): void {
    AppStorage.setOrCreate('detailRoute', '')
    if (!RoamDetailNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
    RoamDetailNav.bumpDetailToken()
  }

  static openSettings(): void {
    AppStorage.setOrCreate('showMineSettings', true)
    AppStorage.setOrCreate('tabBarHidden', true)
    RoamDetailNav.bumpDetailToken()
  }

  static closeSettings(): void {
    AppStorage.setOrCreate('showMineSettings', false)
    if (!RoamDetailNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
    RoamDetailNav.bumpDetailToken()
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
    const second = route.indexOf(':', first + 1)
    if (second < 0) {
      return route.substring(first + 1)
    }
    return route.substring(first + 1, second)
  }

  static parseRouteBookIndex(route: string): number {
    const parts = route.split(':')
    if (parts.length < 3) {
      return 0
    }
    const n = parseInt(parts[2], 10)
    if (isNaN(n)) {
      return 0
    }
    return n
  }

  static isDetailOpen(): boolean {
    const route = AppStorage.get<string>('detailRoute') ?? ''
    return route.length > 0
  }

  static isSettingsOpen(): boolean {
    return AppStorage.get<boolean>('showMineSettings') === true
  }

  static keepTabHidden(): boolean {
    return RoamDetailNav.isDetailOpen() || RoamDetailNav.isSettingsOpen()
  }

  static routeType(): string {
    const route = AppStorage.get<string>('detailRoute') ?? ''
    const idx = route.indexOf(':')
    if (idx < 0) {
      return ''
    }
    return route.substring(0, idx)
  }

  static parseId(): string {
    const route = AppStorage.get<string>('detailRoute') ?? ''
    const first = route.indexOf(':')
    if (first < 0) {
      return ''
    }
    const second = route.indexOf(':', first + 1)
    if (second < 0) {
      return route.substring(first + 1)
    }
    return route.substring(first + 1, second)
  }

  static parseBookIndex(): number {
    const route = AppStorage.get<string>('detailRoute') ?? ''
    const parts = route.split(':')
    if (parts.length < 3) {
      return 0
    }
    const n = parseInt(parts[2], 10)
    if (isNaN(n)) {
      return 0
    }
    return n
  }

  static switchTab(index: number): void {
    AppStorage.setOrCreate('mainTabIndex', index)
  }
}
