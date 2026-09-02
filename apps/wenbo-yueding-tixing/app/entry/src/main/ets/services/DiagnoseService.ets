import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'

/** 约定节奏诊断：问卷 + 规则模板，不含生成式模型 */
export class DiagnoseService {
  static questions(): DiagnoseQuestion[] {
    return [
      DiagnoseQuestion.of('load', '最近一周，每天大概有几件约定？', [
        DiagnoseOption.of('few', '1–2 件，比较从容'),
        DiagnoseOption.of('mid', '3–5 件，刚刚好'),
        DiagnoseOption.of('many', '6 件以上，经常赶场')
      ]),
      DiagnoseQuestion.of('late', '迟到或错过提醒的频率？', [
        DiagnoseOption.of('rare', '很少发生'),
        DiagnoseOption.of('sometimes', '偶尔会忘'),
        DiagnoseOption.of('often', '经常来不及')
      ]),
      DiagnoseQuestion.of('scene', '目前占用时间最多的是？', [
        DiagnoseOption.of('work', '工作会议与对接'),
        DiagnoseOption.of('life', '生活琐事与家人'),
        DiagnoseOption.of('study', '学习与考试'),
        DiagnoseOption.of('health', '运动与健康')
      ]),
      DiagnoseQuestion.of('buffer', '两件约定之间，你通常预留多久？', [
        DiagnoseOption.of('none', '几乎无缝衔接'),
        DiagnoseOption.of('short', '10–20 分钟'),
        DiagnoseOption.of('enough', '半小时以上')
      ]),
      DiagnoseQuestion.of('remind', '你更习惯哪种提醒节奏？', [
        DiagnoseOption.of('tight', '临近 10 分钟再提醒'),
        DiagnoseOption.of('hour', '提前 1 小时准备'),
        DiagnoseOption.of('day', '提前 1 天安排')
      ]),
      DiagnoseQuestion.of('repeat', '需要重复守约的事项多吗？', [
        DiagnoseOption.of('habit', '有学习/运动等习惯'),
        DiagnoseOption.of('week', '主要是周会一类'),
        DiagnoseOption.of('once', '多数是一次性')
      ]),
      DiagnoseQuestion.of('prep', '出发前会核对准备事项吗？', [
        DiagnoseOption.of('yes', '会列清单'),
        DiagnoseOption.of('head', '只在脑子里过一遍'),
        DiagnoseOption.of('no', '经常出门才发现漏带')
      ]),
      DiagnoseQuestion.of('goal', '接下来最想改善哪一点？', [
        DiagnoseOption.of('miss', '少遗漏、少冲突'),
        DiagnoseOption.of('focus', '给深度事务留整段时间'),
        DiagnoseOption.of('balance', '工作与生活更均衡')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const load = DiagnoseService.optionId(answers, 'load')
    const late = DiagnoseService.optionId(answers, 'late')
    const scene = DiagnoseService.optionId(answers, 'scene')
    const buffer = DiagnoseService.optionId(answers, 'buffer')
    const remind = DiagnoseService.optionId(answers, 'remind')
    const repeat = DiagnoseService.optionId(answers, 'repeat')
    const prep = DiagnoseService.optionId(answers, 'prep')
    const goal = DiagnoseService.optionId(answers, 'goal')

    const report = new DiagnoseReport()
    report.title = '本周约定节奏报告'
    report.generatedAt = DiagnoseService.nowLabel()
    report.summary =
      `根据问卷：负荷「${DiagnoseService.labelOf(answers, 'load')}」、` +
      `易遗漏程度「${DiagnoseService.labelOf(answers, 'late')}」、` +
      `主场景「${DiagnoseService.labelOf(answers, 'scene')}」。以下为规则整理，供自己调整日程。`

    if (load === 'many' || late === 'often') {
      report.scoreLabel = '节奏偏紧'
    } else if (load === 'mid' && late === 'sometimes') {
      report.scoreLabel = '基本可控'
    } else {
      report.scoreLabel = '较为从容'
    }

    report.strength = late === 'rare'
      ? '你已经较少错过约定，适合用日历和桌面卡片做总览，而不是反复加提醒。'
      : '你愿意把约定写下来，这是守约的第一步。接下来用冲突检测和会前准备把遗漏压下去。'
    report.weakness = buffer === 'none'
      ? '约定之间几乎没有缓冲，一旦一件超时，后面会连环延误。'
      : (prep === 'no' ? '出发前缺少核对，材料或地点容易临时出岔子。' : '提醒时机与实际准备时长可能还没对齐。')
    report.opportunity = goal === 'focus'
      ? '首页空档提示可以直接变成「深度事务」约定，把碎片时间收成整块。'
      : '用智能分类把工作/生活/学习拆开，周复盘能看出哪一类在挤占时间。'
    report.threat = load === 'many'
      ? '高峰日容易重叠。保存约定时请留意冲突提示，必要时改期 15 分钟或 1 小时。'
      : '重复事项若只靠记忆，周末一放松就断档。学习/运动请打开每周重复。'

    const actions: string[] = []
    if (late !== 'rare') {
      actions.push(remind === 'tight' ? '把关键约定改成提前 1 小时，留出路上时间。' : '为易忘事项打开提前 1 天提醒。')
    }
    if (buffer === 'none') {
      actions.push('相邻约定至少留 15 分钟空档，可直接用详情里的改期。')
    }
    if (prep !== 'yes') {
      actions.push('创建后勾选会前准备（材料、地点、提前出发），完成一件勾一件。')
    }
    if (repeat === 'habit') {
      actions.push('学习或运动改成每天/每周重复，避免每次重新填写。')
    }
    if (scene === 'work' && goal === 'balance') {
      actions.push('本周至少加 1 件健康或生活约定，避免工作完全占满。')
    }
    if (goal === 'miss') {
      actions.push('打开桌面卡片看今日下一件，出门前先看准备进度。')
    }
    if (actions.length === 0) {
      actions.push('保持现有节奏，用周复盘导出本周安排做一次回顾。')
    }
    report.actions = actions

    if (goal === 'focus') {
      report.matchCategory = '深度事务'
      report.ctaLabel = '按建议创建「深度事务」约定'
      report.matchHint = '将使用 90 分钟时长、提前 1 小时提醒，并带上准备清单。'
    } else if (repeat === 'habit' || scene === 'health') {
      report.matchCategory = '健身计划'
      report.ctaLabel = '按建议创建重复运动约定'
      report.matchHint = '默认每周重复，会前准备含装备与热身。'
    } else if (scene === 'study') {
      report.matchCategory = '学习计划'
      report.ctaLabel = '按建议创建学习约定'
      report.matchHint = '默认每天重复，提醒提前 10 分钟进入状态。'
    } else {
      report.matchCategory = '会议提醒'
      report.ctaLabel = '按建议创建工作约定'
      report.matchHint = '带冲突检测与会前材料清单，适合对接和例会。'
    }
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
    const m = d.getMonth() + 1
    const day = d.getDate()
    const hh = d.getHours()
    const mm = d.getMinutes()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    const hs = hh < 10 ? `0${hh}` : `${hh}`
    const mis = mm < 10 ? `0${mm}` : `${mm}`
    return `${d.getFullYear()}-${ms}-${ds} ${hs}:${mis}`
  }
}
