import {
  DiagnoseAnswer,
  DiagnoseOption,
  DiagnoseQuestion,
  DiagnoseReport
} from '../models/DiagnoseModels'

/** 个人效率自诊 — 问卷 + 规则模板报告（非大模型） */
export class DiagnoseService {
  static questions(): DiagnoseQuestion[] {
    return [
      DiagnoseQuestion.of('overload', '今日待办数量感受？', [
        DiagnoseOption.of('light', '3 项以内，可控'),
        DiagnoseOption.of('medium', '4–8 项，略忙'),
        DiagnoseOption.of('heavy', '9 项以上，容易拖延')
      ]),
      DiagnoseQuestion.of('priority', '处理事项时更常？', [
        DiagnoseOption.of('urgent', '先做紧急的'),
        DiagnoseOption.of('easy', '先做简单的'),
        DiagnoseOption.of('plan', '按日程计划执行')
      ]),
      DiagnoseQuestion.of('habit', '习惯打卡坚持情况？', [
        DiagnoseOption.of('daily', '几乎每天打卡'),
        DiagnoseOption.of('sometimes', '偶尔忘记'),
        DiagnoseOption.of('none', '尚未建立习惯')
      ]),
      DiagnoseQuestion.of('organize', '事项整理频率？', [
        DiagnoseOption.of('daily', '每天整理标签/清单'),
        DiagnoseOption.of('weekly', '每周集中整理'),
        DiagnoseOption.of('rare', '很少整理，靠搜索')
      ]),
      DiagnoseQuestion.of('focus', '最容易被打断的时段？', [
        DiagnoseOption.of('morning', '上午'),
        DiagnoseOption.of('afternoon', '下午'),
        DiagnoseOption.of('evening', '晚上')
      ])
    ]
  }

  static buildReport(answers: DiagnoseAnswer[]): DiagnoseReport {
    const overload = DiagnoseService.optionId(answers, 'overload')
    const priority = DiagnoseService.optionId(answers, 'priority')
    const habit = DiagnoseService.optionId(answers, 'habit')
    const organize = DiagnoseService.optionId(answers, 'organize')
    const focus = DiagnoseService.optionId(answers, 'focus')

    const report = new DiagnoseReport()
    report.title = '个人效率自诊报告'
    report.generatedAt = DiagnoseService.nowLabel()
    report.summary =
      `基于你的自诊：待办负荷「${DiagnoseService.labelOf(answers, 'overload')}」、` +
      `习惯「${DiagnoseService.labelOf(answers, 'habit')}」、` +
      `整理「${DiagnoseService.labelOf(answers, 'organize')}」。` +
      '以下为可执行的效率建议（规则模板生成，非 AI 对话）。'
    report.strength = DiagnoseService.strengthText(habit, organize, priority)
    report.weakness = DiagnoseService.weaknessText(overload, habit, organize)
    report.opportunity = DiagnoseService.opportunityText(focus, priority, habit)
    report.threat = DiagnoseService.threatText(overload, priority)
    report.actions = DiagnoseService.actions(overload, habit, organize, focus)
    report.matchCategory = '个人效率闭环'
    report.matchHint = '结合事项清单、习惯打卡与智慧整理，按行动清单在 App 内逐步执行。'
    report.scoreLabel = DiagnoseService.scoreLabel(overload, habit, organize)
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
    return '未答'
  }

  private static nowLabel(): string {
    const d = new Date()
    return `${d.getFullYear()}-${d.getMonth() + 1}-${d.getDate()}`
  }

  private static strengthText(habit: string, organize: string, priority: string): string {
    const parts: string[] = []
    if (habit === 'daily') {
      parts.push('习惯打卡稳定，连续天数可形成正反馈')
    }
    if (organize === 'daily') {
      parts.push('事项标签整理及时，清单检索效率高')
    }
    if (priority === 'plan') {
      parts.push('按日程执行，时间块意识较好')
    }
    if (parts.length === 0) {
      return '你已在使用事项笺锁定今日承诺，具备建立限量执行闭环的基础。'
    }
    return parts.join('；')
  }

  private static weaknessText(overload: string, habit: string, organize: string): string {
    const parts: string[] = []
    if (overload === 'heavy') {
      parts.push('待办过多易导致选择性拖延')
    }
    if (habit === 'none' || habit === 'sometimes') {
      parts.push('习惯坚持不足，长期目标难沉淀')
    }
    if (organize === 'rare') {
      parts.push('缺少定期整理，历史事项难以复用')
    }
    if (parts.length === 0) {
      return '当前主要瓶颈在专注时段保护，可进一步减少打断。'
    }
    return parts.join('；')
  }

  private static opportunityText(focus: string, priority: string, habit: string): string {
    let slot = '上午'
    if (focus === 'afternoon') {
      slot = '下午'
    } else if (focus === 'evening') {
      slot = '晚上'
    }
    let tip = `在${slot}安排 1 项高优先级事项，减少切换成本。`
    if (priority === 'easy') {
      tip += ' 建议先把最小事项放进候补池，承诺席只留给必须兑现的 3 件。'
    }
    if (habit === 'none') {
      tip += ' 可从 7 天微习惯开始，在「习惯」Tab 设定目标天数。'
    }
    return tip
  }

  private static threatText(overload: string, priority: string): string {
    if (overload === 'heavy' && priority === 'easy') {
      return '长期「先做简单」可能积压高优事项，影响截止日期事项。'
    }
    if (overload === 'heavy') {
      return '待办堆积可能导致完成率下降与焦虑感上升。'
    }
    return '若缺少每周回顾，已完成事项的经验难以转化为下一周计划。'
  }

  private static actions(overload: string, habit: string, organize: string, focus: string): string[] {
    const out: string[] = []
    if (overload !== 'light') {
      out.push('首页只锁定 3 件今日承诺，超额一律进候补池')
    }
    if (habit !== 'daily') {
      out.push('在「习惯」创建 1 个微习惯并设定 7–21 天目标')
    }
    if (organize !== 'daily') {
      out.push('使用「智慧整理」按标签筛选，每周归档已完成事项')
    }
    if (focus === 'morning') {
      out.push('上午开启「日程」Tab，按日历顺序逐项处理')
    } else if (focus === 'afternoon') {
      out.push('午后进入对应工位开始专注，计时结束后再收工')
    } else {
      out.push('晚间在「完成记录」回顾今日产出，规划明日 3 项')
    }
    out.push('阅读首页「效率贴士」，应用 1 条可执行方法')
    return out
  }

  private static scoreLabel(overload: string, habit: string, organize: string): string {
    let score = 72
    if (overload === 'light') {
      score += 8
    } else if (overload === 'heavy') {
      score -= 10
    }
    if (habit === 'daily') {
      score += 10
    } else if (habit === 'none') {
      score -= 8
    }
    if (organize === 'daily') {
      score += 6
    } else if (organize === 'rare') {
      score -= 6
    }
    if (score >= 85) {
      return '效率指数 · 优秀'
    }
    if (score >= 70) {
      return '效率指数 · 良好'
    }
    return '效率指数 · 待提升'
  }
}
