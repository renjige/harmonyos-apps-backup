export class PuzzleNav {
  static openCreate(): void {
    AppStorage.setOrCreate('tabBarHidden', true)
    AppStorage.setOrCreate('puzzleShowCreate', true)
    AppStorage.setOrCreate('puzzleEditId', '')
  }

  static openEdit(id: string): void {
    AppStorage.setOrCreate('tabBarHidden', true)
    AppStorage.setOrCreate('puzzleShowCreate', true)
    AppStorage.setOrCreate('puzzleEditId', id)
  }

  static closeCreate(): void {
    AppStorage.setOrCreate('puzzleShowCreate', false)
    AppStorage.setOrCreate('puzzleEditId', '')
    PuzzleNav.restoreBar()
  }

  static openDetail(id: string): void {
    AppStorage.setOrCreate('tabBarHidden', true)
    AppStorage.setOrCreate('puzzleShowDetail', true)
    AppStorage.setOrCreate('puzzleDetailId', id)
  }

  static closeDetail(): void {
    AppStorage.setOrCreate('puzzleShowDetail', false)
    AppStorage.setOrCreate('puzzleDetailId', '')
    PuzzleNav.restoreBar()
  }

  static restoreBar(): void {
    const mineOpen = AppStorage.get<boolean>('puzzleMinePanel') === true
    const createOpen = AppStorage.get<boolean>('puzzleShowCreate') === true
    const detailOpen = AppStorage.get<boolean>('puzzleShowDetail') === true
    if (!mineOpen && !createOpen && !detailOpen) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }
}
