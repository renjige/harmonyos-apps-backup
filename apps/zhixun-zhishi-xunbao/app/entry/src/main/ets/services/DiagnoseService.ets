import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'

/**
 * 问卷 → 规则模板主题匹配（不调用大模型）。
 */
export class DiagnoseService {
  static questions(): DiagnoseQuestion[] {
    return [
      DiagnoseQuestion.of('interest', '你更想先探索哪类知识？', [
        DiagnoseOption.of('history', '历史探秘'),
        DiagnoseOption.of('science', '科学发现'),
        DiagnoseOption.of('culture', '文化艺术'),
        DiagnoseOption.of('nature', '自然奇观'),
        DiagnoseOption.of('life', '生活智慧')
      ]),
      DiagnoseQuestion.of('time', '每次大概能投入多久？', [
        DiagnoseOption.of('short', '5 分钟内'),
        DiagnoseOption.of('mid', '10–15 分钟'),
        DiagnoseOption.of('long', '20 分钟以上')
      ]),
      DiagnoseQuestion.of('diff', '更习惯的闯关难度？', [
        DiagnoseOption.of('easy', '轻松入门'),
        DiagnoseOption.of('mix', '循序渐进'),
        DiagnoseOption.of('hard', '挑战高阶')
      ]),
      DiagnoseQuestion.of('goal', '你最看重的收获？', [
        DiagnoseOption.of('story', '故事与典故'),
        DiagnoseOption.of('fact', '原理与事实'),
        DiagnoseOption.of('skill', '能用上的小知识'),
        DiagnoseOption.of('collect', '点亮宝藏与徽章')
      ]),
      DiagnoseQuestion.of('pace', '学习节奏更接近？', [
        DiagnoseOption.of('daily', '每天一小关'),
        DiagnoseOption.of('weekend', '周末集中闯关'),
        DiagnoseOption.of('burst', '有空就连闯几张')
      ]),
      DiagnoseQuestion.of('retry', '答错时你更倾向？', [
        DiagnoseOption.of('parse', '先看解析再继续'),
        DiagnoseOption.of('retry', '马上再试一次'),
        DiagnoseOption.of('later', '先换一张地图')
      ]),
      DiagnoseQuestion.of('scene', '常用场景？', [
        DiagnoseOption.of('commute', '通勤碎片时间'),
        DiagnoseOption.of('night', '睡前放松'),
        DiagnoseOption.of('family', '和家人一起玩')
      ]),
      DiagnoseQuestion.of('next', '匹配完成后希望？', [
        DiagnoseOption.of('map', '直接去知识地图'),
        DiagnoseOption.of('checkin', '先去发现页签到'),
        DiagnoseOption.of('vault', '看看宝藏与徽章')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const interest = DiagnoseService.optionId(answers, 'interest')
    const time = DiagnoseService.optionId(answers, 'time')
    const diff = DiagnoseService.optionId(answers, 'diff')
    const goal = DiagnoseService.optionId(answers, 'goal')
    const next = DiagnoseService.optionId(answers, 'next')

    const report = new DiagnoseReport()
    report.title = '主题匹配报告'
    report.generatedAt = DiagnoseService.nowLabel()
    report.summary =
      `基于问卷：兴趣「${DiagnoseService.labelOf(answers, 'interest')}」、` +
      `时长「${DiagnoseService.labelOf(answers, 'time')}」、` +
      `难度「${DiagnoseService.labelOf(answers, 'diff')}」。` +
      `以下为规则模板建议，仅供参考，不构成学历或考试承诺。`
    report.strength = DiagnoseService.strengthText(interest, time, goal)
    report.weakness = DiagnoseService.weaknessText(diff, time)
    report.opportunity = DiagnoseService.opportunityText(interest, next)
    report.threat = DiagnoseService.threatText(diff)
    report.actions = DiagnoseService.actions(interest, next)
    report.matchCategory = DiagnoseService.matchCategory(interest)
    report.matchHint =
      `建议先打开「${report.matchCategory}」分类，选一张封面地图开始寻宝。`
    report.scoreLabel = DiagnoseService.scoreLabel(time, diff)
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

  private static strengthText(interest: string, time: string, goal: string): string {
    let s = '你已经明确了想探索的方向，适合用主题地图代替零散浏览。'
    if (time === 'daily' || time === 'short') {
      s = `${s} 碎片时间也能完成一张入门地图。`
    }
    if (goal === 'collect') {
      s = `${s} 宝藏与徽章会给你持续的完成感。`
    }
    if (interest === 'life') {
      s = `${s} 生活智慧类题目更贴近日常。`
    }
    return s
  }

  private static weaknessText(diff: string, time: string): string {
    let w = '如果一次选太难的地图，容易在重试次数用尽前放弃。'
    if (diff === 'hard') {
      w = '高阶题需要先看解析再前进，建议从一星地图热身。'
    }
    if (time === 'short') {
      w = `${w} 时长较短时优先选 6 题入门图。`
    }
    return w
  }

  private static opportunityText(interest: string, next: string): string {
    let o = `「${DiagnoseService.matchCategory(interest)}」下有多张独立封面地图可连闯。`
    if (next === 'checkin') {
      o = `${o} 可先领取今日智慧再开图。`
    }
    if (next === 'vault') {
      o = `${o} 通关后到「我的宝藏」回顾收获。`
    }
    return o
  }

  private static threatText(diff: string): string {
    if (diff === 'hard') {
      return '连续答错会消耗本关 3 次重试，建议答完先读解析。'
    }
    return '中途退出不会扣智慧值，但进度需重新开图。'
  }

  private static actions(interest: string, next: string): string[] {
    const list: string[] = []
    list.push(`进入知识地图，筛选「${DiagnoseService.matchCategory(interest)}」。`)
    list.push('点开一张封面图，阅读简介后点「开始寻宝」。')
    if (next === 'checkin') {
      list.push('返回发现页领取今日智慧，再开始闯关。')
    } else if (next === 'vault') {
      list.push('通关后到「我的宝藏」查看刚点亮的卡片。')
    } else {
      list.push('全部答对后领取该图的知识宝藏。')
    }
    return list
  }

  private static matchCategory(interest: string): string {
    if (interest === 'science') {
      return '科学发现'
    }
    if (interest === 'culture') {
      return '文化艺术'
    }
    if (interest === 'nature') {
      return '自然奇观'
    }
    if (interest === 'life') {
      return '生活智慧'
    }
    return '历史探秘'
  }

  private static scoreLabel(time: string, diff: string): string {
    if (diff === 'easy' || time === 'short') {
      return '适合轻松开图'
    }
    if (diff === 'hard') {
      return '建议循序渐进'
    }
    return '节奏匹配良好'
  }
}
