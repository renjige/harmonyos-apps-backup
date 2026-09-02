import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'

export class DiagnoseService {
  static questions(): DiagnoseQuestion[] {
    return [
      DiagnoseQuestion.of('stage', '当前装修做到哪一步？', [
        DiagnoseOption.of('demo', '拆改'),
        DiagnoseOption.of('hydro', '水电'),
        DiagnoseOption.of('wood', '泥木'),
        DiagnoseOption.of('paint', '油漆'),
        DiagnoseOption.of('install', '安装'),
        DiagnoseOption.of('accept', '验收')
      ]),
      DiagnoseQuestion.of('record', '现场记录习惯？', [
        DiagnoseOption.of('none', '很少记录'),
        DiagnoseOption.of('photo', '偶尔拍照'),
        DiagnoseOption.of('daily', '每天记一笔')
      ]),
      DiagnoseQuestion.of('material', '材料规格怎么记？', [
        DiagnoseOption.of('memory', '全凭记忆'),
        DiagnoseOption.of('chat', '散落在聊天记录'),
        DiagnoseOption.of('list', '已有清单')
      ]),
      DiagnoseQuestion.of('water', '卫生间防水是否做过闭水？', [
        DiagnoseOption.of('yes', '已完成并记录'),
        DiagnoseOption.of('doing', '正在做'),
        DiagnoseOption.of('no', '还没做 / 不清楚')
      ]),
      DiagnoseQuestion.of('point', '开关插座点位确认了吗？', [
        DiagnoseOption.of('yes', '已确认'),
        DiagnoseOption.of('part', '部分确认'),
        DiagnoseOption.of('no', '尚未确认')
      ]),
      DiagnoseQuestion.of('next', '接下来最想先做？', [
        DiagnoseOption.of('task', '理清待办事项'),
        DiagnoseOption.of('material', '核对材料规格'),
        DiagnoseOption.of('note', '补现场记录'),
        DiagnoseOption.of('inspect', '按清单验收')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const stage = DiagnoseService.optionId(answers, 'stage')
    const record = DiagnoseService.optionId(answers, 'record')
    const material = DiagnoseService.optionId(answers, 'material')
    const next = DiagnoseService.optionId(answers, 'next')
    const report = new DiagnoseReport()
    report.title = '装修进度自检'
    report.generatedAt = DiagnoseService.nowLabel()
    report.summary = `当前阶段「${DiagnoseService.labelOf(answers, 'stage')}」。以下为规则整理的记录建议，仅供个人对照，不构成专业鉴定。`
    report.strength = record === 'daily'
      ? '你已经有每天记录的习惯，后续翻看会轻松很多。'
      : '只要从今天开始记一笔，现场细节就不会散落。'
    report.weakness = material === 'memory'
      ? '材料规格如果只靠记忆，进场时容易对不上。'
      : '材料信息可以继续集中到清单里，避免聊天记录里翻找。'
    report.opportunity = next === 'inspect'
      ? '可以用验收清单逐项标记通过或待处理。'
      : '智能装修清单会按当前阶段给出建议事项，可一键加入待办。'
    report.threat = stage === 'hydro' && DiagnoseService.optionId(answers, 'water') === 'no'
      ? '水电与防水节点建议尽早留下日期和照片备注。'
      : '重要节点没有记录时，后期沟通成本会变高。'
    report.actions = [
      '打开智能装修清单，把当前阶段事项加入待办',
      '把待确认材料补上规格、房间和状态',
      '现场拍一张或写一段记录',
      '需要核对时使用轻量验收清单'
    ]
    report.matchCategory = next === 'material' ? '材料清单' : (next === 'inspect' ? '验收清单' : '智能装修清单')
    report.matchHint = '建议回到清单页继续操作。本结果为模板整理，不是检测报告。'
    report.scoreLabel = DiagnoseService.score(answers)
    return report
  }

  private static score(answers: DiagnoseAnswer[]): string {
    let n = 0
    if (DiagnoseService.optionId(answers, 'record') === 'daily') {
      n += 1
    }
    if (DiagnoseService.optionId(answers, 'material') === 'list') {
      n += 1
    }
    if (DiagnoseService.optionId(answers, 'water') === 'yes') {
      n += 1
    }
    if (DiagnoseService.optionId(answers, 'point') === 'yes') {
      n += 1
    }
    if (n >= 3) {
      return '记录较完整'
    }
    if (n >= 1) {
      return '可以再补几项'
    }
    return '建议先建立记录习惯'
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
    return ''
  }

  private static nowLabel(): string {
    const d = new Date()
    return `${d.getFullYear()}-${d.getMonth() + 1}-${d.getDate()}`
  }
}
