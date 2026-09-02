export class TreasureNav {
  static openEditor(itemId: string): void {
    AppStorage.setOrCreate('treasureEditId', itemId)
    AppStorage.setOrCreate('treasureShowEditor', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openDetail(itemId: string): void {
    AppStorage.setOrCreate('treasureDetailId', itemId)
    AppStorage.setOrCreate('treasureShowDetail', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openSubPage(page: string): void {
    AppStorage.setOrCreate('treasureSubPage', page)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openSearch(): void {
    TreasureNav.openSubPage('search')
  }

  static openSmartOrganize(): void {
    TreasureNav.openSubPage('smartOrganize')
  }

  static openPlanEditor(planId: string): void {
    AppStorage.setOrCreate('treasurePlanId', planId)
    TreasureNav.openSubPage('planEditor')
  }

  static openNoteEditor(noteId: string): void {
    AppStorage.setOrCreate('treasureNoteId', noteId)
    TreasureNav.openSubPage('noteEditor')
  }

  static openAlbumDetail(albumId: string): void {
    AppStorage.setOrCreate('treasureAlbumId', albumId)
    TreasureNav.openSubPage('albumDetail')
  }

  static openPlanList(): void {
    TreasureNav.openSubPage('planList')
  }

  static openWishList(): void {
    TreasureNav.openSubPage('wishList')
  }

  static openNoteList(): void {
    TreasureNav.openSubPage('noteList')
  }

  static openCompare(firstId: string): void {
    AppStorage.setOrCreate('treasureCompareFirst', firstId)
    AppStorage.setOrCreate('treasureCompareSecond', '')
    TreasureNav.openSubPage('compare')
  }

  static openDomainArchive(domainKey: string): void {
    AppStorage.setOrCreate('treasureDomainKey', domainKey)
    TreasureNav.openSubPage('domainArchive')
  }

  static switchTab(index: number): void {
    AppStorage.setOrCreate('treasureTabIndex', index)
  }

  static closeDetail(): void {
    AppStorage.setOrCreate('treasureShowDetail', false)
    AppStorage.setOrCreate('treasureDetailId', '')
    TreasureNav.restoreBarIfIdle()
  }

  static closeEditor(): void {
    AppStorage.setOrCreate('treasureShowEditor', false)
    AppStorage.setOrCreate('treasureEditId', '')
    TreasureNav.restoreBarIfIdle()
  }

  static closeSubPage(): void {
    AppStorage.setOrCreate('treasureSubPage', '')
    TreasureNav.restoreBarIfIdle()
  }

  static restoreBarIfIdle(): void {
    const editor = AppStorage.get<boolean>('treasureShowEditor') ?? false
    const detail = AppStorage.get<boolean>('treasureShowDetail') ?? false
    const sub = `${AppStorage.get<string>('treasureSubPage') ?? ''}`
    if (!editor && !detail && sub.length === 0) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static restoreBar(): void {
    AppStorage.setOrCreate('tabBarHidden', false)
  }
}
