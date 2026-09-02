export class HabitOption {
  id: string = ''
  label: string = ''

  static of(id: string, label: string): HabitOption {
    const row = new HabitOption()
    row.id = id
    row.label = label
    return row
  }
}

export class HabitQuestion {
  id: string = ''
  title: string = ''
  options: HabitOption[] = []

  static of(id: string, title: string, options: HabitOption[]): HabitQuestion {
    const row = new HabitQuestion()
    row.id = id
    row.title = title
    row.options = options
    return row
  }
}

export class HabitAnswer {
  questionId: string = ''
  optionId: string = ''
  optionLabel: string = ''

  static of(questionId: string, optionId: string, optionLabel: string): HabitAnswer {
    const row = new HabitAnswer()
    row.questionId = questionId
    row.optionId = optionId
    row.optionLabel = optionLabel
    return row
  }
}

export class HabitReport {
  summary: string = ''
  tips: string[] = []
}

export class ShoppingHabitService {
  static questions(): HabitQuestion[] {
    return [
      HabitQuestion.of('freq', '你通常多久采购一次？', [
        HabitOption.of('daily', '几乎每天'),
        HabitOption.of('few', '2–3 天一次'),
        HabitOption.of('weekly', '每周一次'),
        HabitOption.of('monthly', '按需 / 不固定')
      ]),
      HabitQuestion.of('scene', '最常见的采购场景？', [
        HabitOption.of('supermarket', '超市 / 便利店'),
        HabitOption.of('market', '菜市场 / 生鲜'),
        HabitOption.of('online', '线上补货后到店自提'),
        HabitOption.of('travel', '旅行 / 出差前集中采购')
      ]),
      HabitQuestion.of('pain', '最容易出现的问题？', [
        HabitOption.of('forget', '忘记买什么'),
        HabitOption.of('duplicate', '重复购买'),
        HabitOption.of('category', '清单太乱不好找'),
        HabitOption.of('time', '总是临时想起却来不及买')
      ]),
      HabitQuestion.of('plan', '你更习惯怎样列清单？', [
        HabitOption.of('instant', '想到就记'),
        HabitOption.of('template', '用模板再微调'),
        HabitOption.of('category', '按分类分区'),
        HabitOption.of('share', '和家人分工协作')
      ]),
      HabitQuestion.of('remind', '希望怎样收到提醒？', [
        HabitOption.of('before', '出门前 15 分钟'),
        HabitOption.of('evening', '前一晚整理'),
        HabitOption.of('weekend', '周末集中提醒'),
        HabitOption.of('manual', '我自己看清单即可')
      ])
    ]
  }

  static buildReport(answers: HabitAnswer[]): HabitReport {
    const pain = ShoppingHabitService.pick(answers, 'pain')
    const plan = ShoppingHabitService.pick(answers, 'plan')
    const remind = ShoppingHabitService.pick(answers, 'remind')
    const freq = ShoppingHabitService.pick(answers, 'freq')
    const scene = ShoppingHabitService.pick(answers, 'scene')
    const report = new HabitReport()
    report.summary =
      `采购频率「${ShoppingHabitService.label(answers, 'freq')}」，场景「${ShoppingHabitService.label(answers, 'scene')}」。` +
      `主要困扰是「${ShoppingHabitService.label(answers, 'pain')}」。以下为可立即执行的清单建议。`
    const tips: string[] = []
    if (pain === 'forget') {
      tips.push('把「今日购物清单」设为默认入口，想到物品立刻添加，不要等回家再记')
      tips.push('使用「出门前核对」模式，到店前逐项勾选未买项')
    }
    if (pain === 'duplicate') {
      tips.push('添加前先搜索清单，常买物品可从首页标签一键加入')
      tips.push('完成采购后点「标记已完成」，避免旧清单干扰判断')
    }
    if (pain === 'category') {
      tips.push('添加物品时采用建议分类，详情页会按食品/日用品等分区展示')
      tips.push('同类物品尽量写在同一清单，减少跨清单查找')
    }
    if (pain === 'time') {
      tips.push('在清单详情设置「智慧提醒」，选今天或明天固定时段')
      tips.push('把补充说明写在「备忘」页，与清单分开但可对照查看')
    }
    if (plan === 'template') {
      tips.push('清单页有家庭/旅行/早餐模板，可先创建再删减，比从零写更快')
    }
    if (plan === 'share') {
      tips.push('用「分享」复制清单文本给家人，分工采购时每人负责一类')
    }
    if (remind === 'before') {
      tips.push('建议设置出门采购前 15–30 分钟的系统提醒')
    } else if (remind === 'evening') {
      tips.push('前一晚创建明日清单并设提醒，第二天到店更从容')
    }
    if (freq === 'daily') {
      tips.push('高频采购可固定「今日购物」清单，勾选完成即可，不必每天新建')
    }
    if (scene === 'travel') {
      tips.push('旅行前使用旅行模板，并单独设出发前一晚的提醒')
    }
    if (tips.length === 0) {
      tips.push('保持「记录 → 分类 → 勾选 → 完成」闭环，每周查看采购看板了解习惯')
    }
    report.tips = tips
    return report
  }

  private static pick(answers: HabitAnswer[], questionId: string): string {
    for (const a of answers) {
      if (a.questionId === questionId) {
        return a.optionId
      }
    }
    return ''
  }

  private static label(answers: HabitAnswer[], questionId: string): string {
    for (const a of answers) {
      if (a.questionId === questionId) {
        return a.optionLabel
      }
    }
    return '未选择'
  }
}
