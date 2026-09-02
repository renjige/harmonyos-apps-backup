import { XdStore } from './XdStore'

export class XdDetailNav {
  static openEntry(id: string): void {
    AppStorage.setOrCreate('XdEntryId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeEntry(): void {
    AppStorage.setOrCreate('XdEntryId', '')
    XdDetailNav.restore()
  }

  static openClip(id: string): void {
    AppStorage.setOrCreate('XdClipId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeClip(): void {
    AppStorage.setOrCreate('XdClipId', '')
    XdDetailNav.restore()
  }

  static openTheme(id: string): void {
    AppStorage.setOrCreate('XdThemeId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeTheme(): void {
    AppStorage.setOrCreate('XdThemeId', '')
    XdDetailNav.restore()
  }

  static openEntryEditor(id: string, templateKey: string): void {
    AppStorage.setOrCreate('XdEntryEditId', id)
    AppStorage.setOrCreate('XdEntryTemplate', templateKey)
    AppStorage.setOrCreate('XdEntryEditorOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeEntryEditor(): void {
    AppStorage.setOrCreate('XdEntryEditorOpen', false)
    AppStorage.setOrCreate('XdEntryEditId', '')
    XdDetailNav.restore()
  }

  static openClipEditor(id: string): void {
    AppStorage.setOrCreate('XdClipEditId', id)
    AppStorage.setOrCreate('XdClipEditorOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeClipEditor(): void {
    AppStorage.setOrCreate('XdClipEditorOpen', false)
    AppStorage.setOrCreate('XdClipEditId', '')
    XdDetailNav.restore()
  }

  static openThemeEditor(id: string): void {
    AppStorage.setOrCreate('XdThemeEditId', id)
    AppStorage.setOrCreate('XdThemeEditorOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeThemeEditor(): void {
    AppStorage.setOrCreate('XdThemeEditorOpen', false)
    AppStorage.setOrCreate('XdThemeEditId', '')
    XdDetailNav.restore()
  }

  static openSearch(): void {
    AppStorage.setOrCreate('xdSearchOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeSearch(): void {
    AppStorage.setOrCreate('xdSearchOpen', false)
    XdDetailNav.restore()
  }

  static openYear(): void {
    AppStorage.setOrCreate('xdYearOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeYear(): void {
    AppStorage.setOrCreate('xdYearOpen', false)
    XdDetailNav.restore()
  }

  static openMoodEditor(): void {
    AppStorage.setOrCreate('xdMoodOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeMoodEditor(): void {
    AppStorage.setOrCreate('xdMoodOpen', false)
    XdDetailNav.restore()
  }

  static openWishList(): void {
    AppStorage.setOrCreate('xdWishOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeWishList(): void {
    AppStorage.setOrCreate('xdWishOpen', false)
    XdDetailNav.restore()
  }

  static openTidyPanel(): void {
    AppStorage.setOrCreate('xdTidyOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeTidyPanel(): void {
    AppStorage.setOrCreate('xdTidyOpen', false)
    XdDetailNav.restore()
  }

  static openMemoryAlbum(): void {
    AppStorage.setOrCreate('xdMemoryOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeMemoryAlbum(): void {
    AppStorage.setOrCreate('xdMemoryOpen', false)
    XdDetailNav.restore()
  }

  static restore(): void {
    const wasHidden = AppStorage.get<boolean>('tabBarHidden') === true
    const entryId = AppStorage.get<string>('XdEntryId') ?? ''
    const clipId = AppStorage.get<string>('XdClipId') ?? ''
    const themeId = AppStorage.get<string>('XdThemeId') ?? ''
    const entryEd = AppStorage.get<boolean>('XdEntryEditorOpen') === true
    const clipEd = AppStorage.get<boolean>('XdClipEditorOpen') === true
    const themeEd = AppStorage.get<boolean>('XdThemeEditorOpen') === true
    const search = AppStorage.get<boolean>('xdSearchOpen') === true
    const year = AppStorage.get<boolean>('xdYearOpen') === true
    const mood = AppStorage.get<boolean>('xdMoodOpen') === true
    const wish = AppStorage.get<boolean>('xdWishOpen') === true
    const tidy = AppStorage.get<boolean>('xdTidyOpen') === true
    const memory = AppStorage.get<boolean>('xdMemoryOpen') === true
    const hidden = entryId.length > 0 || clipId.length > 0 || themeId.length > 0
      || entryEd || clipEd || themeEd || search || year || mood || wish || tidy || memory
    AppStorage.setOrCreate('tabBarHidden', hidden)
    if (wasHidden && !hidden) {
      XdStore.bump()
    }
  }
}
