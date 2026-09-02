/** 全局详情导航 — MainTabPage 顶层 Overlay */
export class InspirationDetailNav {
  static applyRoute(route: string): void {
    AppStorage.setOrCreate('detailRoute', route)
    AppStorage.setOrCreate('tabBarHidden', true)
    const token = AppStorage.get<number>('detailToken') ?? 0
    AppStorage.setOrCreate('detailToken', token + 1)
  }

  static openFeatured(id: string): void {
    if (id.length === 0) {
      return
    }
    InspirationDetailNav.applyRoute(`featured:${id}`)
  }

  static openInspiration(id: string): void {
    if (id.length === 0) {
      return
    }
    InspirationDetailNav.applyRoute(`inspiration:${id}`)
  }

  static openBoard(id: string): void {
    if (id.length === 0) {
      return
    }
    InspirationDetailNav.applyRoute(`board:${id}`)
  }

  /**
   * 做成计划时会从 inspiration: 切到 plan:。
   * 先清空再打开，避免旧 InspirationDetailPane 复用到计划 id，误显示「灵感不存在」且无法关闭。
   */
  static openPlan(id: string): void {
    if (id.length === 0) {
      return
    }
    const current = InspirationDetailNav.currentRoute()
    const fromOther = current.length > 0 && current.indexOf('plan:') !== 0
    if (fromOther) {
      AppStorage.setOrCreate('detailRoute', '')
      AppStorage.setOrCreate('tabBarHidden', true)
      setTimeout((): void => {
        InspirationDetailNav.applyRoute(`plan:${id}`)
      }, 32)
      return
    }
    InspirationDetailNav.applyRoute(`plan:${id}`)
  }

  static close(): void {
    AppStorage.setOrCreate('detailRoute', '')
  }

  static currentRoute(): string {
    const v = AppStorage.get<string>('detailRoute')
    return v !== undefined && v !== null ? v : ''
  }

  static isOpen(): boolean {
    return InspirationDetailNav.currentRoute().length > 0
  }

  static parseKind(): string {
    const route = InspirationDetailNav.currentRoute()
    const idx = route.indexOf(':')
    if (idx < 0) {
      return ''
    }
    return route.substring(0, idx)
  }

  static parseId(): string {
    const route = InspirationDetailNav.currentRoute()
    const idx = route.indexOf(':')
    if (idx < 0) {
      return ''
    }
    return route.substring(idx + 1)
  }
}
