import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'

/** 训练配比问卷 → 规则模板报告（非生成式对话） */
export class DiagnoseService {
  static questions(): DiagnoseQuestion[] {
    return [
      DiagnoseQuestion.of('freq', '本周实际运动几次？', [
        DiagnoseOption.of('f0', '0–1 次'),
        DiagnoseOption.of('f2', '2–3 次'),
        DiagnoseOption.of('f4', '4 次以上')
      ]),
      DiagnoseQuestion.of('main', '当前主项更接近？', [
        DiagnoseOption.of('run', '跑步'),
        DiagnoseOption.of('ride', '骑行'),
        DiagnoseOption.of('gym', '力量健身'),
        DiagnoseOption.of('ball', '球类'),
        DiagnoseOption.of('mix', '多项混合')
      ]),
      DiagnoseQuestion.of('load', '最近一次训练体感？', [
        DiagnoseOption.of('easy', '轻松还能加量'),
        DiagnoseOption.of('ok', '正常刚好'),
        DiagnoseOption.of('hard', '明显吃力')
      ]),
      DiagnoseQuestion.of('goal', '近 30 天最想提升？', [
        DiagnoseOption.of('endurance', '耐力与距离'),
        DiagnoseOption.of('strength', '力量与核心'),
        DiagnoseOption.of('skill', '球技/专项'),
        DiagnoseOption.of('habit', '先养成频率')
      ]),
      DiagnoseQuestion.of('rest', '休息日如何安排？', [
        DiagnoseOption.of('none', '几乎不休息'),
        DiagnoseOption.of('one', '每周 1 天'),
        DiagnoseOption.of('two', '每周 ≥2 天')
      ]),
      DiagnoseQuestion.of('pain', '是否有持续酸痛或不适？', [
        DiagnoseOption.of('no', '没有'),
        DiagnoseOption.of('mild', '轻度、可活动'),
        DiagnoseOption.of('yes', '明显、影响动作')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const freq = DiagnoseService.optionId(answers, 'freq')
    const main = DiagnoseService.optionId(answers, 'main')
    const load = DiagnoseService.optionId(answers, 'load')
    const goal = DiagnoseService.optionId(answers, 'goal')
    const rest = DiagnoseService.optionId(answers, 'rest')
    const pain = DiagnoseService.optionId(answers, 'pain')

    const report = new DiagnoseReport()
    report.title = '训练配比复盘'
    report.generatedAt = DiagnoseService.nowLabel()
    report.summary =
      `根据问卷：频率「${DiagnoseService.labelOf(answers, 'freq')}」、` +
      `主项「${DiagnoseService.labelOf(answers, 'main')}」、` +
      `目标「${DiagnoseService.labelOf(answers, 'goal')}」。` +
      `以下为规则模板建议，供自行调整训练，不构成医疗意见。`
    report.strength = DiagnoseService.strengthText(freq, main)
    report.weakness = DiagnoseService.weaknessText(load, rest, pain)
    report.opportunity = DiagnoseService.opportunityText(goal, main)
    report.threat = DiagnoseService.threatText(pain, rest, load)
    report.actions = DiagnoseService.actions(goal, pain, freq)
    report.matchCategory = DiagnoseService.matchCategory(goal)
    report.matchHint = `建议下一笔记录按「${report.matchCategory}」模板开练，并写清收获与下次重点。`
    report.scoreLabel = DiagnoseService.scoreLabel(freq, load, pain, rest)
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

  private static strengthText(freq: string, main: string): string {
    if (freq === 'f4') {
      return '训练频率已经成型，适合用挑战把次数锁进赛季目标。'
    }
    if (freq === 'f2') {
      return `已有稳定主项（${main === 'mix' ? '混合' : '专项'}），可在记录里对照个人最佳。`
    }
    return '起点清晰：先用模板完成 2 次可执行训练，比追求完美计划更重要。'
  }

  private static weaknessText(load: string, rest: string, pain: string): string {
    if (pain === 'yes') {
      return '不适已影响动作，应降低强度、缩短时长，并在复盘写明下次重点。'
    }
    if (rest === 'none' && load === 'hard') {
      return '连续高负荷且缺少休息日，配比偏满，恢复窗口不足。'
    }
    if (load === 'easy' && rest === 'two') {
      return '负荷偏轻，若目标是提升，可在下一笔适当加距离或组数。'
    }
    return '负荷与休息基本匹配，可用挑战把本周次数可视化。'
  }

  private static opportunityText(goal: string, main: string): string {
    if (goal === 'endurance') {
      return '用「跑步/骑行 30 分」模板连续打卡，日历上会形成可见的耐力条带。'
    }
    if (goal === 'strength') {
      return '力量日写清收获（哪一组完成），比只记分钟数更能对照进步。'
    }
    if (goal === 'skill') {
      return '球类记录加上比赛日体感，方便和日常训练区分。'
    }
    return '先把频率做成 7 日挑战，主项可保持当前选择。'
  }

  private static threatText(pain: string, rest: string, load: string): string {
    if (pain === 'yes') {
      return '带伤加量是最常见的中断原因，优先保动作质量。'
    }
    if (rest === 'none') {
      return '无休息日会让连续天数虚高，实际恢复不足。'
    }
    if (load === 'hard') {
      return '连续吃力训练后若仍加码，容易掉出节奏。'
    }
    return '最大风险是只看次数不写复盘，进步无法复用。'
  }

  private static actions(goal: string, pain: string, freq: string): string[] {
    const list: string[] = []
    if (pain === 'yes') {
      list.push('下一笔改用室内/轻松体感，时长减半，写清不适部位。')
    } else if (freq === 'f0') {
      list.push('今天用模板完成 1 次 30 分钟训练并保存。')
    } else {
      list.push('新建一条本周挑战（次数目标），让进度环跟着记录走。')
    }
    if (goal === 'endurance') {
      list.push('连续 3 笔跑步/骑行都填写距离，方便对照个人最佳。')
    } else if (goal === 'strength') {
      list.push('力量记录在「收获」写完成组数，在「下次重点」写薄弱肌群。')
    } else {
      list.push('每次结束后用 20 秒写收获，日历点进去能看到完整复盘。')
    }
    list.push('需要时把成长轨迹复制到剪贴板，方便自己存档。')
    return list
  }

  private static matchCategory(goal: string): string {
    if (goal === 'endurance') {
      return '耐力模板'
    }
    if (goal === 'strength') {
      return '力量模板'
    }
    if (goal === 'skill') {
      return '专项模板'
    }
    return '频率挑战'
  }

  private static scoreLabel(freq: string, load: string, pain: string, rest: string): string {
    let score = 68
    if (freq === 'f4') {
      score += 10
    } else if (freq === 'f0') {
      score -= 8
    }
    if (pain === 'yes') {
      score -= 12
    }
    if (rest === 'none') {
      score -= 6
    }
    if (load === 'ok') {
      score += 4
    }
    if (score >= 80) {
      return '配比健康，可加挑战'
    }
    if (score >= 62) {
      return '节奏可用，建议微调'
    }
    return '先降强度保连贯'
  }
}
