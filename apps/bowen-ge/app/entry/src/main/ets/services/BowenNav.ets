export class BowenNav {
  static openThought(id: string): void {
    BowenNav.clearDetails()
    AppStorage.setOrCreate('thoughtDetailId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openReading(id: string): void {
    BowenNav.clearDetails()
    AppStorage.setOrCreate('readingDetailId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openCard(id: string): void {
    BowenNav.clearDetails()
    AppStorage.setOrCreate('cardDetailId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openSpark(id: string): void {
    BowenNav.clearDetails()
    AppStorage.setOrCreate('sparkDetailId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openTheme(id: string): void {
    BowenNav.clearDetails()
    AppStorage.setOrCreate('themeDetailId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openStudy(id: string): void {
    BowenNav.clearDetails()
    AppStorage.setOrCreate('studyDetailId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openEditor(kind: string, id: string): void {
    AppStorage.setOrCreate('editorKind', kind)
    AppStorage.setOrCreate('editorId', id)
    AppStorage.setOrCreate('editorOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openSearch(): void {
    AppStorage.setOrCreate('searchOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeEditor(): void {
    AppStorage.setOrCreate('editorOpen', false)
    AppStorage.setOrCreate('editorKind', '')
    AppStorage.setOrCreate('editorId', '')
    BowenNav.restoreBar()
  }

  static closeSearch(): void {
    AppStorage.setOrCreate('searchOpen', false)
    BowenNav.restoreBar()
  }

  static closeDetails(): void {
    BowenNav.clearDetails()
    BowenNav.restoreBar()
  }

  static restoreBar(): void {
    const thoughtId = AppStorage.get<string>('thoughtDetailId') ?? ''
    const readingId = AppStorage.get<string>('readingDetailId') ?? ''
    const cardId = AppStorage.get<string>('cardDetailId') ?? ''
    const sparkId = AppStorage.get<string>('sparkDetailId') ?? ''
    const themeId = AppStorage.get<string>('themeDetailId') ?? ''
    const studyId = AppStorage.get<string>('studyDetailId') ?? ''
    const editorOpen = AppStorage.get<boolean>('editorOpen') === true
    const searchOpen = AppStorage.get<boolean>('searchOpen') === true
    const any = thoughtId.length > 0 || readingId.length > 0 || cardId.length > 0 ||
      sparkId.length > 0 || themeId.length > 0 || studyId.length > 0 || editorOpen || searchOpen
    AppStorage.setOrCreate('tabBarHidden', any)
  }

  private static clearDetails(): void {
    AppStorage.setOrCreate('thoughtDetailId', '')
    AppStorage.setOrCreate('readingDetailId', '')
    AppStorage.setOrCreate('cardDetailId', '')
    AppStorage.setOrCreate('sparkDetailId', '')
    AppStorage.setOrCreate('themeDetailId', '')
    AppStorage.setOrCreate('studyDetailId', '')
  }
}
