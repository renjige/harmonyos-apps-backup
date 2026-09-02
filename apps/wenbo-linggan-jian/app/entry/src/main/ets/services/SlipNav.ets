export class SlipNav {
  static openWrite(editId: string): void {
    AppStorage.setOrCreate('writeNoteId', editId)
    AppStorage.setOrCreate('showWriteNote', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeWrite(): void {
    AppStorage.setOrCreate('showWriteNote', false)
    AppStorage.setOrCreate('writeNoteId', '')
    if (!SlipNav.isDetailOpen() && !SlipNav.isCardOpen()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static openDetail(id: string): void {
    AppStorage.setOrCreate('detailRoute', `note:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    const token = AppStorage.get<number>('detailToken') ?? 0
    AppStorage.setOrCreate('detailToken', token + 1)
  }

  static closeDetail(): void {
    AppStorage.setOrCreate('detailRoute', '')
    if (!SlipNav.isWriteOpen() && !SlipNav.isCardOpen()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static openCard(id: string): void {
    AppStorage.setOrCreate('cardNoteId', id)
    AppStorage.setOrCreate('showCardPane', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeCard(): void {
    AppStorage.setOrCreate('showCardPane', false)
    AppStorage.setOrCreate('cardNoteId', '')
    if (!SlipNav.isWriteOpen() && !SlipNav.isDetailOpen()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static isWriteOpen(): boolean {
    return AppStorage.get<boolean>('showWriteNote') === true
  }

  static isDetailOpen(): boolean {
    const route = AppStorage.get<string>('detailRoute') ?? ''
    return route.length > 0
  }

  static isCardOpen(): boolean {
    return AppStorage.get<boolean>('showCardPane') === true
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
    return AppStorage.get<string>('writeNoteId') ?? ''
  }

  static cardId(): string {
    return AppStorage.get<string>('cardNoteId') ?? ''
  }

  static openMessages(): void {
    AppStorage.setOrCreate('showMessages', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeMessages(): void {
    AppStorage.setOrCreate('showMessages', false)
    if (!SlipNav.isWriteOpen() && !SlipNav.isDetailOpen() && !SlipNav.isCardOpen()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static openSearch(): void {
    AppStorage.setOrCreate('openLibrarySearch', true)
  }

  static openFavLibrary(): void {
    AppStorage.setOrCreate('openLibraryFav', true)
  }

  static openDiagnose(): void {
    AppStorage.setOrCreate('showDiagnose', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeDiagnose(): void {
    AppStorage.setOrCreate('showDiagnose', false)
    if (!SlipNav.isWriteOpen() && !SlipNav.isDetailOpen() && !SlipNav.isCardOpen() &&
      AppStorage.get<boolean>('showMessages') !== true) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }
}
