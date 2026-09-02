/** 全局详情 / 二级页路由（MainTabPage 顶层 Stack） */
export class LifeDetailNav {
  static openNote(id: string): void {
    AppStorage.setOrCreate('lifeNoteDetailId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeNote(): void {
    AppStorage.setOrCreate('lifeNoteDetailId', '')
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static openNoteEditor(id: string): void {
    AppStorage.setOrCreate('lifeEditorTemplate', '')
    AppStorage.setOrCreate('lifeEditorCategory', '')
    AppStorage.setOrCreate('lifeNoteEditorId', id)
    AppStorage.setOrCreate('lifeNoteEditorOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openNoteEditorWithTemplate(templateKey: string, category: string): void {
    AppStorage.setOrCreate('lifeEditorTemplate', templateKey)
    AppStorage.setOrCreate('lifeEditorCategory', category)
    AppStorage.setOrCreate('lifeNoteEditorId', '')
    AppStorage.setOrCreate('lifeNoteEditorOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeNoteEditor(): void {
    AppStorage.setOrCreate('lifeNoteEditorOpen', false)
    const detailId = AppStorage.get<string>('lifeNoteDetailId') ?? ''
    AppStorage.setOrCreate('tabBarHidden', detailId.length > 0)
  }

  static openTodoEdit(id: string): void {
    AppStorage.setOrCreate('lifeTodoEditId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeTodoEdit(): void {
    AppStorage.setOrCreate('lifeTodoEditId', '')
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static openSearch(): void {
    AppStorage.setOrCreate('lifeSearchOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeSearch(): void {
    AppStorage.setOrCreate('lifeSearchOpen', false)
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static openCraft(id: string): void {
    AppStorage.setOrCreate('lifeCraftDetailId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeCraft(): void {
    AppStorage.setOrCreate('lifeCraftDetailId', '')
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static openCraftEditor(id: string, kind: string): void {
    AppStorage.setOrCreate('lifeCraftEditorId', id)
    AppStorage.setOrCreate('lifeCraftEditorKind', kind)
    AppStorage.setOrCreate('lifeCraftEditorOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeCraftEditor(): void {
    AppStorage.setOrCreate('lifeCraftEditorOpen', false)
    const detailId = AppStorage.get<string>('lifeCraftDetailId') ?? ''
    AppStorage.setOrCreate('tabBarHidden', detailId.length > 0)
  }
}
