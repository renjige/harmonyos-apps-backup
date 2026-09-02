export class XuDetailNav {
  static openAgenda(id: string): void {
    AppStorage.setOrCreate('xuAgendaId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeAgenda(): void {
    AppStorage.setOrCreate('xuAgendaId', '')
    XuDetailNav.restoreBar()
  }

  static openAgendaEditor(id: string, dateKey: string = ''): void {
    AppStorage.setOrCreate('xuAgendaEditId', id)
    AppStorage.setOrCreate('xuAgendaEditDate', dateKey)
    AppStorage.setOrCreate('xuAgendaEditOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeAgendaEditor(): void {
    AppStorage.setOrCreate('xuAgendaEditOpen', false)
    AppStorage.setOrCreate('xuAgendaEditId', '')
    AppStorage.setOrCreate('xuAgendaEditDate', '')
    XuDetailNav.restoreBar()
  }

  /** 保存后让日程页跳到该日期并刷新列表 */
  static markAgendaFocus(dateKey: string): void {
    if (dateKey.length > 0) {
      AppStorage.setOrCreate('xuAgendaFocusDate', dateKey)
    }
  }

  static openHabit(id: string): void {
    AppStorage.setOrCreate('xuHabitId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeHabit(): void {
    AppStorage.setOrCreate('xuHabitId', '')
    XuDetailNav.restoreBar()
  }

  static openHabitEditor(id: string): void {
    AppStorage.setOrCreate('xuHabitEditId', id)
    AppStorage.setOrCreate('xuHabitEditOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeHabitEditor(): void {
    AppStorage.setOrCreate('xuHabitEditOpen', false)
    AppStorage.setOrCreate('xuHabitEditId', '')
    XuDetailNav.restoreBar()
  }

  static openNote(id: string): void {
    AppStorage.setOrCreate('xuNoteId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeNote(): void {
    AppStorage.setOrCreate('xuNoteId', '')
    XuDetailNav.restoreBar()
  }

  static openNoteEditor(id: string): void {
    AppStorage.setOrCreate('xuNoteEditId', id)
    AppStorage.setOrCreate('xuNoteEditOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeNoteEditor(): void {
    AppStorage.setOrCreate('xuNoteEditOpen', false)
    AppStorage.setOrCreate('xuNoteEditId', '')
    XuDetailNav.restoreBar()
  }

  static openTip(id: string): void {
    AppStorage.setOrCreate('xuTipId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeTip(): void {
    AppStorage.setOrCreate('xuTipId', '')
    XuDetailNav.restoreBar()
  }

  static openDiagnose(): void {
    AppStorage.setOrCreate('xuDiagnoseOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeDiagnose(): void {
    AppStorage.setOrCreate('xuDiagnoseOpen', false)
    XuDetailNav.restoreBar()
  }

  static openMessages(): void {
    AppStorage.setOrCreate('xuMessagesOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeMessages(): void {
    AppStorage.setOrCreate('xuMessagesOpen', false)
    XuDetailNav.restoreBar()
  }

  private static restoreBar(): void {
    const agenda = AppStorage.get<string>('xuAgendaId') ?? ''
    const habit = AppStorage.get<string>('xuHabitId') ?? ''
    const note = AppStorage.get<string>('xuNoteId') ?? ''
    const tip = AppStorage.get<string>('xuTipId') ?? ''
    const editA = AppStorage.get<boolean>('xuAgendaEditOpen') === true
    const editH = AppStorage.get<boolean>('xuHabitEditOpen') === true
    const editN = AppStorage.get<boolean>('xuNoteEditOpen') === true
    const diag = AppStorage.get<boolean>('xuDiagnoseOpen') === true
    const msg = AppStorage.get<boolean>('xuMessagesOpen') === true
    const mine = AppStorage.get<boolean>('xuSettingsOpen') === true
    if (agenda.length === 0 && habit.length === 0 && note.length === 0 && tip.length === 0 &&
      !editA && !editH && !editN && !diag && !msg && !mine) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }
}
