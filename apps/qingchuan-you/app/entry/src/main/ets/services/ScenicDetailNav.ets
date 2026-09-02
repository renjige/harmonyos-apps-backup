/** 全局详情 / 二级页导航 — MainTabPage 顶层 Overlay */

export class ScenicDetailNav {
  static openDest(id: string): void {
    ScenicDetailNav.setRoute(`dest:${id}`)
  }

  static openInsp(id: string): void {
    ScenicDetailNav.setRoute(`insp:${id}`)
  }

  static openNote(id: string): void {
    ScenicDetailNav.setRoute(`note:${id}`)
  }

  static openNoteNew(destId: string, destName: string, coverKey: string): void {
    AppStorage.setOrCreate('noteDraftDestId', destId)
    AppStorage.setOrCreate('noteDraftDestName', destName)
    AppStorage.setOrCreate('noteDraftCover', coverKey)
    ScenicDetailNav.setRoute('nnew')
  }

  static openTrip(id: string): void {
    ScenicDetailNav.setRoute(`trip:${id}`)
  }

  static openTripNew(destId: string, destName: string, coverKey: string): void {
    AppStorage.setOrCreate('tripDraftDestId', destId)
    AppStorage.setOrCreate('tripDraftDestName', destName)
    AppStorage.setOrCreate('tripDraftCover', coverKey)
    ScenicDetailNav.setRoute('tnew')
  }

  static openFavorites(): void {
    ScenicDetailNav.setRoute('favorites')
  }

  static openMessages(): void {
    ScenicDetailNav.setRoute('messages')
  }

  static openAbout(): void {
    ScenicDetailNav.setRoute('about')
  }

  static openSearch(): void {
    ScenicDetailNav.setRoute('search')
  }

  static openDiagnose(): void {
    ScenicDetailNav.setRoute('diagnose')
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
    const route = ScenicDetailNav.currentRoute()
    const idx = route.indexOf(':')
    if (idx < 0) {
      return route
    }
    return route.substring(0, idx)
  }

  static parseId(): string {
    const route = ScenicDetailNav.currentRoute()
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
