import { QyStore } from './QyStore'

export class QyDetailNav {
  static openEntry(id: string): void {
    AppStorage.setOrCreate('QyEntryId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeEntry(): void {
    AppStorage.setOrCreate('QyEntryId', '')
    QyDetailNav.restore()
  }

  static openClip(id: string): void {
    AppStorage.setOrCreate('QyClipId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeClip(): void {
    AppStorage.setOrCreate('QyClipId', '')
    QyDetailNav.restore()
  }

  static openTheme(id: string): void {
    AppStorage.setOrCreate('QyThemeId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeTheme(): void {
    AppStorage.setOrCreate('QyThemeId', '')
    QyDetailNav.restore()
  }

  static openEntryEditor(id: string, templateKey: string): void {
    AppStorage.setOrCreate('QyEntryEditId', id)
    AppStorage.setOrCreate('QyEntryTemplate', templateKey)
    AppStorage.setOrCreate('QyEntryEditorOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeEntryEditor(): void {
    AppStorage.setOrCreate('QyEntryEditorOpen', false)
    AppStorage.setOrCreate('QyEntryEditId', '')
    QyDetailNav.restore()
  }

  static openClipEditor(id: string): void {
    AppStorage.setOrCreate('QyClipEditId', id)
    AppStorage.setOrCreate('QyClipEditorOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeClipEditor(): void {
    AppStorage.setOrCreate('QyClipEditorOpen', false)
    AppStorage.setOrCreate('QyClipEditId', '')
    QyDetailNav.restore()
  }

  static openThemeEditor(id: string): void {
    AppStorage.setOrCreate('QyThemeEditId', id)
    AppStorage.setOrCreate('QyThemeEditorOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeThemeEditor(): void {
    AppStorage.setOrCreate('QyThemeEditorOpen', false)
    AppStorage.setOrCreate('QyThemeEditId', '')
    QyDetailNav.restore()
  }

  static openSearch(): void {
    AppStorage.setOrCreate('QySearchOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeSearch(): void {
    AppStorage.setOrCreate('QySearchOpen', false)
    QyDetailNav.restore()
  }

  static openYear(): void {
    AppStorage.setOrCreate('QyYearOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeYear(): void {
    AppStorage.setOrCreate('QyYearOpen', false)
    QyDetailNav.restore()
  }

  static restore(): void {
    const wasHidden = AppStorage.get<boolean>('tabBarHidden') === true
    const entryId = AppStorage.get<string>('QyEntryId') ?? ''
    const clipId = AppStorage.get<string>('QyClipId') ?? ''
    const themeId = AppStorage.get<string>('QyThemeId') ?? ''
    const entryEd = AppStorage.get<boolean>('QyEntryEditorOpen') === true
    const clipEd = AppStorage.get<boolean>('QyClipEditorOpen') === true
    const themeEd = AppStorage.get<boolean>('QyThemeEditorOpen') === true
    const search = AppStorage.get<boolean>('QySearchOpen') === true
    const year = AppStorage.get<boolean>('QyYearOpen') === true
    const hidden = entryId.length > 0 || clipId.length > 0 || themeId.length > 0
      || entryEd || clipEd || themeEd || search || year
    AppStorage.setOrCreate('tabBarHidden', hidden)
    if (wasHidden && !hidden) {
      QyStore.bump()
    }
  }
}
