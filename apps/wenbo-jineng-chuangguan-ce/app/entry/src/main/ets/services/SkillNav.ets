export class SkillNav {
  static readonly NONE: string = ''
  static readonly LEVEL: string = 'level'
  static readonly BADGE: string = 'badge'
  static readonly SUBMIT: string = 'submit'

  static setRoute(route: string): void {
    AppStorage.setOrCreate('skillRoute', route)
    AppStorage.setOrCreate('tabBarHidden', route.length > 0)
    SkillNav.bump()
  }

  static close(): void {
    SkillNav.setRoute(SkillNav.NONE)
  }

  static bump(): void {
    const n = AppStorage.get<number>('skillTick') ?? 0
    AppStorage.setOrCreate('skillTick', n + 1)
  }

  static openLevel(id: string): void {
    AppStorage.setOrCreate('detailId', id)
    SkillNav.setRoute(SkillNav.LEVEL)
  }

  static openBadge(id: string): void {
    AppStorage.setOrCreate('detailId', id)
    SkillNav.setRoute(SkillNav.BADGE)
  }

  static openSubmit(levelId: string): void {
    AppStorage.setOrCreate('submitLevelId', levelId)
    SkillNav.setRoute(SkillNav.SUBMIT)
  }

  static detailId(): string {
    return AppStorage.get<string>('detailId') ?? ''
  }

  static submitLevelId(): string {
    return AppStorage.get<string>('submitLevelId') ?? ''
  }
}
