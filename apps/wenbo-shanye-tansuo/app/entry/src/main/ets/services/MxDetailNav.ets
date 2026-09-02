/** 全局详情 / 二级页导航 — MainTabPage 顶层 Overlay */

export class MxDetailNav {
  static openTrail(id: string): void {
    MxDetailNav.setRoute(`trail:${id}`)
  }

  static openTip(id: string): void {
    MxDetailNav.setRoute(`tip:${id}`)
  }

  static openWiki(id: string): void {
    MxDetailNav.setRoute(`wiki:${id}`)
  }

  static openSearch(): void {
    MxDetailNav.setRoute('search')
  }

  static openFavorites(): void {
    MxDetailNav.setRoute('favorites')
  }

  static openFootprints(): void {
    MxDetailNav.setRoute('footprints')
  }

  static openMessages(): void {
    MxDetailNav.setRoute('messages')
  }

  static openDiagnose(): void {
    MxDetailNav.setRoute('diagnose')
  }

  static openAbout(): void {
    MxDetailNav.setRoute('about')
  }

  static openPrefs(): void {
    MxDetailNav.setRoute('prefs')
  }

  static switchTabTrails(): void {
    AppStorage.setOrCreate('switchTabIndex', 1)
  }

  static switchTabWiki(): void {
    AppStorage.setOrCreate('switchTabIndex', 2)
  }

  static kind(): string {
    const r = MxDetailNav.currentRoute()
    const idx = r.indexOf(':')
    if (idx < 0) {
      return r
    }
    return r.substring(0, idx)
  }

  static parseId(): string {
    const r = MxDetailNav.currentRoute()
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
