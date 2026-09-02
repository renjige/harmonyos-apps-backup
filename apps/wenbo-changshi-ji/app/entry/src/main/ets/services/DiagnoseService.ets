import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'

/** 阅读兴趣问卷 → 模板分类推荐（纯规则，不调用大模型）。 */
export class DiagnoseService {
  static questions(): DiagnoseQuestion[] {
    return [
      DiagnoseQuestion.of('when', '你更常在什么时候读常识？', [
        DiagnoseOption.of('morning', '清晨或通勤时'),
        DiagnoseOption.of('noon', '午休片刻'),
        DiagnoseOption.of('night', '睡前'),
        DiagnoseOption.of('spare', '碎片时间')
      ]),
      DiagnoseQuestion.of('len', '单次能接受的篇幅？', [
        DiagnoseOption.of('short', '一两分钟读完'),
        DiagnoseOption.of('mid', '三五分钟'),
        DiagnoseOption.of('long', '愿意读完整正文')
      ]),
      DiagnoseQuestion.of('mood', '读完后你更想留下什么？', [
        DiagnoseOption.of('use', '能立刻用的小办法'),
        DiagnoseOption.of('fun', '一句能讲给别人的冷知'),
        DiagnoseOption.of('think', '一个可以慢慢想的观点')
      ]),
      DiagnoseQuestion.of('topic', '最近更想靠近哪一类？', [
        DiagnoseOption.of('life', '生活技巧'),
        DiagnoseOption.of('science', '科学原理'),
        DiagnoseOption.of('history', '人文历史'),
        DiagnoseOption.of('health', '健康养生'),
        DiagnoseOption.of('nature', '自然百科'),
        DiagnoseOption.of('career', '职场智慧'),
        DiagnoseOption.of('food', '饮食文化'),
        DiagnoseOption.of('mind', '心理常识')
      ]),
      DiagnoseQuestion.of('habit', '你会怎样积累？', [
        DiagnoseOption.of('daily', '每天固定读一条'),
        DiagnoseOption.of('fav', '收藏后再看'),
        DiagnoseOption.of('note', '读完后写笔记')
      ]),
      DiagnoseQuestion.of('next', '匹配完成后你打算？', [
        DiagnoseOption.of('home', '回今日常识'),
        DiagnoseOption.of('browse', '去分类浏览'),
        DiagnoseOption.of('fav', '整理收藏夹')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const report = new DiagnoseReport()
    const topic = DiagnoseService.optionId(answers, 'topic')
    const mood = DiagnoseService.optionId(answers, 'mood')
    const len = DiagnoseService.optionId(answers, 'len')
    report.title = '阅读兴趣匹配'
    report.generatedAt = DiagnoseService.nowLabel()
    report.summary = `根据你的选择，更适合从「${DiagnoseService.matchCategory(topic)}」开始读。结论为模板拼装，仅供参考。`
    report.strength = DiagnoseService.strengthText(mood, len)
    report.weakness = DiagnoseService.weaknessText(DiagnoseService.optionId(answers, 'habit'))
    report.opportunity = DiagnoseService.opportunityText(topic)
    report.threat = '只刷标题不读正文，容易「好像知道」却用不上。收藏一篇、隔天再看摘要更稳。'
    report.actions = DiagnoseService.actions(topic, DiagnoseService.optionId(answers, 'next'))
    report.matchCategory = DiagnoseService.matchCategory(topic)
    report.matchHint = `打开「分类浏览」选择「${report.matchCategory}」，先读一篇完整正文再决定是否收藏。`
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

  private static nowLabel(): string {
    const d = new Date()
    const mo = d.getMonth() + 1
    const day = d.getDate()
    const moStr = mo < 10 ? `0${mo}` : `${mo}`
    const dayStr = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${moStr}-${dayStr}`
  }

  private static strengthText(mood: string, len: string): string {
    if (mood === 'use') {
      return '你在找能落地的办法，生活技巧与健康类会更对胃口。'
    }
    if (mood === 'think') {
      return '你愿意把一条话慢慢想完，人文与心理类都合适。'
    }
    if (len === 'short') {
      return '碎片时间也能读完，今日常识大卡片会是好入口。'
    }
    return '你愿意为有用的常识停下几分钟，这已经足够形成习惯。'
  }

  private static weaknessText(habit: string): string {
    if (habit === 'fav') {
      return '收藏多、回看少时，可以每周导出收藏文本做一次整理。'
    }
    if (habit === 'note') {
      return '笔记写得勤，记得给每条笔记配一个分类，方便检索。'
    }
    return '没有固定时段时，用每日打卡提醒比靠意志力更可靠。'
  }

  private static opportunityText(topic: string): string {
    if (topic === 'science') {
      return '科学原理适合纠正直觉，记得停在「有趣但不神化」的边界。'
    }
    if (topic === 'career') {
      return '职场智慧讲的是体面沟通，不是鸡汤控场。'
    }
    if (topic === 'health') {
      return '健康类条目是生活卫生常识，不能替代诊疗。'
    }
    return '生活技巧靠把一件常用物说清楚，收藏后最容易复用。'
  }

  private static actions(topic: string, next: string): string[] {
    const list: string[] = []
    list.push(`先打开「分类浏览 → ${DiagnoseService.matchCategory(topic)}」，点进一篇读完正文。`)
    list.push('觉得有用就收藏；收藏夹默认是空的，只显示你自己收下的条目。')
    if (next === 'browse') {
      list.push('用搜索找关键词，比把所有分类扫一遍更快。')
    } else if (next === 'fav') {
      list.push('收藏夹空着很正常，读完一篇再回来看。')
    } else {
      list.push('也可以先完成「今日常识」再决定今天的分类。')
    }
    return list
  }

  private static matchCategory(topic: string): string {
    if (topic === 'science') {
      return '科学原理'
    }
    if (topic === 'history') {
      return '人文历史'
    }
    if (topic === 'health') {
      return '健康养生'
    }
    if (topic === 'nature') {
      return '自然百科'
    }
    if (topic === 'career') {
      return '职场智慧'
    }
    if (topic === 'food') {
      return '饮食文化'
    }
    if (topic === 'mind') {
      return '心理常识'
    }
    return '生活技巧'
  }
}
