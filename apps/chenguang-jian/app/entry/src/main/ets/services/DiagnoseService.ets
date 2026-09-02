import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'

/** 书写习惯自检：问卷 + 规则模板，不调用大模型。 */
export class DiagnoseService {
  static questions(): DiagnoseQuestion[] {
    return [
      DiagnoseQuestion.of('when', '你更常在什么时候写？', [
        DiagnoseOption.of('dawn', '清晨，刚醒来'),
        DiagnoseOption.of('noon', '午间空隙'),
        DiagnoseOption.of('night', '夜里灯只留一盏'),
        DiagnoseOption.of('any', '念头来了就写')
      ]),
      DiagnoseQuestion.of('len', '一张笺对你来说多长刚刚好？', [
        DiagnoseOption.of('line', '一两行就够'),
        DiagnoseOption.of('para', '一小段'),
        DiagnoseOption.of('page', '写满一页才安心')
      ]),
      DiagnoseQuestion.of('freq', '最近一周，你希望自己写几次？', [
        DiagnoseOption.of('daily', '每天一张'),
        DiagnoseOption.of('few', '两三张'),
        DiagnoseOption.of('one', '一张也很好')
      ]),
      DiagnoseQuestion.of('hard', '最容易让你停笔的是？', [
        DiagnoseOption.of('blank', '空白页的压力'),
        DiagnoseOption.of('time', '觉得没有整块时间'),
        DiagnoseOption.of('perfect', '总想写得更漂亮'),
        DiagnoseOption.of('forget', '写完就找不到')
      ]),
      DiagnoseQuestion.of('tag', '标签对你意味着？', [
        DiagnoseOption.of('later', '方便以后再遇见'),
        DiagnoseOption.of('now', '写的时候理清念头'),
        DiagnoseOption.of('skip', '暂时不太需要')
      ]),
      DiagnoseQuestion.of('goal', '这一个月，你更想留下什么？', [
        DiagnoseOption.of('mood', '心情的痕迹'),
        DiagnoseOption.of('idea', '一闪而过的念头'),
        DiagnoseOption.of('day', '普通日子的切片')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const when = DiagnoseService.optionId(answers, 'when')
    const hard = DiagnoseService.optionId(answers, 'hard')
    const freq = DiagnoseService.optionId(answers, 'freq')
    const goal = DiagnoseService.optionId(answers, 'goal')

    const report = new DiagnoseReport()
    report.title = '书写习惯对照'
    report.generatedAt = DiagnoseService.nowLabel()
    report.summary =
      `根据你的选择：时段「${DiagnoseService.labelOf(answers, 'when')}」、` +
      `频率「${DiagnoseService.labelOf(answers, 'freq')}」、` +
      `想留下「${DiagnoseService.labelOf(answers, 'goal')}」。` +
      `以下为规则模板建议，不是心理评估。`
    report.strength = when === 'dawn' ?
      '你已经把书写放在一天最安静的位置，晨光笺会更适合你。' :
      '你允许念头在任何时刻落纸，这本身就是一种轻盈。'
    report.weakness = hard === 'perfect' ?
      '对「写得漂亮」的期待，容易挡住第一行。' :
      (hard === 'blank' ? '空白页会放大自我要求，先写三个字即可。' : '停笔往往不是没话说，而是入口太重。')
    report.opportunity = freq === 'daily' ?
      '把「每天一张」当成轻轻打卡，而不是作业。' :
      '低频率也可以连续：连续天数看的是有没有留下痕迹。'
    report.threat = '若把笺写成日记任务清单，仪式感会变薄。允许普通，允许短。'
    report.actions = [
      '打开笺集，写一行不必成篇的句子',
      '让智慧标签自动出现，不必先分类',
      '用月视图回看，而不是苛责空白的日子'
    ]
    report.matchCategory = '写一张新笺'
    report.matchHint = goal === 'idea' ? '把一闪而过的念头先按进纸里。' : '给今天留一张信笺就够了。'
    report.scoreLabel = '可开始'
    return report
  }

  private static optionId(answers: DiagnoseAnswer[], questionId: string): string {
    for (const a of answers) {
      if (a.questionId === questionId) {
        return a.optionId
      }
    }
    return ''
  }

  private static labelOf(answers: DiagnoseAnswer[], questionId: string): string {
    for (const a of answers) {
      if (a.questionId === questionId) {
        return a.optionLabel
      }
    }
    return ''
  }

  private static nowLabel(): string {
    const d = new Date()
    return `${d.getMonth() + 1}月${d.getDate()}日`
  }
}
