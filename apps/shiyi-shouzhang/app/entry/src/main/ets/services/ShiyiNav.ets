export class ShiyiNav {
  static openCompose(id: string, date: string): void {
    AppStorage.setOrCreate('shiyiComposeId', id)
    AppStorage.setOrCreate('shiyiComposeDate', date)
    AppStorage.setOrCreate('shiyiShowCompose', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openDetail(id: string): void {
    AppStorage.setOrCreate('shiyiDetailId', id)
    AppStorage.setOrCreate('shiyiShowDetail', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openPickup(): void {
    AppStorage.setOrCreate('shiyiShowPickup', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openTags(): void {
    AppStorage.setOrCreate('shiyiShowTags', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static restoreBar(): void {
    const compose = AppStorage.get<boolean>('shiyiShowCompose') === true
    const detail = AppStorage.get<boolean>('shiyiShowDetail') === true
    const pickup = AppStorage.get<boolean>('shiyiShowPickup') === true
    const tags = AppStorage.get<boolean>('shiyiShowTags') === true
    const minePanel = AppStorage.get<boolean>('shiyiMinePanel') === true
    AppStorage.setOrCreate('tabBarHidden', compose || detail || pickup || tags || minePanel)
  }

  static closeCompose(): void {
    AppStorage.setOrCreate('shiyiShowCompose', false)
    AppStorage.setOrCreate('shiyiComposeId', '')
    ShiyiNav.restoreBar()
  }

  static closeDetail(): void {
    AppStorage.setOrCreate('shiyiShowDetail', false)
    AppStorage.setOrCreate('shiyiDetailId', '')
    ShiyiNav.restoreBar()
  }

  static closePickup(): void {
    AppStorage.setOrCreate('shiyiShowPickup', false)
    ShiyiNav.restoreBar()
  }

  static closeTags(): void {
    AppStorage.setOrCreate('shiyiShowTags', false)
    ShiyiNav.restoreBar()
  }
}
