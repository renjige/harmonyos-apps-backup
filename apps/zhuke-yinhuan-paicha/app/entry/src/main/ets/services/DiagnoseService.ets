import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'

/** 现场自检问卷 → 规则模板摘要（不调用大模型）。 */
export class DiagnoseService {
  static questions(): DiagnoseQuestion[] {
    return [
      DiagnoseQuestion.of('edge', '临边与洞口防护如何？', [
        DiagnoseOption.of('ok', '栏杆、洞口防护齐全'),
        DiagnoseOption.of('gap', '个别位置缺失或松动'),
        DiagnoseOption.of('bad', '多处临边无有效防护')
      ]),
      DiagnoseQuestion.of('power', '临时用电是否规范？', [
        DiagnoseOption.of('ok', '配电箱完好、电缆无破损'),
        DiagnoseOption.of('gap', '有裸线或箱门未锁'),
        DiagnoseOption.of('bad', '明显违规用电')
      ]),
      DiagnoseQuestion.of('fire', '消防通道与灭火器？', [
        DiagnoseOption.of('ok', '通道畅通、灭火器有效'),
        DiagnoseOption.of('gap', '个别堵塞或过期'),
        DiagnoseOption.of('bad', '通道占用或器材缺失')
      ]),
      DiagnoseQuestion.of('height', '高处作业防护？', [
        DiagnoseOption.of('ok', '用品齐全、区域有防护'),
        DiagnoseOption.of('gap', '个别未系挂或围挡不足'),
        DiagnoseOption.of('bad', '发现违章攀爬或抛物')
      ]),
      DiagnoseQuestion.of('civil', '文明施工与材料堆放？', [
        DiagnoseOption.of('ok', '分区码放、通道整洁'),
        DiagnoseOption.of('gap', '局部杂乱'),
        DiagnoseOption.of('bad', '通道堵塞、垃圾未集中')
      ]),
      DiagnoseQuestion.of('owner', '整改责任是否明确？', [
        DiagnoseOption.of('ok', '责任人与期限清楚'),
        DiagnoseOption.of('gap', '部分项未指定'),
        DiagnoseOption.of('bad', '无人跟踪')
      ]),
      DiagnoseQuestion.of('close', '既有隐患闭环情况？', [
        DiagnoseOption.of('ok', '高风险均已整改或复查中'),
        DiagnoseOption.of('gap', '仍有待整改项'),
        DiagnoseOption.of('bad', '多项逾期未闭环')
      ]),
      DiagnoseQuestion.of('next', '接下来最想做的？', [
        DiagnoseOption.of('record', '立即登记隐患'),
        DiagnoseOption.of('inspect', '先走一遍检查清单'),
        DiagnoseOption.of('review', '优先复查待闭环项')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const edge = DiagnoseService.optionId(answers, 'edge')
    const power = DiagnoseService.optionId(answers, 'power')
    const fire = DiagnoseService.optionId(answers, 'fire')
    const height = DiagnoseService.optionId(answers, 'height')
    const civil = DiagnoseService.optionId(answers, 'civil')
    const close = DiagnoseService.optionId(answers, 'close')
    const next = DiagnoseService.optionId(answers, 'next')

    const report = new DiagnoseReport()
    report.title = '现场自检摘要'
    report.generatedAt = DiagnoseService.nowLabel()
    report.summary =
      `根据问卷：临边「${DiagnoseService.labelOf(answers, 'edge')}」、` +
      `用电「${DiagnoseService.labelOf(answers, 'power')}」、` +
      `消防「${DiagnoseService.labelOf(answers, 'fire')}」。` +
      `以下为规则模板结论，供现场记录参考，不替代法定安全检查。`
    report.strength = DiagnoseService.strengthText(edge, power, fire)
    report.weakness = DiagnoseService.weaknessText(height, civil, close)
    report.opportunity = DiagnoseService.opportunityText(next)
    report.threat = DiagnoseService.threatText(edge, power, fire, height)
    report.actions = DiagnoseService.actions(edge, power, fire, next)
    report.matchCategory = DiagnoseService.matchCategory(edge, power, fire, height)
    report.matchHint = `建议优先关注「${report.matchCategory}」，把异常项记入隐患并跟踪整改。`
    report.scoreLabel = DiagnoseService.scoreLabel(edge, power, fire, close)
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
    const mo = d.getMonth() + 1
    const day = d.getDate()
    const moStr = mo < 10 ? `0${mo}` : `${mo}`
    const dayStr = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${moStr}-${dayStr}`
  }

  private static strengthText(edge: string, power: string, fire: string): string {
    if (edge === 'ok' && power === 'ok' && fire === 'ok') {
      return '临边、用电、消防三项基础防护总体到位，可作为今日安全基线继续保持。'
    }
    if (edge === 'ok' || power === 'ok' || fire === 'ok') {
      return '部分关键防护已落实，可把经验复制到薄弱工点。'
    }
    return '现场已开始关注防护，建议尽快把缺口登记成可跟踪隐患。'
  }

  private static weaknessText(height: string, civil: string, close: string): string {
    let w = '薄弱环节需要落实到责任人和期限。'
    if (height === 'bad') {
      w = '高处作业防护不足，坠落风险需立即登记。'
    } else if (civil === 'bad') {
      w = '文明施工与通道占用可能掩盖作业风险。'
    }
    if (close === 'bad') {
      w = `${w} 既有隐患逾期未闭环，整改跟踪应优先。`
    }
    return w
  }

  private static opportunityText(next: string): string {
    if (next === 'inspect') {
      return '先走检查清单，把异常项自动记入隐患，减少漏项。'
    }
    if (next === 'review') {
      return '优先复查待闭环项，避免重复发现同一问题。'
    }
    return '立即登记隐患，把位置、风险和整改建议一次写清。'
  }

  private static threatText(edge: string, power: string, fire: string, height: string): string {
    if (edge === 'bad' || height === 'bad') {
      return '临边或高处防护缺失可能导致坠落，属于应优先处理的高风险。'
    }
    if (power === 'bad' || fire === 'bad') {
      return '用电或消防异常可能迅速扩大，建议当天完成登记与整改安排。'
    }
    return '风险仍可控，但未闭环项可能在交叉作业时被放大。'
  }

  private static actions(edge: string, power: string, fire: string, next: string): string[] {
    const list: string[] = []
    list.push('把问卷中的异常点写成隐患名称与位置，指定责任人。')
    if (edge !== 'ok') {
      list.push('临边与洞口：补齐栏杆、盖板和警示标识。')
    }
    if (power !== 'ok') {
      list.push('临时用电：检查配电箱门锁、漏电保护和电缆绝缘。')
    }
    if (fire !== 'ok') {
      list.push('消防：清理通道，核对灭火器有效期。')
    }
    if (next === 'inspect') {
      list.push('完成一轮检查清单，异常项转入隐患跟踪。')
    } else {
      list.push('对高风险项设定整改期限并安排复查。')
    }
    return list
  }

  private static matchCategory(edge: string, power: string, fire: string, height: string): string {
    if (edge === 'bad') {
      return '临边防护'
    }
    if (height === 'bad') {
      return '高处作业'
    }
    if (power === 'bad') {
      return '用电安全'
    }
    if (fire === 'bad') {
      return '消防安全'
    }
    return '文明施工'
  }

  private static scoreLabel(edge: string, power: string, fire: string, close: string): string {
    let score = 72
    if (edge === 'ok') { score += 6 } else if (edge === 'bad') { score -= 10 }
    if (power === 'ok') { score += 4 } else if (power === 'bad') { score -= 8 }
    if (fire === 'ok') { score += 4 } else if (fire === 'bad') { score -= 8 }
    if (close === 'bad') { score -= 8 }
    if (score >= 80) {
      return '现场风险总体可控'
    }
    if (score >= 65) {
      return '有待整改项'
    }
    return '建议立即登记隐患'
  }
}
