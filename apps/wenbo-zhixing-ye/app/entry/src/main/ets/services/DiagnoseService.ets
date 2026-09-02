import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'

/** 学情自检：问卷 → 模板报告（纯规则，不调用大模型）。 */
export class DiagnoseService {
  static questions(): DiagnoseQuestion[] {
    return [
      DiagnoseQuestion.of('capture', '你多久把学到的写成笔记或卡片？', [
        DiagnoseOption.of('daily', '几乎每天'),
        DiagnoseOption.of('week', '每周几次'),
        DiagnoseOption.of('rare', '偶尔想到才写'),
        DiagnoseOption.of('never', '几乎不写')
      ]),
      DiagnoseQuestion.of('act', '知识有没有变成计划或习惯？', [
        DiagnoseOption.of('often', '经常转化'),
        DiagnoseOption.of('sometimes', '偶尔转化'),
        DiagnoseOption.of('planonly', '只有计划很少执行'),
        DiagnoseOption.of('none', '几乎没有转化')
      ]),
      DiagnoseQuestion.of('read', '阅读时你如何做摘要？', [
        DiagnoseOption.of('struct', '标题+要点+自己的话'),
        DiagnoseOption.of('copy', '主要摘抄原句'),
        DiagnoseOption.of('progress', '只记进度不写摘要'),
        DiagnoseOption.of('none', '读完就算')
      ]),
      DiagnoseQuestion.of('plan', '学习计划完成情况？', [
        DiagnoseOption.of('good', '大多能按时推进'),
        DiagnoseOption.of('half', '完成一半左右'),
        DiagnoseOption.of('slip', '经常延期'),
        DiagnoseOption.of('noplan', '很少制定计划')
      ]),
      DiagnoseQuestion.of('habit', '有没有固定学习习惯？', [
        DiagnoseOption.of('streak', '连续打卡中'),
        DiagnoseOption.of('try', '刚开始培养'),
        DiagnoseOption.of('break', '经常中断'),
        DiagnoseOption.of('none', '没有习惯')
      ]),
      DiagnoseQuestion.of('tag', '你用标签整理知识吗？', [
        DiagnoseOption.of('sys', '有稳定标签体系'),
        DiagnoseOption.of('some', '有时会打标签'),
        DiagnoseOption.of('messy', '标签很乱'),
        DiagnoseOption.of('none', '几乎不用标签')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const capture = DiagnoseService.optionId(answers, 'capture')
    const act = DiagnoseService.optionId(answers, 'act')
    const read = DiagnoseService.optionId(answers, 'read')
    const plan = DiagnoseService.optionId(answers, 'plan')
    const habit = DiagnoseService.optionId(answers, 'habit')
    const tag = DiagnoseService.optionId(answers, 'tag')
    const report = new DiagnoseReport()
    report.title = '学情自检报告'
    report.generatedAt = DiagnoseService.nowLabel()
    report.summary =
      `基于问卷：捕获「${DiagnoseService.labelOf(answers, 'capture')}」、` +
      `转化「${DiagnoseService.labelOf(answers, 'act')}」、` +
      `阅读「${DiagnoseService.labelOf(answers, 'read')}」。结论为规则模板，仅供自我对照。`
    report.strength = DiagnoseService.strengthText(capture, habit, tag)
    report.weakness = DiagnoseService.weaknessText(act, plan, read)
    report.opportunity = DiagnoseService.opportunityText(tag, capture)
    report.threat = DiagnoseService.threatText(act, habit)
    report.actions = DiagnoseService.actions(capture, act, plan)
    report.matchCategory = DiagnoseService.matchCategory(act, capture)
    report.matchHint = `建议下一步：${report.matchCategory}。回到知库或行录完成一次具体动作。`
    report.scoreLabel = DiagnoseService.scoreLabel(capture, act, plan, habit)
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

  private static strengthText(capture: string, habit: string, tag: string): string {
    if (capture === 'daily' || habit === 'streak') {
      return '你已经有持续记录或打卡的节奏，这是知行闭环最难得的底座。'
    }
    if (tag === 'sys') {
      return '标签体系清楚，知识图谱会更容易长出来。'
    }
    return '你愿意做学情自检，说明已经开始正视「学了却没落地」的问题。'
  }

  private static weaknessText(act: string, plan: string, read: string): string {
    if (act === 'none' || act === 'planonly') {
      return '知识停留在知库，较少进入行录，转化是当前短板。'
    }
    if (plan === 'slip' || plan === 'noplan') {
      return '计划不稳定，进度难以被看见，容易半途而废。'
    }
    if (read === 'none' || read === 'copy') {
      return '阅读还没有变成自己的结构化摘要，复用成本高。'
    }
    return '各环节都有，但还不够稳定，需要一个最小闭环固定下来。'
  }

  private static opportunityText(tag: string, capture: string): string {
    if (tag === 'none' || tag === 'messy') {
      return '先给现有卡片补 3 个标签，图谱和推荐阅读会立刻变得有用。'
    }
    if (capture === 'rare' || capture === 'never') {
      return '每天只写一张卡片，比完美体系更重要。'
    }
    return '可以把最高频标签绑定一个习惯打卡，让「知」自动催生「行」。'
  }

  private static threatText(act: string, habit: string): string {
    if (act === 'none' && habit === 'none') {
      return '若继续只输入不输出，知识会堆积成负担。'
    }
    if (habit === 'break') {
      return '习惯反复中断会打击信心，建议把目标降到每天 10 分钟。'
    }
    return '信息过载而行动不足，是最常见的学习疲劳来源。'
  }

  private static actions(capture: string, act: string, plan: string): string[] {
    const list: string[] = []
    list.push('今天在知库新建一张知识卡片，写清标题、摘要和两个标签。')
    if (act === 'none' || act === 'planonly') {
      list.push('把这张卡片转成一条学习计划，进度先设为 10%。')
    } else {
      list.push('给一个进行中的计划更新进度，或写一条行动日志。')
    }
    if (plan === 'noplan') {
      list.push('只设一个本周目标，截止日期用日历选择，不要同时开三个。')
    } else {
      list.push('开启智慧页的学习提醒，选一个固定晚上时间。')
    }
    if (capture === 'never' || capture === 'rare') {
      list.push('连续 3 天各写一张卡片，用打卡习惯托住记录。')
    }
    return list
  }

  private static matchCategory(act: string, capture: string): string {
    if (capture === 'never' || capture === 'rare') {
      return '去知库写卡片'
    }
    if (act === 'none' || act === 'planonly') {
      return '去行录建计划'
    }
    return '去智慧页开提醒'
  }

  private static scoreLabel(capture: string, act: string, plan: string, habit: string): string {
    let score = 62
    if (capture === 'daily') {
      score += 10
    }
    if (act === 'often') {
      score += 10
    }
    if (plan === 'good') {
      score += 8
    }
    if (habit === 'streak') {
      score += 8
    }
    if (capture === 'never') {
      score -= 8
    }
    if (act === 'none') {
      score -= 8
    }
    if (score >= 80) {
      return '知行节奏较好'
    }
    if (score >= 65) {
      return '有改进空间'
    }
    return '建议先完成一个最小闭环'
  }
}
