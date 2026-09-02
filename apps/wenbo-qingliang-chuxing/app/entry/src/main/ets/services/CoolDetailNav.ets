/** 全局详情 / 二级页导航 — MainTabPage 顶层 Overlay */

export class CoolDetailNav {
  static openRoute(id: string): void {
    CoolDetailNav.setRoute(`route:${id}`)
  }

  static openStop(id: string): void {
    CoolDetailNav.setRoute(`stop:${id}`)
  }

  static openAdvice(id: string): void {
    CoolDetailNav.setRoute(`advice:${id}`)
  }

  static openCity(id: string): void {
    CoolDetailNav.setRoute(`city:${id}`)
  }

  static openFavorites(): void {
    CoolDetailNav.setRoute('favorites')
  }

  static openMessages(): void {
    CoolDetailNav.setRoute('messages')
  }

  static openDiagnose(): void {
    CoolDetailNav.setRoute('diagnose')
  }

  static openAbout(): void {
    CoolDetailNav.setRoute('about')
  }

  static switchTabRoutes(): void {
    AppStorage.setOrCreate('switchTabIndex', 1)
  }

  static switchTabWeather(): void {
    AppStorage.setOrCreate('switchTabIndex', 2)
  }

  static openPrefs(): void {
    CoolDetailNav.setRoute('prefs')
  }

  static kind(): string {
    const r = CoolDetailNav.currentRoute()
    const idx = r.indexOf(':')
    if (idx < 0) {
      return r
    }
    return r.substring(0, idx)
  }

  static parseId(): string {
    const r = CoolDetailNav.currentRoute()
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
