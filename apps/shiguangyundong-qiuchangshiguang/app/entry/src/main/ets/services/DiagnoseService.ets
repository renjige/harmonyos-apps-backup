import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'

/**
 * 智慧选场问卷 → 模板报告 + 场馆类型匹配（纯规则，不调用大模型）。
 */
export class DiagnoseService {
  static questions(): DiagnoseQuestion[] {
    return [
      DiagnoseQuestion.of('sport', '你最常参与的运动是？', [
        DiagnoseOption.of('badminton', '羽毛球'),
        DiagnoseOption.of('basketball', '篮球'),
        DiagnoseOption.of('tennis', '网球'),
        DiagnoseOption.of('football', '足球'),
        DiagnoseOption.of('tabletennis', '乒乓球')
      ]),
      DiagnoseQuestion.of('frequency', '你平均每周运动几次？', [
        DiagnoseOption.of('rare', '0–1 次'),
        DiagnoseOption.of('normal', '2–3 次'),
        DiagnoseOption.of('active', '4 次以上')
      ]),
      DiagnoseQuestion.of('time', '你更偏好的运动时段？', [
        DiagnoseOption.of('morning', '上午 / 清晨'),
        DiagnoseOption.of('afternoon', '下午'),
        DiagnoseOption.of('evening', '晚间 / 夜场')
      ]),
      DiagnoseQuestion.of('budget', '单次场地预算更接近？', [
        DiagnoseOption.of('low', '50 元以内'),
        DiagnoseOption.of('mid', '50–120 元'),
        DiagnoseOption.of('high', '120 元以上')
      ]),
      DiagnoseQuestion.of('distance', '你能接受的通勤距离？', [
        DiagnoseOption.of('near', '3 公里内'),
        DiagnoseOption.of('mid', '3–8 公里'),
        DiagnoseOption.of('far', '8 公里以上也可')
      ]),
      DiagnoseQuestion.of('need', '选场时你最看重？', [
        DiagnoseOption.of('price', '性价比 / 优惠'),
        DiagnoseOption.of('facility', '场地设施与灯光'),
        DiagnoseOption.of('crowd', '人流与氛围'),
        DiagnoseOption.of('service', '预约与服务响应')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const sport = DiagnoseService.optionId(answers, 'sport')
    const frequency = DiagnoseService.optionId(answers, 'frequency')
    const time = DiagnoseService.optionId(answers, 'time')
    const budget = DiagnoseService.optionId(answers, 'budget')
    const distance = DiagnoseService.optionId(answers, 'distance')
    const need = DiagnoseService.optionId(answers, 'need')

    const report = new DiagnoseReport()
    report.title = '智慧选场报告'
    report.generatedAt = DiagnoseService.nowLabel()
    report.summary =
      `基于问卷：运动「${DiagnoseService.labelOf(answers, 'sport')}」、` +
      `频率「${DiagnoseService.labelOf(answers, 'frequency')}」、` +
      `时段「${DiagnoseService.labelOf(answers, 'time')}」。` +
      `以下为规则模板建议，供选场参考，不构成价格承诺。`
    report.strength = DiagnoseService.strengthText(sport, frequency, time)
    report.weakness = DiagnoseService.weaknessText(frequency, budget, distance)
    report.opportunity = DiagnoseService.opportunityText(sport, need, time)
    report.threat = DiagnoseService.threatText(time, distance, budget)
    report.actions = DiagnoseService.actions(sport, need, budget)
    report.matchCategory = DiagnoseService.matchCategory(sport)
    report.matchHint =
      `建议优先筛选「${report.matchCategory}」类场馆，并按 ${DiagnoseService.labelOf(answers, 'time')} 时段预约。`
    report.scoreLabel = DiagnoseService.scoreLabel(frequency, need, distance)
    return report
  }

  private static optionId(answers: DiagnoseAnswer[], qid: string): string {
    for (let a of answers) {
      if (a.questionId === qid) {
        return a.optionId
      }
    }
    return ''
  }

  private static labelOf(answers: DiagnoseAnswer[], qid: string): string {
    for (let a of answers) {
      if (a.questionId === qid) {
        return a.optionLabel
      }
    }
    return '未填'
  }

  private static nowLabel(): string {
    const d = new Date()
    const y = d.getFullYear()
    const mo = d.getMonth() + 1
    const day = d.getDate()
    const moStr = mo < 10 ? `0${mo}` : `${mo}`
    const dayStr = day < 10 ? `0${day}` : `${day}`
    return `${y}-${moStr}-${dayStr}`
  }

  private static strengthText(sport: string, frequency: string, time: string): string {
    let s = '运动目标清晰，适合按固定节奏订场养成习惯。'
    if (frequency === 'active') {
      s = '运动频率较高，建议优先选择会员优惠或固定时段场馆。'
    } else if (frequency === 'rare') {
      s = '低频运动更需「低决策成本」的场馆，优先看近距离开订。'
    }
    if (time === 'evening') {
      s = `${s} 夜场偏好建议关注灯光与通风条件。`
    }
    if (sport === 'badminton' || sport === 'tabletennis') {
      s = `${s} 室内项目受天气影响小，预约成功率更高。`
    }
    return s
  }

  private static weaknessText(frequency: string, budget: string, distance: string): string {
    let w = '若未提前锁定时段，热门场馆可能出现满场。'
    if (frequency === 'active' && budget === 'low') {
      w = '高频运动 + 低预算组合，需更关注错峰与团购优惠。'
    }
    if (distance === 'near') {
      w = `${w} 3 公里内选择面较窄，建议扩大 1–2 个备选场馆。`
    }
    if (budget === 'high') {
      w = `${w} 高预算场馆建议提前 24 小时预约以确保时段。`
    }
    return w
  }

  private static opportunityText(sport: string, need: string, time: string): string {
    let o = '平台优惠活动可叠加时段选择，降低单次成本。'
    if (need === 'price') {
      o = '关注首页 Banner 与新客券，优先选标注「起」价且评分 4.7+ 的场馆。'
    } else if (need === 'facility') {
      o = '详情页查看场地说明与时长标签，优先选「2小时起」且预约量高的场馆。'
    } else if (need === 'crowd') {
      o = '工作日上午与深夜时段通常人流较低，体验更从容。'
    } else if (need === 'service') {
      o = '选择预约量高、评分稳定的场馆，确认响应更及时。'
    }
    if (time === 'morning') {
      o = `${o} 清晨时段竞争小，适合养成固定训练节奏。`
    }
    if (sport === 'football' || sport === 'basketball') {
      o = `${o} 团队项目可优先选支持多人预约的场地。`
    }
    return o
  }

  private static threatText(time: string, distance: string, budget: string): string {
    let t = '临时改期可能导致热门时段被占用。'
    if (time === 'evening') {
      t = '夜场黄金时段竞争激烈，建议提前预约。'
    }
    if (distance === 'far') {
      t = `${t} 远距离出行受交通影响，需预留到场缓冲时间。`
    }
    if (budget === 'low') {
      t = `${t} 低价时段可能设施较基础，需权衡预期。`
    }
    return t
  }

  private static actions(sport: string, need: string, budget: string): string[] {
    const list: string[] = []
    list.push('在「发现」页按推荐类型筛选，收藏 2–3 个备选场馆。')
    if (need === 'price' || budget === 'low') {
      list.push('查看优惠活动详情，优先使用限时折扣场馆。')
    } else {
      list.push('打开场馆详情，确认设施说明与可预约时长。')
    }
    list.push('选定日期与时段后提交预约，等待工作人员电话确认。')
    if (sport === 'basketball' || sport === 'football') {
      list.push('团队运动建议备注人数，便于场馆预留半场/全场。')
    } else {
      list.push('单打/双打项目可在备注中说明用场需求。')
    }
    list.push('预约成功后可在「拾光」页查看球迷记录与场地预约。')
    return list
  }

  private static matchCategory(sport: string): string {
    if (sport === 'badminton') {
      return '羽毛球'
    }
    if (sport === 'basketball') {
      return '篮球'
    }
    if (sport === 'tennis') {
      return '网球'
    }
    if (sport === 'football') {
      return '足球'
    }
    if (sport === 'tabletennis') {
      return '乒乓球'
    }
    return '综合'
  }

  private static scoreLabel(frequency: string, need: string, distance: string): string {
    let score = 72
    if (frequency === 'active') {
      score += 8
    } else if (frequency === 'rare') {
      score -= 6
    }
    if (need === 'service' || need === 'facility') {
      score += 4
    }
    if (distance === 'near') {
      score += 6
    } else if (distance === 'far') {
      score -= 5
    }
    if (score >= 80) {
      return '匹配度高'
    }
    if (score >= 65) {
      return '建议多对比'
    }
    return '需缩小范围'
  }
}
