import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'

/**
 * 表达习惯问卷 → 模板报告（纯规则，不调用大模型）。
 */
export class DiagnoseService {
  static questions(): DiagnoseQuestion[] {
    return [
      DiagnoseQuestion.of('scene', '你最常写哪类内容？', [
        DiagnoseOption.of('work', '工作邮件 / 纪要'),
        DiagnoseOption.of('study', '作业 / 论文'),
        DiagnoseOption.of('daily', '日常消息 / 社交'),
        DiagnoseOption.of('copy', '产品 / 活动文案')
      ]),
      DiagnoseQuestion.of('stuck', '写不顺时通常卡在哪里？', [
        DiagnoseOption.of('open', '开头第一句'),
        DiagnoseOption.of('tone', '语气太硬或太软'),
        DiagnoseOption.of('long', '句子太长绕'),
        DiagnoseOption.of('logic', '逻辑顺序乱')
      ]),
      DiagnoseQuestion.of('reader', '读者通常是？', [
        DiagnoseOption.of('boss', '上级 / 客户'),
        DiagnoseOption.of('peer', '同事 / 同学'),
        DiagnoseOption.of('public', '陌生读者 / 用户'),
        DiagnoseOption.of('close', '亲友')
      ]),
      DiagnoseQuestion.of('worry', '发出去前最担心？', [
        DiagnoseOption.of('rude', '显得不礼貌'),
        DiagnoseOption.of('vague', '意思不清楚'),
        DiagnoseOption.of('wordy', '太啰嗦'),
        DiagnoseOption.of('cold', '太冷冰冰')
      ]),
      DiagnoseQuestion.of('habit', '你平时的改稿习惯？', [
        DiagnoseOption.of('once', '很少改，差不多就发'),
        DiagnoseOption.of('read', '通读一遍再发'),
        DiagnoseOption.of('aloud', '会读出声检查'),
        DiagnoseOption.of('compare', '会对照范例改')
      ]),
      DiagnoseQuestion.of('length', '你更习惯哪种句子？', [
        DiagnoseOption.of('short', '短句，一句一事'),
        DiagnoseOption.of('mix', '长短交替'),
        DiagnoseOption.of('long', '长句铺陈'),
        DiagnoseOption.of('list', '分点列举')
      ]),
      DiagnoseQuestion.of('channel', '主要用什么渠道写？', [
        DiagnoseOption.of('email', '邮件 / 文档'),
        DiagnoseOption.of('im', '即时消息'),
        DiagnoseOption.of('form', '表单 / 报告'),
        DiagnoseOption.of('note', '笔记 / 草稿')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const scene = DiagnoseService.optionId(answers, 'scene')
    const stuck = DiagnoseService.optionId(answers, 'stuck')
    const reader = DiagnoseService.optionId(answers, 'reader')
    const worry = DiagnoseService.optionId(answers, 'worry')
    const habit = DiagnoseService.optionId(answers, 'habit')
    const length = DiagnoseService.optionId(answers, 'length')
    const channel = DiagnoseService.optionId(answers, 'channel')

    const report = new DiagnoseReport()
    report.generatedAt = DiagnoseService.nowLabel()
    report.summary =
      `场景「${DiagnoseService.labelOf(answers, 'scene')}」、` +
      `卡点「${DiagnoseService.labelOf(answers, 'stuck')}」、` +
      `读者「${DiagnoseService.labelOf(answers, 'reader')}」。` +
      `以下为规则模板结论，供自我对照，不构成专业咨询建议。`
    report.strength = DiagnoseService.strengthText(habit, length, channel)
    report.weakness = DiagnoseService.weaknessText(stuck, worry, habit)
    report.opportunity = DiagnoseService.opportunityText(scene, reader, stuck)
    report.threat = DiagnoseService.threatText(worry, reader)
    report.actions = DiagnoseService.actions(scene, stuck, length)
    report.matchCategory = DiagnoseService.matchCategory(scene)
    report.matchHint =
      `建议优先浏览「${report.matchCategory}」灵感，并在润色页用「${DiagnoseService.styleHint(stuck)}」风格对照改一版。`
    report.scoreLabel = DiagnoseService.scoreLabel(habit, worry, stuck)
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

  private static strengthText(habit: string, length: string, channel: string): string {
    let s = '已有固定写作场景，具备可优化的明确对象。'
    if (habit === 'read' || habit === 'aloud' || habit === 'compare') {
      s = '你有改稿意识，适合用对照润色巩固习惯。'
    }
    if (length === 'short' || length === 'list') {
      s = `${s} 偏好短句或分点，利于信息传达。`
    }
    if (channel === 'email' || channel === 'form') {
      s = `${s} 正式渠道写作，结构比口语更重要。`
    }
    return s
  }

  private static weaknessText(stuck: string, worry: string, habit: string): string {
    let w = '个别环节仍依赖直觉，缺少可重复的检查清单。'
    if (stuck === 'open') {
      w = '开头容易空泛，可先写结论再补背景。'
    } else if (stuck === 'tone') {
      w = '语气在「太硬 / 太软」之间摇摆，需按读者切换风格。'
    } else if (stuck === 'long') {
      w = '长句堆叠，读者需要多次回读。'
    } else if (stuck === 'logic') {
      w = '信息顺序与读者关心点不一致。'
    }
    if (worry === 'rude' || worry === 'cold') {
      w = `${w} 发前可多用「亲切」风格对照。`
    }
    if (habit === 'once') {
      w = `${w} 建议至少通读一遍再发送。`
    }
    return w
  }

  private static opportunityText(scene: string, reader: string, stuck: string): string {
    let o = '用灵感范例 + 润色对照，可快速获得第二版说法。'
    if (scene === 'work') {
      o = '职场沟通类范例可直接套用「结论-主人-时限」骨架。'
    } else if (scene === 'study') {
      o = '学术写作范例帮助把论证写成「主张-理由-限制」。'
    } else if (scene === 'copy') {
      o = '创意文案范例强调场景画面，可替换空泛形容词。'
    }
    if (reader === 'boss') {
      o = `${o} 对上汇报优先「正式 + 简洁」。`
    }
    if (stuck === 'logic') {
      o = `${o} 摘要页可帮你先抽出主线再重写。`
    }
    return o
  }

  private static threatText(worry: string, reader: string): string {
    let t = '未对照修改时，误解成本由读者承担，也影响你的专业感。'
    if (worry === 'vague') {
      t = '意思含糊时，对方可能反复确认，拖慢协作。'
    } else if (worry === 'wordy') {
      t = '冗长文本在移动端易被略读，关键信息被淹没。'
    }
    if (reader === 'boss' || reader === 'public') {
      t = `${t} 对外表达更需一次说清。`
    }
    return t
  }

  private static actions(scene: string, stuck: string, length: string): string[] {
    const list: string[] = []
    list.push('本周选一段真实草稿，在润色页跑四种风格各一次，保留最顺的一版。')
    if (stuck === 'open') {
      list.push('开头先写「本次要对方知道/决定的一件事」，再补背景。')
    } else if (stuck === 'long') {
      list.push('把超过 40 字的句子拆成两句，用分号或换行连接。')
    } else {
      list.push('发前用摘要页生成精简版，对照是否漏掉关键动作。')
    }
    if (scene === 'work') {
      list.push('收藏 2 条职场沟通灵感，下次写邮件前先打开对照。')
    } else if (scene === 'study') {
      list.push('学术类段落按「主张-理由-限制」自检一遍。')
    } else {
      list.push('在灵感页按场景分类浏览，复制一条范例改写成你的版本。')
    }
    if (length === 'long') {
      list.push('优先尝试「简洁」风格润色，再决定是否补「详尽」背景。')
    }
    return list
  }

  private static matchCategory(scene: string): string {
    if (scene === 'work') {
      return '职场沟通'
    }
    if (scene === 'study') {
      return '学术写作'
    }
    if (scene === 'copy') {
      return '创意文案'
    }
    return '日常表达'
  }

  private static styleHint(stuck: string): string {
    if (stuck === 'tone') {
      return '亲切'
    }
    if (stuck === 'long' || stuck === 'logic') {
      return '简洁'
    }
    if (stuck === 'open') {
      return '详尽'
    }
    return '正式'
  }

  private static scoreLabel(habit: string, worry: string, stuck: string): string {
    let score = 72
    if (habit === 'compare' || habit === 'aloud') {
      score += 10
    } else if (habit === 'once') {
      score -= 8
    }
    if (worry === 'vague' || worry === 'wordy') {
      score -= 6
    }
    if (stuck === 'logic' || stuck === 'long') {
      score -= 4
    }
    if (score >= 80) {
      return '表达习惯较稳'
    }
    if (score >= 65) {
      return '有清晰改进点'
    }
    return '建议先练对照润色'
  }
}
