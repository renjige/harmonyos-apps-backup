/** 全局 Overlay 路由 */

export class KnowledgeNav {
  static openWrite(editId: string): void {
    AppStorage.setOrCreate('writeKnowledgeId', editId)
    AppStorage.setOrCreate('showWriteKnowledge', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeWrite(): void {
    AppStorage.setOrCreate('showWriteKnowledge', false)
    AppStorage.setOrCreate('writeKnowledgeId', '')
    if (!KnowledgeNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static openSpark(editId: string): void {
    AppStorage.setOrCreate('writeSparkId', editId)
    AppStorage.setOrCreate('showWriteSpark', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeSpark(): void {
    AppStorage.setOrCreate('showWriteSpark', false)
    AppStorage.setOrCreate('writeSparkId', '')
    if (!KnowledgeNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static openDetail(id: string): void {
    AppStorage.setOrCreate('detailRoute', `knowledge:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeDetail(): void {
    AppStorage.setOrCreate('detailRoute', '')
    if (!KnowledgeNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static openSearch(): void {
    AppStorage.setOrCreate('showSearch', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeSearch(): void {
    AppStorage.setOrCreate('showSearch', false)
    if (!KnowledgeNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static openFavorites(): void {
    AppStorage.setOrCreate('showFavorites', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeFavorites(): void {
    AppStorage.setOrCreate('showFavorites', false)
    if (!KnowledgeNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static openSparks(): void {
    AppStorage.setOrCreate('showSparks', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeSparks(): void {
    AppStorage.setOrCreate('showSparks', false)
    if (!KnowledgeNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static openManage(): void {
    AppStorage.setOrCreate('showManage', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeManage(): void {
    AppStorage.setOrCreate('showManage', false)
    if (!KnowledgeNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static openMessages(): void {
    AppStorage.setOrCreate('showMessages', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeMessages(): void {
    AppStorage.setOrCreate('showMessages', false)
    if (!KnowledgeNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static isWriteOpen(): boolean {
    return AppStorage.get<boolean>('showWriteKnowledge') === true
  }

  static isSparkOpen(): boolean {
    return AppStorage.get<boolean>('showWriteSpark') === true
  }

  static isDetailOpen(): boolean {
    const route = AppStorage.get<string>('detailRoute') ?? ''
    return route.length > 0
  }

  static keepTabHidden(): boolean {
    return KnowledgeNav.isWriteOpen() || KnowledgeNav.isSparkOpen() || KnowledgeNav.isDetailOpen() ||
      AppStorage.get<boolean>('showSearch') === true ||
      AppStorage.get<boolean>('showFavorites') === true ||
      AppStorage.get<boolean>('showSparks') === true ||
      AppStorage.get<boolean>('showManage') === true ||
      AppStorage.get<boolean>('showMessages') === true ||
      AppStorage.get<boolean>('minePanelOpen') === true
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
    return AppStorage.get<string>('writeKnowledgeId') ?? ''
  }

  static sparkId(): string {
    return AppStorage.get<string>('writeSparkId') ?? ''
  }

  static switchTab(index: number): void {
    AppStorage.setOrCreate('mainTabIndex', index)
  }
}
