/** 全局详情 / 编辑路由（MainTabPage 顶层 Stack） */
export class ArchiveDetailNav {
  static openArchiveDetail(id: string): void {
    AppStorage.setOrCreate('archiveDetailId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeArchiveDetail(): void {
    AppStorage.setOrCreate('archiveDetailId', '')
    ArchiveDetailNav.restoreTabBar()
  }

  static openNodeDetail(id: string): void {
    AppStorage.setOrCreate('nodeDetailId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeNodeDetail(): void {
    AppStorage.setOrCreate('nodeDetailId', '')
    ArchiveDetailNav.restoreTabBar()
  }

  static openCreateArchive(): void {
    AppStorage.setOrCreate('editArchiveId', '')
    AppStorage.setOrCreate('createArchiveOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openEditArchive(id: string): void {
    AppStorage.setOrCreate('editArchiveId', id)
    AppStorage.setOrCreate('createArchiveOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeCreateArchive(): void {
    AppStorage.setOrCreate('createArchiveOpen', false)
    AppStorage.setOrCreate('editArchiveId', '')
    ArchiveDetailNav.restoreTabBar()
  }

  static openNodeEditor(archiveId: string, nodeId: string): void {
    AppStorage.setOrCreate('nodeEditorArchiveId', archiveId)
    AppStorage.setOrCreate('nodeEditorNodeId', nodeId)
    AppStorage.setOrCreate('nodeEditorOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeNodeEditor(): void {
    AppStorage.setOrCreate('nodeEditorOpen', false)
    const archiveDetail = AppStorage.get<string>('archiveDetailId') ?? ''
    const nodeDetail = AppStorage.get<string>('nodeDetailId') ?? ''
    AppStorage.setOrCreate('tabBarHidden', archiveDetail.length > 0 || nodeDetail.length > 0)
  }

  static close(): void {
    AppStorage.setOrCreate('archiveDetailId', '')
    AppStorage.setOrCreate('nodeDetailId', '')
    AppStorage.setOrCreate('createArchiveOpen', false)
    AppStorage.setOrCreate('editArchiveId', '')
    AppStorage.setOrCreate('nodeEditorOpen', false)
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private static restoreTabBar(): void {
    const createOpen = AppStorage.get<boolean>('createArchiveOpen') === true
    const editorOpen = AppStorage.get<boolean>('nodeEditorOpen') === true
    const searchOpen = AppStorage.get<boolean>('searchOpen') === true
    const inspirationOpen = AppStorage.get<boolean>('inspirationEditorOpen') === true
    const momentOpen = AppStorage.get<boolean>('momentEditorOpen') === true
    const themeAlbumOpen = AppStorage.get<boolean>('themeAlbumListOpen') === true
    const checklistOpen = AppStorage.get<boolean>('checklistSheetOpen') === true
    const experienceOpen = AppStorage.get<boolean>('experienceLibraryOpen') === true
    const favoritesOpen = AppStorage.get<boolean>('favoritesCenterOpen') === true
    const planDetail = AppStorage.get<string>('planDetailId') ?? ''
    const archiveDetail = AppStorage.get<string>('archiveDetailId') ?? ''
    const nodeDetail = AppStorage.get<string>('nodeDetailId') ?? ''
    const hidden = createOpen || editorOpen || searchOpen || inspirationOpen || momentOpen
      || themeAlbumOpen || checklistOpen || experienceOpen || favoritesOpen
      || planDetail.length > 0
      || archiveDetail.length > 0 || nodeDetail.length > 0
    AppStorage.setOrCreate('tabBarHidden', hidden)
  }
}
