export class BrochureDetailNav {
  static openBrochure(id: string): void {
    AppStorage.setOrCreate('brochureRoute', `brochure:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    BrochureDetailNav.bump()
  }

  static openArticle(id: string): void {
    AppStorage.setOrCreate('brochureRoute', `article:${id}`)
    AppStorage.setOrCreate('tabBarHidden', true)
    BrochureDetailNav.bump()
  }

  static close(): void {
    AppStorage.setOrCreate('brochureRoute', '')
    AppStorage.setOrCreate('tabBarHidden', false)
    BrochureDetailNav.bump()
  }

  static bump(): void {
    const n = AppStorage.get<number>('brochureTick') ?? 0
    AppStorage.setOrCreate('brochureTick', n + 1)
  }

  static switchTab(index: number): void {
    AppStorage.setOrCreate('mainTab', index)
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
