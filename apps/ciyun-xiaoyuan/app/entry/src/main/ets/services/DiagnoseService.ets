import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'

/**
 * 格律入门问卷 → 规则模板报告（不调用大模型，文案不用 AI 字样）。
 */
export class DiagnoseService {
  static questions(): DiagnoseQuestion[] {
    return [
      DiagnoseQuestion.of('goal', '来小院最想先做哪一件？', [
        DiagnoseOption.of('read', '把名篇读明白'),
        DiagnoseOption.of('meter', '核对平仄韵脚'),
        DiagnoseOption.of('cipai', '学填词牌'),
        DiagnoseOption.of('write', '保存自己的习作')
      ]),
      DiagnoseQuestion.of('form', '更常接触哪一体裁？', [
        DiagnoseOption.of('shi', '近体诗 / 古体诗'),
        DiagnoseOption.of('ci', '词'),
        DiagnoseOption.of('both', '诗与词都读'),
        DiagnoseOption.of('unsure', '还分不太清')
      ]),
      DiagnoseQuestion.of('pingze', '对平仄的熟悉程度？', [
        DiagnoseOption.of('new', '几乎没接触过'),
        DiagnoseOption.of('mid', '知道平声仄声，对不上句'),
        DiagnoseOption.of('ok', '能大致标出一句')
      ]),
      DiagnoseQuestion.of('rhyme', '查韵时更想用哪本韵书？', [
        DiagnoseOption.of('pingshui', '平水韵（近体诗）'),
        DiagnoseOption.of('cilin', '词林正韵（填词）'),
        DiagnoseOption.of('xin', '中华新韵（普通话）'),
        DiagnoseOption.of('unsure', '还没想好')
      ]),
      DiagnoseQuestion.of('freq', '每周打算花多少时间？', [
        DiagnoseOption.of('s', '十几分钟翻一首'),
        DiagnoseOption.of('m', '半小时对照格律'),
        DiagnoseOption.of('l', '一小时以上习作')
      ]),
      DiagnoseQuestion.of('block', '眼下最大的卡点？', [
        DiagnoseOption.of('dict', '生僻字与典故'),
        DiagnoseOption.of('tone', '分不清平仄'),
        DiagnoseOption.of('rhyme', '不知道该押哪一部'),
        DiagnoseOption.of('blank', '对着空白写不出')
      ]),
      DiagnoseQuestion.of('path', '更喜欢哪种学法？', [
        DiagnoseOption.of('daily', '每日一诗慢慢品'),
        DiagnoseOption.of('detect', '先检测再对照谱'),
        DiagnoseOption.of('article', '先读赏析入门')
      ]),
      DiagnoseQuestion.of('next', '做完问卷后想去哪？', [
        DiagnoseOption.of('library', '回诗库读今日一诗'),
        DiagnoseOption.of('workshop', '去格律工坊试一首'),
        DiagnoseOption.of('notes', '去赏析页看笺注译法')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const goal = DiagnoseService.optionId(answers, 'goal')
    const form = DiagnoseService.optionId(answers, 'form')
    const pingze = DiagnoseService.optionId(answers, 'pingze')
    const rhyme = DiagnoseService.optionId(answers, 'rhyme')
    const freq = DiagnoseService.optionId(answers, 'freq')
    const block = DiagnoseService.optionId(answers, 'block')
    const path = DiagnoseService.optionId(answers, 'path')
    const next = DiagnoseService.optionId(answers, 'next')

    const report = new DiagnoseReport()
    report.title = '格律入门报告'
    report.generatedAt = DiagnoseService.nowLabel()
    report.summary =
      `基于问卷：目标「${DiagnoseService.labelOf(answers, 'goal')}」、` +
      `体裁「${DiagnoseService.labelOf(answers, 'form')}」、` +
      `卡点「${DiagnoseService.labelOf(answers, 'block')}」。` +
      `以下为规则模板建议，供自学参考，不构成考试提分承诺。`
    report.strength = DiagnoseService.strengthText(pingze, freq, form)
    report.weakness = DiagnoseService.weaknessText(block, pingze)
    report.opportunity = DiagnoseService.opportunityText(path, rhyme, next)
    report.threat = DiagnoseService.threatText(block, pingze)
    report.actions = DiagnoseService.actions(goal, block, next)
    report.matchCategory = DiagnoseService.matchCategory(goal)
    report.matchHint =
      `建议先打开「${report.matchCategory}」，把今日一诗或一段习作走一遍检测。`
    report.scoreLabel = DiagnoseService.scoreLabel(pingze, freq, block)
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

  private static strengthText(pingze: string, freq: string, form: string): string {
    let s = '愿意打开小院，已经迈出读诗与习作的第一步。'
    if (pingze === 'ok') {
      s = '已能大致标平仄，适合用图谱核对韵脚。'
    }
    if (freq === 'l' || freq === 'm') {
      s = `${s} 每周有固定时间，适合养成「读一首、检一次」的节奏。`
    }
    if (form === 'ci') {
      s = `${s} 填词路径清晰，可从词牌谱对照开始。`
    }
    return s
  }

  private static weaknessText(block: string, pingze: string): string {
    let w = '格律规则需要对照原文反复看，不必一次记全。'
    if (block === 'tone' || pingze === 'new') {
      w = '平仄还不熟。建议先看一句的平/仄色标，再查韵典。'
    } else if (block === 'rhyme') {
      w = '韵部容易混。近体诗用平水韵，填词用词林正韵，今韵习作用中华新韵。'
    } else if (block === 'dict') {
      w = '典故与生僻字可在详情页看笺注、译文，不必离开正文。'
    } else if (block === 'blank') {
      w = '空白难以下笔。可先随机拾贝一首，改一字再做检测。'
    }
    return w
  }

  private static opportunityText(path: string, rhyme: string, next: string): string {
    let o = '诗库、格律、赏析三页可以串成一条学习闭环。'
    if (path === 'daily') {
      o = '每日一诗适合慢读：封面进详情，读完再去做检测。'
    } else if (path === 'detect') {
      o = '先检测再对照词牌，能立刻看到平仄图谱。'
    } else if (path === 'article') {
      o = '赏析入门短文可先建立读法，再回到名篇。'
    }
    if (rhyme === 'pingshui') {
      o = `${o} 默认韵书可设为平水韵。`
    } else if (rhyme === 'cilin') {
      o = `${o} 默认韵书可设为词林正韵。`
    } else if (rhyme === 'xin') {
      o = `${o} 默认韵书可设为中华新韵。`
    }
    if (next === 'workshop') {
      o = `${o} 下一步直接去格律工坊粘贴一首即可。`
    }
    return o
  }

  private static threatText(block: string, pingze: string): string {
    if (block === 'tone' || pingze === 'new') {
      return '若只浏览不检测，平仄会一直停留在「听说过」。每天标一句即可。'
    }
    if (block === 'blank') {
      return '空着不写会越拖越难。保存一条短习作，比追求完篇更重要。'
    }
    return '不要把规则提示当成标准答案；存疑时对照韵典原文。'
  }

  private static actions(goal: string, block: string, next: string): string[] {
    const list: string[] = []
    list.push('打开诗库读今日一诗，点封面进入笺注与译文。')
    if (goal === 'meter' || block === 'tone') {
      list.push('把原诗粘到格律工坊，看平仄色标与韵脚。')
    } else if (goal === 'cipai') {
      list.push('在格律页点开一个词牌，对照谱式再试填两句。')
    } else if (goal === 'write') {
      list.push('检测后点「保存为个人作品」，新账号作品列表从空开始。')
    } else {
      list.push('用检索或分类芯片找同主题的另一首，形成对照。')
    }
    if (block === 'rhyme') {
      list.push('在「我的」里设定默认韵书，再打开对应韵部。')
    }
    if (next === 'notes') {
      list.push('到赏析页读一篇入门短文，再回详情看评点。')
    } else {
      list.push('收藏一首真正想反复读的诗，不要一次囤太多。')
    }
    return list
  }

  private static matchCategory(goal: string): string {
    if (goal === 'meter' || goal === 'cipai' || goal === 'write') {
      return '格律工坊'
    }
    if (goal === 'read') {
      return '诗库'
    }
    return '赏析'
  }

  private static scoreLabel(pingze: string, freq: string, block: string): string {
    let score = 68
    if (pingze === 'ok') {
      score += 10
    } else if (pingze === 'new') {
      score -= 8
    }
    if (freq === 'l') {
      score += 6
    } else if (freq === 's') {
      score -= 4
    }
    if (block === 'tone' || block === 'blank') {
      score -= 6
    }
    if (score >= 80) {
      return '已有对照习惯'
    }
    if (score >= 65) {
      return '适合从一首诗练起'
    }
    return '先读再检，不必赶进度'
  }
}
