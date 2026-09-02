export class TeaNav {
  static openTea(id: string): void {
    if (id.length === 0) {
      return
    }
    // 品饮详情叠在茶档案之上时，必须先关掉品饮，否则看起来像点了没反应
    AppStorage.setOrCreate('tastingDetailId', '')
    AppStorage.setOrCreate('teaDetailId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeTea(): void {
    AppStorage.setOrCreate('teaDetailId', '')
    TeaNav.restoreBar()
  }

  static openTasting(id: string): void {
    if (id.length === 0) {
      return
    }
    AppStorage.setOrCreate('tastingDetailId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeTasting(): void {
    AppStorage.setOrCreate('tastingDetailId', '')
    TeaNav.restoreBar()
  }

  static openTeaEditor(id: string): void {
    AppStorage.setOrCreate('teaEditorId', id)
    AppStorage.setOrCreate('teaEditorOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeTeaEditor(): void {
    AppStorage.setOrCreate('teaEditorOpen', false)
    AppStorage.setOrCreate('teaEditorId', '')
    TeaNav.restoreBar()
  }

  static openTastingEditor(teaId: string, tastingId: string): void {
    AppStorage.setOrCreate('tastingEditorTeaId', teaId)
    AppStorage.setOrCreate('tastingEditorId', tastingId)
    AppStorage.setOrCreate('tastingEditorOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeTastingEditor(): void {
    AppStorage.setOrCreate('tastingEditorOpen', false)
    AppStorage.setOrCreate('tastingEditorTeaId', '')
    AppStorage.setOrCreate('tastingEditorId', '')
    TeaNav.restoreBar()
  }

  static openSearch(): void {
    AppStorage.setOrCreate('searchOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeSearch(): void {
    AppStorage.setOrCreate('searchOpen', false)
    TeaNav.restoreBar()
  }

  static openSheet(key: string): void {
    AppStorage.setOrCreate(key, true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeSheet(key: string): void {
    AppStorage.setOrCreate(key, false)
    TeaNav.restoreBar()
  }

  static restoreBar(): void {
    const tea = AppStorage.get<string>('teaDetailId') ?? ''
    const tasting = AppStorage.get<string>('tastingDetailId') ?? ''
    const teaEd = AppStorage.get<boolean>('teaEditorOpen') === true
    const sipEd = AppStorage.get<boolean>('tastingEditorOpen') === true
    const search = AppStorage.get<boolean>('searchOpen') === true
    const list = AppStorage.get<boolean>('listSheetOpen') === true
    const album = AppStorage.get<boolean>('albumSheetOpen') === true
    const plan = AppStorage.get<boolean>('planSheetOpen') === true
    const org = AppStorage.get<boolean>('organizeOpen') === true
    const tag = AppStorage.get<boolean>('tagSheetOpen') === true
    if (tea.length === 0 && tasting.length === 0 && !teaEd && !sipEd && !search && !list && !album && !plan && !org && !tag) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }
}
