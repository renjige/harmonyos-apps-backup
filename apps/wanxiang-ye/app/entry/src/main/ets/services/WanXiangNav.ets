export class WanXiangNav {
  static openSearch(): void {
    AppStorage.setOrCreate('wanxiangSearchOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeSearch(): void {
    AppStorage.setOrCreate('wanxiangSearchOpen', false)
    if (WanXiangNav.currentDetailId().length === 0 && WanXiangNav.currentKnowledgeId().length === 0) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static openKnowledge(id: string): void {
    AppStorage.setOrCreate('wanxiangKnowledgeId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeKnowledge(): void {
    AppStorage.setOrCreate('wanxiangKnowledgeId', '')
    if (WanXiangNav.currentDetailId().length === 0 && !WanXiangNav.isSearchOpen()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static openEditor(editId: string = ''): void {
    AppStorage.setOrCreate('wanxiangEditorId', editId)
    AppStorage.setOrCreate('wanxiangEditorKind', 'knowledge')
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openSparkEditor(): void {
    AppStorage.setOrCreate('wanxiangEditorId', '')
    AppStorage.setOrCreate('wanxiangEditorKind', 'spark')
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeEditor(): void {
    AppStorage.setOrCreate('wanxiangEditorId', '')
    AppStorage.setOrCreate('wanxiangEditorKind', '')
    if (WanXiangNav.currentDetailId().length === 0 && WanXiangNav.currentKnowledgeId().length === 0 &&
      !WanXiangNav.isSearchOpen()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static switchTab(index: number): void {
    AppStorage.setOrCreate('wanxiangTabIndex', index)
  }

  static currentDetailId(): string {
    const v = AppStorage.get<string>('wanxiangDetailId')
    return v !== undefined ? v : ''
  }

  static currentKnowledgeId(): string {
    const v = AppStorage.get<string>('wanxiangKnowledgeId')
    return v !== undefined ? v : ''
  }

  static isSearchOpen(): boolean {
    const v = AppStorage.get<boolean>('wanxiangSearchOpen')
    return v === true
  }
}
