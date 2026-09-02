export class NoteNav {
  static openDetail(id: string): void {
    AppStorage.setOrCreate('detailNoteId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeDetail(): void {
    AppStorage.setOrCreate('detailNoteId', '')
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static openWrite(editId: string): void {
    AppStorage.setOrCreate('writeNoteId', editId)
    AppStorage.setOrCreate('showWriteNote', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeWrite(): void {
    AppStorage.setOrCreate('writeNoteId', '')
    AppStorage.setOrCreate('showWriteNote', false)
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static detailId(): string {
    const v = AppStorage.get<string>('detailNoteId')
    return v !== undefined ? v : ''
  }
}
