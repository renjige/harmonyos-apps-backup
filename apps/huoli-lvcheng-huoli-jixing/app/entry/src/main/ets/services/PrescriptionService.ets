import { MicroAction, VitalityRecord } from '../models/VitalityModels'
import { VitalityStore } from './VitalityStore'

/**
 * 规则处方：按当日三维组合给出可完成的微行动（非生成式对话）。
 */
export class PrescriptionService {
  static build(record: VitalityRecord): MicroAction[] {
    const titles: string[] = []
    const hints: string[] = []
    PrescriptionService.pushIf(record.energyKey === 'low', titles, hints,
      '闭眼休息 3 分钟', '不刷手机，让精力回一点')
    PrescriptionService.pushIf(record.energyKey === 'low' || record.moodKey === 'tired', titles, hints,
      '喝一杯温水', '补水往往比再熬一会儿更有效')
    PrescriptionService.pushIf(record.exerciseKey === 'easy', titles, hints,
      '室内拉伸 5 分钟', '肩颈或腿后侧，动作放慢')
    PrescriptionService.pushIf(record.exerciseKey === 'moderate', titles, hints,
      '出门走 10 分钟', '不追求配速，走完即可')
    PrescriptionService.pushIf(record.exerciseKey === 'full', titles, hints,
      '拉伸放松 5 分钟', '避免第二天僵硬，把充足运动收个尾')
    PrescriptionService.pushIf(record.moodKey === 'tired', titles, hints,
      '写下今天已做成的一件事', '再小也算，用来对抗「一事无成」感')
    PrescriptionService.pushIf(record.moodKey === 'calm', titles, hints,
      '专注处理一件小事', '10 分钟即可，保持节奏')
    PrescriptionService.pushIf(record.moodKey === 'happy', titles, hints,
      '把亮点写进备注或设为高光日', '愉悦值得被以后的自己看见')
    PrescriptionService.pushIf(record.energyKey === 'high', titles, hints,
      '清掉一件拖延小事', '趁精力在，闭环比新开任务更值')
    PrescriptionService.pushIf(record.energyKey === 'normal', titles, hints,
      '调暗屏幕休息双眼', '20-20-20：看远处 20 秒')

    if (titles.length < 3) {
      PrescriptionService.pushIf(true, titles, hints, '提前 15 分钟准备入睡', '为明天的精力留空间')
      PrescriptionService.pushIf(true, titles, hints, '站立活动 3 分钟', '离开椅子，活动脚踝与腰背')
    }

    const out: MicroAction[] = []
    const max = titles.length < 3 ? titles.length : 3
    for (let i = 0; i < max; i++) {
      const a = new MicroAction()
      a.id = `${record.dateKey}-a${i}`
      a.dateKey = record.dateKey
      a.title = titles[i]
      a.hint = hints[i]
      a.done = false
      out.push(a)
    }
    return out
  }

  static async ensureFor(record: VitalityRecord): Promise<MicroAction[]> {
    const existing = await VitalityStore.actionsForDate(record.dateKey)
    if (existing.length > 0) {
      return existing
    }
    const built = PrescriptionService.build(record)
    await VitalityStore.saveActionsForDate(record.dateKey, built)
    return built
  }

  private static pushIf(cond: boolean, titles: string[], hints: string[], title: string, hint: string): void {
    if (!cond) {
      return
    }
    for (const t of titles) {
      if (t === title) {
        return
      }
    }
    titles.push(title)
    hints.push(hint)
  }
}
