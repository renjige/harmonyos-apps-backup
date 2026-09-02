export class KitchenLabDetailNav {
  static open(kind: string, id: string): void {
    AppStorage.setOrCreate('kitchenRoute', `${kind}:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openBare(kind: string): void {
    AppStorage.setOrCreate('kitchenRoute', kind)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static close(): void {
    AppStorage.setOrCreate('kitchenRoute', '')
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static bump(): void {
    const n = AppStorage.get<number>('kitchenTick') ?? 0
    AppStorage.setOrCreate('kitchenTick', n + 1)
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
