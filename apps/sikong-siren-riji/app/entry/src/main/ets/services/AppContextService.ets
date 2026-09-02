import { common } from '@kit.AbilityKit'

export class AppContextService {
  private static abilityContext: common.UIAbilityContext | null = null

  static setContext(context: common.UIAbilityContext): void {
    AppContextService.abilityContext = context
  }

  static getContext(): common.UIAbilityContext | null {
    return AppContextService.abilityContext
  }
}
