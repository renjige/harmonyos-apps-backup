import { MoveItem } from '../models/TrainingModels'
import { PracticeService } from './PracticeService'
import { PracticeHubStore } from './PracticeHubStore'

export class MoveCatalog {
  static cloneZone(zone: string): MoveItem[] {
    const titles: string[] = []
    const purposes: string[] = []
    const combos: string[] = []
    const cautions: string[] = []
    if (zone === '热身') {
      titles.push('颈部绕环')
      purposes.push('唤醒颈椎与肩带')
      combos.push('可接肩部开合 + 扩胸')
      cautions.push('动作缓慢，避开疼痛角度')
      titles.push('踝关节画圈')
      purposes.push('活动下肢关节')
      combos.push('适合跑步或有氧前')
      cautions.push('单脚站稳再画圈')
    } else if (zone === '拉伸') {
      titles.push('腿后侧拉伸')
      purposes.push('缓解久坐紧绷')
      combos.push('可接髋部开合')
      cautions.push('膝盖微屈，不要弹振')
      titles.push('胸部开门拉伸')
      purposes.push('打开含胸')
      combos.push('训练后放松组合')
      cautions.push('肩胛下沉，呼吸放慢')
    } else if (zone === '力量') {
      titles.push('靠墙静蹲')
      purposes.push('下肢基础力量')
      combos.push('可接臀桥')
      cautions.push('膝盖不超过脚尖过多')
      titles.push('俯身支撑')
      purposes.push('核心稳定')
      combos.push('晨练组合第二项')
      cautions.push('腰背一条直线')
    } else if (zone === '平衡') {
      titles.push('单脚站立')
      purposes.push('踝稳定与专注')
      combos.push('热身后进行')
      cautions.push('靠近墙面保护')
      titles.push('足跟对足尖走')
      purposes.push('直线平衡')
      combos.push('放松日前的趣味练习')
      cautions.push('抬头看前方固定点')
    } else {
      titles.push('仰卧放松呼吸')
      purposes.push('训练后恢复')
      combos.push('拉伸后收尾')
      cautions.push('环境安静即可，无需设备')
      titles.push('肩颈放松滚')
      purposes.push('缓解肩颈僵硬')
      combos.push('晚间拉伸方案')
      cautions.push('力度轻柔')
    }
    const out: MoveItem[] = []
    let i = 0
    for (const title of titles) {
      const m = new MoveItem()
      m.id = PracticeService.newMoveId()
      m.title = title
      m.category = zone
      m.purpose = i < purposes.length ? purposes[i] : ''
      m.combo = i < combos.length ? combos[i] : ''
      m.tips = i < cautions.length ? cautions[i] : ''
      m.favorited = '0'
      m.createdAt = new Date().toISOString()
      out.push(m)
      i += 1
    }
    return out
  }

  static async importZone(zone: string): Promise<number> {
    const existing = PracticeHubStore.listMoves()
    const templates = MoveCatalog.cloneZone(zone)
    let added = 0
    for (const m of templates) {
      let hit = false
      for (const e of existing) {
        if (e.title === m.title) {
          hit = true
          break
        }
      }
      if (!hit) {
        await PracticeHubStore.saveMove(m)
        added += 1
      }
    }
    return added
  }
}
