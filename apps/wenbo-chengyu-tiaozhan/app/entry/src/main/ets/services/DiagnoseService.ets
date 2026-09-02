import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'

/**
 * 薄弱诊断：问卷 + 规则模板报告。不调用大模型。
 */
export class DiagnoseService {
  static questions(): DiagnoseQuestion[] {
    return [
      DiagnoseQuestion.of('history', '历史典故类成语，你更常卡在哪？', [
        DiagnoseOption.of('history', '典故对不上号'),
        DiagnoseOption.of('nature', '其实天气山水更不熟'),
        DiagnoseOption.of('even', '两边差不多')
      ]),
      DiagnoseQuestion.of('character', '人物品质与励志类，哪边更容易用错？', [
        DiagnoseOption.of('character', '气节、诚实一类'),
        DiagnoseOption.of('aspire', '坚持、自强一类'),
        DiagnoseOption.of('even', '都还行')
      ]),
      DiagnoseQuestion.of('confuse', '易混成语和诗文出处，更想先补哪边？', [
        DiagnoseOption.of('confuse', '先把易混辨析理清'),
        DiagnoseOption.of('poetry', '先熟悉诗文出处'),
        DiagnoseOption.of('even', '都可以')
      ]),
      DiagnoseQuestion.of('strategy', '兵法谋略与生僻压轴，你更怕哪一类？', [
        DiagnoseOption.of('strategy', '计策类成语'),
        DiagnoseOption.of('rare', '书卷气更重的生僻'),
        DiagnoseOption.of('even', '都想练')
      ]),
      DiagnoseQuestion.of('pace', '限时十五秒时，你通常？', [
        DiagnoseOption.of('rush', '来不及读完选项'),
        DiagnoseOption.of('guess', '会凭感觉抢答'),
        DiagnoseOption.of('ok', '节奏还跟得上')
      ]),
      DiagnoseQuestion.of('goal', '接下来两周最想达成？', [
        DiagnoseOption.of('daily', '先把每日五题养成习惯'),
        DiagnoseOption.of('campaign', '把闯关往前推进'),
        DiagnoseOption.of('theme', '针对薄弱主题专项练')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const report = new DiagnoseReport()
    report.title = '薄弱诊断报告'
    report.generatedAt = DiagnoseService.nowLabel()
    const theme = DiagnoseService.pickTheme(answers)
    report.matchCategory = DiagnoseService.themeLabel(theme)
    report.summary =
      `根据六道选择题：当前更适合先练「${report.matchCategory}」。` +
      `结论由规则模板拼装，不是测评分数，也不调用大模型。`
    report.strength = DiagnoseService.strengthText(answers)
    report.weakness = DiagnoseService.weaknessText(theme, answers)
    report.opportunity = DiagnoseService.opportunityText(answers)
    report.threat = DiagnoseService.threatText(answers)
    report.actions = DiagnoseService.actions(theme, answers)
    report.matchHint = `打开智慧题库，进入「${report.matchCategory}」做一组专项。进度记在本机。`
    report.scoreLabel = DiagnoseService.scoreLabel(answers)
    return report
  }

  static pickTheme(answers: DiagnoseAnswer[]): string {
    const votes: string[] = []
    votes.push(DiagnoseService.optionId(answers, 'history'))
    votes.push(DiagnoseService.optionId(answers, 'character'))
    votes.push(DiagnoseService.optionId(answers, 'confuse'))
    votes.push(DiagnoseService.optionId(answers, 'strategy'))
    let best = 'history'
    let bestN = 0
    const keys: string[] = ['history', 'nature', 'character', 'aspire', 'confuse', 'poetry', 'strategy', 'rare']
    for (const k of keys) {
      let n = 0
      for (const v of votes) {
        if (v === k) {
          n++
        }
      }
      if (n > bestN) {
        bestN = n
        best = k
      }
    }
    return best
  }

  private static themeLabel(theme: string): string {
    if (theme === 'nature') {
      return '自然万象'
    }
    if (theme === 'character') {
      return '人物品质'
    }
    if (theme === 'aspire') {
      return '励志进取'
    }
    if (theme === 'confuse') {
      return '易混辨析'
    }
    if (theme === 'poetry') {
      return '诗文出处'
    }
    if (theme === 'strategy') {
      return '兵法谋略'
    }
    if (theme === 'rare') {
      return '生僻压轴'
    }
    return '历史典故'
  }

  private static optionId(answers: DiagnoseAnswer[], qid: string): string {
    for (const a of answers) {
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

  private static strengthText(answers: DiagnoseAnswer[]): string {
    const pace = DiagnoseService.optionId(answers, 'pace')
    if (pace === 'ok') {
      return '限时节奏跟得上，适合用连击把正确率再抬一截。'
    }
    if (pace === 'guess') {
      return '敢于下判断，专项练习时先读释义再选，正确率会更稳。'
    }
    return '你愿意面对限时，说明已经把每日挑战当成习惯入口。'
  }

  private static weaknessText(theme: string, answers: DiagnoseAnswer[]): string {
    const label = DiagnoseService.themeLabel(theme)
    const confuse = DiagnoseService.optionId(answers, 'confuse')
    let w = `目前更需要补「${label}」这一路的出典与用法。`
    if (confuse === 'confuse') {
      w = `${w} 易混成语建议对照近义/反义一起记。`
    }
    return w
  }

  private static opportunityText(answers: DiagnoseAnswer[]): string {
    const goal = DiagnoseService.optionId(answers, 'goal')
    if (goal === 'daily') {
      return '每日五题足够建立连续打卡，连击加成会把分数抬上去。'
    }
    if (goal === 'campaign') {
      return '闯关是一关一个成语五题，答对四题即可解锁，适合系统过一遍。'
    }
    return '智慧题库会按本机错题主题排序，专项一组就能对准薄弱点。'
  }

  private static threatText(answers: DiagnoseAnswer[]): string {
    const pace = DiagnoseService.optionId(answers, 'pace')
    if (pace === 'rush') {
      return '时间到按错题记，建议先看题干再扫选项，不必追连击。'
    }
    return '不要把称号和金印当成考试排名。它们只是本机纪念。'
  }

  private static actions(theme: string, answers: DiagnoseAnswer[]): string[] {
    const list: string[] = []
    list.push(`打开智慧题库，完成一组「${DiagnoseService.themeLabel(theme)}」专项。`)
    const goal = DiagnoseService.optionId(answers, 'goal')
    if (goal === 'campaign') {
      list.push('回到闯关，从当前可挑战关开始，答对四题再进下一关。')
    } else {
      list.push('今晚再做一轮今日挑战，把连续打卡续上。')
    }
    list.push('错题主题会记在本机，下次打开题库会优先推荐。')
    return list
  }

  private static scoreLabel(answers: DiagnoseAnswer[]): string {
    const pace = DiagnoseService.optionId(answers, 'pace')
    if (pace === 'ok') {
      return '节奏稳定'
    }
    if (pace === 'rush') {
      return '建议放慢读题'
    }
    return '先求准再求快'
  }
}
