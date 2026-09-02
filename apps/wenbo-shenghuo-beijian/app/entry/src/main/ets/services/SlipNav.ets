/** 全局详情 / 新建 Overlay 路由 */

export class SlipNav {
  static openWrite(editId: string): void {
    AppStorage.setOrCreate('writeSlipId', editId)
    AppStorage.setOrCreate('showWriteSlip', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeWrite(): void {
    AppStorage.setOrCreate('showWriteSlip', false)
    AppStorage.setOrCreate('writeSlipId', '')
    if (!SlipNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static openDetail(id: string): void {
    AppStorage.setOrCreate('detailRoute', `slip:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openCatalog(kind: string, id: string): void {
    AppStorage.setOrCreate('detailRoute', `${kind}:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeDetail(): void {
    AppStorage.setOrCreate('detailRoute', '')
    if (!SlipNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static openCatalogList(): void {
    AppStorage.setOrCreate('showCatalogList', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeCatalogList(): void {
    AppStorage.setOrCreate('showCatalogList', false)
    if (!SlipNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static isWriteOpen(): boolean {
    return AppStorage.get<boolean>('showWriteSlip') === true
  }

  static isDetailOpen(): boolean {
    const route = AppStorage.get<string>('detailRoute') ?? ''
    return route.length > 0
  }

  static isMessagesOpen(): boolean {
    return AppStorage.get<boolean>('showMessages') === true
  }

  static isMinePanelOpen(): boolean {
    return AppStorage.get<boolean>('minePanelOpen') === true
  }

  static isCatalogListOpen(): boolean {
    return AppStorage.get<boolean>('showCatalogList') === true
  }

  static keepTabHidden(): boolean {
    return SlipNav.isWriteOpen() || SlipNav.isDetailOpen() ||
      SlipNav.isMessagesOpen() || SlipNav.isMinePanelOpen() || SlipNav.isCatalogListOpen()
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
    return AppStorage.get<string>('writeSlipId') ?? ''
  }

  static openMessages(): void {
    AppStorage.setOrCreate('showMessages', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeMessages(): void {
    AppStorage.setOrCreate('showMessages', false)
    if (!SlipNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static hintCategory(category: string): void {
    AppStorage.setOrCreate('writeCategoryHint', category)
  }

  static takeCategoryHint(): string {
    const v = AppStorage.get<string>('writeCategoryHint') ?? ''
    AppStorage.setOrCreate('writeCategoryHint', '')
    return v
  }
}
