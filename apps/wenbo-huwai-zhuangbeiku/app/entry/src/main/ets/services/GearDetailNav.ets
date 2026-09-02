/** 全局详情 / 二级页导航 — MainTabPage 顶层 Overlay */

export class GearDetailNav {
  static openGear(id: string): void {
    GearDetailNav.setRoute(`gear:${id}`)
  }

  static openGearNew(): void {
    GearDetailNav.setRoute('gnew')
  }

  static openGearEdit(id: string): void {
    GearDetailNav.setRoute(`gedit:${id}`)
  }

  static openCatalog(id: string): void {
    GearDetailNav.setRoute(`catalog:${id}`)
  }

  static openCategory(id: string): void {
    GearDetailNav.setRoute(`cat:${id}`)
  }

  static openTrail(id: string): void {
    GearDetailNav.setRoute(`trail:${id}`)
  }

  static openRoute(id: string): void {
    GearDetailNav.setRoute(`route:${id}`)
  }

  static openRouteNew(): void {
    GearDetailNav.setRoute('rnew')
  }

  static openNote(id: string): void {
    GearDetailNav.setRoute(`note:${id}`)
  }

  static openPost(id: string): void {
    GearDetailNav.setRoute(`post:${id}`)
  }

  static openPostNew(): void {
    GearDetailNav.setRoute('pnew')
  }

  static openInspect(): void {
    GearDetailNav.setRoute('inspect')
  }

  static openFavorites(): void {
    GearDetailNav.setRoute('favorites')
  }

  static openMyPosts(): void {
    GearDetailNav.setRoute('myposts')
  }

  static openMessages(): void {
    GearDetailNav.setRoute('messages')
  }

  static openAbout(): void {
    GearDetailNav.setRoute('about')
  }

  static setRoute(route: string): void {
    AppStorage.setOrCreate('detailRoute', route)
    AppStorage.setOrCreate('detailToken', Date.now())
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static close(): void {
    AppStorage.setOrCreate('detailRoute', '')
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static kind(): string {
    const r = AppStorage.get<string>('detailRoute') ?? ''
    const i = r.indexOf(':')
    if (i < 0) {
      return r
    }
    return r.substring(0, i)
  }

  static parseId(): string {
    const r = AppStorage.get<string>('detailRoute') ?? ''
    const i = r.indexOf(':')
    if (i < 0) {
      return ''
    }
    return r.substring(i + 1)
  }
}
