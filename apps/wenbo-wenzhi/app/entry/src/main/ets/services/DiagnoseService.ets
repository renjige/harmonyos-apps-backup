import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'

/**
 * 求知偏好问卷 → 模板报告 + 主题匹配（纯规则，不调用大模型）。
 */
export class DiagnoseService {
  static questions(): DiagnoseQuestion[] {
    return [
      DiagnoseQuestion.of('goal', '最近最想弄清楚的是？', [
        DiagnoseOption.of('work', '工作方法与专注'),
        DiagnoseOption.of('study', '阅读与记忆'),
        DiagnoseOption.of('life', '生活判断与习惯'),
        DiagnoseOption.of('mix', '都想兼顾一点')
      ]),
      DiagnoseQuestion.of('time', '每天能安静提问的时间？', [
        DiagnoseOption.of('short', '十分钟以内'),
        DiagnoseOption.of('mid', '半小时左右'),
        DiagnoseOption.of('long', '可以坐下来细看')
      ]),
      DiagnoseQuestion.of('style', '更喜欢哪种解答？', [
        DiagnoseOption.of('points', '先看三条要点'),
        DiagnoseOption.of('bg', '先看背景再看要点'),
        DiagnoseOption.of('further', '要点 + 延伸阅读')
      ]),
      DiagnoseQuestion.of('habit', '收藏之后通常会？', [
        DiagnoseOption.of('note', '写一句自己的备注'),
        DiagnoseOption.of('reread', '隔天再看一遍'),
        DiagnoseOption.of('idle', '收着但很少再打开')
      ]),
      DiagnoseQuestion.of('source', '看到一条消息时你会？', [
        DiagnoseOption.of('check', '先看来源和证据'),
        DiagnoseOption.of('feel', '先看情绪是否被带动'),
        DiagnoseOption.of('share', '先想要不要转发给别人')
      ]),
      DiagnoseQuestion.of('block', '最常卡住的地方？', [
        DiagnoseOption.of('start', '不知道从哪个问题问起'),
        DiagnoseOption.of('long', '长文抓不住主线'),
        DiagnoseOption.of('forget', '看过就忘')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const goal = DiagnoseService.optionId(answers, 'goal')
    const time = DiagnoseService.optionId(answers, 'time')
    const habit = DiagnoseService.optionId(answers, 'habit')
    const block = DiagnoseService.optionId(answers, 'block')
    const report = new DiagnoseReport()
    report.title = '求知偏好匹配报告'
    report.generatedAt = DiagnoseService.nowLabel()
    report.summary =
      `根据问卷：目标「${DiagnoseService.labelOf(answers, 'goal')}」、` +
      `时长「${DiagnoseService.labelOf(answers, 'time')}」。` +
      `以下为规则模板建议，供参考，不构成专业意见。`
    report.strength = time === 'long' ?
      '你愿意坐下来细看，适合完整阅读要点、背景与延伸。' :
      '短时间窗口也够用：先问一个具体问题，只带走三条要点。'
    report.weakness = habit === 'idle' ?
      '收藏后很少再打开，建议给每条收藏加一句备注，写清「下次在哪用」。' :
      '把收藏夹按工作 / 学习 / 生活分开，检索会更容易。'
    report.opportunity = goal === 'work' ?
      '优先从「番茄工作法」「会议纪要」类热门问题开始。' :
      (goal === 'study' ?
        '优先从「长文主线」「记笔记」类问题开始。' :
        '优先从「消息是否可靠」「睡眠与记忆」类生活问题开始。')
    report.threat = block === 'start' ?
      '没有问题可问时，点首页热门问题填入即可起步。' :
      '不要一次追问太多，先消化当前三条要点。'
    const actions: string[] = []
    actions.push('打开「问答」，输入或点选一个热门问题。')
    actions.push('读完要点后，点收藏并写一句备注。')
    actions.push('每天打开「新知」点一次已阅，养成连续阅读。')
    if (block === 'forget') {
      actions.push('隔天在知识库搜索关键词，用自己的话复述一条。')
    }
    report.actions = actions
    report.matchCategory = goal === 'work' ? '工作' : (goal === 'life' ? '生活' : '学习')
    report.matchHint = `建议先在知识库筛选「${report.matchCategory}」，或回问答页继续提问。`
    report.scoreLabel = time === 'short' ? '轻量起步' : '可加深阅读'
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
}
