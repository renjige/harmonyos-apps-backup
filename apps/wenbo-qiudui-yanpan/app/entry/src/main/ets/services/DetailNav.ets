/** 全局详情导航 — 栈式 Overlay，避免子页替换父页时 native 闪退 */
export class DetailNav {
  static openTeam(id: string): void {
    DetailNav.push('team', id)
  }

  static openMatch(id: string): void {
    DetailNav.push('match', id)
  }

  static openLeague(id: string): void {
    DetailNav.push('league', id)
  }

  static close(): void {
    const stack = DetailNav.readStack()
    if (stack.length > 0) {
      const prev = stack.pop() as string
      DetailNav.writeStack(stack)
      AppStorage.setOrCreate('detailRoute', prev)
      AppStorage.setOrCreate('tabBarHidden', true)
      DetailNav.bump()
      return
    }
    AppStorage.setOrCreate('detailRoute', '')
    AppStorage.setOrCreate('detailStack', '')
    AppStorage.setOrCreate('tabBarHidden', false)
    DetailNav.bump()
  }

  static reset(): void {
    AppStorage.setOrCreate('detailRoute', '')
    AppStorage.setOrCreate('detailStack', '')
    AppStorage.setOrCreate('tabBarHidden', false)
    DetailNav.bump()
  }

  static currentRoute(): string {
    const v = AppStorage.get<string>('detailRoute')
    return v !== undefined && v !== null ? v : ''
  }

  static isOpen(): boolean {
    return DetailNav.currentRoute().length > 0
  }

  static parseKind(): string {
    return DetailNav.kindOf(DetailNav.currentRoute())
  }

  static parseId(): string {
    return DetailNav.idOf(DetailNav.currentRoute())
  }

  static hasKind(kind: string): boolean {
    if (DetailNav.parseKind() === kind) {
      return true
    }
    const stack = DetailNav.readStack()
    for (const row of stack) {
      if (DetailNav.kindOf(row) === kind) {
        return true
      }
    }
    return false
  }

  static idForKind(kind: string): string {
    const cur = DetailNav.currentRoute()
    if (DetailNav.kindOf(cur) === kind) {
      return DetailNav.idOf(cur)
    }
    const stack = DetailNav.readStack()
    let i = stack.length - 1
    while (i >= 0) {
      if (DetailNav.kindOf(stack[i]) === kind) {
        return DetailNav.idOf(stack[i])
      }
      i -= 1
    }
    return ''
  }

  private static push(kind: string, id: string): void {
    const next = `${kind}:${id}`
    const cur = DetailNav.currentRoute()
    if (cur === next) {
      AppStorage.setOrCreate('tabBarHidden', true)
      return
    }
    if (cur.length > 0) {
      if (DetailNav.kindOf(cur) === kind) {
        AppStorage.setOrCreate('detailRoute', next)
        AppStorage.setOrCreate('tabBarHidden', true)
        DetailNav.bump()
        return
      }
      const stack = DetailNav.readStack()
      stack.push(cur)
      DetailNav.writeStack(stack)
    }
    AppStorage.setOrCreate('detailRoute', next)
    AppStorage.setOrCreate('tabBarHidden', true)
    DetailNav.bump()
  }

  private static bump(): void {
    const token = AppStorage.get<number>('detailToken') ?? 0
    AppStorage.setOrCreate('detailToken', token + 1)
  }

  private static kindOf(route: string): string {
    const idx = route.indexOf(':')
    if (idx < 0) {
      return ''
    }
    return route.substring(0, idx)
  }

  private static idOf(route: string): string {
    const idx = route.indexOf(':')
    if (idx < 0) {
      return ''
    }
    return route.substring(idx + 1)
  }

  private static readStack(): string[] {
    const raw = AppStorage.get<string>('detailStack')
    if (raw === undefined || raw === null || raw.length === 0) {
      return []
    }
    return raw.split('|')
  }

  private static writeStack(stack: string[]): void {
    let joined = ''
    for (let i = 0; i < stack.length; i++) {
      if (i > 0) {
        joined = `${joined}|`
      }
      joined = `${joined}${stack[i]}`
    }
    AppStorage.setOrCreate('detailStack', joined)
  }
}
