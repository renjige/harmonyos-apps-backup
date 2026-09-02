/** 全局详情 / 二级页导航 — MainTabPage 顶层 Overlay */

export class WanderDetailNav {
  static openRoute(id: string): void {
    WanderDetailNav.setRoute(`route:${id}`)
  }

  static openInspiration(id: string): void {
    WanderDetailNav.setRoute(`insp:${id}`)
  }

  static openJournal(id: string): void {
    WanderDetailNav.setRoute(`journal:${id}`)
  }

  static openJournalEdit(id: string): void {
    WanderDetailNav.setRoute(`jedit:${id}`)
  }

  static openJournalNew(title: string, place: string, coverKey: string): void {
    AppStorage.setOrCreate('journalDraftTitle', title)
    AppStorage.setOrCreate('journalDraftPlace', place)
    AppStorage.setOrCreate('journalDraftCover', coverKey)
    WanderDetailNav.setRoute('jnew')
  }

  static openChecklist(): void {
    WanderDetailNav.setRoute('checklist')
  }

  static openFavorites(): void {
    WanderDetailNav.setRoute('favorites')
  }

  static openMessages(): void {
    WanderDetailNav.setRoute('messages')
  }

  static openAbout(): void {
    WanderDetailNav.setRoute('about')
  }

  static openFeedback(): void {
    WanderDetailNav.setRoute('feedback')
  }

  static openSearch(): void {
    WanderDetailNav.setRoute('search')
  }

  static openDiagnose(): void {
    WanderDetailNav.setRoute('diagnose')
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
    return WanderDetailNav.currentRoute().length > 0
  }

  static kind(): string {
    const route = WanderDetailNav.currentRoute()
    const idx = route.indexOf(':')
    if (idx < 0) {
      return route
    }
    return route.substring(0, idx)
  }

  static parseId(): string {
    const route = WanderDetailNav.currentRoute()
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
