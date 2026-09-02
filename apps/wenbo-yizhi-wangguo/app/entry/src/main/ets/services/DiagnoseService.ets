import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'

/** 能力小测：问卷 + 规则模板，不调用大模型。 */
export class DiagnoseService {
  static questions(): DiagnoseQuestion[] {
    return [
      DiagnoseQuestion.of('age', '孩子现在更接近哪个阶段？', [
        DiagnoseOption.of('pre', '3–6 岁，喜欢认形状颜色'),
        DiagnoseOption.of('low', '6–9 岁，开始数顺序'),
        DiagnoseOption.of('mid', '9–12 岁，能做简单推理')
      ]),
      DiagnoseQuestion.of('like', '平时更愿意玩哪一类？', [
        DiagnoseOption.of('shape', '积木 / 拼图'),
        DiagnoseOption.of('color', '涂色 / 颜料'),
        DiagnoseOption.of('maze', '找路线 / 排队'),
        DiagnoseOption.of('reason', '为什么 / 故事因果')
      ]),
      DiagnoseQuestion.of('pace', '作答时更常见的是？', [
        DiagnoseOption.of('slow', '慢慢看，不怕想'),
        DiagnoseOption.of('fast', '很快点，偶尔看错'),
        DiagnoseOption.of('mix', '看心情')
      ]),
      DiagnoseQuestion.of('time', '每天大概能拿出多久？', [
        DiagnoseOption.of('mini', '5 分钟左右'),
        DiagnoseOption.of('short', '10–15 分钟'),
        DiagnoseOption.of('long', '更久也可以')
      ]),
      DiagnoseQuestion.of('goal', '家长更希望先练什么？', [
        DiagnoseOption.of('observe', '把东西看仔细'),
        DiagnoseOption.of('logic', '把顺序和因果理清'),
        DiagnoseOption.of('habit', '每天坚持一小步')
      ]),
      DiagnoseQuestion.of('mood', '答错时孩子通常？', [
        DiagnoseOption.of('retry', '愿意再试'),
        DiagnoseOption.of('stop', '容易停下来'),
        DiagnoseOption.of('ask', '会问为什么')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const like = DiagnoseService.optionId(answers, 'like')
    const goal = DiagnoseService.optionId(answers, 'goal')
    const time = DiagnoseService.optionId(answers, 'time')
    const report = new DiagnoseReport()
    report.title = '能力小测说明'
    report.generatedAt = DiagnoseService.nowLabel()
    report.summary =
      `根据勾选：兴趣「${DiagnoseService.labelOf(answers, 'like')}」、` +
      `目标「${DiagnoseService.labelOf(answers, 'goal')}」。` +
      `以下为规则模板建议，不是智力测评，也不承诺提高考试成绩。`
    if (like === 'shape') {
      report.strength = '图形与空间观察是当前兴趣点。'
      report.matchCategory = '形状花园 / 图形密林'
    } else if (like === 'color') {
      report.strength = '色彩感知是当前兴趣点。'
      report.matchCategory = '颜色城堡 / 彩虹塔'
    } else if (like === 'maze') {
      report.strength = '顺序与路径是当前兴趣点。'
      report.matchCategory = '数字小径 / 迷宫钟楼'
    } else {
      report.strength = '生活因果与排除是当前兴趣点。'
      report.matchCategory = '因果小屋 / 推理庭院'
    }
    report.weakness = '一次走太多关容易累，建议按关卡星级慢慢开。'
    report.opportunity = time === 'mini' ? '用「每日益智」保持轻量习惯。' : '可以从当前石阶连续完成两关。'
    report.threat = '把闯关当成考试或排名，会让孩子紧张。'
    report.actions = [
      '从大厅点「踏上石阶」打开当前可玩关卡',
      goal === 'habit' ? '优先完成每日益智' : '优先完成兴趣匹配的关卡类型',
      '答错先看提示再选，不催促'
    ]
    report.matchHint = '报告页可继续查看星星与四维练习次数。'
    report.scoreLabel = '建议从当前关开始'
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
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms: string = m < 10 ? `0${m}` : `${m}`
    const ds: string = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${ms}-${ds}`
  }
}
