/** 全局详情 / 撰写 Overlay 路由 */

export class EssayNav {
  static openWrite(editId: string): void {
    AppStorage.setOrCreate('writeEssayId', editId)
    AppStorage.setOrCreate('showWriteEssay', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeWrite(): void {
    AppStorage.setOrCreate('showWriteEssay', false)
    AppStorage.setOrCreate('writeEssayId', '')
    if (!EssayNav.isDetailOpen() && !EssayNav.isDiagnoseOpen() && !EssayNav.isMessagesOpen() &&
      !EssayNav.isFavOpen()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static openDetail(kind: string, id: string): void {
    AppStorage.setOrCreate('detailRoute', `${kind}:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    const token = AppStorage.get<number>('detailToken') ?? 0
    AppStorage.setOrCreate('detailToken', token + 1)
  }

  static closeDetail(): void {
    AppStorage.setOrCreate('detailRoute', '')
    if (!EssayNav.isWriteOpen() && !EssayNav.isDiagnoseOpen() && !EssayNav.isMessagesOpen() &&
      !EssayNav.isFavOpen()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static openMessages(): void {
    AppStorage.setOrCreate('showMessages', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeMessages(): void {
    AppStorage.setOrCreate('showMessages', false)
    EssayNav.restoreBar()
  }

  static openDiagnose(): void {
    AppStorage.setOrCreate('showDiagnose', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeDiagnose(): void {
    AppStorage.setOrCreate('showDiagnose', false)
    EssayNav.restoreBar()
  }

  static openFav(): void {
    AppStorage.setOrCreate('showFavQuotes', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeFav(): void {
    AppStorage.setOrCreate('showFavQuotes', false)
    EssayNav.restoreBar()
  }

  static restoreBar(): void {
    if (!EssayNav.isWriteOpen() && !EssayNav.isDetailOpen() && !EssayNav.isDiagnoseOpen() &&
      !EssayNav.isMessagesOpen() && !EssayNav.isFavOpen()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static isWriteOpen(): boolean {
    return AppStorage.get<boolean>('showWriteEssay') === true
  }

  static isDetailOpen(): boolean {
    const route = AppStorage.get<string>('detailRoute') ?? ''
    return route.length > 0
  }

  static isMessagesOpen(): boolean {
    return AppStorage.get<boolean>('showMessages') === true
  }

  static isDiagnoseOpen(): boolean {
    return AppStorage.get<boolean>('showDiagnose') === true
  }

  static isFavOpen(): boolean {
    return AppStorage.get<boolean>('showFavQuotes') === true
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
    return AppStorage.get<string>('writeEssayId') ?? ''
  }

  static bumpRefresh(): void {
    const token = AppStorage.get<number>('essayRefresh') ?? 0
    AppStorage.setOrCreate('essayRefresh', token + 1)
  }
}
