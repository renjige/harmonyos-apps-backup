import { common } from '@kit.AbilityKit'
import { AppStoreContext } from './AppStoreContext'
import { LocalRecordStore } from './LocalRecordStore'
import { FavoriteStore } from './FavoriteStore'
import { ResearchStore } from './ResearchStore'
import { HubStore } from './HubStore'

/** 确保本机 Preferences 全部就绪（Mine / 成长统计用） */
export class AppStores {
  static async warmUp(): Promise<boolean> {
    const ctx: common.Context | null = AppStoreContext.get()
    if (ctx === null) {
      return false
    }
    try {
      await LocalRecordStore.init(ctx)
      await FavoriteStore.init(ctx)
      await ResearchStore.init(ctx)
      await HubStore.init(ctx)
      AppStorage.setOrCreate('storesReady', true)
      return true
    } catch {
      return false
    }
  }
}
