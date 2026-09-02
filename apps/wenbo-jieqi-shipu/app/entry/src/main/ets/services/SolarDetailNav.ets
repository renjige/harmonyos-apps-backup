/** 全局详情 / 二级页导航 — MainTabPage 顶层 Overlay */

export class SolarDetailNav {
  static openRecipe(id: string): void {
    SolarDetailNav.setRoute(`recipe:${id}`)
  }

  static openTerm(id: string): void {
    SolarDetailNav.setRoute(`term:${id}`)
  }

  static openTip(id: string): void {
    SolarDetailNav.setRoute(`tip:${id}`)
  }

  static openFavorites(): void {
    SolarDetailNav.setRoute('favorites')
  }

  static openHistory(): void {
    SolarDetailNav.setRoute('history')
  }

  static openPreferences(): void {
    SolarDetailNav.setRoute('preferences')
  }

  static close(): void {
    AppStorage.setOrCreate('detailRoute', '')
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static currentRoute(): string {
    const v = AppStorage.get<string>('detailRoute')
    return v !== undefined && v !== null ? v : ''
  }

  static kind(): string {
    const route = SolarDetailNav.currentRoute()
    const idx = route.indexOf(':')
    if (idx < 0) {
      return route
    }
    return route.substring(0, idx)
  }

  static parseId(): string {
    const route = SolarDetailNav.currentRoute()
    const idx = route.indexOf(':')
    if (idx < 0) {
      return ''
    }
    return route.substring(idx + 1)
  }

  private static setRoute(value: string): void {
    AppStorage.setOrCreate('detailRoute', value)
    AppStorage.setOrCreate('tabBarHidden', true)
    const token = AppStorage.get<number>('detailToken') ?? 0
    AppStorage.setOrCreate('detailToken', token + 1)
  }
}
