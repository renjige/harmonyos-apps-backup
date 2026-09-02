import { common } from '@kit.AbilityKit'

let appContext: common.UIAbilityContext | null = null

export class AppContextService {
  static setContext(ctx: common.UIAbilityContext): void {
    appContext = ctx
  }

  static getContext(): common.UIAbilityContext | null {
    return appContext
  }
}
