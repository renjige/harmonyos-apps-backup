/** 全局详情 / 二级页导航 — MainTabPage 顶层 Overlay */

export class WarmCompanionNav {
  static openQuote(id: string): void {
    WarmCompanionNav.setRoute(`quote:${id}`)
  }

  static openBreathMode(id: string): void {
    WarmCompanionNav.setRoute(`breath:${id}`)
  }

  static switchTabCompanion(): void {
    AppStorage.setOrCreate('switchTabIndex', 1)
  }

  static switchTabCompanionFromOverlay(): void {
    AppStorage.setOrCreate('detailRouteParent', '')
    AppStorage.setOrCreate('detailRoute', '')
    AppStorage.setOrCreate('tabBarHidden', false)
    AppStorage.setOrCreate('switchTabIndex', 1)
  }

  static kind(): string {
    const r = WarmCompanionNav.currentRoute()
    const idx = r.indexOf(':')
    if (idx < 0) {
      return r
    }
    return r.substring(0, idx)
  }

  static parseId(): string {
    const r = WarmCompanionNav.currentRoute()
    const idx = r.indexOf(':')
    if (idx < 0) {
      return ''
    }
    return r.substring(idx + 1)
  }

  static close(): void {
    AppStorage.setOrCreate('detailRoute', '')
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static currentRoute(): string {
    const v = AppStorage.get<string>('detailRoute')
    return v !== undefined && v !== null ? v : ''
  }

  private static setRoute(value: string): void {
    AppStorage.setOrCreate('detailRoute', value)
    AppStorage.setOrCreate('tabBarHidden', true)
    const token = AppStorage.get<number>('detailToken') ?? 0
    AppStorage.setOrCreate('detailToken', token + 1)
  }
}
