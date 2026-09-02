export class PoetryNav {
  static readonly NONE: string = ''
  static readonly POEM: string = 'poem'
  static readonly PLACE: string = 'place'
  static readonly HUNT: string = 'hunt'
  static readonly MATCH: string = 'match'
  static readonly MESSAGES: string = 'messages'
  static readonly NOTES: string = 'notes'
  static readonly FAVS: string = 'favs'
  static readonly MEDALS: string = 'medals'
  static readonly RECORDS: string = 'records'

  static route(): string {
    return AppStorage.get<string>('poetryRoute') ?? PoetryNav.NONE
  }

  static setRoute(route: string): void {
    AppStorage.setOrCreate('poetryRoute', route)
    AppStorage.setOrCreate('tabBarHidden', route.length > 0)
    PoetryNav.bump()
  }

  static close(): void {
    PoetryNav.setRoute(PoetryNav.NONE)
  }

  static bump(): void {
    const n = AppStorage.get<number>('poetryTick') ?? 0
    AppStorage.setOrCreate('poetryTick', n + 1)
  }

  static openPoem(id: string): void {
    AppStorage.setOrCreate('poetryFocusId', id)
    PoetryNav.setRoute(PoetryNav.POEM)
  }

  static openPlace(id: string): void {
    AppStorage.setOrCreate('poetryFocusId', id)
    PoetryNav.setRoute(PoetryNav.PLACE)
  }

  static openHunt(levelId: string): void {
    AppStorage.setOrCreate('huntLevelId', levelId)
    AppStorage.setOrCreate('huntIndex', 0)
    AppStorage.setOrCreate('huntSelected', -1)
    AppStorage.setOrCreate('huntPhase', 'answering')
    PoetryNav.setRoute(PoetryNav.HUNT)
  }

  static focusId(): string {
    return AppStorage.get<string>('poetryFocusId') ?? ''
  }
}
