import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'

/**
 * 问卷 → 学习路径匹配报告（纯规则，不调用大模型）。
 */
export class DiagnoseService {
  static questions(): DiagnoseQuestion[] {
    return [
      DiagnoseQuestion.of('goal', '最近最想先筑哪一类知识？', [
        DiagnoseOption.of('code', '编程入门'),
        DiagnoseOption.of('lang', '外语精进'),
        DiagnoseOption.of('career', '职场表达'),
        DiagnoseOption.of('literacy', '通识素养'),
        DiagnoseOption.of('thinking', '思维方法')
      ]),
      DiagnoseQuestion.of('time', '每天能稳定拿出多久？', [
        DiagnoseOption.of('s', '10 分钟以内'),
        DiagnoseOption.of('m', '10–20 分钟'),
        DiagnoseOption.of('l', '20 分钟以上')
      ]),
      DiagnoseQuestion.of('level', '目前基础更接近？', [
        DiagnoseOption.of('zero', '几乎没系统学过'),
        DiagnoseOption.of('some', '看过一些但没路径'),
        DiagnoseOption.of('ok', '有基础，想补结构')
      ]),
      DiagnoseQuestion.of('habit', '更怕哪件事让你中断？', [
        DiagnoseOption.of('scatter', '内容太散，不知道下一步'),
        DiagnoseOption.of('quiz', '刷题太多，没有成就感'),
        DiagnoseOption.of('long', '单课太长，坚持不住')
      ]),
      DiagnoseQuestion.of('output', '更希望学完能立刻做什么？', [
        DiagnoseOption.of('make', '做出一个小成果'),
        DiagnoseOption.of('speak', '能开口或能写清楚'),
        DiagnoseOption.of('judge', '能判断信息靠不靠谱')
      ]),
      DiagnoseQuestion.of('pace', '接下来 7 天的节奏偏好？', [
        DiagnoseOption.of('daily', '每天一小课'),
        DiagnoseOption.of('block', '隔天一块较长内容'),
        DiagnoseOption.of('flex', '先看匹配，再自己调')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const goal = DiagnoseService.optionId(answers, 'goal')
    const time = DiagnoseService.optionId(answers, 'time')
    const level = DiagnoseService.optionId(answers, 'level')
    const habit = DiagnoseService.optionId(answers, 'habit')
    const output = DiagnoseService.optionId(answers, 'output')
    const pace = DiagnoseService.optionId(answers, 'pace')

    const report = new DiagnoseReport()
    report.generatedAt = DiagnoseService.nowLabel()
    report.matchCategory = DiagnoseService.matchPathId(goal, output)
    report.matchHint = DiagnoseService.pathHint(report.matchCategory)
    report.summary =
      `基于问卷：领域「${DiagnoseService.labelOf(answers, 'goal')}」、` +
      `时长「${DiagnoseService.labelOf(answers, 'time')}」、` +
      `基础「${DiagnoseService.labelOf(answers, 'level')}」。` +
      `以下为规则匹配结论，仅供参考，不构成学历或职业承诺。`
    report.strength = DiagnoseService.strengthText(time, pace, level)
    report.weakness = DiagnoseService.weaknessText(habit, time)
    report.opportunity = DiagnoseService.opportunityText(output, goal)
    report.threat = DiagnoseService.threatText(habit, pace)
    report.actions = DiagnoseService.actions(report.matchCategory, time, habit)
    report.scoreLabel = DiagnoseService.scoreLabel(time, level, pace)
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

  static matchPathId(goal: string, output: string): string {
    if (goal === 'lang') {
      return 'xz_path_english21'
    }
    if (goal === 'career') {
      return 'xz_path_report5'
    }
    if (goal === 'literacy') {
      return 'xz_path_digital'
    }
    if (goal === 'thinking') {
      return 'xz_path_critical'
    }
    if (goal === 'code' || output === 'make') {
      return 'xz_path_frontend7'
    }
    if (output === 'speak') {
      return 'xz_path_english21'
    }
    if (output === 'judge') {
      return 'xz_path_digital'
    }
    return 'xz_path_frontend7'
  }

  static pathHint(pathId: string): string {
    if (pathId === 'xz_path_english21') {
      return '推荐「21 日英语晨读」：短课时、能开口。'
    }
    if (pathId === 'xz_path_report5') {
      return '推荐「职场汇报五步」：结论先行，把流水账压成可决策纪要。'
    }
    if (pathId === 'xz_path_digital') {
      return '推荐「数字素养小筑」：练习核对来源与读懂比例。'
    }
    if (pathId === 'xz_path_critical') {
      return '推荐「批判性思维入门」：主张、证据、反例、适用范围。'
    }
    return '推荐「7 日前端小筑」：每天一课，做出可运行的最小页面。'
  }

  private static strengthText(time: string, pace: string, level: string): string {
    let s = '你已经愿意用结构化路径代替零散资讯流，这是最重要的起点。'
    if (time === 'm' || time === 'l') {
      s = `${s} 每天有可预期的时间盒，适合「一课一砖」。`
    }
    if (pace === 'daily') {
      s = `${s} 日更节奏与本应用课时长度匹配。`
    }
    if (level === 'ok') {
      s = `${s} 有基础时，路径能帮你补上缺口而不是从头刷题。`
    }
    return s
  }

  private static weaknessText(habit: string, time: string): string {
    let w = '若没有「下一课」提示，容易停在收藏夹里。'
    if (habit === 'scatter') {
      w = '内容一散就容易放弃。请严格按路径顺序学，先不要跳课。'
    } else if (habit === 'quiz') {
      w = '刷题容易消耗热情。本路径强调可运行成果，请以完成课时为准。'
    } else if (habit === 'long') {
      w = '长课时会打断坚持。请把单课控制在提示的分钟数内，超时就停。'
    }
    if (time === 's') {
      w = `${w} 每天时间很短，请只完成一课中的「今日练习」。`
    }
    return w
  }

  private static opportunityText(output: string, goal: string): string {
    if (output === 'make') {
      return '把「做出一个小成果」当成验收：改一行标题、换一处颜色，比看完视频更重要。'
    }
    if (output === 'speak') {
      return '把卡片里的句子带到真实对话再用一次，路径才算合上。'
    }
    if (output === 'judge') {
      return '遇到陌生图表先问三个核对问题，这是数字素养路径的验收。'
    }
    if (goal === 'career') {
      return '下周会前用五步结构改写一次汇报，立刻验证路径是否有用。'
    }
    return '完成第一节课后标记进度，让看板开始有自己的砖。'
  }

  private static threatText(habit: string, pace: string): string {
    let t = '最大风险是同时开太多领域，路径被资讯流冲散。'
    if (habit === 'scatter') {
      t = '同时收藏很多卡片却不按顺序学，进度会长期停在 0。'
    }
    if (pace === 'flex') {
      t = `${t} 「先随便看看」容易变成不开始。建议先锁一条 7 日路径。`
    }
    return t
  }

  private static actions(pathId: string, time: string, habit: string): string[] {
    const list: string[] = []
    list.push('打开推荐路径，只学第一节课并标记完成。')
    list.push('把今日智慧读完，收藏不超过 1 张真正会复用的卡片。')
    if (time === 's') {
      list.push('设一个 10 分钟计时：只做课时里的「今日练习」。')
    } else {
      list.push('按课时标注的分钟数学完，超时就停，明天续。')
    }
    if (habit === 'scatter') {
      list.push('7 天内不要切换领域；疑问去「智慧问答」对照词条。')
    }
    list.push(`推荐路径编号：${pathId}。结论仅供参考。`)
    return list
  }

  private static scoreLabel(time: string, level: string, pace: string): string {
    let score = 68
    if (time === 'm' || time === 'l') {
      score += 8
    }
    if (level === 'ok') {
      score += 6
    }
    if (pace === 'daily') {
      score += 6
    }
    if (score >= 80) {
      return '节奏匹配较好'
    }
    if (score >= 70) {
      return '可以开始筑第一块砖'
    }
    return '建议先缩短单课时长'
  }
}
