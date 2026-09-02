import { SavedActionItem } from '../models/VitalityModels'
import { VitalityStore } from './VitalityStore'
import { DateHelper } from './DateHelper'
import { MicroAction } from '../models/VitalityModels'

export class ActionLibraryService {
  static builtinCatalog(): SavedActionItem[] {
    const defs: string[][] = [
      ['b1', '闭眼休息 3 分钟', '不刷手机，让精力回一点', 'restore'],
      ['b2', '喝一杯温水', '补水往往比再熬一会儿更有效', 'restore'],
      ['b3', '室内拉伸 5 分钟', '肩颈或腿后侧，动作放慢', 'move'],
      ['b4', '出门走 10 分钟', '不追求配速，走完即可', 'move'],
      ['b5', '写下今天已做成的一件事', '再小也算，对抗「一事无成」感', 'mind'],
      ['b6', '专注处理一件小事', '10 分钟即可，保持节奏', 'focus'],
      ['b7', '调暗屏幕休息双眼', '看远处 20 秒', 'restore'],
      ['b8', '站立活动 3 分钟', '离开椅子，活动脚踝与腰背', 'move'],
      ['b9', '整理桌面 5 分钟', '视觉清爽会带动心理清爽', 'focus'],
      ['b10', '深呼吸 4 轮', '吸 4 秒 · 屏 4 秒 · 呼 4 秒', 'restore'],
      ['b11', '给重要的人发一条消息', '轻量社交连接', 'mind'],
      ['b12', '提前准备明日第一事', '降低明天的启动成本', 'focus']
    ]
    const out: SavedActionItem[] = []
    for (const d of defs) {
      const a = new SavedActionItem()
      a.id = d[0]
      a.title = d[1]
      a.hint = d[2]
      a.category = d[3]
      a.source = 'builtin'
      a.usageCount = 0
      out.push(a)
    }
    return out
  }

  static categoryLabel(key: string): string {
    if (key === 'restore') {
      return '恢复'
    }
    if (key === 'move') {
      return '运动'
    }
    if (key === 'mind') {
      return '心绪'
    }
    return '专注'
  }

  static async addToToday(item: SavedActionItem): Promise<boolean> {
    const today = DateHelper.todayKey()
    const existing = await VitalityStore.actionsForDate(today)
    for (const e of existing) {
      if (e.title === item.title) {
        return false
      }
    }
    const a = new MicroAction()
    a.id = `${today}-lib-${Date.now()}`
    a.dateKey = today
    a.title = item.title
    a.hint = item.hint
    a.done = false
    existing.push(a)
    await VitalityStore.saveActionsForDate(today, existing)
    if (item.source === 'user') {
      await VitalityStore.bumpActionUsage(item.id)
    }
    return true
  }
}
