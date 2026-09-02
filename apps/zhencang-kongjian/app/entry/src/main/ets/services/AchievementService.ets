import { AchievementDef, TreasureAlbum, CollectionPlan, TreasureItem } from '../models/TreasureModels'
import { TreasureStore } from './TreasureStore'

export class AchievementService {
  static catalog(): AchievementDef[] {
    const defs: AchievementDef[] = []
    const rows: string[][] = [
      ['first_item', '初入藏间', '建立第一件珍藏'],
      ['items_10', '珍藏新秀', '累计 10 件珍藏'],
      ['items_50', '整理达人', '累计 50 件珍藏'],
      ['items_100', '百件珍藏', '累计 100 件珍藏'],
      ['albums_5', '主题收藏家', '创建 5 个主题册'],
      ['plan_done', '年度收藏家', '完成一项收藏计划']
    ]
    for (const row of rows) {
      const d = new AchievementDef()
      d.id = row[0]
      d.title = row[1]
      d.subtitle = row[2]
      defs.push(d)
    }
    return defs
  }

  static evaluate(): string[] {
    const unlocked: string[] = []
    const items = TreasureStore.activeItems()
    const albums = TreasureStore.albums()
    const plans = TreasureStore.plans()
    if (items.length >= 1) {
      unlocked.push('first_item')
    }
    if (items.length >= 10) {
      unlocked.push('items_10')
    }
    if (items.length >= 50) {
      unlocked.push('items_50')
    }
    if (items.length >= 100) {
      unlocked.push('items_100')
    }
    if (albums.length >= 5) {
      unlocked.push('albums_5')
    }
    for (const p of plans) {
      if (p.completedAt > 0 || TreasureStore.planProgress(p) >= 100) {
        unlocked.push('plan_done')
        break
      }
    }
    return unlocked
  }

  static async syncUnlocks(): Promise<void> {
    const next = AchievementService.evaluate()
    const s = TreasureStore.settings()
    s.achievementsUnlocked = next
    await TreasureStore.saveSettings(s)
  }
}
