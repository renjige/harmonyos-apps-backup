/** 全局详情 / 二级 Overlay 路由 */
export class CourtyardDetailNav {
  static openPoem(id: string): void {
    CourtyardDetailNav.open(`poem:${id}`)
  }

  static openCipai(id: string): void {
    CourtyardDetailNav.open(`cipai:${id}`)
  }

  static openRhyme(id: string): void {
    CourtyardDetailNav.open(`rhyme:${id}`)
  }

  static openArticle(id: string): void {
    CourtyardDetailNav.open(`article:${id}`)
  }

  static openWork(id: string): void {
    CourtyardDetailNav.open(`work:${id}`)
  }

  static openFavorites(): void {
    CourtyardDetailNav.open('list:favorites')
  }

  static openWorks(): void {
    CourtyardDetailNav.open('list:works')
  }

  static openProgress(): void {
    CourtyardDetailNav.open('list:progress')
  }

  static openMeterWithText(text: string): void {
    AppStorage.setOrCreate('meterDraft', text)
    AppStorage.setOrCreate('switchTab', 1)
    CourtyardDetailNav.close()
  }

  static open(route: string): void {
    AppStorage.setOrCreate('detailRoute', route)
    AppStorage.setOrCreate('tabBarHidden', true)
    const token = AppStorage.get<number>('detailToken') ?? 0
    AppStorage.setOrCreate('detailToken', token + 1)
  }

  static close(): void {
    AppStorage.setOrCreate('detailRoute', '')
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static currentRoute(): string {
    const v = AppStorage.get<string>('detailRoute')
    return v !== undefined && v !== null ? v : ''
  }

  static isOpen(): boolean {
    return CourtyardDetailNav.currentRoute().length > 0
  }

  static parseKind(): string {
    const route = CourtyardDetailNav.currentRoute()
    const idx = route.indexOf(':')
    if (idx < 0) {
      return ''
    }
    return route.substring(0, idx)
  }

  static parseId(): string {
    const route = CourtyardDetailNav.currentRoute()
    const idx = route.indexOf(':')
    if (idx < 0) {
      return ''
    }
    return route.substring(idx + 1)
  }
}
