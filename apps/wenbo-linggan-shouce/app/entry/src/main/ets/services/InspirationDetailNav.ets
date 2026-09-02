/** 全局详情导航 — MainTabPage 顶层 Overlay */
export class InspirationDetailNav {
  static openFeatured(id: string): void {
    InspirationDetailNav.navigateTo('featured', id)
  }

  static openInspiration(id: string): void {
    InspirationDetailNav.navigateTo('inspiration', id)
  }

  static openBoard(id: string): void {
    InspirationDetailNav.navigateTo('board', id)
  }

  static openPlan(id: string): void {
    InspirationDetailNav.navigateTo('plan', id)
  }

  static openTopic(id: string): void {
    InspirationDetailNav.navigateTo('topic', id)
  }

  /** 切换详情目标（灵感 ↔ 计划 ↔ 画板）时须递增 detailToken 以重建 Overlay */
  static navigateTo(kind: string, id: string): void {
    if (kind.length === 0 || id.length === 0) {
      return
    }
    AppStorage.setOrCreate('detailRoute', `${kind}:${id}`)
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
    return InspirationDetailNav.currentRoute().length > 0
  }

  static parseKind(): string {
    const route = InspirationDetailNav.currentRoute()
    const idx = route.indexOf(':')
    if (idx < 0) {
      return ''
    }
    return route.substring(0, idx)
  }

  static parseId(): string {
    const route = InspirationDetailNav.currentRoute()
    const idx = route.indexOf(':')
    if (idx < 0) {
      return ''
    }
    return route.substring(idx + 1)
  }
}
