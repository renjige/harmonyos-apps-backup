import { common } from '@kit.AbilityKit'

export class AppContextService {
  private static ctx: common.UIAbilityContext | null = null

  static setContext(context: common.UIAbilityContext): void {
    AppContextService.ctx = context
  }

  static getContext(): common.UIAbilityContext | null {
    return AppContextService.ctx
  }
}
