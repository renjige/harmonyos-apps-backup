import { RmStore } from './RmStore'

export class RmDetailNav {
  static openItem(id: string): void {
    AppStorage.setOrCreate('RmItemId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeItem(): void {
    AppStorage.setOrCreate('RmItemId', '')
    RmDetailNav.restore()
  }

  static openChecklist(id: string): void {
    AppStorage.setOrCreate('RmChecklistId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeChecklist(): void {
    AppStorage.setOrCreate('RmChecklistId', '')
    RmDetailNav.restore()
  }

  static openWish(id: string): void {
    AppStorage.setOrCreate('RmWishId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeWish(): void {
    AppStorage.setOrCreate('RmWishId', '')
    RmDetailNav.restore()
  }

  static openTheme(id: string): void {
    AppStorage.setOrCreate('RmThemeId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeTheme(): void {
    AppStorage.setOrCreate('RmThemeId', '')
    RmDetailNav.restore()
  }

  static openChecklistEditor(id: string, templateKey: string): void {
    AppStorage.setOrCreate('RmChecklistEditId', id)
    AppStorage.setOrCreate('RmChecklistTemplate', templateKey)
    AppStorage.setOrCreate('RmChecklistEditorOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeChecklistEditor(): void {
    AppStorage.setOrCreate('RmChecklistEditorOpen', false)
    AppStorage.setOrCreate('RmChecklistEditId', '')
    RmDetailNav.restore()
  }

  static openWishEditor(id: string): void {
    AppStorage.setOrCreate('RmWishEditId', id)
    AppStorage.setOrCreate('RmWishEditorOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeWishEditor(): void {
    AppStorage.setOrCreate('RmWishEditorOpen', false)
    AppStorage.setOrCreate('RmWishEditId', '')
    RmDetailNav.restore()
  }

  static openThemeEditor(id: string): void {
    AppStorage.setOrCreate('RmThemeEditId', id)
    AppStorage.setOrCreate('RmThemeEditorOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeThemeEditor(): void {
    AppStorage.setOrCreate('RmThemeEditorOpen', false)
    AppStorage.setOrCreate('RmThemeEditId', '')
    RmDetailNav.restore()
  }

  static openSearch(): void {
    AppStorage.setOrCreate('RmSearchOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeSearch(): void {
    AppStorage.setOrCreate('RmSearchOpen', false)
    RmDetailNav.restore()
  }

  static openYear(): void {
    AppStorage.setOrCreate('RmYearOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeYear(): void {
    AppStorage.setOrCreate('RmYearOpen', false)
    RmDetailNav.restore()
  }

  static restore(): void {
    const wasHidden = AppStorage.get<boolean>('tabBarHidden') === true
    const entryId = AppStorage.get<string>('RmChecklistId') ?? ''
    const clipId = AppStorage.get<string>('RmWishId') ?? ''
    const itemId = AppStorage.get<string>('RmItemId') ?? ''
    const themeId = AppStorage.get<string>('RmThemeId') ?? ''
    const entryEd = AppStorage.get<boolean>('RmChecklistEditorOpen') === true
    const clipEd = AppStorage.get<boolean>('RmWishEditorOpen') === true
    const themeEd = AppStorage.get<boolean>('RmThemeEditorOpen') === true
    const search = AppStorage.get<boolean>('RmSearchOpen') === true
    const year = AppStorage.get<boolean>('RmYearOpen') === true
    const hidden = entryId.length > 0 || clipId.length > 0 || itemId.length > 0 || themeId.length > 0
      || entryEd || clipEd || themeEd || search || year
    AppStorage.setOrCreate('tabBarHidden', hidden)
    if (wasHidden && !hidden) {
      RmStore.bump()
    }
  }
}
