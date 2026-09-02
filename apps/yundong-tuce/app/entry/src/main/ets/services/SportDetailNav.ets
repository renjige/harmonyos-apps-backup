export class SportDetailNav {
  static openDetail(id: string): void {
    AppStorage.setOrCreate('sportDetailId', id)
    AppStorage.setOrCreate('sportDetailOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeDetail(): void {
    AppStorage.setOrCreate('sportDetailOpen', false)
    AppStorage.setOrCreate('sportDetailId', '')
    SportDetailNav.restoreBar()
  }

  static openEditor(id: string): void {
    AppStorage.setOrCreate('sportEditorId', id)
    AppStorage.setOrCreate('sportEditorOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeEditor(refresh: boolean): void {
    AppStorage.setOrCreate('sportEditorOpen', false)
    AppStorage.setOrCreate('sportEditorId', '')
    if (refresh) {
      AppStorage.setOrCreate('sportReloadToken', Date.now())
    }
    SportDetailNav.restoreBar()
  }

  static openReport(): void {
    AppStorage.setOrCreate('sportReportOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeReport(): void {
    AppStorage.setOrCreate('sportReportOpen', false)
    SportDetailNav.restoreBar()
  }

  static restoreBar(): void {
    const detailOpen = AppStorage.get<boolean>('sportDetailOpen') === true
    const editorOpen = AppStorage.get<boolean>('sportEditorOpen') === true
    const reportOpen = AppStorage.get<boolean>('sportReportOpen') === true
    if (!detailOpen && !editorOpen && !reportOpen) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }
}
