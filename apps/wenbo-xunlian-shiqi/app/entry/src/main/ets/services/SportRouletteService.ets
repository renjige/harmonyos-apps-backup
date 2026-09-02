import { PlayPick } from '../models/PlayModels'

/** 「今天玩什么」随机玩法 — 非计划/非单纯记录 */
export class SportRouletteService {
  static pool(): PlayPick[] {
    const items: PlayPick[] = []
    const defs: string[] = [
      'follow|跟练一组动作|从图鉴选动作逐步计时跟练',
      'breath|呼吸放松 3 分钟|4-7-8 节奏引导，练后更舒缓',
      'discover|图鉴探索日|浏览五专区并收藏喜欢的动作',
      'challenge|挑战打卡|加入 7 天习惯挑战并查看进度',
      'card|写运动笔记|记录心得、技巧或今日感受',
      'goal|设定小目标|为本阶段设次数或分钟目标',
      'check|训练清单日|勾选热身与拉伸清单',
      'recap|周复盘问答|用问卷回顾本周运动状态',
      'growth|查看成长报告|月度统计、热力日历与徽章',
      'record|自由运动记录|按心情记一次运动（非计划模板）'
    ]
    for (const line of defs) {
      const parts = line.split('|')
      if (parts.length < 3) {
        continue
      }
      const p = new PlayPick()
      p.id = parts[0]
      p.action = parts[0]
      p.title = parts[1]
      p.hint = parts[2]
      items.push(p)
    }
    return items
  }

  static spin(): PlayPick {
    const pool = SportRouletteService.pool()
    const idx = Math.floor(Math.random() * pool.length)
    return pool[idx] ?? pool[0]
  }
}
