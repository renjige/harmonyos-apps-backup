export class WrongDetailNav {
  static openCatalog(kind: string, id: string): void {
    AppStorage.setOrCreate('wqDetailKind', kind)
    AppStorage.setOrCreate('wqDetailId', id)
    AppStorage.setOrCreate('wqDetailOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openEntry(id: string): void {
    WrongDetailNav.openCatalog('entry', id)
  }

  static openCapture(mode: string, editId: string): void {
    AppStorage.setOrCreate('wqCaptureMode', mode)
    AppStorage.setOrCreate('wqCaptureEditId', editId)
    AppStorage.setOrCreate('wqCaptureOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static close(): void {
    AppStorage.setOrCreate('wqDetailOpen', false)
    AppStorage.setOrCreate('wqCaptureOpen', false)
    const messages = AppStorage.get<boolean>('wqMessagesOpen') === true
    const settings = AppStorage.get<boolean>('wqSettingsOpen') === true
    if (!messages && !settings) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }
}
