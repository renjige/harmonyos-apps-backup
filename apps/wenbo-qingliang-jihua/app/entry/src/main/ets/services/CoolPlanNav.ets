/** 全局详情 / 二级页导航 — MainTabPage 顶层 Overlay */

export class CoolPlanNav {
  static openQuote(id: string): void {
    const current = CoolPlanNav.currentRoute()
    if (current === 'quote-list') {
      AppStorage.setOrCreate('detailRouteParent', 'quote-list')
    } else {
      AppStorage.setOrCreate('detailRouteParent', '')
    }
    CoolPlanNav.setRoute(`quote:${id}`)
  }

  static openBreathMode(id: string): void {
    CoolPlanNav.setRoute(`breath:${id}`)
  }

  static openMessages(): void {
    CoolPlanNav.setRoute('messages')
  }

  static openQuoteList(): void {
    CoolPlanNav.setRoute('quote-list')
  }

  static switchTabBreath(): void {
    AppStorage.setOrCreate('switchTabIndex', 1)
  }

  /** 关闭全部详情层并切到呼吸 Tab（语录详情 CTA 用） */
  static switchTabBreathFromOverlay(): void {
    AppStorage.setOrCreate('detailRouteParent', '')
    AppStorage.setOrCreate('detailRoute', '')
    AppStorage.setOrCreate('tabBarHidden', false)
    AppStorage.setOrCreate('switchTabIndex', 1)
  }

  static switchTabRecord(): void {
    AppStorage.setOrCreate('switchTabIndex', 2)
  }

  static kind(): string {
    const r = CoolPlanNav.currentRoute()
    const idx = r.indexOf(':')
    if (idx < 0) {
      return r
    }
    return r.substring(0, idx)
  }

  static parseId(): string {
    const r = CoolPlanNav.currentRoute()
    const idx = r.indexOf(':')
    if (idx < 0) {
      return ''
    }
    return r.substring(idx + 1)
  }

  static close(): void {
    const parent = AppStorage.get<string>('detailRouteParent') ?? ''
    if (parent.length > 0) {
      AppStorage.setOrCreate('detailRouteParent', '')
      AppStorage.setOrCreate('detailRoute', parent)
      AppStorage.setOrCreate('tabBarHidden', true)
      const token = AppStorage.get<number>('detailToken') ?? 0
      AppStorage.setOrCreate('detailToken', token + 1)
      return
    }
    AppStorage.setOrCreate('detailRoute', '')
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  static currentRoute(): string {
    const v = AppStorage.get<string>('detailRoute')
    return v !== undefined && v !== null ? v : ''
  }

  private static setRoute(value: string): void {
    AppStorage.setOrCreate('detailRoute', value)
    AppStorage.setOrCreate('tabBarHidden', true)
    const token = AppStorage.get<number>('detailToken') ?? 0
    AppStorage.setOrCreate('detailToken', token + 1)
  }
}
