import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'

/** 书房匹配问卷（纯规则，不调用大模型） */
export class DiagnoseService {
  static questions(): DiagnoseQuestion[] {
    return [
      DiagnoseQuestion.of('time', '你更常在何时读书？', [
        DiagnoseOption.of('morning', '清晨茶后'),
        DiagnoseOption.of('commute', '通勤碎片'),
        DiagnoseOption.of('night', '灯下睡前'),
        DiagnoseOption.of('weekend', '周末整块时间')
      ]),
      DiagnoseQuestion.of('mood', '此刻更想靠近哪种气质？', [
        DiagnoseOption.of('xiushen', '修身自省'),
        DiagnoseOption.of('chushi', '处世进退'),
        DiagnoseOption.of('shanshui', '山水闲情'),
        DiagnoseOption.of('shici', '诗意审美')
      ]),
      DiagnoseQuestion.of('length', '一次能安心读多长？', [
        DiagnoseOption.of('short', '三五行即可'),
        DiagnoseOption.of('mid', '一小段原文'),
        DiagnoseOption.of('long', '愿意慢慢读完一章')
      ]),
      DiagnoseQuestion.of('note', '读完习惯怎么留下痕迹？', [
        DiagnoseOption.of('copy', '抄一句原文'),
        DiagnoseOption.of('feel', '写感受'),
        DiagnoseOption.of('none', '先读着，暂不写')
      ]),
      DiagnoseQuestion.of('circle', '文友圈对你意味着？', [
        DiagnoseOption.of('checkin', '给自己打卡'),
        DiagnoseOption.of('review', '写几句书评'),
        DiagnoseOption.of('read', '只看精选笺')
      ]),
      DiagnoseQuestion.of('next', '接下来最想做的一步？', [
        DiagnoseOption.of('excerpt', '读今日书摘'),
        DiagnoseOption.of('list', '打开匹配书单'),
        DiagnoseOption.of('note', '先写一条墨迹')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const mood = DiagnoseService.optionId(answers, 'mood')
    const report = new DiagnoseReport()
    report.title = '书房匹配说明'
    report.generatedAt = DiagnoseService.nowLabel()
    report.summary =
      `基于问卷：气质「${DiagnoseService.labelOf(answers, 'mood')}」、` +
      `时长「${DiagnoseService.labelOf(answers, 'length')}」。以下为规则模板，不含生成式对话。`

    if (mood === 'chushi') {
      report.matchCategory = '处世进退'
      report.strength = '你愿意把句子对照进退，而不是只收藏金句。'
      report.weakness = '容易把「不争」读成放弃标准，需落到一件具体的事。'
      report.opportunity = '推荐书单：处世进退。可从《道德经》上善若水读起。'
      report.threat = '若只求鸡汤，会错过原文的冷。'
    } else if (mood === 'shanshui' || mood === 'shici') {
      report.matchCategory = '山水闲情'
      report.strength = '你更在意声音、意象与留白。'
      report.weakness = '进度感弱时容易中断，可用打卡只写四个字。'
      report.opportunity = '推荐书单：山水闲情。鲲鹏与河洲都适合慢读。'
      report.threat = '把闲情做成打卡 KPI 会破坏气氛。'
    } else {
      report.matchCategory = '修身日课'
      report.strength = '你愿意把一句原文变成日课。'
      report.weakness = '容易求全，一次读太多会空。'
      report.opportunity = '推荐书单：修身日课。从学而时习抄一句即可。'
      report.threat = '把修身变成自我责备。'
    }

    report.actions = [
      '打开今日书摘，出声或默读原文一遍',
      '在墨迹里写下不超过三行的对照',
      '需要时在文友圈打卡，文案可以很短'
    ]
    report.matchHint = '点击下方按钮返回书房，打开对应主题书单。'
    report.scoreLabel = '已匹配'
    return report
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
    return '未选'
  }

  private static nowLabel(): string {
    const d = new Date()
    const m = d.getMonth() + 1
    const day = d.getDate()
    return `${d.getFullYear()}-${m}-${day}`
  }
}
