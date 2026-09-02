/** 墨香小筑全局 Overlay 路由 */

export class InkDetailNav {
  private static bump(): void {
    const token = AppStorage.get<number>('detailToken') ?? 0
    AppStorage.setOrCreate('detailToken', token + 1)
  }

  static openExcerpt(id: string): void {
    AppStorage.setOrCreate('detailRoute', `excerpt:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    InkDetailNav.bump()
  }

  static openList(id: string): void {
    AppStorage.setOrCreate('detailRoute', `list:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    InkDetailNav.bump()
  }

  static openEssay(id: string): void {
    AppStorage.setOrCreate('detailRoute', `essay:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    InkDetailNav.bump()
  }

  static openNote(id: string): void {
    AppStorage.setOrCreate('detailRoute', `note:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    InkDetailNav.bump()
  }

  static openReview(id: string): void {
    AppStorage.setOrCreate('detailRoute', `review:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    InkDetailNav.bump()
  }

  static openEditor(kind: string, id: string): void {
    AppStorage.setOrCreate('detailRoute', `editor:${kind}:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    InkDetailNav.bump()
  }

  static openMatch(): void {
    AppStorage.setOrCreate('showMatchQuiz', true)
    AppStorage.setOrCreate('tabBarHidden', true)
    InkDetailNav.bump()
  }

  static closeMatch(): void {
    AppStorage.setOrCreate('showMatchQuiz', false)
    if (!InkDetailNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
    InkDetailNav.bump()
  }

  static close(): void {
    AppStorage.setOrCreate('detailRoute', '')
    if (!InkDetailNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
    InkDetailNav.bump()
  }

  static keepTabHidden(): boolean {
    const route = AppStorage.get<string>('detailRoute') ?? ''
    const match = AppStorage.get<boolean>('showMatchQuiz') === true
    const settings = AppStorage.get<boolean>('showMineSettings') === true
    return route.length > 0 || match || settings
  }

  static routeKind(route: string): string {
    const idx = route.indexOf(':')
    if (idx < 0) {
      return ''
    }
    return route.substring(0, idx)
  }

  static parseId(route: string): string {
    const first = route.indexOf(':')
    if (first < 0) {
      return ''
    }
    const second = route.indexOf(':', first + 1)
    if (second < 0) {
      return route.substring(first + 1)
    }
    return route.substring(second + 1)
  }

  static parseEditorKind(route: string): string {
    const first = route.indexOf(':')
    if (first < 0) {
      return 'note'
    }
    const second = route.indexOf(':', first + 1)
    if (second < 0) {
      return route.substring(first + 1)
    }
    return route.substring(first + 1, second)
  }

  static switchTab(index: number): void {
    AppStorage.setOrCreate('mainTabIndex', index)
  }

  static bumpRefresh(): void {
    const n = AppStorage.get<number>('inkRefresh') ?? 0
    AppStorage.setOrCreate('inkRefresh', n + 1)
  }
}
