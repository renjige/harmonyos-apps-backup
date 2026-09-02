/** 全局详情 / 二级页路由（MainTabPage 顶层 Stack） */
export class ZhaDetailNav {
  static openNote(id: string): void {
    AppStorage.setOrCreate('zhaNoteDetailId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeNote(): void {
    AppStorage.setOrCreate('zhaNoteDetailId', '')
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static openNoteEditor(id: string): void {
    AppStorage.setOrCreate('zhaNoteEditorId', id)
    AppStorage.setOrCreate('zhaNoteEditorOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeNoteEditor(): void {
    AppStorage.setOrCreate('zhaNoteEditorOpen', false)
    const detailId = AppStorage.get<string>('zhaNoteDetailId') ?? ''
    AppStorage.setOrCreate('tabBarHidden', detailId.length > 0)
  }

  static openJournalCalendar(): void {
    AppStorage.setOrCreate('zhaJournalCalendarOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeJournalCalendar(): void {
    AppStorage.setOrCreate('zhaJournalCalendarOpen', false)
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static openJournalDetail(dateKey: string): void {
    AppStorage.setOrCreate('zhaJournalDetailKey', dateKey)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeJournalDetail(): void {
    AppStorage.setOrCreate('zhaJournalDetailKey', '')
    const calOpen = AppStorage.get<boolean>('zhaJournalCalendarOpen') === true
    AppStorage.setOrCreate('tabBarHidden', calOpen)
  }

  static openTodoEdit(id: string): void {
    AppStorage.setOrCreate('zhaTodoEditId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeTodoEdit(): void {
    AppStorage.setOrCreate('zhaTodoEditId', '')
    AppStorage.setOrCreate('tabBarHidden', false)
  }
}
