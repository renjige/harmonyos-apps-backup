export class ConvertStep {
  index: number = 0
  label: string = ''
  done: boolean = false
}

/** 灵感 → 创意计划：结构化转化步骤（规则模板，非大模型） */
export class InspirationConvertService {
  static readonly STEP_PIN: string = '钉入画板对照构图与文案'
  static readonly STEP_SPLIT: string = '写成可执行的下一步'
  static readonly STEP_WEEK: string = '本周推进到可演示'

  static buildPlanGoal(title: string, body: string, inspirationId: string): string {
    const src = inspirationId.length > 0 ? `[[srcinsp:${inspirationId}]]\n` : ''
    return `${src}【来自灵感】${title}\n【转化步骤】\n□ ${InspirationConvertService.STEP_PIN}\n□ ${InspirationConvertService.STEP_SPLIT}\n□ ${InspirationConvertService.STEP_WEEK}\n---\n${body}`
  }

  static bodyOf(goal: string): string {
    const idx = goal.indexOf('\n---\n')
    if (idx >= 0) {
      return InspirationConvertService.stripInternal(goal.substring(idx + 5))
    }
    return InspirationConvertService.stripInternal(goal)
  }

  /** 列表卡片副标题：隐藏 srcinsp 等内部标记，展示灵感摘要或步骤进度 */
  static listSubtitle(goal: string, summary: string): string {
    const g = goal.trim()
    if (g.length === 0) {
      const s = summary.trim()
      if (s.length > 0) {
        return InspirationConvertService.clipText(InspirationConvertService.stripInternal(s), 56)
      }
      return '暂无目标描述'
    }
    if (g.indexOf('[[srcinsp:') >= 0 || g.indexOf('【来自灵感】') >= 0 || g.indexOf('【转化步骤】') >= 0) {
      const body = InspirationConvertService.bodyOf(g).trim()
      if (body.length > 0) {
        return InspirationConvertService.clipText(body, 56)
      }
      const steps = InspirationConvertService.stepsOf(g)
      let done = 0
      for (const s of steps) {
        if (s.done) {
          done += 1
        }
      }
      const fromTitle = InspirationConvertService.fromInspirationTitle(g)
      if (fromTitle.length > 0) {
        return `来自灵感 · 步骤 ${done}/3`
      }
      return `转化步骤 ${done}/3 已完成`
    }
    return InspirationConvertService.clipText(InspirationConvertService.stripInternal(g), 56)
  }

  private static fromInspirationTitle(goal: string): string {
    const marker = '【来自灵感】'
    const idx = goal.indexOf(marker)
    if (idx < 0) {
      return ''
    }
    const rest = goal.substring(idx + marker.length)
    const nl = rest.indexOf('\n')
    return (nl >= 0 ? rest.substring(0, nl) : rest).trim()
  }

  private static stripInternal(text: string): string {
    let out = text
    const srcIdx = out.indexOf('[[srcinsp:')
    if (srcIdx >= 0) {
      const endIdx = out.indexOf(']]', srcIdx)
      if (endIdx >= 0) {
        out = out.substring(0, srcIdx) + out.substring(endIdx + 2)
      }
    }
    out = out.replace('【转化步骤】', '')
    return out.replace(/^\s+|\s+$/g, '')
  }

  private static clipText(text: string, max: number): string {
    if (text.length <= max) {
      return text
    }
    return `${text.substring(0, max)}…`
  }

  static stepProgressText(goal: string): string {
    if (goal.indexOf('【转化步骤】') < 0 && goal.indexOf('[[srcinsp:') < 0) {
      return ''
    }
    const steps = InspirationConvertService.stepsOf(goal)
    let done = 0
    for (const s of steps) {
      if (s.done) {
        done += 1
      }
    }
    return `转化步骤 ${done}/3`
  }

  static stepsOf(goal: string): ConvertStep[] {
    const labels: string[] = [
      InspirationConvertService.STEP_PIN,
      InspirationConvertService.STEP_SPLIT,
      InspirationConvertService.STEP_WEEK
    ]
    const out: ConvertStep[] = []
    for (let i = 0; i < labels.length; i++) {
      const step = new ConvertStep()
      step.index = i
      step.label = labels[i]
      step.done = goal.indexOf(`☑ ${labels[i]}`) >= 0
      out.push(step)
    }
    return out
  }

  private static swapOnce(raw: string, from: string, to: string): string {
    const idx = raw.indexOf(from)
    if (idx < 0) {
      return raw
    }
    return raw.substring(0, idx) + to + raw.substring(idx + from.length)
  }

  static toggleGoal(goal: string, index: number): string {
    const labels: string[] = [
      InspirationConvertService.STEP_PIN,
      InspirationConvertService.STEP_SPLIT,
      InspirationConvertService.STEP_WEEK
    ]
    if (index < 0 || index >= labels.length) {
      return goal
    }
    const label = labels[index]
    const checked = `☑ ${label}`
    const unchecked = `□ ${label}`
    if (goal.indexOf(checked) >= 0) {
      return InspirationConvertService.swapOnce(goal, checked, unchecked)
    }
    if (goal.indexOf(unchecked) >= 0) {
      return InspirationConvertService.swapOnce(goal, unchecked, checked)
    }
    return `${goal}\n${checked}`
  }

  static progressFromGoal(goal: string): number {
    const steps = InspirationConvertService.stepsOf(goal)
    let done = 0
    for (const s of steps) {
      if (s.done) {
        done += 1
      }
    }
    if (done <= 0) {
      return 0
    }
    if (done >= 3) {
      return 100
    }
    return done * 33
  }
}
