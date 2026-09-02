import { QgStore } from './QgStore'

export class QgDetailNav {
  static openEntry(id: string): void {
    AppStorage.setOrCreate('qgEntryId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeEntry(): void {
    AppStorage.setOrCreate('qgEntryId', '')
    QgDetailNav.restore()
  }

  static openClip(id: string): void {
    AppStorage.setOrCreate('qgClipId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeClip(): void {
    AppStorage.setOrCreate('qgClipId', '')
    QgDetailNav.restore()
  }

  static openTheme(id: string): void {
    AppStorage.setOrCreate('qgThemeId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeTheme(): void {
    AppStorage.setOrCreate('qgThemeId', '')
    QgDetailNav.restore()
  }

  static openEntryEditor(id: string, templateKey: string): void {
    AppStorage.setOrCreate('qgEntryEditId', id)
    AppStorage.setOrCreate('qgEntryTemplate', templateKey)
    AppStorage.setOrCreate('qgEntryEditorOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeEntryEditor(): void {
    AppStorage.setOrCreate('qgEntryEditorOpen', false)
    AppStorage.setOrCreate('qgEntryEditId', '')
    QgDetailNav.restore()
  }

  static openClipEditor(id: string): void {
    AppStorage.setOrCreate('qgClipEditId', id)
    AppStorage.setOrCreate('qgClipEditorOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeClipEditor(): void {
    AppStorage.setOrCreate('qgClipEditorOpen', false)
    AppStorage.setOrCreate('qgClipEditId', '')
    QgDetailNav.restore()
  }

  static openThemeEditor(id: string): void {
    AppStorage.setOrCreate('qgThemeEditId', id)
    AppStorage.setOrCreate('qgThemeEditorOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeThemeEditor(): void {
    AppStorage.setOrCreate('qgThemeEditorOpen', false)
    AppStorage.setOrCreate('qgThemeEditId', '')
    QgDetailNav.restore()
  }

  static openSearch(): void {
    AppStorage.setOrCreate('qgSearchOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeSearch(): void {
    AppStorage.setOrCreate('qgSearchOpen', false)
    QgDetailNav.restore()
  }

  static openYear(): void {
    AppStorage.setOrCreate('qgYearOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeYear(): void {
    AppStorage.setOrCreate('qgYearOpen', false)
    QgDetailNav.restore()
  }

  static restore(): void {
    const wasHidden = AppStorage.get<boolean>('tabBarHidden') === true
    const entryId = AppStorage.get<string>('qgEntryId') ?? ''
    const clipId = AppStorage.get<string>('qgClipId') ?? ''
    const themeId = AppStorage.get<string>('qgThemeId') ?? ''
    const entryEd = AppStorage.get<boolean>('qgEntryEditorOpen') === true
    const clipEd = AppStorage.get<boolean>('qgClipEditorOpen') === true
    const themeEd = AppStorage.get<boolean>('qgThemeEditorOpen') === true
    const search = AppStorage.get<boolean>('qgSearchOpen') === true
    const year = AppStorage.get<boolean>('qgYearOpen') === true
    const hidden = entryId.length > 0 || clipId.length > 0 || themeId.length > 0
      || entryEd || clipEd || themeEd || search || year
    AppStorage.setOrCreate('tabBarHidden', hidden)
    if (wasHidden && !hidden) {
      QgStore.bump()
    }
  }
}
