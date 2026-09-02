export class KagNav {
  static open(kind: string, id: string): void {
    AppStorage.setOrCreate('kagRoute', `${kind}:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openBare(kind: string): void {
    AppStorage.setOrCreate('kagRoute', kind)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static close(): void {
    AppStorage.setOrCreate('kagRoute', '')
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static bump(): void {
    const n = AppStorage.get<number>('kagTick') ?? 0
    AppStorage.setOrCreate('kagTick', n + 1)
  }

  static kindOf(route: string): string {
    const i = route.indexOf(':')
    if (i < 0) {
      return route
    }
    return route.substring(0, i)
  }

  static idOf(route: string): string {
    const i = route.indexOf(':')
    if (i < 0) {
      return ''
    }
    return route.substring(i + 1)
  }
}
