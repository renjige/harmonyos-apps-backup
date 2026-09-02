/** 悦知坊全局 Overlay 路由 */

export class AtelierDetailNav {
  private static bump(): void {
    const token = AppStorage.get<number>('detailToken') ?? 0
    AppStorage.setOrCreate('detailToken', token + 1)
  }

  static openCard(id: string): void {
    AppStorage.setOrCreate('detailRoute', `card:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    AtelierDetailNav.bump()
  }

  static openDaily(id: string): void {
    AppStorage.setOrCreate('detailRoute', `daily:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    AtelierDetailNav.bump()
  }

  static openSearch(): void {
    AppStorage.setOrCreate('detailRoute', 'search:all')
    AppStorage.setOrCreate('tabBarHidden', true)
    AtelierDetailNav.bump()
  }

  static openHot(): void {
    AppStorage.setOrCreate('detailRoute', 'hot:week')
    AppStorage.setOrCreate('tabBarHidden', true)
    AtelierDetailNav.bump()
  }

  static openMessages(): void {
    AppStorage.setOrCreate('detailRoute', 'messages:all')
    AppStorage.setOrCreate('tabBarHidden', true)
    AtelierDetailNav.bump()
  }

  static openDiagnose(): void {
    AppStorage.setOrCreate('detailRoute', 'diagnose:quiz')
    AppStorage.setOrCreate('tabBarHidden', true)
    AtelierDetailNav.bump()
  }

  static openWorkNew(kind: string, cardId: string): void {
    AppStorage.setOrCreate('workCardId', cardId)
    AppStorage.setOrCreate('detailRoute', `worknew:${kind}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    AtelierDetailNav.bump()
  }

  static openWorkEdit(id: string): void {
    AppStorage.setOrCreate('detailRoute', `workedit:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    AtelierDetailNav.bump()
  }

  static openWorkList(): void {
    AppStorage.setOrCreate('detailRoute', 'works:all')
    AppStorage.setOrCreate('tabBarHidden', true)
    AtelierDetailNav.bump()
  }

  static openTimer(): void {
    AppStorage.setOrCreate('detailRoute', 'timer:focus')
    AppStorage.setOrCreate('tabBarHidden', true)
    AtelierDetailNav.bump()
  }

  static openTrail(id: string): void {
    AppStorage.setOrCreate('detailRoute', `trail:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    AtelierDetailNav.bump()
  }

  static workCardId(): string {
    return AppStorage.get<string>('workCardId') ?? ''
  }

  static requestLogin(): void {
    AppStorage.setOrCreate('gateLogin', true)
  }

  static close(): void {
    AppStorage.setOrCreate('detailRoute', '')
    if (!AtelierDetailNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
    AtelierDetailNav.bump()
  }

  static openSettings(): void {
    AppStorage.setOrCreate('showMineSettings', true)
    AppStorage.setOrCreate('tabBarHidden', true)
    AtelierDetailNav.bump()
  }

  static closeSettings(): void {
    AppStorage.setOrCreate('showMineSettings', false)
    if (!AtelierDetailNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
    AtelierDetailNav.bump()
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
    const n = AppStorage.get<number>('atelierRefresh') ?? 0
    AppStorage.setOrCreate('atelierRefresh', n + 1)
  }

  /** 全局顶部 Toast（MainTabPage 顶层渲染，避免详情 Overlay 内看不清） */
  static showToast(message: string): void {
    AppStorage.setOrCreate('appToastText', message)
    setTimeout((): void => {
      const cur = AppStorage.get<string>('appToastText') ?? ''
      if (cur === message) {
        AppStorage.setOrCreate('appToastText', '')
      }
    }, 2400)
  }
}
