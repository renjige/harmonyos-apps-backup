/** 全局详情 / 二级页导航 — MainTabPage 顶层 Overlay */

export class DrinkDetailNav {
  static openDrink(id: string): void {
    DrinkDetailNav.setRoute(`drink:${id}`)
  }

  static openTip(id: string): void {
    DrinkDetailNav.setRoute(`tip:${id}`)
  }

  static openFavorites(): void {
    DrinkDetailNav.setRoute('favorites')
  }

  static openHistory(): void {
    DrinkDetailNav.setRoute('history')
  }

  static openTries(): void {
    DrinkDetailNav.setRoute('tries')
  }

  static openDashboard(): void {
    DrinkDetailNav.setRoute('dashboard')
  }

  static openMessages(): void {
    DrinkDetailNav.setRoute('messages')
  }

  static openAbout(): void {
    DrinkDetailNav.setRoute('about')
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
    const route = DrinkDetailNav.currentRoute()
    const idx = route.indexOf(':')
    if (idx < 0) {
      return route
    }
    return route.substring(0, idx)
  }

  static parseId(): string {
    const route = DrinkDetailNav.currentRoute()
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
