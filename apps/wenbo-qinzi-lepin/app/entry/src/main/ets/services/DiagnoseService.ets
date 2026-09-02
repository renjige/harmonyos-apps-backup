import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'

/**
 * 陪伴建议：问卷 + 规则模板（不调用大模型，文案不出现「AI」）。
 */
export class DiagnoseService {
  static questions(): DiagnoseQuestion[] {
    return [
      DiagnoseQuestion.of('who', '今天谁来拼？', [
        DiagnoseOption.of('child', '孩子自己慢慢拼'),
        DiagnoseOption.of('together', '家长和孩子一起'),
        DiagnoseOption.of('parent_guide', '家长在旁边看着')
      ]),
      DiagnoseQuestion.of('age', '孩子现在大概几岁？', [
        DiagnoseOption.of('young', '3–4 岁'),
        DiagnoseOption.of('mid', '5–6 岁'),
        DiagnoseOption.of('old', '7–8 岁')
      ]),
      DiagnoseQuestion.of('theme', '更想看哪一类画面？', [
        DiagnoseOption.of('animal', '小动物'),
        DiagnoseOption.of('nature', '花草与户外'),
        DiagnoseOption.of('life', '家里的日常'),
        DiagnoseOption.of('fairy', '故事小屋')
      ]),
      DiagnoseQuestion.of('pace', '今天想轻松一点，还是想挑战？', [
        DiagnoseOption.of('easy', '轻松，块少一点'),
        DiagnoseOption.of('steady', '不急，九块正好'),
        DiagnoseOption.of('hard', '想试十六块')
      ]),
      DiagnoseQuestion.of('hint', '要不要用智慧提示？', [
        DiagnoseOption.of('yes', '需要时点一下小灯泡'),
        DiagnoseOption.of('no', '先自己找轮廓'),
        DiagnoseOption.of('later', '卡住再决定')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const who = DiagnoseService.optionId(answers, 'who')
    const age = DiagnoseService.optionId(answers, 'age')
    const theme = DiagnoseService.optionId(answers, 'theme')
    const pace = DiagnoseService.optionId(answers, 'pace')
    const hint = DiagnoseService.optionId(answers, 'hint')

    const report = new DiagnoseReport()
    report.title = '今天的陪伴建议'
    report.generatedAt = DiagnoseService.nowLabel()
    report.summary =
      `按刚才的选择：${DiagnoseService.labelOf(answers, 'who')}，` +
      `大约 ${DiagnoseService.labelOf(answers, 'age')}，` +
      `想看「${DiagnoseService.labelOf(answers, 'theme')}」。` +
      `下面是规则拼出来的建议，不是测评，也不排名。`
    report.strength = DiagnoseService.themeText(theme)
    report.weakness = DiagnoseService.pieceText(age, pace)
    report.opportunity = DiagnoseService.whoText(who)
    report.threat = DiagnoseService.hintText(hint)
    report.actions = DiagnoseService.actions(theme, who, pace)
    report.matchCategory = DiagnoseService.themeLabel(theme)
    report.matchHint = who === 'together'
      ? '可以打开亲子页，选一幅图轮流点一块。'
      : '去乐园点对应主题大卡片，选一幅封面开始。'
    report.scoreLabel = pace === 'easy' ? '轻松节奏' : (pace === 'hard' ? '挑战节奏' : '稳稳节奏')
    return report
  }

  static themeKeyOf(category: string): string {
    if (category === '自然') {
      return 'nature'
    }
    if (category === '生活') {
      return 'life'
    }
    if (category === '童话') {
      return 'fairy'
    }
    return 'animal'
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
    return '未选'
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

  private static themeText(theme: string): string {
    if (theme === 'nature') {
      return '自然主题：花叶、小路、水面轮廓清楚，适合练习「找边缘」。'
    }
    if (theme === 'life') {
      return '生活主题：杯子、桌面、窗边都是孩子熟悉的东西，容易开口讲。'
    }
    if (theme === 'fairy') {
      return '童话主题：小屋、灯火、小路，适合睡前慢慢拼完一幅。'
    }
    return '动物主题：耳朵、鼻子、毛色块面明显，低龄也容易对上。'
  }

  private static pieceText(age: string, pace: string): string {
    if (pace === 'hard' && age !== 'old') {
      return '建议先用 9 块热热手，再试 16 块。块太多时，一起看参考图角落就好。'
    }
    if (age === 'young' || pace === 'easy') {
      return '建议从 4 块开始。块大、对得快，孩子更容易感到「我拼完了」。'
    }
    if (age === 'old' && pace === 'hard') {
      return '可以试 16 块。卡住时用一次智慧提示，不要替孩子拖到位。'
    }
    return '建议用 9 块。时间够就拼完，不够就先对上四角。'
  }

  private static whoText(who: string): string {
    if (who === 'together') {
      return '打开亲子轮流：橙色回合给孩子，蓝色回合给家长。一部手机就够。'
    }
    if (who === 'parent_guide') {
      return '家长坐在旁边指轮廓，不要直接拖。孩子点对了再说「咔嗒，对上了」。'
    }
    return '把手机交给孩子，智慧提示先藏着。拼完再一起看完整画面。'
  }

  private static hintText(hint: string): string {
    if (hint === 'no') {
      return '先自己找轮廓。连续放错两次，再点智慧提示高亮格子。'
    }
    if (hint === 'later') {
      return '卡住超过半分钟再点小灯泡。提示只亮位置，不会替你放进去。'
    }
    return '需要时点「智慧提示」。它会高亮下一块的家，不是评分工具。'
  }

  private static actions(theme: string, who: string, pace: string): string[] {
    const list: string[] = []
    list.push(`打开乐园，点「${DiagnoseService.themeLabel(theme)}」主题卡。`)
    if (who === 'together') {
      list.push('在详情页打开「亲子轮流」，再开始拼。')
    } else {
      list.push('选好块数后开始拼，拼完会记在本机成长页。')
    }
    if (pace === 'easy') {
      list.push('今天以完成一幅为主，不必追求三颗星。')
    } else {
      list.push('拼完可以到成长页看看星星和能力小条。')
    }
    return list
  }

  private static themeLabel(theme: string): string {
    if (theme === 'nature') {
      return '自然'
    }
    if (theme === 'life') {
      return '生活'
    }
    if (theme === 'fairy') {
      return '童话'
    }
    return '动物'
  }
}
