import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'

/** 智慧策展：问卷 → 规则模板，不调用大模型。 */
export class DiagnoseService {
  static questions(): DiagnoseQuestion[] {
    return [
      DiagnoseQuestion.of('age', '孩子现在更接近哪个阶段？', [
        DiagnoseOption.of('a3', '3 岁前后，涂鸦为主'),
        DiagnoseOption.of('a6', '4–6 岁，开始画人物'),
        DiagnoseOption.of('a9', '7–9 岁，喜欢故事画'),
        DiagnoseOption.of('a12', '10–12 岁，媒介更多样')
      ]),
      DiagnoseQuestion.of('count', '已经珍藏了大约多少幅？', [
        DiagnoseOption.of('c0', '还没有 / 不到 4 幅'),
        DiagnoseOption.of('c8', '大约 4–12 幅'),
        DiagnoseOption.of('c20', '已经有一小柜子')
      ]),
      DiagnoseQuestion.of('medium', '最近最常使用的材料？', [
        DiagnoseOption.of('crayon', '蜡笔 / 油画棒'),
        DiagnoseOption.of('water', '水彩'),
        DiagnoseOption.of('marker', '马克笔 / 彩铅'),
        DiagnoseOption.of('mix', '混合都有')
      ]),
      DiagnoseQuestion.of('mood', '希望画展给人什么感觉？', [
        DiagnoseOption.of('home', '像家里的一面墙'),
        DiagnoseOption.of('clean', '干净克制，只剩画'),
        DiagnoseOption.of('sun', '有下午的窗光'),
        DiagnoseOption.of('night', '仪式感、聚光灯')
      ]),
      DiagnoseQuestion.of('share', '主要想分享给谁？', [
        DiagnoseOption.of('family', '祖辈和亲戚'),
        DiagnoseOption.of('self', '只给自己回看'),
        DiagnoseOption.of('class', '老师或同学家长')
      ]),
      DiagnoseQuestion.of('next', '下一步最想做的？', [
        DiagnoseOption.of('album', '先做一本主题画册'),
        DiagnoseOption.of('upload', '先把桌上的画拍完'),
        DiagnoseOption.of('show', '先办一场小画展')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const age = DiagnoseService.optionId(answers, 'age')
    const count = DiagnoseService.optionId(answers, 'count')
    const medium = DiagnoseService.optionId(answers, 'medium')
    const mood = DiagnoseService.optionId(answers, 'mood')
    const report = new DiagnoseReport()
    report.title = '智慧策展方案'
    report.generatedAt = DiagnoseService.nowLabel()
    report.summary =
      `根据问卷：阶段「${DiagnoseService.labelOf(answers, 'age')}」、` +
      `数量「${DiagnoseService.labelOf(answers, 'count')}」、` +
      `材料「${DiagnoseService.labelOf(answers, 'medium')}」。以下为固定模板建议，不是评画。`
    if (medium === 'water') {
      report.strength = '水彩适合收成「水色与纸纹」主题画册，封面选层次最清楚的一张。'
    } else if (medium === 'crayon') {
      report.strength = '蜡笔涂鸦适合按季度装册，保留孩子自己的命名。'
    } else {
      report.strength = '混合媒介可以按主题而不是按工具归档，避免柜子越分越碎。'
    }
    if (count === 'c0') {
      report.weakness = '作品还少，先珍藏 4 幅再进画廊，墙面才站得住。'
    } else {
      report.weakness = '数量已经够开一小展，注意不要把所有画塞进同一本。'
    }
    if (mood === 'night') {
      report.opportunity = '展厅建议「夜间聚光」，适合生日或第一次画展海报。'
      report.matchCategory = '夜间聚光'
    } else if (mood === 'clean') {
      report.opportunity = '展厅建议「白墙当代」，让纸边和笔触成为主角。'
      report.matchCategory = '白墙当代'
    } else if (mood === 'sun') {
      report.opportunity = '展厅建议「窗边午后」，和四季风景特别搭。'
      report.matchCategory = '窗边午后'
    } else {
      report.opportunity = '展厅建议「暖光木廊」，像把客厅变成小画廊。'
      report.matchCategory = '暖光木廊'
    }
    if (age === 'a3') {
      report.threat = '这一阶段最容易随手丢掉纸片。优先标记「第一次握笔 / 第一次画圆形」。'
    } else {
      report.threat = '人物和故事画变化很快，记得把年龄写在作品上。'
    }
    report.actions = [
      '打开时间线，点「珍藏一幅」拍下桌上的画',
      '按建议新建一本不超过 16 幅的主题画册',
      '到画廊切换对应展厅，左右滑动看墙',
      '需要时生成海报发给亲友，不必公开社区'
    ]
    report.matchHint = '可在画廊查看展厅详情，或按主题去建画册。'
    report.scoreLabel = count === 'c0' ? '起步珍藏' : '可以办小展'
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
    return `${d.getFullYear()}-${d.getMonth() + 1}-${d.getDate()}`
  }
}
