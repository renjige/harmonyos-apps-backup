export class CottageNav {
  static readonly NONE: string = ''
  static readonly PATH: string = 'path'
  static readonly LESSON: string = 'lesson'
  static readonly CARD: string = 'card'
  static readonly DAILY: string = 'daily'
  static readonly QA: string = 'qa'
  static readonly DIAGNOSE: string = 'diagnose'
  static readonly FAVORITES: string = 'favorites'

  static bump(): void {
    const n = AppStorage.get<number>('cottageTick') ?? 0
    AppStorage.setOrCreate('cottageTick', n + 1)
  }

  static setDetail(kind: string, id: string): void {
    AppStorage.setOrCreate('detailKind', kind)
    AppStorage.setOrCreate('detailId', id)
    AppStorage.setOrCreate('detailRoute', `${kind}:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    CottageNav.bump()
  }

  static closeDetail(): void {
    AppStorage.setOrCreate('detailRoute', '')
    AppStorage.setOrCreate('detailKind', '')
    AppStorage.setOrCreate('detailId', '')
    if (!CottageNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
    CottageNav.bump()
  }

  static openPath(id: string): void {
    CottageNav.setDetail(CottageNav.PATH, id)
  }

  static openLesson(id: string): void {
    CottageNav.setDetail(CottageNav.LESSON, id)
  }

  static openCard(id: string): void {
    CottageNav.setDetail(CottageNav.CARD, id)
  }

  static openDaily(id: string): void {
    CottageNav.setDetail(CottageNav.DAILY, id)
  }

  static openQa(): void {
    AppStorage.setOrCreate('overlayRoute', CottageNav.QA)
    AppStorage.setOrCreate('tabBarHidden', true)
    CottageNav.bump()
  }

  static openDiagnose(): void {
    AppStorage.setOrCreate('overlayRoute', CottageNav.DIAGNOSE)
    AppStorage.setOrCreate('tabBarHidden', true)
    CottageNav.bump()
  }

  static openFavorites(): void {
    AppStorage.setOrCreate('overlayRoute', CottageNav.FAVORITES)
    AppStorage.setOrCreate('tabBarHidden', true)
    CottageNav.bump()
  }

  static closeOverlay(): void {
    AppStorage.setOrCreate('overlayRoute', '')
    if (!CottageNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
    CottageNav.bump()
  }

  static openMessages(): void {
    AppStorage.setOrCreate('showMessages', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeMessages(): void {
    AppStorage.setOrCreate('showMessages', false)
    if (!CottageNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static switchTab(index: number): void {
    AppStorage.setOrCreate('mainTabIndex', index)
  }

  static keepTabHidden(): boolean {
    const detail = AppStorage.get<string>('detailRoute') ?? ''
    const overlay = AppStorage.get<string>('overlayRoute') ?? ''
    return detail.length > 0 || overlay.length > 0 || AppStorage.get<boolean>('showMessages') === true
  }

  static kind(): string {
    return AppStorage.get<string>('detailKind') ?? ''
  }

  static id(): string {
    return AppStorage.get<string>('detailId') ?? ''
  }
}
