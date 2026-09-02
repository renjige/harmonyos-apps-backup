export class AlbumNav {
  static openDetail(id: string): void {
    AppStorage.setOrCreate('albumDetailId', id)
    AppStorage.setOrCreate('albumShowDetail', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeDetail(): void {
    AppStorage.setOrCreate('albumShowDetail', false)
    AppStorage.setOrCreate('albumDetailId', '')
    AlbumNav.restoreTab()
  }

  static openUpload(): void {
    AppStorage.setOrCreate('albumShowUpload', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeUpload(): void {
    AppStorage.setOrCreate('albumShowUpload', false)
    AlbumNav.restoreTab()
  }

  static openFilter(kind: string, value: string): void {
    AppStorage.setOrCreate('albumFilterKind', kind)
    AppStorage.setOrCreate('albumFilterValue', value)
    AppStorage.setOrCreate('albumShowFilter', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeFilter(): void {
    AppStorage.setOrCreate('albumShowFilter', false)
    AlbumNav.restoreTab()
  }

  static openSearch(): void {
    AppStorage.setOrCreate('albumShowSearch', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeSearch(): void {
    AppStorage.setOrCreate('albumShowSearch', false)
    AlbumNav.restoreTab()
  }

  static openRecap(): void {
    AppStorage.setOrCreate('albumShowRecap', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeRecap(): void {
    AppStorage.setOrCreate('albumShowRecap', false)
    AlbumNav.restoreTab()
  }

  private static restoreTab(): void {
    const detail = AppStorage.get<boolean>('albumShowDetail') === true
    const upload = AppStorage.get<boolean>('albumShowUpload') === true
    const filter = AppStorage.get<boolean>('albumShowFilter') === true
    const search = AppStorage.get<boolean>('albumShowSearch') === true
    const recap = AppStorage.get<boolean>('albumShowRecap') === true
    AppStorage.setOrCreate('tabBarHidden', detail || upload || filter || search || recap)
  }
}
