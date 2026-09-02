import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'

/** 识趣偏好问卷 → 模板分类推荐（纯规则，不调用大模型）。 */
export class DiagnoseService {
  static questions(): DiagnoseQuestion[] {
    return [
      DiagnoseQuestion.of('when', '你更常在什么时候读一点东西？', [
        DiagnoseOption.of('morning', '清晨通勤或早饭时'),
        DiagnoseOption.of('noon', '午休片刻'),
        DiagnoseOption.of('night', '晚上睡前'),
        DiagnoseOption.of('spare', '排队、等人的碎片时间')
      ]),
      DiagnoseQuestion.of('len', '单次能接受的篇幅？', [
        DiagnoseOption.of('short', '一两分钟的短卡片'),
        DiagnoseOption.of('mid', '三五分钟把一件事说清'),
        DiagnoseOption.of('long', '愿意读完整故事')
      ]),
      DiagnoseQuestion.of('mood', '读完后你更想留下什么？', [
        DiagnoseOption.of('fun', '一句能讲给别人听的冷知'),
        DiagnoseOption.of('use', '能用在生活里的小办法'),
        DiagnoseOption.of('think', '一个可以慢慢想的观点')
      ]),
      DiagnoseQuestion.of('topic', '最近更想靠近哪一类？', [
        DiagnoseOption.of('history', '文史趣谈'),
        DiagnoseOption.of('science', '科学冷知'),
        DiagnoseOption.of('life', '生活智慧'),
        DiagnoseOption.of('career', '职场识趣')
      ]),
      DiagnoseQuestion.of('share', '你会不会收藏后再读第二遍？', [
        DiagnoseOption.of('often', '经常收藏，隔几天再看'),
        DiagnoseOption.of('rare', '偶尔收藏'),
        DiagnoseOption.of('once', '读过就算')
      ]),
      DiagnoseQuestion.of('next', '匹配完成后你打算？', [
        DiagnoseOption.of('home', '回首页按分类浏览'),
        DiagnoseOption.of('daily', '先看今日一趣'),
        DiagnoseOption.of('fav', '去收藏夹整理')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const report = new DiagnoseReport()
    const topic = DiagnoseService.optionId(answers, 'topic')
    const mood = DiagnoseService.optionId(answers, 'mood')
    const len = DiagnoseService.optionId(answers, 'len')
    report.title = '识趣偏好匹配'
    report.generatedAt = DiagnoseService.nowLabel()
    report.summary = `根据你的选择，更适合从「${DiagnoseService.labelOf(answers, 'topic')}」开始读。结论为模板拼装，仅供参考。`
    report.strength = DiagnoseService.strengthText(mood, len)
    report.weakness = DiagnoseService.weaknessText(len, DiagnoseService.optionId(answers, 'share'))
    report.opportunity = DiagnoseService.opportunityText(topic)
    report.threat = '碎片阅读容易只记标题。收藏一篇、隔天再打开，比一次囤很多更有用。'
    report.actions = DiagnoseService.actions(topic, DiagnoseService.optionId(answers, 'next'))
    report.matchCategory = DiagnoseService.matchCategory(topic)
    report.matchHint = `打开首页分类「${report.matchCategory}」，先读一篇完整正文再决定是否收藏。`
    report.scoreLabel = len === 'long' ? '适合深读' : '适合短读'
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

  private static strengthText(mood: string, len: string): string {
    if (mood === 'use') {
      return '你在找能落地的办法，生活智慧类清单会更对胃口。'
    }
    if (mood === 'think') {
      return '你愿意把一篇话慢慢想完，文史与职场观点都合适。'
    }
    if (len === 'short') {
      return '碎片时间也能读完，每日一趣会是好入口。'
    }
    return '你愿意为有趣的知识停下几分钟，这已经足够开卷。'
  }

  private static weaknessText(len: string, share: string): string {
    if (share === 'once') {
      return '读过即走时，细节容易忘。试着收藏一篇，隔天再看摘要卡。'
    }
    if (len === 'long') {
      return '长文需要完整时段。可以先用每日一趣热身，再进故事。'
    }
    return '分类一多就容易乱点。先固定一个分类读三篇，再换。'
  }

  private static opportunityText(topic: string): string {
    if (topic === 'history') {
      return '文史趣谈适合把典故还原成市井尺度，而不是背词条。'
    }
    if (topic === 'science') {
      return '科学冷知适合纠正直觉，记得停在「有趣但不神化」的边界。'
    }
    if (topic === 'career') {
      return '职场识趣讲的是体面沟通，不是鸡汤控场。'
    }
    return '生活智慧靠把一件常用物说清楚，收藏后最容易复用。'
  }

  private static actions(topic: string, next: string): string[] {
    const list: string[] = []
    list.push(`先打开首页「${DiagnoseService.matchCategory(topic)}」，点进一篇读完正文。`)
    list.push('觉得有趣就收藏；收藏夹默认是空的，只显示你自己收下的篇目。')
    if (next === 'daily') {
      list.push('也可以先读「每日一趣」，再决定今天的分类。')
    } else if (next === 'fav') {
      list.push('收藏夹空着很正常，读完一篇再回来看。')
    } else {
      list.push('用搜索找关键词，比把所有分类扫一遍更快。')
    }
    return list
  }

  private static matchCategory(topic: string): string {
    if (topic === 'history') {
      return '文史趣谈'
    }
    if (topic === 'science') {
      return '科学冷知'
    }
    if (topic === 'career') {
      return '职场识趣'
    }
    return '生活智慧'
  }
}
