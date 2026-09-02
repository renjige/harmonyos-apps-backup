/** 全局 Overlay 路由 */

export class AskNav {
  static openDetail(kind: string, id: string): void {
    AppStorage.setOrCreate('detailRoute', `${kind}:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeDetail(): void {
    AppStorage.setOrCreate('detailRoute', '')
    if (!AskNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static openMessages(): void {
    AppStorage.setOrCreate('showMessages', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeMessages(): void {
    AppStorage.setOrCreate('showMessages', false)
    if (!AskNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static openDiagnose(): void {
    AppStorage.setOrCreate('showDiagnose', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeDiagnose(): void {
    AppStorage.setOrCreate('showDiagnose', false)
    if (!AskNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static openNote(id: string): void {
    AppStorage.setOrCreate('noteEditId', id)
    AppStorage.setOrCreate('showNoteEdit', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static closeNote(): void {
    AppStorage.setOrCreate('showNoteEdit', false)
    AppStorage.setOrCreate('noteEditId', '')
    if (!AskNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static openLearn(panel: string): void {
    AppStorage.setOrCreate('learnPanel', panel)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openChallenge(total: number): void {
    AppStorage.setOrCreate('challengeTotal', total)
    AskNav.openLearn('challenge')
  }

  static openPath(pathId: string): void {
    AskNav.openDetail('path', pathId)
  }

  static closeLearn(): void {
    AppStorage.setOrCreate('learnPanel', '')
    if (!AskNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  static keepTabHidden(): boolean {
    const route = AppStorage.get<string>('detailRoute') ?? ''
    const panel = AppStorage.get<string>('learnPanel') ?? ''
    return route.length > 0 ||
      panel.length > 0 ||
      AppStorage.get<boolean>('showMessages') === true ||
      AppStorage.get<boolean>('showDiagnose') === true ||
      AppStorage.get<boolean>('showNoteEdit') === true ||
      AppStorage.get<boolean>('showAbout') === true
  }

  static parseKind(): string {
    const route = AppStorage.get<string>('detailRoute') ?? ''
    const idx = route.indexOf(':')
    if (idx < 0) {
      return ''
    }
    return route.substring(0, idx)
  }

  static parseId(): string {
    const route = AppStorage.get<string>('detailRoute') ?? ''
    const idx = route.indexOf(':')
    if (idx < 0) {
      return ''
    }
    return route.substring(idx + 1)
  }

  static switchTab(index: number): void {
    AppStorage.setOrCreate('mainTabIndex', index)
  }

  static bumpRefresh(): void {
    const n = AppStorage.get<number>('vaultRefresh') ?? 0
    AppStorage.setOrCreate('vaultRefresh', n + 1)
  }
}
