/** 观思堂全局 Overlay 路由 */

export class WisdomHallNav {
  static openWrite(editId: string): void {
    AppStorage.setOrCreate('writeThoughtId', editId)
    AppStorage.setOrCreate('showWriteThought', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeWrite(): void {
    AppStorage.setOrCreate('showWriteThought', false)
    AppStorage.setOrCreate('writeThoughtId', '')
    AppStorage.setOrCreate('writePrefillTitle', '')
    AppStorage.setOrCreate('writePrefillBody', '')
    if (!WisdomHallNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static openDetail(kind: string, id: string): void {
    AppStorage.setOrCreate('detailRoute', `${kind}:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeDetail(): void {
    AppStorage.setOrCreate('detailRoute', '')
    if (!WisdomHallNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static openSearch(): void {
    AppStorage.setOrCreate('showThoughtSearch', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeSearch(): void {
    AppStorage.setOrCreate('showThoughtSearch', false)
    if (!WisdomHallNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static openFavorites(): void {
    AppStorage.setOrCreate('showFavorites', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeFavorites(): void {
    AppStorage.setOrCreate('showFavorites', false)
    if (!WisdomHallNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static openHistory(): void {
    AppStorage.setOrCreate('showHistory', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeHistory(): void {
    AppStorage.setOrCreate('showHistory', false)
    if (!WisdomHallNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static openMessages(): void {
    AppStorage.setOrCreate('showMessages', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeMessages(): void {
    AppStorage.setOrCreate('showMessages', false)
    if (!WisdomHallNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static openExport(): void {
    AppStorage.setOrCreate('showExportNotes', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeExport(): void {
    AppStorage.setOrCreate('showExportNotes', false)
    if (!WisdomHallNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static openAbout(): void {
    AppStorage.setOrCreate('showAbout', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeAbout(): void {
    AppStorage.setOrCreate('showAbout', false)
    if (!WisdomHallNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static openWriteWithPrefill(title: string, body: string): void {
    AppStorage.setOrCreate('writePrefillTitle', title)
    AppStorage.setOrCreate('writePrefillBody', body)
    WisdomHallNav.openWrite('')
  }

  static switchTab(index: number): void {
    AppStorage.setOrCreate('mainTabIndex', index)
  }

  static parseKind(): string {
    const route = AppStorage.get<string>('detailRoute') ?? ''
    const idx = route.indexOf(':')
    if (idx < 0) {
      return ''
    }
    return route.substring(0, idx)
  }

  static parseId(): string {
    const route = AppStorage.get<string>('detailRoute') ?? ''
    const idx = route.indexOf(':')
    if (idx < 0) {
      return ''
    }
    return route.substring(idx + 1)
  }

  static writeId(): string {
    return AppStorage.get<string>('writeThoughtId') ?? ''
  }

  static keepTabHidden(): boolean {
    return AppStorage.get<boolean>('showWriteThought') === true ||
      (AppStorage.get<string>('detailRoute') ?? '').length > 0 ||
      AppStorage.get<boolean>('showThoughtSearch') === true ||
      AppStorage.get<boolean>('showFavorites') === true ||
      AppStorage.get<boolean>('showHistory') === true ||
      AppStorage.get<boolean>('showMessages') === true ||
      AppStorage.get<boolean>('showExportNotes') === true ||
      AppStorage.get<boolean>('showAbout') === true ||
      AppStorage.get<boolean>('minePanelOpen') === true
  }
}
