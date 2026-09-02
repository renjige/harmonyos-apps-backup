import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'

/**
 * 学习节律问卷 → 规则模板报告（不调用大模型，界面不出现「AI」字样）。
 */
export class DiagnoseService {
  static questions(): DiagnoseQuestion[] {
    return [
      DiagnoseQuestion.of('when', '你通常在哪个时段更容易进入专注？', [
        DiagnoseOption.of('morning', '清晨到上午'),
        DiagnoseOption.of('afternoon', '下午'),
        DiagnoseOption.of('evening', '晚上'),
        DiagnoseOption.of('mixed', '不太固定')
      ]),
      DiagnoseQuestion.of('block', '一次专注你更习惯多长？', [
        DiagnoseOption.of('short', '15 分钟短冲'),
        DiagnoseOption.of('classic', '25 分钟经典'),
        DiagnoseOption.of('long', '45 分钟以上'),
        DiagnoseOption.of('unsure', '还在试')
      ]),
      DiagnoseQuestion.of('goal', '当前最想看见的进步是？', [
        DiagnoseOption.of('habit', '每天都能坐下来学'),
        DiagnoseOption.of('notes', '把要点记清楚'),
        DiagnoseOption.of('cards', '知识卡片能复习起来'),
        DiagnoseOption.of('insight', '看清自己的学习规律')
      ]),
      DiagnoseQuestion.of('interrupt', '最常打断你的是？', [
        DiagnoseOption.of('phone', '消息与通知'),
        DiagnoseOption.of('plan', '目标太大不知道从哪开始'),
        DiagnoseOption.of('tired', '容易疲劳走神'),
        DiagnoseOption.of('env', '环境嘈杂')
      ]),
      DiagnoseQuestion.of('review', '学过后你怎么巩固？', [
        DiagnoseOption.of('none', '很少回顾'),
        DiagnoseOption.of('note', '看笔记'),
        DiagnoseOption.of('card', '翻知识卡片'),
        DiagnoseOption.of('mix', '笔记和卡片都会用')
      ]),
      DiagnoseQuestion.of('days', '最近一周大概学了几天？', [
        DiagnoseOption.of('zero', '几乎没有'),
        DiagnoseOption.of('few', '1–3 天'),
        DiagnoseOption.of('most', '4–6 天'),
        DiagnoseOption.of('all', '每天都有')
      ]),
      DiagnoseQuestion.of('next', '接下来七天你最想先做哪件？', [
        DiagnoseOption.of('timer', '先完成几次专注计时'),
        DiagnoseOption.of('write', '先写几条学习笔记'),
        DiagnoseOption.of('review', '先复习已有卡片'),
        DiagnoseOption.of('report', '先看周报和热力图')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const when = DiagnoseService.optionId(answers, 'when')
    const block = DiagnoseService.optionId(answers, 'block')
    const goal = DiagnoseService.optionId(answers, 'goal')
    const interrupt = DiagnoseService.optionId(answers, 'interrupt')
    const review = DiagnoseService.optionId(answers, 'review')
    const days = DiagnoseService.optionId(answers, 'days')
    const next = DiagnoseService.optionId(answers, 'next')

    const report = new DiagnoseReport()
    report.title = '学习节律报告'
    report.generatedAt = DiagnoseService.nowLabel()
    report.summary =
      `根据问卷：时段「${DiagnoseService.labelOf(answers, 'when')}」、` +
      `时长偏好「${DiagnoseService.labelOf(answers, 'block')}」、` +
      `目标「${DiagnoseService.labelOf(answers, 'goal')}」。` +
      `以下为规则拼装建议，仅供参考，不替代你自己的判断。`
    report.strength = DiagnoseService.strengthText(when, days, review)
    report.weakness = DiagnoseService.weaknessText(interrupt, days, review)
    report.opportunity = DiagnoseService.opportunityText(goal, block, next)
    report.threat = DiagnoseService.threatText(interrupt, days)
    report.actions = DiagnoseService.actions(goal, next, block, review)
    report.matchCategory = DiagnoseService.matchCategory(next)
    report.matchActionId = DiagnoseService.matchActionId(next)
    report.matchHint = DiagnoseService.matchHint(when, block)
    report.scoreLabel = DiagnoseService.scoreLabel(days, review, interrupt)
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
    return '未填'
  }

  private static nowLabel(): string {
    const d = new Date()
    const mo = d.getMonth() + 1
    const day = d.getDate()
    const moStr = mo < 10 ? `0${mo}` : `${mo}`
    const dayStr = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${moStr}-${dayStr}`
  }

  private static strengthText(when: string, days: string, review: string): string {
    let s = '你已经愿意认真看待自己的学习节奏，这是持续进步的起点。'
    if (when === 'morning' || when === 'evening') {
      s = `${s} 你有相对清晰的高效时段，适合把重要内容安排在这段时间。`
    }
    if (days === 'most' || days === 'all') {
      s = `${s} 近一周学习天数不错，热力图会更容易看见积累。`
    }
    if (review === 'card' || review === 'mix') {
      s = `${s} 你已经有复习意识，知识卡片会更有用。`
    }
    return s
  }

  private static weaknessText(interrupt: string, days: string, review: string): string {
    let w = '节奏还不稳定时，不必一次拉满目标，先保证能完成。'
    if (interrupt === 'phone') {
      w = '通知容易把专注切碎，计时开始后建议把手机静音或远离视线。'
    } else if (interrupt === 'plan') {
      w = '目标过大时，先拆成一次 15–25 分钟能做完的小块。'
    } else if (interrupt === 'tired') {
      w = '疲劳时硬撑会降低质量，可用短计时 + 休息，而不是拉长一场。'
    } else if (interrupt === 'env') {
      w = '环境干扰明显时，优先选相对安静的位置，或戴耳机降低噪音。'
    }
    if (days === 'zero' || days === 'few') {
      w = `${w} 近一周天数偏少，先追求「每天一小段」而不是时长冠军。`
    }
    if (review === 'none') {
      w = `${w} 学过很少回顾，建议给卡片标「需复习」，隔天随机抽一张。`
    }
    return w
  }

  private static opportunityText(goal: string, block: string, next: string): string {
    let o = '用专注计时看见投入，用笔记和卡片看见内容，用周报看见趋势。'
    if (goal === 'habit') {
      o = '把每日目标设得略低于舒适区，连续几天比单次学很久更有价值。'
    } else if (goal === 'notes') {
      o = '每段专注结束后用两分钟写下标题和三条要点，笔记会自然变厚。'
    } else if (goal === 'cards') {
      o = '一个概念一张卡片，标「需复习」后用随机复习，比反复抄写更省力。'
    } else if (goal === 'insight') {
      o = '连续记录一周后看热力图和时段柱状图，规律会比感觉更清楚。'
    }
    if (block === 'unsure') {
      o = `${o} 本周可先试 25 分钟，不适再改 15 或 45。`
    }
    if (next === 'timer') {
      o = `${o} 下一步直接开始一段计时即可。`
    }
    return o
  }

  private static threatText(interrupt: string, days: string): string {
    let t = '最大风险是「计划很满、实际为零」，热力图会如实反映。'
    if (interrupt === 'phone') {
      t = '频繁切屏会让时长看起来不少、真正记住的却很少。'
    }
    if (days === 'zero') {
      t = '连续空白日后，重新开始会更难。先完成一次最短计时打破空白。'
    }
    return t
  }

  private static actions(goal: string, next: string, block: string, review: string): string[] {
    const list: string[] = []
    if (block === 'short' || block === 'unsure') {
      list.push('今天先完成 1 次 15 或 25 分钟专注，暂停也没关系，结束时保存时长。')
    } else {
      list.push('按你习惯的时长开始计时；中途可暂停，结束后写入今日进度环。')
    }
    if (goal === 'notes' || next === 'write') {
      list.push('计时结束后立刻写一条笔记：标题 + 三条要点。')
    } else {
      list.push('本周至少写 2 条学习笔记，方便之后在成长轨迹里回看。')
    }
    if (review === 'none' || goal === 'cards' || next === 'review') {
      list.push('新建或翻开一张知识卡片，标「需复习」或「已掌握」，再试一次随机复习。')
    } else {
      list.push('抽一张卡片复习，确认掌握状态是否要更新。')
    }
    list.push('周末打开洞察看周报：总时长、学习天数、智慧分析是否与体感一致。')
    return list
  }

  private static matchCategory(next: string): string {
    if (next === 'write') {
      return '快速笔记'
    }
    if (next === 'review') {
      return '随机复习'
    }
    if (next === 'report') {
      return '周报洞察'
    }
    return '专注计时'
  }

  private static matchActionId(next: string): string {
    if (next === 'write') {
      return 'note'
    }
    if (next === 'review') {
      return 'review'
    }
    if (next === 'report') {
      return 'insight'
    }
    return 'focus'
  }

  private static matchHint(when: string, block: string): string {
    const slot = when === 'morning' ? '上午' : (when === 'evening' ? '晚上' : '你相对清醒的时段')
    const len = block === 'long' ? '45 分钟' : (block === 'short' ? '15 分钟' : '25 分钟')
    return `建议把下一次学习安排在${slot}，先用 ${len} 走完闭环。`
  }

  private static scoreLabel(days: string, review: string, interrupt: string): string {
    let score = 68
    if (days === 'all') {
      score += 12
    } else if (days === 'most') {
      score += 8
    } else if (days === 'zero') {
      score -= 10
    }
    if (review === 'mix' || review === 'card') {
      score += 6
    } else if (review === 'none') {
      score -= 4
    }
    if (interrupt === 'phone' || interrupt === 'plan') {
      score -= 4
    }
    if (score >= 80) {
      return '节律较稳'
    }
    if (score >= 65) {
      return '有改进空间'
    }
    return '建议先建立最小闭环'
  }
}
