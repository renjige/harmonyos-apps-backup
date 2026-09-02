/** 全局详情 / 二级页导航 — MainTabPage 顶层 Overlay */

export class NqDetailNav {
  static openSpot(id: string): void {
    NqDetailNav.setRoute(`spot:${id}`)
  }

  static openTip(id: string): void {
    NqDetailNav.setRoute(`tip:${id}`)
  }

  static openWiki(id: string): void {
    NqDetailNav.setRoute(`wiki:${id}`)
  }

  static openRecord(id: string): void {
    NqDetailNav.setRoute(`record:${id}`)
  }

  static openRecordEditor(id: string): void {
    if (id.length > 0) {
      NqDetailNav.setRoute(`recordEditor:${id}`)
    } else {
      NqDetailNav.setRoute('recordEditor')
    }
  }

  static openFavorites(): void {
    NqDetailNav.setRoute('favorites')
  }

  static openFootprintMap(): void {
    NqDetailNav.setRoute('footprintMap')
  }

  static switchTabRecords(): void {
    AppStorage.setOrCreate('switchTabIndex', 1)
  }

  static switchTabWiki(): void {
    AppStorage.setOrCreate('switchTabIndex', 2)
  }

  static switchTabDiscover(): void {
    AppStorage.setOrCreate('switchTabIndex', 0)
  }

  static kind(): string {
    const r = NqDetailNav.currentRoute()
    const idx = r.indexOf(':')
    if (idx < 0) {
      return r
    }
    return r.substring(0, idx)
  }

  static parseId(): string {
    const r = NqDetailNav.currentRoute()
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
