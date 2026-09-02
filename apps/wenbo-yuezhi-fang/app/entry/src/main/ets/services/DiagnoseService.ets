import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'

/** 智慧偏好问卷 → 五工坊模板推荐（纯规则，不调用大模型）。 */
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
        DiagnoseOption.of('fun', '一句能讲给别人听的知识点'),
        DiagnoseOption.of('use', '能用在工作或生活里的办法'),
        DiagnoseOption.of('think', '一个可以慢慢想的观点')
      ]),
      DiagnoseQuestion.of('topic', '最近更想靠近哪一工坊？', [
        DiagnoseOption.of('business', '商业'),
        DiagnoseOption.of('humanity', '人文'),
        DiagnoseOption.of('tech', '科技'),
        DiagnoseOption.of('life', '生活'),
        DiagnoseOption.of('art', '艺术')
      ]),
      DiagnoseQuestion.of('share', '你会不会收入书坊后再读第二遍？', [
        DiagnoseOption.of('often', '经常收藏，隔几天再看'),
        DiagnoseOption.of('rare', '偶尔收藏'),
        DiagnoseOption.of('once', '读过就算')
      ]),
      DiagnoseQuestion.of('next', '匹配完成后你打算？', [
        DiagnoseOption.of('home', '回发现页按工坊浏览'),
        DiagnoseOption.of('daily', '先看每日精选'),
        DiagnoseOption.of('work', '去做一页工坊练习'),
        DiagnoseOption.of('search', '用搜索找一篇对口的知识卡')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const report = new DiagnoseReport()
    const topic = DiagnoseService.optionId(answers, 'topic')
    const mood = DiagnoseService.optionId(answers, 'mood')
    const len = DiagnoseService.optionId(answers, 'len')
    report.title = '智慧偏好匹配'
    report.generatedAt = DiagnoseService.nowLabel()
    report.summary = `根据你的选择，更适合从「${DiagnoseService.labelOf(answers, 'topic')}」工坊开始读。结论为模板拼装，仅供参考。`
    report.strength = DiagnoseService.strengthText(mood, len)
    report.weakness = DiagnoseService.weaknessText(len, DiagnoseService.optionId(answers, 'share'))
    report.opportunity = DiagnoseService.opportunityText(topic)
    report.threat = '碎片阅读容易只记标题。收入书坊一篇、隔天再打开，比一次囤很多更有用。'
    report.actions = DiagnoseService.actions(topic, DiagnoseService.optionId(answers, 'next'))
    report.matchCategory = DiagnoseService.matchCategory(topic)
    report.matchHint = `打开发现页「${report.matchCategory}」读完一篇，再在工坊台做一页对应练习。`
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
      return '你在找能落地的办法，商业与生活工坊会更对胃口。'
    }
    if (mood === 'think') {
      return '你愿意把一篇话慢慢想完，人文与艺术观点都合适。'
    }
    if (len === 'short') {
      return '碎片时间也能读完，每日精选会是好入口。'
    }
    return '你愿意为知识停下几分钟，这已经足够开卷。'
  }

  private static weaknessText(len: string, share: string): string {
    if (share === 'once') {
      return '读过即走时，细节容易忘。试着收入书坊一篇，隔天再看摘要卡。'
    }
    if (len === 'long') {
      return '长文需要完整时段。可以先用每日精选热身，再进工坊。'
    }
    return '分类一多就容易乱点。先固定一个工坊读三篇，再换。'
  }

  private static opportunityText(topic: string): string {
    if (topic === 'business') {
      return '商业工坊适合把会议、报价写成可复查的动作，而不是鸡汤口号。'
    }
    if (topic === 'humanity') {
      return '人文工坊提醒：读完若不能用自己的话说给邻座听，知识还停在别人的句子里。'
    }
    if (topic === 'tech') {
      return '科技工坊谈的是注意力租金与可执行默认值，不是神话新工具。'
    }
    if (topic === 'art') {
      return '艺术工坊适合把观看变成可回看的笔记，而不是只刷封面。'
    }
    return '生活工坊靠把一件常用习惯说清楚，收入书坊后最容易复用。'
  }

  private static actions(topic: string, next: string): string[] {
    const list: string[] = []
    list.push(`先打开发现页「${DiagnoseService.matchCategory(topic)}」，点进一篇读完正文。`)
    list.push('觉得有用就收入书坊；新用户书坊是空的，只显示你自己收下的篇目。')
    if (next === 'daily') {
      list.push('也可以先读「每日精选」，再决定今天的工坊。')
    } else if (next === 'search') {
      list.push('用搜索找关键词，比把所有工坊扫一遍更快。')
    } else if (next === 'work') {
      list.push('读完后打开工坊台，写一页三问或余味，比只收藏标题更记得住。')
    } else {
      list.push('读完一篇完整正文，再决定是否收入书坊。')
    }
    return list
  }

  private static matchCategory(topic: string): string {
    if (topic === 'business') {
      return '商业'
    }
    if (topic === 'humanity') {
      return '人文'
    }
    if (topic === 'tech') {
      return '科技'
    }
    if (topic === 'art') {
      return '艺术'
    }
    return '生活'
  }
}
