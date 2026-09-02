/** 全局详情 / 二级页导航 — MainTabPage 顶层 Overlay */

export class EscapeDetailNav {
  static openDest(id: string): void {
    EscapeDetailNav.setRoute(`dest:${id}`)
  }

  static openGuide(id: string): void {
    EscapeDetailNav.setRoute(`guide:${id}`)
  }

  static openJournal(id: string): void {
    EscapeDetailNav.setRoute(`journal:${id}`)
  }

  static openJournalNew(destId: string, destName: string, coverKey: string): void {
    AppStorage.setOrCreate('journalDraftDestId', destId)
    AppStorage.setOrCreate('journalDraftDestName', destName)
    AppStorage.setOrCreate('journalDraftCover', coverKey)
    EscapeDetailNav.setRoute('jnew')
  }

  static openFavorites(): void {
    EscapeDetailNav.setRoute('favorites')
  }

  static openMessages(): void {
    EscapeDetailNav.setRoute('messages')
  }

  static openAbout(): void {
    EscapeDetailNav.setRoute('about')
  }

  static openSearch(): void {
    EscapeDetailNav.setRoute('search')
  }

  static openDiagnose(): void {
    EscapeDetailNav.setRoute('diagnose')
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
    const route = EscapeDetailNav.currentRoute()
    const idx = route.indexOf(':')
    if (idx < 0) {
      return route
    }
    return route.substring(0, idx)
  }

  static parseId(): string {
    const route = EscapeDetailNav.currentRoute()
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
