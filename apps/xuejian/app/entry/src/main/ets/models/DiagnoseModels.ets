/** 学习节律问卷（规则模板，不调用大模型） */

export class DiagnoseOption {
  id: string = ''
  label: string = ''

  static of(id: string, label: string): DiagnoseOption {
    const o = new DiagnoseOption()
    o.id = id
    o.label = label
    return o
  }
}

export class DiagnoseQuestion {
  id: string = ''
  title: string = ''
  options: DiagnoseOption[] = []

  static of(id: string, title: string, options: DiagnoseOption[]): DiagnoseQuestion {
    const q = new DiagnoseQuestion()
    q.id = id
    q.title = title
    q.options = options
    return q
  }
}

export class DiagnoseAnswer {
  questionId: string = ''
  optionId: string = ''
  optionLabel: string = ''

  static of(questionId: string, optionId: string, optionLabel: string): DiagnoseAnswer {
    const a = new DiagnoseAnswer()
    a.questionId = questionId
    a.optionId = optionId
    a.optionLabel = optionLabel
    return a
  }
}

export class DiagnoseReport {
  title: string = '学习节律报告'
  summary: string = ''
  strength: string = ''
  weakness: string = ''
  opportunity: string = ''
  threat: string = ''
  actions: string[] = []
  matchCategory: string = '专注计时'
  matchActionId: string = 'focus'
  matchHint: string = ''
  scoreLabel: string = '待完善'
  generatedAt: string = ''
}
