/** 全局详情导航 — MainTabPage 顶层 Overlay */
export class DetailNav {
  static openMatch(id: string): void {
    AppStorage.setOrCreate('detailRoute', `match:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    const token = AppStorage.get<number>('detailToken') ?? 0
    AppStorage.setOrCreate('detailToken', token + 1)
  }

  static openTeam(id: string): void {
    AppStorage.setOrCreate('detailRoute', `team:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    const token = AppStorage.get<number>('detailToken') ?? 0
    AppStorage.setOrCreate('detailToken', token + 1)
  }

  static openLeague(id: string): void {
    AppStorage.setOrCreate('detailRoute', `league:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    const token = AppStorage.get<number>('detailToken') ?? 0
    AppStorage.setOrCreate('detailToken', token + 1)
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
    return DetailNav.currentRoute().length > 0
  }

  static parseKind(): string {
    const route = DetailNav.currentRoute()
    const idx = route.indexOf(':')
    if (idx < 0) {
      return ''
    }
    return route.substring(0, idx)
  }

  static parseId(): string {
    const route = DetailNav.currentRoute()
    const idx = route.indexOf(':')
    if (idx < 0) {
      return ''
    }
    return route.substring(idx + 1)
  }
}
