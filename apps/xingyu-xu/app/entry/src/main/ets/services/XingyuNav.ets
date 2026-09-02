export class XingyuNav {
  static bump(): void {
    const rev = AppStorage.get<number>('xingyuRev') ?? 0
    AppStorage.setOrCreate('xingyuRev', rev + 1)
  }

  static hideBar(): void {
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static restoreBar(): void {
    const n = AppStorage.get<string>('xingyuNarrativeId') ?? ''
    const s = AppStorage.get<string>('xingyuSparkId') ?? ''
    const t = AppStorage.get<string>('xingyuThemeId') ?? ''
    const e = AppStorage.get<string>('xingyuEditorKind') ?? ''
    const search = AppStorage.get<boolean>('xingyuSearchOpen') === true
    const fav = AppStorage.get<boolean>('xingyuFavOpen') === true
    const ach = AppStorage.get<boolean>('xingyuAchieveOpen') === true
    const tags = AppStorage.get<boolean>('xingyuTagsOpen') === true
    const mine = AppStorage.get<boolean>('xingyuSettingsOpen') === true
    if (n.length > 0 || s.length > 0 || t.length > 0 || e.length > 0 || search || fav || ach || tags || mine) {
      AppStorage.setOrCreate('tabBarHidden', true)
      return
    }
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static openNarrative(id: string): void {
    AppStorage.setOrCreate('xingyuNarrativeId', id)
    XingyuNav.hideBar()
  }

  static closeNarrative(): void {
    AppStorage.setOrCreate('xingyuNarrativeId', '')
    XingyuNav.restoreBar()
  }

  static openSpark(id: string): void {
    AppStorage.setOrCreate('xingyuSparkId', id)
    XingyuNav.hideBar()
  }

  static closeSpark(): void {
    AppStorage.setOrCreate('xingyuSparkId', '')
    XingyuNav.restoreBar()
  }

  static openTheme(id: string): void {
    AppStorage.setOrCreate('xingyuThemeId', id)
    XingyuNav.hideBar()
  }

  static closeTheme(): void {
    AppStorage.setOrCreate('xingyuThemeId', '')
    XingyuNav.restoreBar()
  }

  static openEditor(kind: string, id: string): void {
    AppStorage.setOrCreate('xingyuEditorKind', kind)
    AppStorage.setOrCreate('xingyuEditorId', id)
    XingyuNav.hideBar()
  }

  static closeEditor(): void {
    AppStorage.setOrCreate('xingyuEditorKind', '')
    AppStorage.setOrCreate('xingyuEditorId', '')
    XingyuNav.restoreBar()
  }

  static openSearch(): void {
    AppStorage.setOrCreate('xingyuSearchOpen', true)
    XingyuNav.hideBar()
  }

  static closeSearch(): void {
    AppStorage.setOrCreate('xingyuSearchOpen', false)
    XingyuNav.restoreBar()
  }

  static openFavorites(): void {
    AppStorage.setOrCreate('xingyuFavOpen', true)
    XingyuNav.hideBar()
  }

  static closeFavorites(): void {
    AppStorage.setOrCreate('xingyuFavOpen', false)
    XingyuNav.restoreBar()
  }

  static openAchievements(): void {
    AppStorage.setOrCreate('xingyuAchieveOpen', true)
    XingyuNav.hideBar()
  }

  static closeAchievements(): void {
    AppStorage.setOrCreate('xingyuAchieveOpen', false)
    XingyuNav.restoreBar()
  }

  static openTags(): void {
    AppStorage.setOrCreate('xingyuTagsOpen', true)
    XingyuNav.hideBar()
  }

  static closeTags(): void {
    AppStorage.setOrCreate('xingyuTagsOpen', false)
    XingyuNav.restoreBar()
  }

  static setPendingTheme(id: string): void {
    AppStorage.setOrCreate('xingyuPendingThemeId', id)
  }

  static takePendingTheme(): string {
    const id = AppStorage.get<string>('xingyuPendingThemeId') ?? ''
    AppStorage.setOrCreate('xingyuPendingThemeId', '')
    return id
  }

  static switchTab(index: number): void {
    AppStorage.setOrCreate('xingyuTabIndex', index)
  }
}
