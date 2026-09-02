/** 全局详情 / 二级页导航 — MainTabPage 顶层 Overlay */

export class CampDetailNav {
  static openCamp(id: string): void {
    CampDetailNav.setRoute(`camp:${id}`)
  }

  static openGuide(id: string): void {
    CampDetailNav.setRoute(`guide:${id}`)
  }

  static openTemplate(id: string): void {
    CampDetailNav.setRoute(`tpl:${id}`)
  }

  static openTrip(id: string): void {
    CampDetailNav.setRoute(`trip:${id}`)
  }

  static openTripNew(): void {
    CampDetailNav.setRoute('tnew')
  }

  static openGearNew(): void {
    CampDetailNav.setRoute('gnew')
  }

  static openGearEdit(id: string): void {
    CampDetailNav.setRoute(`gedit:${id}`)
  }

  static openJournal(id: string): void {
    CampDetailNav.setRoute(`journal:${id}`)
  }

  static openJournalNew(): void {
    CampDetailNav.setRoute('jnew')
  }

  static openPack(id: string): void {
    CampDetailNav.setRoute(`pack:${id}`)
  }

  static openPackNew(tripId: string): void {
    AppStorage.setOrCreate('packDraftTrip', tripId)
    CampDetailNav.setRoute('pnew')
  }

  static openNote(campId: string): void {
    AppStorage.setOrCreate('noteDraftCamp', campId)
    CampDetailNav.setRoute(`note:${campId}`)
  }

  static openPostNew(): void {
    CampDetailNav.setRoute('postnew')
  }

  static openPost(id: string): void {
    CampDetailNav.setRoute(`post:${id}`)
  }

  static openFavorites(): void {
    CampDetailNav.setRoute('favorites')
  }

  static openAlbum(): void {
    CampDetailNav.setRoute('album')
  }

  static openMessages(): void {
    CampDetailNav.setRoute('messages')
  }

  static openAbout(): void {
    CampDetailNav.setRoute('about')
  }

  static openFeedback(): void {
    CampDetailNav.setRoute('feedback')
  }

  static openDiagnose(): void {
    CampDetailNav.setRoute('diagnose')
  }

  static openMyPosts(): void {
    CampDetailNav.setRoute('myposts')
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
    const route = CampDetailNav.currentRoute()
    const idx = route.indexOf(':')
    if (idx < 0) {
      return route
    }
    return route.substring(0, idx)
  }

  static parseId(): string {
    const route = CampDetailNav.currentRoute()
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
