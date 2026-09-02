import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'

/** 问卷 → 个人成长模板报告（纯规则，不调用大模型）。 */
export class DiagnoseService {
  static questions(): DiagnoseQuestion[] {
    return [
      DiagnoseQuestion.of('focus', '最近最想推进的方向？', [
        DiagnoseOption.of('learn', '学习与技能'),
        DiagnoseOption.of('health', '运动与作息'),
        DiagnoseOption.of('career', '职业与作品'),
        DiagnoseOption.of('mood', '情绪与关系'),
        DiagnoseOption.of('habit', '日常习惯')
      ]),
      DiagnoseQuestion.of('energy', '这一周精力如何？', [
        DiagnoseOption.of('high', '比较充沛'),
        DiagnoseOption.of('mid', '起伏明显'),
        DiagnoseOption.of('low', '经常疲惫')
      ]),
      DiagnoseQuestion.of('rhythm', '记录与行动的节奏？', [
        DiagnoseOption.of('daily', '几乎每天都有动作'),
        DiagnoseOption.of('weekly', '一周能做几次'),
        DiagnoseOption.of('rare', '常常中断')
      ]),
      DiagnoseQuestion.of('block', '最常卡住的原因？', [
        DiagnoseOption.of('time', '时间碎片化'),
        DiagnoseOption.of('plan', '目标太大无从下手'),
        DiagnoseOption.of('mood', '情绪波动'),
        DiagnoseOption.of('feedback', '缺少可见反馈')
      ]),
      DiagnoseQuestion.of('support', '目前的支持系统？', [
        DiagnoseOption.of('self', '主要靠自己'),
        DiagnoseOption.of('peer', '有同伴或家人提醒'),
        DiagnoseOption.of('tool', '靠工具和提醒')
      ]),
      DiagnoseQuestion.of('horizon', '接下来 30 天更想看到？', [
        DiagnoseOption.of('streak', '连续打卡不断档'),
        DiagnoseOption.of('goal', '完成一个小目标'),
        DiagnoseOption.of('review', '每周都有复盘'),
        DiagnoseOption.of('record', '把过程写下来')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const focus = DiagnoseService.optionId(answers, 'focus')
    const energy = DiagnoseService.optionId(answers, 'energy')
    const rhythm = DiagnoseService.optionId(answers, 'rhythm')
    const block = DiagnoseService.optionId(answers, 'block')
    const horizon = DiagnoseService.optionId(answers, 'horizon')

    const report = new DiagnoseReport()
    report.title = '个人成长诊断报告'
    report.generatedAt = DiagnoseService.nowLabel()
    report.summary =
      `基于问卷：方向「${DiagnoseService.labelOf(answers, 'focus')}」、` +
      `节奏「${DiagnoseService.labelOf(answers, 'rhythm')}」、` +
      `卡点「${DiagnoseService.labelOf(answers, 'block')}」。` +
      `以下为规则模板建议，供你对照调整，不是心理或医疗诊断。`
    report.strength = DiagnoseService.strengthText(energy, rhythm)
    report.weakness = DiagnoseService.weaknessText(block, energy)
    report.opportunity = DiagnoseService.opportunityText(focus, horizon)
    report.threat = DiagnoseService.threatText(rhythm, block)
    report.actions = DiagnoseService.actions(focus, horizon, block)
    report.matchCategory = DiagnoseService.matchCategory(horizon, focus)
    report.matchHint =
      `下一步建议优先使用「${report.matchCategory}」，把诊断落到本周一次可完成的动作。`
    report.scoreLabel = DiagnoseService.scoreLabel(energy, rhythm)
    return report
  }

  private static optionId(answers: DiagnoseAnswer[], qid: string): string {
    for (let i = 0; i < answers.length; i++) {
      if (answers[i].questionId === qid) {
        return answers[i].optionId
      }
    }
    return ''
  }

  private static labelOf(answers: DiagnoseAnswer[], qid: string): string {
    for (let i = 0; i < answers.length; i++) {
      if (answers[i].questionId === qid) {
        return answers[i].optionLabel
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

  private static strengthText(energy: string, rhythm: string): string {
    if (rhythm === 'daily') {
      return '你已经有稳定的行动节奏，适合把力量集中到一个可量化的小目标上。'
    }
    if (energy === 'high') {
      return '精力储备不错，适合用习惯打卡把热情固化成每日动作。'
    }
    return '愿意停下来做诊断，本身就是自我管理的开始。'
  }

  private static weaknessText(block: string, energy: string): string {
    if (block === 'plan') {
      return '目标颗粒度偏大，容易启动失败。需要拆到「今天 15 分钟能做完」的尺寸。'
    }
    if (block === 'time') {
      return '时间被碎片占满时，记录和打卡最先被牺牲。需要固定一个不会被挤掉的时间窗。'
    }
    if (block === 'mood' || energy === 'low') {
      return '情绪或精力波动会打断连续性。用短记录代替完美日记，降低启动成本。'
    }
    return '缺少即时反馈时，坚持很难被看见。进度条和连续天数能补上这一环。'
  }

  private static opportunityText(focus: string, horizon: string): string {
    if (horizon === 'streak') {
      return '用习惯打卡建立连续天数，比一次冲刺更能形成身份认同。'
    }
    if (horizon === 'review') {
      return '每周四问复盘能帮你看见模式：什么有效、什么该停。'
    }
    if (focus === 'learn' || focus === 'career') {
      return '把学习或作品拆成可记录的节点，时间轴会成为作品集。'
    }
    return '把过程写下来，未来的你能看见这段时间并没有缺席。'
  }

  private static threatText(rhythm: string, block: string): string {
    if (rhythm === 'rare') {
      return '长期中断会让自我评价变差，建议先追求「不断档」而不是「做得完美」。'
    }
    if (block === 'plan') {
      return '目标过大时容易全盘放弃。一次只保留一个主目标。'
    }
    return '同时开太多方向会稀释反馈。本月只选一个主战场。'
  }

  private static actions(focus: string, horizon: string, block: string): string[] {
    const list: string[] = []
    list.push('从诊断结论里选出本周唯一主任务，写进成长目标并设一个可打勾的进度。')
    if (horizon === 'streak' || focus === 'habit' || focus === 'health') {
      list.push('创建一个每日习惯，连续打卡 7 天，允许某一天只做最小版本。')
    } else if (horizon === 'review') {
      list.push('本周日完成一份四问复盘，并据此修正下周目标。')
    } else {
      list.push('今天写一条成长记录：发生了什么、你做了什么、下一步是什么。')
    }
    if (block === 'plan') {
      list.push('把大目标改成「本周只完成第一步」，进度条从 10% 开始。')
    }
    list.push('打开「我的」查看个人数据；数据只统计你自己产生的记录，不会预填他人内容。')
    return list
  }

  private static matchCategory(horizon: string, focus: string): string {
    if (horizon === 'streak' || focus === 'habit' || focus === 'health') {
      return '习惯打卡'
    }
    if (horizon === 'review') {
      return '每周复盘'
    }
    if (horizon === 'goal' || focus === 'career') {
      return '成长目标'
    }
    return '成长记录'
  }

  private static scoreLabel(energy: string, rhythm: string): string {
    if (rhythm === 'daily' && energy !== 'low') {
      return '节奏稳定，适合加码'
    }
    if (rhythm === 'rare' || energy === 'low') {
      return '先恢复连续性'
    }
    return '有改进空间'
  }
}
