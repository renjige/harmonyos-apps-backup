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
      DiagnoseQuestion.of('stage', '企业当前阶段？', [
        DiagnoseOption.of('startup', '初创探索'),
        DiagnoseOption.of('growth', '快速成长'),
        DiagnoseOption.of('mature', '稳健经营'),
        DiagnoseOption.of('transform', '转型突破')
      ]),
      DiagnoseQuestion.of('industry', '主营行业更接近？', [
        DiagnoseOption.of('manufacturing', '制造 / 供应链'),
        DiagnoseOption.of('retail', '零售 / 消费'),
        DiagnoseOption.of('tech', '科技 / SaaS'),
        DiagnoseOption.of('service', '专业服务'),
        DiagnoseOption.of('other', '其他')
      ]),
      DiagnoseQuestion.of('need', '当前最核心诉求？', [
        DiagnoseOption.of('strategy', '战略与组织'),
        DiagnoseOption.of('brand', '品牌与营销'),
        DiagnoseOption.of('digital', '数字化转型'),
        DiagnoseOption.of('finance', '财税与合规'),
        DiagnoseOption.of('project', '项目与政策申报')
      ]),
      DiagnoseQuestion.of('team', '团队规模？', [
        DiagnoseOption.of('s', '1–20 人'),
        DiagnoseOption.of('m', '21–100 人'),
        DiagnoseOption.of('l', '100 人以上')
      ]),
      DiagnoseQuestion.of('revenue', '近一年营收体感？', [
        DiagnoseOption.of('pressure', '承压下滑'),
        DiagnoseOption.of('flat', '基本平稳'),
        DiagnoseOption.of('up', '明显增长')
      ]),
      DiagnoseQuestion.of('risk', '最紧迫的风险？', [
        DiagnoseOption.of('cash', '现金流'),
        DiagnoseOption.of('acquire', '获客与转化'),
        DiagnoseOption.of('compliance', '合规与财税'),
        DiagnoseOption.of('org', '组织与人才'),
        DiagnoseOption.of('tech', '技术与交付')
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
      `基于问卷：阶段「${DiagnoseService.labelOf(answers, 'stage')}」、` +
      `行业「${DiagnoseService.labelOf(answers, 'industry')}」、` +
      `诉求「${DiagnoseService.labelOf(answers, 'need')}」。` +
      `以下为规则模板结论，供内部讨论参考，不构成法律/财税/投资建议。`
    report.strength = DiagnoseService.strengthText(stage, team, revenue, digital)
    report.weakness = DiagnoseService.weaknessText(revenue, risk, digital)
    report.opportunity = DiagnoseService.opportunityText(need, industry, next)
    report.threat = DiagnoseService.threatText(risk, revenue)
    report.actions = DiagnoseService.actions(need, risk, next)
    report.matchCategory = DiagnoseService.matchCategory(need)
    report.matchHint =
      `建议优先查看「${report.matchCategory}」服务，并预约顾问把模板结论落成执行计划。`
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
    let s = '已形成可描述的业务方向，具备继续优化的基础。'
    if (stage === 'growth' || stage === 'mature') {
      s = '经营节奏相对清晰，具备规模化或精细化改进空间。'
    }
    if (team === 'm' || team === 'l') {
      s = `${s} 团队规模可支撑专项改进项目。`
    }
    if (revenue === 'up') {
      s = `${s} 营收增长为投入数字化与品牌提供窗口。`
    }
    if (digital === 'high') {
      s = `${s} 数字化基础较好，适合推进数据驱动决策。`
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
    let o = '可通过顾问辅导把诉求拆成 30–90 天可执行家庭清单。'
    if (need === 'brand') {
      o = '品牌与营销升级可带来获客效率提升，适合组合投放与内容资产。'
    } else if (need === 'digital') {
      o = '数字化打通可降低协同成本，优先选 1–2 个高 ROI 场景试点。'
    } else if (need === 'finance') {
      o = '财税合规梳理可降低经营不确定性，并为后续融资/申报铺路。'
    } else if (need === 'project') {
      o = '政策与项目申报窗口可带来资金与资质机会，需匹配材料家庭清单。'
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
    list.push('确认本报告中 SWOT 与团队共识，标出本周可验证的 1 个指标。')
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
      return '品牌策划'
    }
    if (need === 'digital') {
      return '数字化'
    }
    if (need === 'finance') {
      return '财税'
    }
    if (need === 'project') {
      return '项目培训认证'
    }
    return '企业咨询'
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
