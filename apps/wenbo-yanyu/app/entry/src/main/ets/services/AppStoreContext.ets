import { common } from '@kit.AbilityKit'

/** 保存 Ability Context，供 Preferences 在 init 竞态时二次恢复 */
export class AppStoreContext {
  private static ctx: common.Context | null = null

  static bind(context: common.Context): void {
    AppStoreContext.ctx = context
  }

  static get(): common.Context | null {
    return AppStoreContext.ctx
  }
}
