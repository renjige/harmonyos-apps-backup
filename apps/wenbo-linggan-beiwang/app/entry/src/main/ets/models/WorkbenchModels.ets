/** 今日灵感提示 + 本周复盘（规则模板，不调用大模型） */

export class DailyPrompt {
  title: string = ''
  hint: string = ''
  starter: string = ''
  tag: string = ''

  static of(title: string, hint: string, starter: string, tag: string): DailyPrompt {
    const p = new DailyPrompt()
    p.title = title
    p.hint = hint
    p.starter = starter
    p.tag = tag
    return p
  }
}

export class WeeklyReviewReport {
  weekLabel: string = ''
  captureCount: number = 0
  favoriteCount: number = 0
  boardCount: number = 0
  tagLine: string = ''
  summary: string = ''
  captureNote: string = ''
  organizeNote: string = ''
  collectNote: string = ''
  nextAction1: string = ''
  nextAction2: string = ''
  nextAction3: string = ''
  generatedAt: string = ''
}
