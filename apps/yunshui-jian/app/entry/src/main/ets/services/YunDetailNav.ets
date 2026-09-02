/** 全局详情 / 二级页路由（MainTabPage 顶层 Stack） */
export class YunDetailNav {
  static openNote(id: string): void {
    AppStorage.setOrCreate('yunNoteDetailId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeNote(): void {
    AppStorage.setOrCreate('yunNoteDetailId', '')
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static openNoteEditor(id: string): void {
    AppStorage.setOrCreate('lifeEditorTemplate', '')
    AppStorage.setOrCreate('lifeEditorCategory', '')
    AppStorage.setOrCreate('yunNoteEditorId', id)
    AppStorage.setOrCreate('yunNoteEditorOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openNoteEditorWithTemplate(templateKey: string, category: string): void {
    AppStorage.setOrCreate('lifeEditorTemplate', templateKey)
    AppStorage.setOrCreate('lifeEditorCategory', category)
    AppStorage.setOrCreate('yunNoteEditorId', '')
    AppStorage.setOrCreate('yunNoteEditorOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeNoteEditor(): void {
    AppStorage.setOrCreate('yunNoteEditorOpen', false)
    const detailId = AppStorage.get<string>('yunNoteDetailId') ?? ''
    AppStorage.setOrCreate('tabBarHidden', detailId.length > 0)
  }

  static openTodoEdit(id: string): void {
    AppStorage.setOrCreate('yunTodoEditId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeTodoEdit(): void {
    AppStorage.setOrCreate('yunTodoEditId', '')
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static openSearch(): void {
    AppStorage.setOrCreate('yunSearchOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeSearch(): void {
    AppStorage.setOrCreate('yunSearchOpen', false)
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static openCraft(id: string): void {
    AppStorage.setOrCreate('yunCraftDetailId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeCraft(): void {
    AppStorage.setOrCreate('yunCraftDetailId', '')
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static openCraftEditor(id: string, kind: string): void {
    AppStorage.setOrCreate('lifeCraftEditorId', id)
    AppStorage.setOrCreate('lifeCraftEditorKind', kind)
    AppStorage.setOrCreate('yunCraftEditorOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeCraftEditor(): void {
    AppStorage.setOrCreate('yunCraftEditorOpen', false)
    const detailId = AppStorage.get<string>('yunCraftDetailId') ?? ''
    AppStorage.setOrCreate('tabBarHidden', detailId.length > 0)
  }
}
