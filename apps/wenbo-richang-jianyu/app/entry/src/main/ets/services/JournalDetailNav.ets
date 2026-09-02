/** 全局详情导航 — MainTabPage 顶层 Overlay */
export class JournalDetailNav {
  static openFeatured(id: string): void {
    AppStorage.setOrCreate('detailRoute', `featured:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    const token = AppStorage.get<number>('detailToken') ?? 0
    AppStorage.setOrCreate('detailToken', token + 1)
  }

  static openDiary(id: string): void {
    AppStorage.setOrCreate('detailRoute', `diary:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    const token = AppStorage.get<number>('detailToken') ?? 0
    AppStorage.setOrCreate('detailToken', token + 1)
  }

  static openAlbum(id: string): void {
    AppStorage.setOrCreate('detailRoute', `album:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    const token = AppStorage.get<number>('detailToken') ?? 0
    AppStorage.setOrCreate('detailToken', token + 1)
  }

  static close(): void {
    AppStorage.setOrCreate('detailRoute', '')
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  /** 笺语增删改后通知各 Tab 刷新列表（无需重启） */
  static notifyDiaryChanged(): void {
    const version = AppStorage.get<number>('diaryDataVersion') ?? 0
    AppStorage.setOrCreate('diaryDataVersion', version + 1)
  }

  static closeAfterDiaryChange(): void {
    JournalDetailNav.notifyDiaryChanged()
    JournalDetailNav.close()
  }

  static currentRoute(): string {
    const v = AppStorage.get<string>('detailRoute')
    return v !== undefined && v !== null ? v : ''
  }

  static isOpen(): boolean {
    return JournalDetailNav.currentRoute().length > 0
  }

  static parseKind(): string {
    const route = JournalDetailNav.currentRoute()
    const idx = route.indexOf(':')
    if (idx < 0) {
      return ''
    }
    return route.substring(0, idx)
  }

  static parseId(): string {
    const route = JournalDetailNav.currentRoute()
    const idx = route.indexOf(':')
    if (idx < 0) {
      return ''
    }
    return route.substring(idx + 1)
  }
}
