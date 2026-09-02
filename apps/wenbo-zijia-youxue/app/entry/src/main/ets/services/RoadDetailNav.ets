/** 全局详情 / 二级页导航 — MainTabPage 顶层 Overlay；用 || 栈支持路线→景点→问答返回 */

export class RoadDetailNav {
  static openRoute(id: string): void {
    RoadDetailNav.reset(`route:${id}`)
  }

  static openSpot(id: string): void {
    RoadDetailNav.pushOrReset(`spot:${id}`)
  }

  static openQuiz(id: string): void {
    RoadDetailNav.pushOrReset(`quiz:${id}`)
  }

  static openJournal(id: string): void {
    RoadDetailNav.reset(`journal:${id}`)
  }

  static openJournalNew(): void {
    RoadDetailNav.reset('jnew')
  }

  static openPlanNew(routeId: string): void {
    AppStorage.setOrCreate('planDraftRouteId', routeId)
    RoadDetailNav.pushOrReset('plannew')
  }

  static openPlanEdit(id: string): void {
    RoadDetailNav.reset(`plan:${id}`)
  }

  static openFavorites(): void {
    RoadDetailNav.reset('favorites')
  }

  static openMessages(): void {
    RoadDetailNav.reset('messages')
  }

  static openSearch(): void {
    RoadDetailNav.reset('search')
  }

  static openDiagnose(): void {
    RoadDetailNav.reset('diagnose')
  }

  static close(): void {
    const stack = AppStorage.get<string>('detailStack') ?? ''
    const sep = '||'
    const idx = stack.lastIndexOf(sep)
    if (idx < 0) {
      AppStorage.setOrCreate('detailStack', '')
      AppStorage.setOrCreate('detailRoute', '')
      AppStorage.setOrCreate('tabBarHidden', false)
      return
    }
    const prevStack = stack.substring(0, idx)
    const prevSep = prevStack.lastIndexOf(sep)
    const prev = prevSep < 0 ? prevStack : prevStack.substring(prevSep + sep.length)
    AppStorage.setOrCreate('detailStack', prevStack)
    AppStorage.setOrCreate('detailRoute', prev)
    AppStorage.setOrCreate('detailToken', Date.now())
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static currentRoute(): string {
    const v = AppStorage.get<string>('detailRoute')
    return v !== undefined && v !== null ? v : ''
  }

  static isOpen(): boolean {
    return RoadDetailNav.currentRoute().length > 0
  }

  static kind(): string {
    const route = RoadDetailNav.currentRoute()
    const idx = route.indexOf(':')
    if (idx < 0) {
      return route
    }
    return route.substring(0, idx)
  }

  static parseId(): string {
    const route = RoadDetailNav.currentRoute()
    const idx = route.indexOf(':')
    if (idx < 0) {
      return ''
    }
    return route.substring(idx + 1)
  }

  private static reset(route: string): void {
    AppStorage.setOrCreate('detailStack', route)
    AppStorage.setOrCreate('detailRoute', route)
    AppStorage.setOrCreate('detailToken', Date.now())
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private static pushOrReset(route: string): void {
    const cur = RoadDetailNav.currentRoute()
    if (cur.length === 0) {
      RoadDetailNav.reset(route)
      return
    }
    const stack = AppStorage.get<string>('detailStack') ?? cur
    AppStorage.setOrCreate('detailStack', `${stack}||${route}`)
    AppStorage.setOrCreate('detailRoute', route)
    AppStorage.setOrCreate('detailToken', Date.now())
    AppStorage.setOrCreate('tabBarHidden', true)
  }
}
