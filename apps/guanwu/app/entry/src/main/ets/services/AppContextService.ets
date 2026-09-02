import { common } from '@kit.AbilityKit'
import { window } from '@kit.ArkUI'

export class AppContextService {
  private static abilityContext: common.UIAbilityContext | null = null
  private static mainWindow: window.Window | null = null

  static setContext(context: common.UIAbilityContext): void {
    AppContextService.abilityContext = context
  }

  static getContext(): common.UIAbilityContext | null {
    return AppContextService.abilityContext
  }

  static setWindow(win: window.Window): void {
    AppContextService.mainWindow = win
  }

  static getWindow(): window.Window | null {
    return AppContextService.mainWindow
  }
}
