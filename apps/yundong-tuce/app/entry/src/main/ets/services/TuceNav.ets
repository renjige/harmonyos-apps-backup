export class TuceNav {
  static open(route: string, id: string): void {
    AppStorage.setOrCreate('tuceRoute', route)
    AppStorage.setOrCreate('tuceRouteId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static close(): void {
    AppStorage.setOrCreate('tuceRoute', '')
    AppStorage.setOrCreate('tuceRouteId', '')
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static bump(): void {
    const n = AppStorage.get<number>('tuceReload') ?? 0
    AppStorage.setOrCreate('tuceReload', n + 1)
  }
}
