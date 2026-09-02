/** 全局详情 / 写心笺 Overlay 路由 */

export class NoteNav {
  static openWrite(editId: string): void {
    AppStorage.setOrCreate('writeNoteId', editId)
    AppStorage.setOrCreate('showWriteNote', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeWrite(): void {
    AppStorage.setOrCreate('showWriteNote', false)
    AppStorage.setOrCreate('writeNoteId', '')
    if (!NoteNav.isDetailOpen()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static openDetail(id: string): void {
    AppStorage.setOrCreate('detailRoute', `note:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    const token = AppStorage.get<number>('detailToken') ?? 0
    AppStorage.setOrCreate('detailToken', token + 1)
  }

  static closeDetail(): void {
    AppStorage.setOrCreate('detailRoute', '')
    if (!NoteNav.isWriteOpen()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static isWriteOpen(): boolean {
    return AppStorage.get<boolean>('showWriteNote') === true
  }

  static isDetailOpen(): boolean {
    const route = AppStorage.get<string>('detailRoute') ?? ''
    return route.length > 0
  }

  static parseId(): string {
    const route = AppStorage.get<string>('detailRoute') ?? ''
    const idx = route.indexOf(':')
    if (idx < 0) {
      return ''
    }
    return route.substring(idx + 1)
  }

  static writeId(): string {
    return AppStorage.get<string>('writeNoteId') ?? ''
  }

  static openMessages(): void {
    AppStorage.setOrCreate('showMessages', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeMessages(): void {
    AppStorage.setOrCreate('showMessages', false)
    if (!NoteNav.isWriteOpen() && !NoteNav.isDetailOpen()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }
}
