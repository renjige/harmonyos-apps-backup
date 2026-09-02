import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'

/** 阅读节律自检：问卷 + 模板报告，不调用大模型。 */
export class DiagnoseService {
  static questions(): DiagnoseQuestion[] {
    return [
      DiagnoseQuestion.of('when', '你通常在什么时候阅读？', [
        DiagnoseOption.of('morning', '早晨清醒时'),
        DiagnoseOption.of('commute', '通勤碎片时间'),
        DiagnoseOption.of('night', '晚上安静时'),
        DiagnoseOption.of('weekend', '周末集中补读')
      ]),
      DiagnoseQuestion.of('len', '单次阅读多久更舒服？', [
        DiagnoseOption.of('s', '15 分钟以内'),
        DiagnoseOption.of('m', '15–40 分钟'),
        DiagnoseOption.of('l', '40 分钟以上')
      ]),
      DiagnoseQuestion.of('goal', '此刻最想沉淀的是？', [
        DiagnoseOption.of('work', '职场方法与项目'),
        DiagnoseOption.of('study', '学习概念与笔记'),
        DiagnoseOption.of('life', '生活经验与习惯'),
        DiagnoseOption.of('method', '可复用的思考框架')
      ]),
      DiagnoseQuestion.of('excerpt', '你更习惯怎样摘录？', [
        DiagnoseOption.of('quote', '先抄原文'),
        DiagnoseOption.of('reflect', '先写感想'),
        DiagnoseOption.of('both', '原文和感想一起'),
        DiagnoseOption.of('rare', '很少摘录')
      ]),
      DiagnoseQuestion.of('review', '你希望多久回顾一次？', [
        DiagnoseOption.of('daily', '每天一条'),
        DiagnoseOption.of('week', '每周集中复习'),
        DiagnoseOption.of('need', '用到再翻'),
        DiagnoseOption.of('none', '还没建立回顾')
      ]),
      DiagnoseQuestion.of('block', '最常卡住你的是？', [
        DiagnoseOption.of('start', '不知道从哪篇开始'),
        DiagnoseOption.of('keep', '读着读着就放下'),
        DiagnoseOption.of('sort', '摘录散落无法归类'),
        DiagnoseOption.of('forget', '读过很快忘记')
      ]),
      DiagnoseQuestion.of('device', '主要在什么设备读？', [
        DiagnoseOption.of('phone', '手机'),
        DiagnoseOption.of('mix', '手机 + 电脑文档'),
        DiagnoseOption.of('paper', '纸书再转到手机')
      ]),
      DiagnoseQuestion.of('next', '下一步最想做的是？', [
        DiagnoseOption.of('import', '先导入一篇正在读的文稿'),
        DiagnoseOption.of('folio', '先建一本知识册'),
        DiagnoseOption.of('review', '先打开今日智慧卡片')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const goal = DiagnoseService.optionId(answers, 'goal')
    const block = DiagnoseService.optionId(answers, 'block')
    const next = DiagnoseService.optionId(answers, 'next')
    const report = new DiagnoseReport()
    report.title = '阅读节律报告'
    report.generatedAt = DiagnoseService.nowLabel()
    report.summary =
      `基于问卷：时段「${DiagnoseService.labelOf(answers, 'when')}」、` +
      `时长「${DiagnoseService.labelOf(answers, 'len')}」、` +
      `目标「${DiagnoseService.labelOf(answers, 'goal')}」。以下为规则模板建议，供你自己调整阅读节奏。`
    report.strength = DiagnoseService.strengthOf(answers)
    report.weakness = DiagnoseService.weakOf(block)
    report.opportunity = '用知识册把摘录按主题归位，每日智慧卡片只复习一条，比一次翻完全部更可持续。'
    report.threat = '只收藏不回顾，文稿进度会停在打开过的那一页。'
    report.actions = DiagnoseService.actionsOf(next, goal)
    report.matchCategory = DiagnoseService.matchOf(goal)
    report.matchHint = '点下方按钮：把本报告写入对应知识册，生成可阅读的节律计划文稿和一条可编辑摘录。'
    report.scoreLabel = block === 'forget' || block === 'sort' ? '适合先建回顾节奏' : '适合先打通阅读闭环'
    return report
  }

  private static strengthOf(answers: DiagnoseAnswer[]): string {
    const excerpt = DiagnoseService.optionId(answers, 'excerpt')
    if (excerpt === 'both') {
      return '你已经习惯原文与感想一起留下，知识册会很好用。'
    }
    if (excerpt === 'quote') {
      return '你重视原文，适合在阅读页复制后快速写入摘录。'
    }
    return '你愿意专门留一段时间阅读，这是最难得的起点。'
  }

  private static weakOf(block: string): string {
    if (block === 'start') {
      return '缺少「正在读」的明确文稿，首页继续阅读条会一直空着。'
    }
    if (block === 'keep') {
      return '进度没有被记住，下次只能重新找位置。'
    }
    if (block === 'sort') {
      return '摘录没有主题册，搜索时只能靠记忆。'
    }
    return '缺少每日一条的轻量回顾，读过的句子容易沉底。'
  }

  private static actionsOf(next: string, goal: string): string[] {
    const lines: string[] = []
    lines.push(next === 'folio' ? '先新建一本与当前主题同名的知识册' : '导入或粘贴一篇正在读的文稿')
    lines.push('阅读时复制一句原文，写入摘录并加上智慧归类标签')
    lines.push(goal === 'work' ? '收入「职场」封面的知识册，方便项目复用' : '打开今日智慧卡片，只复习一条')
    lines.push('在阅读页用 25%/50%/读完 更新进度，方便下次接续')
    return lines
  }

  private static matchOf(goal: string): string {
    if (goal === 'work') {
      return '职场知识册'
    }
    if (goal === 'study') {
      return '学习知识册'
    }
    if (goal === 'life') {
      return '生活知识册'
    }
    return '方法知识册'
  }

  static planDocBody(report: DiagnoseReport): string {
    let body = `${report.title}\n${report.scoreLabel} · ${report.generatedAt}\n\n`
    body += `${report.summary}\n\n`
    body += `优势：${report.strength}\n`
    body += `短板：${report.weakness}\n`
    body += `机会：${report.opportunity}\n`
    body += `风险：${report.threat}\n\n行动清单：\n`
    let n = 1
    for (const line of report.actions) {
      body += `${n}. ${line}\n`
      n++
    }
    body += `\n建议收入：${report.matchCategory}\n${report.matchHint}`
    return body
  }

  static excerptQuote(report: DiagnoseReport): string {
    let first = report.matchHint
    if (report.actions.length > 0) {
      first = report.actions[0]
    }
    return `【阅读节律】下一步：${first}`
  }

  static excerptReflection(report: DiagnoseReport): string {
    return `${report.summary}\n优势：${report.strength}\n短板：${report.weakness}`
  }

  private static optionId(answers: DiagnoseAnswer[], qid: string): string {
    for (const a of answers) {
      if (a.questionId === qid) {
        return a.optionId
      }
    }
    return ''
  }

  private static labelOf(answers: DiagnoseAnswer[], qid: string): string {
    for (const a of answers) {
      if (a.questionId === qid) {
        return a.optionLabel
      }
    }
    return '未填'
  }

  private static nowLabel(): string {
    const d = new Date()
    const m = d.getMonth() + 1
    const day = d.getDate()
    return `${d.getFullYear()}-${m < 10 ? '0' : ''}${m}-${day < 10 ? '0' : ''}${day}`
  }
}
