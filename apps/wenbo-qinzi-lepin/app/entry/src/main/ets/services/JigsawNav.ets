export class JigsawNav {
  static readonly NONE: string = ''
  static readonly THEME: string = 'theme'
  static readonly DETAIL: string = 'detail'
  static readonly PLAY: string = 'play'
  static readonly GUIDE: string = 'guide'
  static readonly MEDALS: string = 'medals'
  static readonly MESSAGES: string = 'messages'
  static readonly DIAGNOSE: string = 'diagnose'

  static setRoute(route: string): void {
    AppStorage.setOrCreate('jigRoute', route)
    AppStorage.setOrCreate('tabBarHidden', route.length > 0)
    JigsawNav.bump()
  }

  static close(): void {
    const route = AppStorage.get<string>('jigRoute') ?? ''
    if (route === JigsawNav.PLAY) {
      JigsawNav.setRoute(JigsawNav.DETAIL)
      return
    }
    if (route === JigsawNav.DETAIL) {
      const fromFamily = AppStorage.get<boolean>('jigFromFamily') === true
      if (fromFamily) {
        AppStorage.setOrCreate('jigFromFamily', false)
        JigsawNav.setRoute(JigsawNav.NONE)
        return
      }
      JigsawNav.setRoute(JigsawNav.THEME)
      return
    }
    JigsawNav.setRoute(JigsawNav.NONE)
  }

  static bump(): void {
    const n = AppStorage.get<number>('jigTick') ?? 0
    AppStorage.setOrCreate('jigTick', n + 1)
  }

  static openTheme(theme: string): void {
    AppStorage.setOrCreate('jigTheme', theme)
    JigsawNav.setRoute(JigsawNav.THEME)
  }

  static openDetail(id: string, fromFamily: boolean): void {
    AppStorage.setOrCreate('jigId', id)
    AppStorage.setOrCreate('jigFromFamily', fromFamily)
    AppStorage.setOrCreate('jigCollab', fromFamily)
    JigsawNav.setRoute(JigsawNav.DETAIL)
  }

  static openPlay(id: string, pieces: number, collab: boolean): void {
    AppStorage.setOrCreate('jigId', id)
    AppStorage.setOrCreate('jigPieces', pieces)
    AppStorage.setOrCreate('jigCollab', collab)
    JigsawNav.setRoute(JigsawNav.PLAY)
  }

  static themeKey(): string {
    return AppStorage.get<string>('jigTheme') ?? 'animal'
  }

  static jigId(): string {
    return AppStorage.get<string>('jigId') ?? ''
  }

  static pieces(): number {
    const n = AppStorage.get<number>('jigPieces') ?? 4
    if (n === 9 || n === 16) {
      return n
    }
    return 4
  }

  static collab(): boolean {
    return AppStorage.get<boolean>('jigCollab') === true
  }
}
