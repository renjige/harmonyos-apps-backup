import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'

/** 赛后复盘问卷 → 规则模板报告（非生成式 AI） */
export class DiagnoseService {
  static questions(): DiagnoseQuestion[] {
    return [
      DiagnoseQuestion.of('feel', '本场发挥体感？', [
        DiagnoseOption.of('peak', '超常发挥'),
        DiagnoseOption.of('ok', '正常水准'),
        DiagnoseOption.of('off', '明显失常')
      ]),
      DiagnoseQuestion.of('body', '身体状态？', [
        DiagnoseOption.of('fresh', '充沛'),
        DiagnoseOption.of('mid', '一般'),
        DiagnoseOption.of('tired', '透支')
      ]),
      DiagnoseQuestion.of('plan', '战术执行？', [
        DiagnoseOption.of('follow', '按计划推进'),
        DiagnoseOption.of('react', '被动应对'),
        DiagnoseOption.of('chaos', '场面较乱')
      ]),
      DiagnoseQuestion.of('shine', '最亮的一块？', [
        DiagnoseOption.of('attack', '进攻/速度'),
        DiagnoseOption.of('defend', '防守/纪律'),
        DiagnoseOption.of('stamina', '体能续航'),
        DiagnoseOption.of('mind', '心态抗压')
      ]),
      DiagnoseQuestion.of('gap', '下场最该补？', [
        DiagnoseOption.of('skill', '技术细节'),
        DiagnoseOption.of('endurance', '耐力'),
        DiagnoseOption.of('tactics', '跑位/配合'),
        DiagnoseOption.of('rest', '恢复与睡眠')
      ]),
      DiagnoseQuestion.of('mood', '赛后心情？', [
        DiagnoseOption.of('up', '兴奋想再打'),
        DiagnoseOption.of('calm', '平静可复盘'),
        DiagnoseOption.of('down', '需要缓一缓')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const feel = DiagnoseService.pick(answers, 'feel')
    const body = DiagnoseService.pick(answers, 'body')
    const plan = DiagnoseService.pick(answers, 'plan')
    const shine = DiagnoseService.pick(answers, 'shine')
    const gap = DiagnoseService.pick(answers, 'gap')
    const mood = DiagnoseService.pick(answers, 'mood')
    const report = new DiagnoseReport()
    report.title = '本场赛后复盘'
    report.generatedAt = DiagnoseService.today()
    report.summary =
      `发挥「${DiagnoseService.lab(answers, 'feel')}」，身体「${DiagnoseService.lab(answers, 'body')}」，` +
      `执行「${DiagnoseService.lab(answers, 'plan')}」。此为规则模板，便于下场对照，不构成运动医学建议。`
    report.strength = DiagnoseService.sText(feel, shine, body)
    report.weakness = DiagnoseService.wText(feel, plan, body)
    report.opportunity = DiagnoseService.oText(gap, shine)
    report.threat = DiagnoseService.tText(mood, body)
    report.actions = DiagnoseService.acts(gap, mood, body)
    report.matchCategory = DiagnoseService.lab(answers, 'gap')
    report.matchHint = `下场训练优先盯「${report.matchCategory}」，并在赛点时刻里标出可验证的一次回合。`
    report.scoreLabel = DiagnoseService.score(feel, body, plan)
    return report
  }

  private static pick(answers: DiagnoseAnswer[], qid: string): string {
    for (const a of answers) {
      if (a.questionId === qid) {
        return a.optionId
      }
    }
    return ''
  }

  private static lab(answers: DiagnoseAnswer[], qid: string): string {
    for (const a of answers) {
      if (a.questionId === qid) {
        return a.optionLabel
      }
    }
    return '未填'
  }

  private static today(): string {
    const d = new Date()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${ms}-${ds}`
  }

  private static sText(feel: string, shine: string, body: string): string {
    let s = '本场有可复用的回合，值得写进赛点时刻。'
    if (feel === 'peak') {
      s = '超常发挥说明赛前准备与临场选择对上了，把关键回合钉进时间线。'
    }
    if (shine === 'mind') {
      s = `${s} 心态是本场优势，压力球可继续当训练主题。`
    }
    if (body === 'fresh') {
      s = `${s} 体能储备支撑了后半段。`
    }
    return s
  }

  private static wText(feel: string, plan: string, body: string): string {
    let w = '把「感觉不好」拆成一个可练的动作，避免空泛自责。'
    if (feel === 'off') {
      w = '发挥低于预期，优先复盘前 10 分钟的选择，而不是整场否定。'
    }
    if (plan === 'chaos') {
      w = `${w} 场面乱时需要一个默认站位/配速预案。`
    }
    if (body === 'tired') {
      w = `${w} 透支后应降低下次强度，先睡够再加练。`
    }
    return w
  }

  private static oText(gap: string, shine: string): string {
    if (gap === 'skill') {
      return '技术细节可用「每场只改一个动作」推进，比一次加练全部更稳。'
    }
    if (gap === 'endurance') {
      return '耐力缺口适合用下周 1 次稳态有氧补，不必天天拉满。'
    }
    if (gap === 'tactics') {
      return '配合问题可约固定队友加练 20 分钟跑位，比加练力量更对症。'
    }
    if (shine === 'attack') {
      return '进攻是亮点，下场可把同样套路再打一遍验证是否可复制。'
    }
    return '恢复日也算训练：拉伸、睡眠、补水写进下场赛前清单。'
  }

  private static tText(mood: string, body: string): string {
    if (mood === 'down' && body === 'tired') {
      return '情绪低 + 身体透支时，48 小时内不要安排高强度对抗。'
    }
    if (mood === 'up') {
      return '兴奋时容易加赛，注意避免连续两天高对抗导致伤病。'
    }
    return '忽略恢复节奏会把单场波动变成连续状态下滑。'
  }

  private static acts(gap: string, mood: string, body: string): string[] {
    const list: string[] = []
    list.push('在详情页为最关键的一次回合添加「赛点时刻」（分钟+类型）。')
    if (gap === 'rest' || body === 'tired') {
      list.push('下次开赛前保证连续两晚 7 小时睡眠，再考虑加练。')
    } else if (gap === 'endurance') {
      list.push('本周安排 1 次 30–40 分钟稳态有氧，记录进训练场。')
    } else if (gap === 'tactics') {
      list.push('下场赛前写下 3 条站位/配速口令，开场对照执行。')
    } else {
      list.push('下场只练一个技术点，赛后再勾选是否出现在赛点时刻。')
    }
    if (mood === 'down') {
      list.push('先写完本场感受再决定是否约下场比赛，避免情绪决策。')
    } else {
      list.push('对照赛季目标看本场是否算有效场次，必要时调整目标数字。')
    }
    return list
  }

  private static score(feel: string, body: string, plan: string): string {
    let n = 72
    if (feel === 'peak') {
      n += 10
    } else if (feel === 'off') {
      n -= 12
    }
    if (body === 'fresh') {
      n += 6
    } else if (body === 'tired') {
      n -= 8
    }
    if (plan === 'follow') {
      n += 6
    } else if (plan === 'chaos') {
      n -= 8
    }
    if (n >= 80) {
      return '可复制的好场'
    }
    if (n >= 65) {
      return '有改进锚点'
    }
    return '先恢复再加练'
  }
}
