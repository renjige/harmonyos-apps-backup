import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'

/** 生活节律自检：问卷 → 模板报告（纯规则，不调用大模型）。 */
export class DiagnoseService {
  static questions(): DiagnoseQuestion[] {
    return [
      DiagnoseQuestion.of('wake', '最近一周起床是否相对固定？', [
        DiagnoseOption.of('stable', '基本固定'),
        DiagnoseOption.of('shift', '偶尔漂移'),
        DiagnoseOption.of('chaos', '很不规律')
      ]),
      DiagnoseQuestion.of('todo', '待办通常如何处理？', [
        DiagnoseOption.of('write', '会写下并勾选'),
        DiagnoseOption.of('head', '多记在脑子里'),
        DiagnoseOption.of('delay', '经常拖延到第二天')
      ]),
      DiagnoseQuestion.of('habit', '正在坚持的习惯有几件？', [
        DiagnoseOption.of('none', '还没有'),
        DiagnoseOption.of('one', '1 件'),
        DiagnoseOption.of('few', '2–3 件'),
        DiagnoseOption.of('many', '4 件以上')
      ]),
      DiagnoseQuestion.of('focus', '深度专注的最长连续时间？', [
        DiagnoseOption.of('short', '不足 25 分钟'),
        DiagnoseOption.of('mid', '25–50 分钟'),
        DiagnoseOption.of('long', '超过 50 分钟')
      ]),
      DiagnoseQuestion.of('note', '灵感或摘抄会留下来吗？', [
        DiagnoseOption.of('often', '经常写成知识碎片'),
        DiagnoseOption.of('rare', '偶尔记一下'),
        DiagnoseOption.of('never', '几乎不记')
      ]),
      DiagnoseQuestion.of('energy', '白天能量更接近？', [
        DiagnoseOption.of('high', '明朗充沛'),
        DiagnoseOption.of('ok', '安宁平稳'),
        DiagnoseOption.of('low', '疲惫或沉郁')
      ]),
      DiagnoseQuestion.of('screen', '睡前刷屏幕的情况？', [
        DiagnoseOption.of('less', '较少'),
        DiagnoseOption.of('mid', '一般'),
        DiagnoseOption.of('more', '经常很晚还在看')
      ]),
      DiagnoseQuestion.of('next', '接下来最想落实？', [
        DiagnoseOption.of('schedule', '把今日待办写清'),
        DiagnoseOption.of('habit', '建立或打卡一个习惯'),
        DiagnoseOption.of('note', '留下一条知识碎片')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const wake = DiagnoseService.optionId(answers, 'wake')
    const todo = DiagnoseService.optionId(answers, 'todo')
    const habit = DiagnoseService.optionId(answers, 'habit')
    const focus = DiagnoseService.optionId(answers, 'focus')
    const note = DiagnoseService.optionId(answers, 'note')
    const energy = DiagnoseService.optionId(answers, 'energy')
    const screen = DiagnoseService.optionId(answers, 'screen')
    const next = DiagnoseService.optionId(answers, 'next')

    const report = new DiagnoseReport()
    report.title = '明序阁 · 生活节律对照'
    report.generatedAt = DiagnoseService.nowLabel()
    report.summary =
      `起床「${DiagnoseService.labelOf(answers, 'wake')}」、待办「${DiagnoseService.labelOf(answers, 'todo')}」、` +
      `习惯「${DiagnoseService.labelOf(answers, 'habit')}」。以下为规则模板对照，不是医疗或心理诊断。`
    report.strength = DiagnoseService.strengthText(wake, habit, note)
    report.weakness = DiagnoseService.weaknessText(todo, focus, screen)
    report.opportunity = DiagnoseService.opportunityText(next, energy)
    report.threat = DiagnoseService.threatText(energy, screen, todo)
    report.actions = DiagnoseService.actions(next, habit, note)
    report.matchCategory = DiagnoseService.matchCategory(next)
    report.matchHint = `建议先去「${report.matchCategory}」落实一件最小的事，再回来对照本清单。`
    report.scoreLabel = DiagnoseService.scoreLabel(wake, todo, habit, energy)
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

  private static strengthText(wake: string, habit: string, note: string): string {
    let s = '你已经愿意审视自己的节奏，这本身就是「明」。'
    if (wake === 'stable') {
      s = `${s} 起床相对固定，给白天提供了稳定的起点。`
    }
    if (habit === 'few' || habit === 'many') {
      s = `${s} 习惯不是零，持续比一次做完更重要。`
    }
    if (note === 'often') {
      s = `${s} 知识碎片在沉淀，洞察不会被刷走。`
    }
    return s
  }

  private static weaknessText(todo: string, focus: string, screen: string): string {
    let w = '秩序需要外部载体：写下来，才不会只停在念头里。'
    if (todo === 'head' || todo === 'delay') {
      w = '待办如果只在脑子里，容易被新刺激冲掉。先写三件今日必做。'
    }
    if (focus === 'short') {
      w = `${w} 深度时段偏短，可先用 25 分钟做一个最小闭环。`
    }
    if (screen === 'more') {
      w = `${w} 睡前屏幕会侵蚀次日的「明」。`
    }
    return w
  }

  private static opportunityText(next: string, energy: string): string {
    if (next === 'habit') {
      return '用习惯页打卡一件小事，连续三天即可看到节奏变化。'
    }
    if (next === 'note') {
      return '把今天的一句观察写成知识碎片，标签不要超过三个。'
    }
    if (energy === 'low') {
      return '能量偏低时，日程只排一件「必须」，其余留给恢复。'
    }
    return '打开日程，把今天要做的事按高/中/低排好，完成即勾选。'
  }

  private static threatText(energy: string, screen: string, todo: string): string {
    if (energy === 'low' && screen === 'more') {
      return '疲惫叠加晚间屏幕，容易进入「越空越刷」的循环。'
    }
    if (todo === 'delay') {
      return '拖延会让待办在次日叠加，首页进度环会长期偏低。'
    }
    return '最大的威胁不是忙碌，而是没有写下的承诺。'
  }

  private static actions(next: string, habit: string, note: string): string[] {
    const list: string[] = []
    list.push('在首页记录今日心情，给自己一个诚实的起点。')
    if (next === 'habit' || habit === 'none') {
      list.push('添加一个可在两分钟内完成的习惯并完成今日打卡。')
    } else {
      list.push('为已有习惯补一次打卡，保护连续天数。')
    }
    if (next === 'note' || note === 'never') {
      list.push('写下一条不超过五行的知识碎片。')
    } else {
      list.push('给最近一条笔记补一个标签，方便以后找回。')
    }
    list.push('在日程里放入今天唯一的「高」优先级事项并完成。')
    return list
  }

  private static matchCategory(next: string): string {
    if (next === 'habit') {
      return '习惯'
    }
    if (next === 'note') {
      return '知识碎片'
    }
    return '日程'
  }

  private static scoreLabel(wake: string, todo: string, habit: string, energy: string): string {
    let score = 68
    if (wake === 'stable') {
      score += 8
    } else if (wake === 'chaos') {
      score -= 8
    }
    if (todo === 'write') {
      score += 8
    } else if (todo === 'delay') {
      score -= 8
    }
    if (habit === 'few' || habit === 'many') {
      score += 6
    }
    if (energy === 'low') {
      score -= 6
    }
    if (score >= 80) {
      return '节律较稳'
    }
    if (score >= 65) {
      return '有改进空间'
    }
    return '建议先立一件小事'
  }
}
