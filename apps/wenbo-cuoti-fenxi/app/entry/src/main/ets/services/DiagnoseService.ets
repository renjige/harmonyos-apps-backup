import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'

/**
 * 学情问卷 → 复习计划模板（纯规则，不调用大模型）。
 */
export class DiagnoseService {
  static questions(): DiagnoseQuestion[] {
    return [
      DiagnoseQuestion.of('stage', '当前学段更接近？', [
        DiagnoseOption.of('primary', '小学'),
        DiagnoseOption.of('junior', '初中'),
        DiagnoseOption.of('senior', '高中'),
        DiagnoseOption.of('exam', '备考冲刺')
      ]),
      DiagnoseQuestion.of('subject', '最想先整理哪一科？', [
        DiagnoseOption.of('math', '数学'),
        DiagnoseOption.of('chinese', '语文'),
        DiagnoseOption.of('english', '英语'),
        DiagnoseOption.of('science', '理化生'),
        DiagnoseOption.of('arts', '史地政')
      ]),
      DiagnoseQuestion.of('source', '错题主要来自？', [
        DiagnoseOption.of('homework', '日常作业'),
        DiagnoseOption.of('quiz', '随堂小测'),
        DiagnoseOption.of('exam', '阶段考试'),
        DiagnoseOption.of('self', '自己加练')
      ]),
      DiagnoseQuestion.of('cause', '最常见的错因？', [
        DiagnoseOption.of('concept', '概念不清'),
        DiagnoseOption.of('careless', '粗心大意'),
        DiagnoseOption.of('misread', '审题错误'),
        DiagnoseOption.of('method', '方法不当')
      ]),
      DiagnoseQuestion.of('time', '每周能拿出多少时间复盘？', [
        DiagnoseOption.of('short', '不到 1 小时'),
        DiagnoseOption.of('mid', '1～3 小时'),
        DiagnoseOption.of('long', '3 小时以上')
      ]),
      DiagnoseQuestion.of('goal', '最想先改善哪一点？', [
        DiagnoseOption.of('find', '能找到同类错题'),
        DiagnoseOption.of('order', '知道先复习什么'),
        DiagnoseOption.of('keep', '掌握后不再回潮'),
        DiagnoseOption.of('parent', '家长能看懂进度')
      ]),
      DiagnoseQuestion.of('habit', '现在错题本怎么用？', [
        DiagnoseOption.of('none', '几乎没记'),
        DiagnoseOption.of('paper', '纸质本，难检索'),
        DiagnoseOption.of('photo', '只拍照不分类'),
        DiagnoseOption.of('ok', '有在用，但缺分析')
      ]),
      DiagnoseQuestion.of('next', '做完问卷希望马上做什么？', [
        DiagnoseOption.of('capture', '去录入一道题'),
        DiagnoseOption.of('analyze', '先看分析页'),
        DiagnoseOption.of('method', '看纠错方法卡')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const cause = DiagnoseService.optionId(answers, 'cause')
    const time = DiagnoseService.optionId(answers, 'time')
    const goal = DiagnoseService.optionId(answers, 'goal')
    const next = DiagnoseService.optionId(answers, 'next')
    const report = new DiagnoseReport()
    report.title = '本周复习计划'
    report.generatedAt = DiagnoseService.nowLabel()
    report.summary =
      `基于问卷：学段「${DiagnoseService.labelOf(answers, 'stage')}」、` +
      `主攻「${DiagnoseService.labelOf(answers, 'subject')}」、` +
      `错因「${DiagnoseService.labelOf(answers, 'cause')}」。` +
      `以下为规则模板，不是生成式内容，也不承诺提高成绩。`
    report.strength = '你愿意把错过的题留下来，这已经比只看正确答案更进一步。'
    if (cause === 'concept') {
      report.weakness = '概念站不稳时，刷同类题会反复错。需要先默写定义再动笔。'
    } else if (cause === 'careless') {
      report.weakness = '会做但写错，说明检查清单比再讲一遍公式更重要。'
    } else {
      report.weakness = '审题或方法选择不稳，建议在题旁写下题型和方法两个词。'
    }
    report.opportunity = time === 'short' ?
      '时间少就只处理分析页前 3 个薄弱标签。' :
      '可以把周末导出一页待复习，限时重做。'
    report.threat = '只收藏不回看，错题本会变成相册。掌握后隔天再看题干。'
    report.actions = [
      '今天录入本周错过的代表题，写清知识点标签',
      '打开分析页，只处理出现两次以上的标签',
      '对应错因走一遍纠错方法卡',
      '做对后标记掌握，说不出步骤就改回待复习'
    ]
    if (goal === 'parent') {
      report.actions.push('家长只问三句：错因、下次怎么检查、要不要导出')
    }
    report.matchCategory = next === 'analyze' ? '智慧分析' : (next === 'method' ? '纠错方法' : '错题录入')
    report.matchHint = next === 'analyze' ?
      '去分析页看学科分布和学习建议。' :
      (next === 'method' ? '去学科导学或方法卡，先处理错因。' : '回首页点拍照或手动录入。')
    report.scoreLabel = '规则模板 · 可执行'
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
    return `${d.getFullYear()}.${m}.${day}`
  }
}
