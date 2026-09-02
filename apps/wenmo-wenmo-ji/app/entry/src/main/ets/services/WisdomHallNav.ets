/** 文墨集全局 Overlay 路由 */

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

  static openQuoteSearch(): void {
    AppStorage.setOrCreate('showQuoteSearch', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeQuoteSearch(): void {
    AppStorage.setOrCreate('showQuoteSearch', false)
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

  static openLibraryCategory(category: string): void {
    AppStorage.setOrCreate('libraryCategoryFilter', category)
    AppStorage.setOrCreate('libraryAuthorFilter', '')
    AppStorage.setOrCreate('mainTabIndex', 0)
  }

  static openLibraryAuthor(author: string): void {
    AppStorage.setOrCreate('libraryAuthorFilter', author)
    AppStorage.setOrCreate('mainTabIndex', 0)
  }

  static openAuthorList(): void {
    AppStorage.setOrCreate('showAuthorList', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeAuthorList(): void {
    AppStorage.setOrCreate('showAuthorList', false)
    if (!WisdomHallNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static openWriteWithPrefill(title: string, body: string): void {
    AppStorage.setOrCreate('writePrefillTitle', title)
    AppStorage.setOrCreate('writePrefillBody', body)
    WisdomHallNav.openWrite('')
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

  static switchTab(index: number): void {
    AppStorage.setOrCreate('mainTabIndex', index)
  }

  static keepTabHidden(): boolean {
    return AppStorage.get<boolean>('showWriteThought') === true ||
      (AppStorage.get<string>('detailRoute') ?? '').length > 0 ||
      AppStorage.get<boolean>('showThoughtSearch') === true ||
      AppStorage.get<boolean>('showQuoteSearch') === true ||
      AppStorage.get<boolean>('showFavorites') === true ||
      AppStorage.get<boolean>('showAuthorList') === true ||
      AppStorage.get<boolean>('showMessages') === true ||
      AppStorage.get<boolean>('minePanelOpen') === true
  }
}
