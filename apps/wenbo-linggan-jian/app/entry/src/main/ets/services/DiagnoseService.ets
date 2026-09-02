import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'

/**
 * 问卷 → 规则模板整理建议（不调用大模型，产品文案不出现 AI 字样）。
 */
export class DiagnoseService {
  static questions(): DiagnoseQuestion[] {
    return [
      DiagnoseQuestion.of('when', '你通常什么时候记下灵感？', [
        DiagnoseOption.of('walk', '走路或通勤时'),
        DiagnoseOption.of('night', '睡前安静的时候'),
        DiagnoseOption.of('work', '工作间隙'),
        DiagnoseOption.of('read', '读完一段文字之后')
      ]),
      DiagnoseQuestion.of('kind', '你更常写下哪一类？', [
        DiagnoseOption.of('life', '生活里的小发现'),
        DiagnoseOption.of('job', '工作中的想法'),
        DiagnoseOption.of('create', '设计或创作念头'),
        DiagnoseOption.of('essay', '随手一段文字')
      ]),
      DiagnoseQuestion.of('length', '一条灵感大概多长？', [
        DiagnoseOption.of('one', '一句话就够'),
        DiagnoseOption.of('para', '一小段'),
        DiagnoseOption.of('long', '想写就写长一点')
      ]),
      DiagnoseQuestion.of('tagHabit', '你怎么用标签？', [
        DiagnoseOption.of('now', '写完随手贴上'),
        DiagnoseOption.of('later', '回头再整理'),
        DiagnoseOption.of('rare', '很少贴标签')
      ]),
      DiagnoseQuestion.of('review', '你更想怎样再看见它们？', [
        DiagnoseOption.of('time', '按时间慢慢翻'),
        DiagnoseOption.of('slip', '随机再遇一条'),
        DiagnoseOption.of('card', '做成精致灵感卡')
      ]),
      DiagnoseQuestion.of('keep', '你会收藏一条灵感，多半因为？', [
        DiagnoseOption.of('reread', '以后还想再读'),
        DiagnoseOption.of('work', '可能做成作品'),
        DiagnoseOption.of('like', '当下就是喜欢')
      ]),
      DiagnoseQuestion.of('pain', '目前最容易卡住的地方？', [
        DiagnoseOption.of('forget', '写过就想不起来'),
        DiagnoseOption.of('messy', '分类有点乱'),
        DiagnoseOption.of('heavy', '不想打开厚重笔记')
      ]),
      DiagnoseQuestion.of('next', '接下来最想做的一件事？', [
        DiagnoseOption.of('write', '先记下一条'),
        DiagnoseOption.of('sort', '把标签理一理'),
        DiagnoseOption.of('card', '做成一张灵感卡')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const kind = DiagnoseService.optionId(answers, 'kind')
    const tagHabit = DiagnoseService.optionId(answers, 'tagHabit')
    const review = DiagnoseService.optionId(answers, 'review')
    const pain = DiagnoseService.optionId(answers, 'pain')
    const next = DiagnoseService.optionId(answers, 'next')

    const report = new DiagnoseReport()
    report.title = '灵感整理建议'
    report.generatedAt = DiagnoseService.nowLabel()
    report.summary =
      `根据你的选择：常写「${DiagnoseService.labelOf(answers, 'kind')}」，` +
      `更想「${DiagnoseService.labelOf(answers, 'review')}」。` +
      `下面是按标签与习惯拼出的整理建议，方便你自己决定下一步，不是心理评估。`
    report.strength = DiagnoseService.habitText(answers)
    report.weakness = DiagnoseService.scatterText(tagHabit, pain)
    report.opportunity = DiagnoseService.directionText(review, kind)
    report.threat = DiagnoseService.watchText(pain)
    report.actions = DiagnoseService.actions(next, tagHabit, review)
    report.matchCategory = DiagnoseService.matchCategory(kind, review, next)
    report.matchHint = `可以先从「${report.matchCategory}」做一件小事：记下、贴标签，或做成灵感卡。`
    report.scoreLabel = DiagnoseService.scoreLabel(tagHabit, pain)
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

  private static habitText(answers: DiagnoseAnswer[]): string {
    return `你记下灵感的时机是「${DiagnoseService.labelOf(answers, 'when')}」，` +
      `篇幅偏「${DiagnoseService.labelOf(answers, 'length')}」。` +
      `保持这个轻量节奏就很好，不必做成复杂笔记本。`
  }

  private static scatterText(tagHabit: string, pain: string): string {
    if (pain === 'forget') {
      return '灵感写完后容易沉底。可以给今天的条目贴一个标签，方便以后按分类找回。'
    }
    if (tagHabit === 'rare' || pain === 'messy') {
      return '标签用得少或事后才补，分类会显得散。写完随手点一下预设标签即可。'
    }
    return '如果打开应用觉得有点满，可以先只看「今日灵感」，不必一次翻完全库。'
  }

  private static directionText(review: string, kind: string): string {
    if (review === 'slip') {
      return '「灵感签」适合随机再遇过去的自己，适合你现在的回看方式。'
    }
    if (review === 'card') {
      return '把喜欢的段落做成灵感卡，文字会更有收藏感。'
    }
    if (kind === 'create' || kind === 'job') {
      return '创意与工作类想法，适合用标签把它们和日常随笔分开。'
    }
    return '按时间轻轻翻阅即可。首页「智慧整理」会按今日标签给出归类建议。'
  }

  private static watchText(pain: string): string {
    if (pain === 'heavy') {
      return '如果记事软件让你觉得重，就只在灵感笺写短句，不必追求完整日记。'
    }
    if (pain === 'forget') {
      return '不回看的灵感会慢慢被忘记。每周点一次「再遇一条灵感」就够。'
    }
    return '分类一旦堆太多自定义标签，反而难找。优先用六个预设分类。'
  }

  private static actions(next: string, tagHabit: string, review: string): string[] {
    const list: string[] = []
    if (next === 'write') {
      list.push('现在就记下一条，哪怕只有一句。')
    } else if (next === 'sort') {
      list.push('打开灵感库，给未分类的条目贴上生活、工作或随笔。')
    } else {
      list.push('选一条喜欢的灵感，点「做成灵感卡」，试试素笺或墨韵。')
    }
    if (tagHabit === 'rare' || tagHabit === 'later') {
      list.push('写完随手点一个预设标签，以后更好找。')
    }
    if (review === 'slip') {
      list.push('有了几条之后，去「灵感签」再遇一条。')
    } else if (review === 'card') {
      list.push('收藏值得再读的条目，做成灵感卡留在本机。')
    } else {
      list.push('需要时用灵感库的时间筛选，只看今天或本周。')
    }
    return list
  }

  private static matchCategory(kind: string, review: string, next: string): string {
    if (next === 'card' || review === 'card') {
      return '灵感卡'
    }
    if (review === 'slip') {
      return '灵感签'
    }
    if (kind === 'life' || kind === 'essay') {
      return '生活随想'
    }
    if (kind === 'create') {
      return '创意手账'
    }
    return '灵感库'
  }

  private static scoreLabel(tagHabit: string, pain: string): string {
    if (tagHabit === 'now' && pain !== 'forget') {
      return '整理节奏轻快'
    }
    if (pain === 'forget' || tagHabit === 'rare') {
      return '适合先贴标签'
    }
    return '可以再轻一点'
  }
}
