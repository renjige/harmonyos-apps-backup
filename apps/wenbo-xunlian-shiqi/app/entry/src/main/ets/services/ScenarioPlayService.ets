/** 按生活场景编排的一键玩法 — 非计划/非单纯记日志 */
export class ScenarioItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  actionHint: string = ''
}

export class ScenarioPlayService {
  static list(): ScenarioItem[] {
    const out: ScenarioItem[] = []
    const s1 = new ScenarioItem()
    s1.id = 'morning'
    s1.title = '晨起唤醒'
    s1.subtitle = '复制热身动作并跟练'
    s1.actionHint = '适合工作日清晨 5～8 分钟'
    out.push(s1)
    const s2 = new ScenarioItem()
    s2.id = 'desk'
    s2.title = '工间拉伸'
    s2.subtitle = '复制拉伸动作并跟练'
    s2.actionHint = '久坐后放松肩背'
    out.push(s2)
    const s3 = new ScenarioItem()
    s3.id = 'evening'
    s3.title = '晚间放松'
    s3.subtitle = '4-7-8 呼吸引导'
    s3.actionHint = '训练后或睡前'
    out.push(s3)
    const s4 = new ScenarioItem()
    s4.id = 'weekend'
    s4.title = '周末探索'
    s4.subtitle = '力量专区 + 图鉴收藏'
    s4.actionHint = '发现新动作组合'
    out.push(s4)
    const s5 = new ScenarioItem()
    s5.id = 'habit'
    s5.title = '习惯挑战'
    s5.subtitle = '加入 7 天趣味挑战'
    s5.actionHint = '游戏化坚持'
    out.push(s5)
    const s6 = new ScenarioItem()
    s6.id = 'journal'
    s6.title = '运动随想'
    s6.subtitle = '写心得与小技巧'
    s6.actionHint = '记录感悟而非打卡'
    out.push(s6)
    return out
  }
}
