import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'

/**
 * 问卷 → SWOT 模板报告 + 服务匹配（纯规则，不调用大模型）。
 */
export class DiagnoseService {
  static questions(): DiagnoseQuestion[] {
    return [
      DiagnoseQuestion.of('stage', '你更想先练哪一块？', [
        DiagnoseOption.of('startup', '记忆宫殿'),
        DiagnoseOption.of('growth', '数独挑战'),
        DiagnoseOption.of('mature', '色彩干扰'),
        DiagnoseOption.of('transform', '速算冲刺')
      ]),
      DiagnoseQuestion.of('industry', '今天能拿出多久？', [
        DiagnoseOption.of('manufacturing', '三分钟以内'),
        DiagnoseOption.of('retail', '五到十分钟'),
        DiagnoseOption.of('tech', '十五分钟'),
        DiagnoseOption.of('service', '想做完全日五项'),
        DiagnoseOption.of('other', '还没想好')
      ]),
      DiagnoseQuestion.of('need', '当前最容易分心的是？', [
        DiagnoseOption.of('strategy', '信息流打断'),
        DiagnoseOption.of('brand', '想同时做几件事'),
        DiagnoseOption.of('digital', '题目稍难就放弃'),
        DiagnoseOption.of('finance', '晚上太困'),
        DiagnoseOption.of('project', '没什么特别')
      ]),
      DiagnoseQuestion.of('team', '最近睡眠感觉？', [
        DiagnoseOption.of('s', '还行'),
        DiagnoseOption.of('m', '有点碎'),
        DiagnoseOption.of('l', '明显不足')
      ]),
      DiagnoseQuestion.of('revenue', '连续训练习惯？', [
        DiagnoseOption.of('pressure', '经常中断'),
        DiagnoseOption.of('flat', '偶尔坚持'),
        DiagnoseOption.of('up', '已经连了好几天')
      ]),
      DiagnoseQuestion.of('risk', '最想看到的变化？', [
        DiagnoseOption.of('cash', '记得住更多东西'),
        DiagnoseOption.of('acquire', '更能抗干扰'),
        DiagnoseOption.of('compliance', '心算更快'),
        DiagnoseOption.of('org', '推理更稳'),
        DiagnoseOption.of('tech', '只想养成打开习惯')
      ]),
      DiagnoseQuestion.of('digital', '数字化程度？', [
        DiagnoseOption.of('low', '工具分散 / 手工多'),
        DiagnoseOption.of('mid', '有系统但未打通'),
        DiagnoseOption.of('high', '数据驱动较成熟')
      ]),
      DiagnoseQuestion.of('next', '希望下一步？', [
        DiagnoseOption.of('report', '先看诊断报告'),
        DiagnoseOption.of('book', '预约顾问面谈'),
        DiagnoseOption.of('policy', '了解政策申报')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const stage = DiagnoseService.optionId(answers, 'stage')
    const industry = DiagnoseService.optionId(answers, 'industry')
    const need = DiagnoseService.optionId(answers, 'need')
    const team = DiagnoseService.optionId(answers, 'team')
    const revenue = DiagnoseService.optionId(answers, 'revenue')
    const risk = DiagnoseService.optionId(answers, 'risk')
    const digital = DiagnoseService.optionId(answers, 'digital')
    const next = DiagnoseService.optionId(answers, 'next')

    const report = new DiagnoseReport()
    report.generatedAt = DiagnoseService.nowLabel()
    report.summary =
      `基于问卷：想练「${DiagnoseService.labelOf(answers, 'stage')}」、` +
      `时长「${DiagnoseService.labelOf(answers, 'industry')}」、` +
      `分心点「${DiagnoseService.labelOf(answers, 'need')}」。` +
      `以下是规则模板建议，用于安排今日训练，不是医疗诊断，也不承诺提高智商。`
    report.strength = DiagnoseService.strengthText(stage, team, revenue, digital)
    report.weakness = DiagnoseService.weaknessText(revenue, risk, digital)
    report.opportunity = DiagnoseService.opportunityText(need, industry, next)
    report.threat = DiagnoseService.threatText(risk, revenue)
    report.actions = DiagnoseService.actions(need, risk, next)
    report.matchCategory = DiagnoseService.matchCategory(need)
    report.matchHint =
      `建议先打开「${report.matchCategory}」，做完一局再决定要不要加练。`
    report.scoreLabel = DiagnoseService.scoreLabel(revenue, risk, digital)
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

  private static strengthText(stage: string, team: string, revenue: string, digital: string): string {
    let s = '你已经愿意打开应用做一次选择，这是探索的起点。'
    if (stage === 'growth' || stage === 'mature') {
      s = '你选了逻辑或专注类项目，适合用短局建立节奏。'
    }
    if (team === 's') {
      s = `${s} 睡眠尚可，可以做完一项再停。`
    }
    if (revenue === 'up') {
      s = `${s} 连续习惯已经在路上，保住最低一项即可。`
    }
    if (digital === 'high') {
      s = `${s} 你倾向先看建议再行动，今天就按匹配项开练。`
    }
    return s
  }

  private static weaknessText(revenue: string, risk: string, digital: string): string {
    let w = '关键约束尚未完全显性化，需用指标与流程固化。'
    if (revenue === 'pressure') {
      w = '营收承压，成本与现金流管理需优先排期。'
    }
    if (risk === 'cash') {
      w = `${w} 现金流敏感度高，应建立滚动预测与回款机制。`
    } else if (risk === 'acquire') {
      w = `${w} 获客与转化链路可能存在断层。`
    } else if (risk === 'compliance') {
      w = `${w} 财税/合规存在不确定性，需专项体检。`
    } else if (risk === 'org') {
      w = `${w} 组织与人才结构可能跟不上业务目标。`
    } else if (risk === 'tech') {
      w = `${w} 交付与技术能力存在瓶颈风险。`
    }
    if (digital === 'low') {
      w = `${w} 工具分散导致数据难复用。`
    }
    return w
  }

  private static opportunityText(need: string, industry: string, next: string): string {
    let o = '可通过顾问辅导把诉求拆成 30–90 天可执行清单。'
    if (need === 'brand') {
      o = '品牌与营销升级可带来获客效率提升，适合组合投放与内容资产。'
    } else if (need === 'digital') {
      o = '数字化打通可降低协同成本，优先选 1–2 个高 ROI 场景试点。'
    } else if (need === 'finance') {
      o = '财税合规梳理可降低经营不确定性，并为后续融资/申报铺路。'
    } else if (need === 'project') {
      o = '政策与项目申报窗口可带来资金与资质机会，需匹配材料清单。'
    } else if (need === 'strategy') {
      o = '战略与组织诊断可统一目标、职责与关键指标。'
    }
    if (industry === 'tech') {
      o = `${o} 科技/SaaS 企业可同步关注产品化与客户成功。`
    }
    if (next === 'policy') {
      o = `${o} 下一步可先筛政策目录再约顾问。`
    }
    return o
  }

  private static threatText(risk: string, revenue: string): string {
    let t = '外部环境与内部执行偏差可能放大经营波动。'
    if (risk === 'cash' || revenue === 'pressure') {
      t = '资金链与回款波动是短期最大威胁，需设置预警阈值。'
    } else if (risk === 'compliance') {
      t = '合规滞后可能导致处罚或业务中断风险。'
    } else if (risk === 'acquire') {
      t = '获客成本上升与转化下降可能挤压毛利。'
    }
    return t
  }

  private static actions(need: string, risk: string, next: string): string[] {
    const list: string[] = []
    list.push('先完成匹配的一项训练，再决定要不要加练。')
    if (need === 'finance' || risk === 'compliance') {
      list.push('预约「财税」类服务，完成合规与成本结构体检。')
    } else if (need === 'brand') {
      list.push('预约「品牌策划」类服务，输出 30 天内容与渠道组合。')
    } else if (need === 'digital') {
      list.push('预约「数字化」类服务，选定试点系统与数据口径。')
    } else if (need === 'project') {
      list.push('在政策智库筛选可申报项，再约顾问评估材料完备度。')
    } else {
      list.push('预约「企业咨询」类服务，把诊断结论落成季度路线图。')
    }
    if (risk === 'cash') {
      list.push('建立 13 周现金流表与回款责任人。')
    }
    if (next === 'book') {
      list.push('本周内完成顾问预约（视频/电话/面谈任选）。')
    } else {
      list.push('保存本报告，需要时在「服务」页一键预约顾问。')
    }
    return list
  }

  private static matchCategory(need: string): string {
    if (need === 'brand') {
      return '色彩干扰'
    }
    if (need === 'digital') {
      return '记忆宫殿'
    }
    if (need === 'finance') {
      return '速算冲刺'
    }
    if (need === 'project') {
      return '图形推理'
    }
    return '数独挑战'
  }

  private static scoreLabel(revenue: string, risk: string, digital: string): string {
    let score = 70
    if (revenue === 'up') {
      score += 8
    } else if (revenue === 'pressure') {
      score -= 10
    }
    if (risk === 'cash' || risk === 'compliance') {
      score -= 8
    }
    if (digital === 'high') {
      score += 6
    } else if (digital === 'low') {
      score -= 5
    }
    if (score >= 80) {
      return '经营韧性较好'
    }
    if (score >= 65) {
      return '有改进空间'
    }
    return '建议优先干预'
  }
}
